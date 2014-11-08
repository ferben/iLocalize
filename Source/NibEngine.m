//
//  NibEngine.m
//  iLocalize3
//
//  Created by Jean on 22.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "NibEngine.h"
#import "StringsEngine.h"
#import "StringsContentModel.h"
#import "StringEncoding.h"

#import "NibStringModel.h"

#import "NibEngine.h"
#import "NibEngineResult.h"

#import "FileTool.h"
#import "Console.h"
#import "Constants.h"

#import "Preferences.h"

@interface NibEngine (PrivateMethods)
- (void)setNibFile:(NSString*)nibfile;
- (void)cleanNibFile:(NSString*)file;
@end

@implementation NibEngine

- (id)initWithConsole:(Console*)console
{
	if(self = [super init]) {
		mNibFile = NULL;
		mTaskData = NULL;
		mTaskErrorData = NULL;
		mConsole = console;
	}
	return self;
}


+ (NibEngine*)engineWithConsole:(Console*)console
{
	return [[NibEngine alloc] initWithConsole:console];		
}

+ (BOOL)ensureTool
{
	// check to see if the path already exists as defined in the preferences
	NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"ibtoolPath"];
	if(![path isPathExisting]) {
		// path doesn't exist. Try default one.
		path = @"/usr/bin/ibtool";
		if(![path isPathExisting]) {
            // try the new Xcode 4.3 location
            path = @"/Applications/Xcode.app/Contents/Developer/usr/bin/ibtool";
            if (![path isPathExisting]) {
                // ibtool is probably not installed
                return NO;                
            }
		}
        // set new value in preferences
        [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"ibtoolPath"];
	}	
	return YES;
}

- (void)setNibFile:(NSString*)nibfile
{
	mNibFile = nibfile;
}

- (void)cleanNibFile:(NSString*)file
{
	// Remove any ~.nib file after a nibtool operation
	NSString *backupFile = [[file stringByDeletingPathExtension] stringByAppendingString:@"~.nib"];
	[backupFile removePathFromDisk];
}

- (NSString*)nibtoolPath
{
	NSString *path = [[NSUserDefaults standardUserDefaults] stringForKey:@"ibtoolPath"];
//	DEBUG(@"ibtool path = %@", path);
	return path;
}

- (NSArray*)userDefaultsArguments
{	
	return [[NSUserDefaults standardUserDefaults] stringArrayForKey:@"ibtoolArguments"];
}

- (NSArray*)suffixArguments
{
	NSMutableArray *args = [NSMutableArray array];
	NSArray *plugins = [[Preferences shared] ibtoolPlugins];
	if([plugins count] > 0) {
		NSEnumerator *enumerator = [plugins objectEnumerator];
		NSString *file;
		while(file=[enumerator nextObject]) {
			if([file isPathExisting]) {
				[args addObject:@"--plugin"];
				[args addObject:file];				
			}
		}
	}	
	// Performance note: actually using the agent will not use all the power of the Mac Pro
	// and will perform slower than without the agent.
	// Note: also, this argument is not supported in Xcode 4 ibtool for now. It results in the message:
	// The --(null) (-_) argument is no longer supported by ibtool
//	[args addObject:@"--agent-name"];
//	[args addObject:@"ilocalize"];
	return args;
}

- (NSArray*)nibtoolArguments:(id)firstObject, ...
{
	NSMutableArray *array = [NSMutableArray array];
	NSArray *args = [self userDefaultsArguments];
	if([args count] > 0) {
		[array addObjectsFromArray:args];
	}
	va_list argList;
	if(firstObject) {
		id currentObject;
		[array addObject:firstObject];
		va_start(argList, firstObject);
		while((currentObject = va_arg(argList, id))) {
			[array addObject:currentObject];
		}
		va_end(argList);
	}
	NSArray *suffixArgs = [self suffixArguments];
	if([suffixArgs count] > 0) {
		[array addObjectsFromArray:suffixArgs];
	}	
	return array;
}

- (NSString*)versionOfIbtool
{
	// ibtool -V
	
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:[self nibtoolPath]];
	[task setArguments:[self nibtoolArguments:@"-V", nil]];
	
	NibEngineResult *result = [self launchAndWaitTask:task workingFile:nil];
	
	
	return result.output;
}

@end

@implementation NibEngine (Parsing)

- (NSDictionary*)localizedContentOfNibFile:(NSString*)nib
{
	// ibtool -all <nib-file>
	
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:[self nibtoolPath]];
	[task setArguments:[self nibtoolArguments:@"-all", nib, nil]];
	
	NibEngineResult *result = [self launchAndWaitTask:task workingFile:nib];
	
	
	NSString *error = nil;
	NSDictionary *dic = [NSPropertyListSerialization propertyListFromData:[result.output dataUsingEncoding:NSUnicodeStringEncoding] mutabilityOption:0 format:nil errorDescription:&error];
	if(!dic) {
		ERROR(@"*** Error reading property list: %@", error);
	}
	return dic;	
}

- (NSString*)stringsOfNibFile:(NSString*)nib
{
	[self setNibFile:nib];
	return [self strings];
}

- (StringsContentModel*)parseStringModelsFromText:(NSString*)text
{
	/* Because ibtool does not guarantee that the strings file from a nib file will have the keys ordered, we enforce
	 that here by sorting the string models by keys */
	self.content = [[StringsEngine engineWithConsole:mConsole] parseStringModelsOfText:text usingModel:[NibStringModel class]];
	[self.content sortByKeys];
	return self.content;
}

- (StringsContentModel*)parseStringModels
{
	return [self parseStringModelsFromText:[self strings]];
}

- (StringsContentModel*)parseStringModelsOfNibFile:(NSString*)nib
{
	[self setNibFile:nib];
	return [self parseStringModels];
}

@end

@implementation NibEngine (Encoding)

- (NSString*)resolveFile:(NSString*)file
{
	NSString *resolvedFile = [FileTool resolveEquivalentFile:file];
	if(![resolvedFile isEqualToString:file]) {
		[mConsole addLog:[NSString stringWithFormat:@"Resolved original file \"%@\" to file \"%@\"", file, resolvedFile] class:[self class]];		
		return resolvedFile;
	}	
	return file;
}

- (void)translateNibFile:(NSString*)nibFile usingStringFile:(NSString*)stringFile
{
	[mConsole addLog:[NSString stringWithFormat:@"Translate nib file \"%@\" using string file \"%@\"", nibFile, stringFile] class:[self class]];

	[self _translateNibFile:nibFile usingStringFile:stringFile];
	
	[self cleanNibFile:nibFile];
}

- (void)translateNibFile:(NSString*)nibFile usingStringModels:(StringsContentModel*)stringModels
{			
	NSData *stringData = [[[StringsEngine engineWithConsole:mConsole] encodeStringModels:stringModels baseStringModels:nil skipEmpty:YES format:STRINGS_FORMAT_APPLE_STRINGS encoding:ENCODING_UNICODE] dataUsingEncoding:NSUnicodeStringEncoding];	

	NSString *tempStringFile = [FileTool generateTemporaryFileNameWithExtension:@"strings"];
	[stringData writeToFile:tempStringFile atomically:NO];
		
	[self translateNibFile:nibFile usingStringFile:tempStringFile];
	
	[tempStringFile removePathFromDisk];
}

- (void)translateNibFile:(NSString*)nibFile usingLayoutFromNibFile:(NSString*)layoutNibFile
{	
	[mConsole addLog:[NSString stringWithFormat:@"Translate nib file \"%@\" using layout from nib file \"%@\"", nibFile, layoutNibFile] class:[self class]];
	[self _translateNibFile:nibFile usingLayoutFromNibFile:layoutNibFile];
	[self cleanNibFile:nibFile];	
}

- (void)translateNibFile:(NSString*)nibFile usingLayoutFromNibFile:(NSString*)layoutNibFile usingStringFile:(NSString*)stringFile
{
	[mConsole addLog:[NSString stringWithFormat:@"Translate nib file \"%@\" using layout from nib file \"%@\" and strings from file \"%@\"", nibFile, layoutNibFile, stringFile] class:[self class]];
	[self _translateNibFile:nibFile usingLayoutFromNibFile:layoutNibFile usingStringFile:stringFile];
	[self cleanNibFile:nibFile];
}

- (void)translateNibFile:(NSString*)nibFile usingLayoutFromNibFile:(NSString*)layoutNibFile usingStringModels:(StringsContentModel*)stringModels
{
	if([stringModels numberOfStrings] == 0) {
		// Certain nib files don't have strings. Do not attempt to use the empty temporary string file because it will
		// be empty and will give warning in the console that are not useful.
		[self translateNibFile:nibFile usingLayoutFromNibFile:layoutNibFile];		
	} else {
		NSData *stringData = [[[StringsEngine engineWithConsole:mConsole] encodeStringModels:stringModels baseStringModels:nil skipEmpty:YES format:STRINGS_FORMAT_APPLE_STRINGS encoding:ENCODING_UNICODE] dataUsingEncoding:NSUnicodeStringEncoding];	
		
		NSString *tempStringFile = [FileTool generateTemporaryFileNameWithExtension:@"strings"];
		[stringData writeToFile:tempStringFile atomically:NO];
		
		[self translateNibFile:nibFile usingLayoutFromNibFile:layoutNibFile usingStringFile:tempStringFile];
		
		[tempStringFile removePathFromDisk];		
	}
}

@end

@implementation NibEngine (Task)

- (NibEngineResult*)launchAndWaitTask:(NSTask*)task workingFile:(NSString*)workingFile
{
	NSString *tempDataFile = [FileTool generateTemporaryFileName];
	[[NSFileManager defaultManager] createFileAtPath:tempDataFile contents:nil attributes:nil];	
	NSFileHandle *dataFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:tempDataFile];
	if(!dataFileHandle) {
		[tempDataFile removePathFromDisk];
		[mConsole addError:@"Cannot create temporary file"
			   description:[NSString stringWithFormat:@"Cannot create temporary file \"%@\"", tempDataFile]
					 class:[self class]];
		return NULL;
	}
	
	NSString *tempErrorFile = [FileTool generateTemporaryFileName];
	[[NSFileManager defaultManager] createFileAtPath:tempErrorFile contents:nil attributes:nil];
	NSFileHandle *errorFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:tempErrorFile];
	if(!errorFileHandle) {
		[tempDataFile removePathFromDisk];
		[tempErrorFile removePathFromDisk];
		[mConsole addError:@"Cannot create temporary file"
			   description:[NSString stringWithFormat:@"Cannot create temporary file \"%@\"", tempErrorFile]
					 class:[self class]];
		return NULL;		
	}

	if([[NSUserDefaults standardUserDefaults] boolForKey:@"outputnibcommand"]) {
		[mConsole addLog:[NSString stringWithFormat:@"%@ %@", [task launchPath], [task arguments]] class:[self class]];		
	}
	
	//NSLog(@"***************** %@ %@", [task launchPath], [task arguments]);

	//The magic line that keeps your log where it belongs (http://www.cocoadev.com/index.pl?NSTask)
	[task setStandardInput:[NSPipe pipe]];

	[task setStandardOutput:dataFileHandle];
	[task setStandardError:errorFileHandle];
	
	[task launch];
	[task waitUntilExit];
	
	int status = [task terminationStatus];	
	NSString *error = [[NSString alloc] initWithContentsOfFile:tempErrorFile usedEncoding:nil error:nil];

	// Allocate string because pool will be auto-released at the end of this method
	NSString *output = [[NSString alloc] initWithContentsOfFile:tempDataFile usedEncoding:nil error:nil];
	[self taskCompletedWithStatus:status error:error output:output workingFile:workingFile task:task];
	
	[tempDataFile removePathFromDisk];
	[tempErrorFile removePathFromDisk];

	// Don't forget to close the handle because otherwise, the file is closed later and can lead to a problem
	// if too many files are opened at the same time! (02/04/05)
	[dataFileHandle closeFile];
	[errorFileHandle closeFile];
	
	NibEngineResult *result = [[NibEngineResult alloc] init];
	result.success = status == 0;
	result.error = error;
	result.output = output;
	return result;
}

@end

@implementation NibEngine (Operations)

- (NSString*)strings
{
	// ibtool --generate-stringsfile file.strings file.nib
	
	NSString *tempFile = [FileTool generateTemporaryFileNameWithExtension:@"strings"];	
	
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:[self nibtoolPath]];
	[task setArguments:[self nibtoolArguments:@"--generate-stringsfile", tempFile, mNibFile, nil]];
	
	[self launchAndWaitTask:task workingFile:mNibFile];
	
	
	// Unfortunately we need to read the strings from a file instead of a pipe like with nibtool
	NSString *strings = [NSString stringWithContentsOfFile:tempFile usedEncoding:nil error:nil];
	[tempFile removePathFromDisk];
	return strings;
}

- (NibEngineResult*)convertNibFile:(NSString*)nibFile toXibFile:(NSString*)xibFile
{
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:[self nibtoolPath]];
	[task setArguments:@[@"--upgrade", nibFile, @"--write", xibFile]];
	
	NibEngineResult *result = [self launchAndWaitTask:task workingFile:nibFile];
	
	
	return result;
}

- (BOOL)isNibFile:(NSString*)source identicalToFile:(NSString*)target error:(NSError**)error
{
	if(*error) {
		*error = nil;
	}
	
	NSDictionary *sourceDic = [self localizedContentOfNibFile:source];
	if(!sourceDic) {
		NSDictionary *errorInfo = @{NSFilePathErrorKey: source, NSLocalizedDescriptionKey: @"Error parsing output of nib file (-all)"};
		*error = [NSError errorWithDomain:ILErrorDomain code:100 userInfo:errorInfo];
		return NO;
	}
	
	NSDictionary *targetDic = [self localizedContentOfNibFile:target];
	if(!targetDic) {
		NSDictionary *errorInfo = @{NSFilePathErrorKey: target, NSLocalizedDescriptionKey: @"Error parsing output of nib file (-all)"};
		*error = [NSError errorWithDomain:ILErrorDomain code:101 userInfo:errorInfo];
		return NO;
	}
	
	// Before doing the comparison, let's remove the ibtool version keys that can be different.
	/*
	 <key>com.apple.ibtool.document.version-history</key>
	 <dict>
	 <key>interface-builder-version</key>
	 <dict>
	 <key>com.apple.AppKit</key>
	 <string>1038.29</string>
	 <key>com.apple.Carbon</key>
	 <string>460.00</string>    <--------------- now is: 461.00
	 <key>com.apple.InterfaceBuilderKit</key>
	 <string>788</string>
	 <key>macosx.version</key>
	 <string>10D573</string>     <------------- now is: 10F569
	 </dict>
	 </dict>	 	
	 */
	NSMutableDictionary *mda = [[NSMutableDictionary alloc] init];
	[mda setDictionary:sourceDic];
	[mda removeObjectForKey:@"com.apple.ibtool.document.version-history"];
	
	NSMutableDictionary *mdb = [[NSMutableDictionary alloc] init];
	[mdb setDictionary:targetDic];
	[mdb removeObjectForKey:@"com.apple.ibtool.document.version-history"];
	
	BOOL identical = [mda isEqualToDictionary:mdb];
	return identical;
}

- (void)_translateNibFile:(NSString*)nibFile usingStringFile:(NSString*)stringFile
{
	// ibtool --strings-file french.strings English.nib --write Translated.nib
	
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:[self nibtoolPath]];
	[task setArguments:[self nibtoolArguments:@"--strings-file", stringFile, nibFile, @"--write", nibFile, nil]];
	
	[self launchAndWaitTask:task workingFile:nibFile];
}

- (void)_translateNibFile:(NSString*)nibFile usingLayoutFromNibFile:(NSString*)layoutNibFile
{
	[self _translateNibFile:nibFile usingLayoutFromNibFile:layoutNibFile usingStringFile:nil];
}

- (void)_translateNibFile:(NSString*)nibFile usingLayoutFromNibFile:(NSString*)layoutNibFile usingStringFile:(NSString*)stringFile
{
	// Original command:
	// ibtool --previous-file English_1.0.nib --incremental-file French_1.0.nib --localize-incremental --write Expected.nib English_2.0.nib
	// Modified command:
	// ibtool --previous-file nibFile --incremental-file layoutNibFile --localize-incremental --write output.nib nibFileDuplicate.nib
	// Optional argument: --strings-file stringFile
	
	// "New" nibFile version required by ibtool
	NSString *nibFileDuplicate = [FileTool generateTemporaryFileNameWithExtension:[nibFile pathExtension]];
	[[FileTool shared] copySourceFile:nibFile toFile:nibFileDuplicate console:mConsole];
	
	// Output file required by ibtool (cannot write over the input nib file apparently)
	NSString *outputFile = [FileTool generateTemporaryFileNameWithExtension:[nibFile pathExtension]];	
	
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:[self nibtoolPath]];
	if(stringFile) {
		[task setArguments:[self nibtoolArguments:@"--previous-file", nibFile, @"--incremental-file", layoutNibFile,
							@"--strings-file", stringFile,
							@"--localize-incremental", @"--write", outputFile, nibFileDuplicate, nil]];
	} else {
		[task setArguments:[self nibtoolArguments:@"--previous-file", nibFile, @"--incremental-file", layoutNibFile,
							@"--localize-incremental", @"--write", outputFile, nibFileDuplicate, nil]];
	}
	
	NibEngineResult *result = [self launchAndWaitTask:task workingFile:nibFile];
	if(!result.success) {
		LOG_DEBUG(@"Error for: %@ %@", [task launchPath], [[task arguments] componentsJoinedByString:@" "]);
	}
	
	// Overwrite nibFile
	[[FileTool shared] copySourceFile:outputFile toReplaceFile:nibFile console:mConsole];
	
	// Remove the temporary files
	[nibFileDuplicate removePathFromDisk];
	[outputFile removePathFromDisk];
	
}

- (void)taskCompletedWithStatus:(int)status error:(NSString*)errorText output:(NSString*)outputText workingFile:(NSString*)workingFile task:(NSTask*)task
{
	if(status == 0) return;
		
	/* Try to parse the error assuming the ibtool XML output such as:
	
	 5/1/11 9:59:08 PM	iLocalize[72740]	Output: [<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.ibtool.errors</key>
	<array>
		<dict>
			<key>description</key>
			<string>The document "BadFile.nib" could not be opened. Interface Builder cannot open compiled nibs.</string>
			<key>recovery-suggestion</key>
			<string>Try opening the source document instead of the compiled nib.</string>
		</dict>
	</array>
</dict>
</plist>
]	 
	 */

	NSMutableString *message = [NSMutableString string];
	
    if (outputText.length > 0) {
        NSError *error = nil;
        NSDictionary *errorDic = [NSPropertyListSerialization propertyListWithData:[outputText dataUsingEncoding:NSUTF8StringEncoding]
                                                                           options:NSPropertyListImmutable
                                                                            format:nil 
                                                                             error:&error];
        if(error) {
            ERROR(@"Unable to convert ibtool output '%@' to property list: %@", outputText, [error description]);
            [message appendString:outputText];
        } else {
            NSArray *ibtoolErrorList = errorDic[@"com.apple.ibtool.errors"];
            if(ibtoolErrorList.count > 0) {
                for(NSDictionary *dic in ibtoolErrorList) {
                    for(NSString *key in [dic allKeys]) {
                        [message appendFormat:@"%@: %@\n", key, dic[key]];					
                    }
                }
            } else {
                ERROR(@"Unable to find the ibtool error entry in property list %@ based on output %@", errorDic, outputText);
                [message appendString:outputText];			
            }
        }        
    }

	[message appendFormat:@"Status: %d\n", status];
	[message appendFormat:@"Arguments: '%@ %@'\n", [task launchPath], [[task arguments] componentsJoinedByString:@" "]];
	
	[mConsole addError:[NSString stringWithFormat:@"%@ ibtool error", [workingFile lastPathComponent]]
		   description:message 
				 class:[self class]];						
	
}

@end


