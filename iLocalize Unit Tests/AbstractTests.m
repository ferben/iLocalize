//
//  AbstractTests.m
//  iLocalize
//
//  Created by Jean Bovet on 11/24/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import "AbstractTests.h"
#import "FileTool.h"
#import "ILContext.h"

@implementation AbstractTests

- (void)setUp
{
    [ILContext shared].runningUnitTests = YES;
    [super setUp];
}

- (void)tearDown
{
    [ILContext shared].runningUnitTests = NO;
    [super tearDown];
}

- (NSString*)pathForResource:(NSString*)resource
{
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] bundlePath];
    bundlePath = [bundlePath stringByAppendingPathComponent:@"Contents"];
    bundlePath = [bundlePath stringByAppendingPathComponent:@"Resources"];
    bundlePath = [bundlePath stringByAppendingPathComponent:@"Resources"];
    return [bundlePath stringByAppendingPathComponent:resource];
}

- (NSString*)ibtoolPath {
    return @"/Applications/Xcode.app/Contents/Developer/usr/bin/ibtool";
}

- (NSString*)launchAndWaitTask:(NSTask*)task
{
	NSString *tempDataFile = [FileTool generateTemporaryFileName];
	[[NSFileManager defaultManager] createFileAtPath:tempDataFile contents:nil attributes:nil];
	NSFileHandle *dataFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:tempDataFile];
	if(!dataFileHandle) {
		[tempDataFile removePathFromDisk];
		NSLog(@"%@", [NSString stringWithFormat:@"Cannot create temporary file \"%@\"", tempDataFile]);
		return NULL;
	}
	
	NSString *tempErrorFile = [FileTool generateTemporaryFileName];
	[[NSFileManager defaultManager] createFileAtPath:tempErrorFile contents:nil attributes:nil];
	NSFileHandle *errorFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:tempErrorFile];
	if(!errorFileHandle) {
		[tempDataFile removePathFromDisk];
		[tempErrorFile removePathFromDisk];
		NSLog(@"%@", [NSString stringWithFormat:@"Cannot create temporary file \"%@\"", tempErrorFile]);
		return NULL;
	}
	
	//The magic line that keeps your log where it belongs (http://www.cocoadev.com/index.pl?NSTask)
	[task setStandardInput:[NSPipe pipe]];
	
	[task setStandardOutput:dataFileHandle];
	[task setStandardError:errorFileHandle];
	
	[task launch];
	[task waitUntilExit];
	int status = [task terminationStatus];
	
	NSString *error = [NSString stringWithContentsOfFile:tempErrorFile usedEncoding:nil error:nil];
	
	if (status != 0 || [error length]>0) {
		if(status != 0) {
			NSLog(@"[Test] ibtool returned an error code %d:", status);
		}
		
		NSEnumerator *enumerator = [[error componentsSeparatedByString:@"\n"] objectEnumerator];
		NSString *s;
		while((s = [enumerator nextObject])) {
			if([s rangeOfString:@"Could not find image named"].location == NSNotFound && [s length]) {
				NSLog(@"  Error: %@", s);
			}
		}
	}
	
	NSString *strings = [[NSString alloc] initWithContentsOfFile:tempDataFile usedEncoding:nil error:nil];
	
	[tempDataFile removePathFromDisk];
	[tempErrorFile removePathFromDisk];
	
	// Don't forget to close the handle because otherwise, the file is closed later and can lead to a problem
	// if too many files are opened at the same time! (02/04/05)
	[dataFileHandle closeFile];
	[errorFileHandle closeFile];
	
	return strings;
}

- (NSString*)contentOfNibFile:(NSString*)file
{
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:[self ibtoolPath]];
	[task setArguments:[NSArray arrayWithObjects:@"--localizable-all", file, nil]];
    
	NSString *content = [self launchAndWaitTask:task];
	return content;
}

- (NSArray*)linesOfString:(NSString*)s
{
	NSMutableArray *array = [NSMutableArray array];
	NSRange r = NSMakeRange(0, 0);
	while(YES) {
		NSRange lr = [s lineRangeForRange:r];
		if(lr.location+lr.length == [s length]) break;
		[array addObject:[s substringWithRange:lr]];
		r.location = lr.location+lr.length;
	}
	return array;
}

- (id)propertyFromNibFile:(NSString*)nibFile {
    NSError *error = nil;
    NSString *sa = [self contentOfNibFile:nibFile];
    id pa = [NSPropertyListSerialization propertyListWithData:[sa dataUsingEncoding:NSUnicodeStringEncoding]
                                                      options:NSPropertyListImmutable
                                                       format:nil
                                                        error:&error];
    if (nil == pa) {
        NSLog(@"Error reading property from file %@: %@", nibFile, error);
    }
    return pa;
}

- (BOOL)isContentOfFile:(NSString*)first equalsToFile:(NSString*)second differences:(NSMutableArray*)differences
{
	BOOL equals = [[NSFileManager defaultManager] contentsEqualAtPath:first andPath:second];
	if(!equals) {
		if([first isPathNib]) {
            id pa = [self propertyFromNibFile:first];
            id pb = [self propertyFromNibFile:second];
            if ([pa isEqual:pb]) {
                return YES;
            }
            
			// Analyze the nib file more in details because some differences are allowable
			NSArray* a = [self linesOfString:[self contentOfNibFile:first]];
			NSArray* b = [self linesOfString:[self contentOfNibFile:second]];
			if([a count] != [b count]) {
				[differences addObject:[NSString stringWithFormat:@"%lu <-- (lines) --> %lu", (unsigned long)[a count], (unsigned long)[b count]]];
				[a writeToFile:@"/tmp/a.xml" atomically:NO];
				[b writeToFile:@"/tmp/b.xml" atomically:NO];
				return NO;
			}
			
			int index;
			for(index = 0; index < [a count]; index++) {
				NSString *la = [a objectAtIndex:index];
				NSString *lb = [b objectAtIndex:index];
				if(![la isEqualToString:lb]) {
					//dataCell = "<NSTextFieldCell: 0x3f6260>";
					NSString *tla = [la stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					NSString *tlb = [lb stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					if([tla hasPrefix:@"dataCell ="] && [tlb hasPrefix:@"dataCell ="]) continue;
					
					[differences addObject:[NSString stringWithFormat:@"%@ <---> %@", tla, tlb]];
					
					NSLog(@"Differences detected between files:");
					NSLog(@" (1) %@", first);
					NSLog(@" (2) %@", second);
					
					[a writeToFile:@"/a.xml" atomically:NO];
					[b writeToFile:@"/b.xml" atomically:NO];
					
					return NO;
				}
			}
			return YES;
		} else {
			[differences addObject:[NSString stringWithFormat:@"[%@]", [NSString stringWithContentsOfFile:first usedEncoding:nil error:nil]]];
			[differences addObject:[NSString stringWithFormat:@"[%@]", [NSString stringWithContentsOfFile:second usedEncoding:nil error:nil]]];
			[differences addObject:[NSString stringWithFormat:@"[%@]", [NSData dataWithContentsOfFile:first]]];
			[differences addObject:[NSString stringWithFormat:@"[%@]", [NSData dataWithContentsOfFile:second]]];
		}
	}
	return equals;
}

- (NSMutableArray*)contentOfPath:(NSString*)path
{
	NSMutableArray *array = [NSMutableArray array];
	
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
	NSString *relativeFilePath;
	while((relativeFilePath = [enumerator nextObject])) {
		NSString *file = [path stringByAppendingPathComponent:relativeFilePath];
		if([file isPathNib] || [file isPathRTFD]) {
			[enumerator skipDescendents];
			[array addObject:relativeFilePath];
			continue;
		}
		if([file isPathInvisible]) continue;
		if([file isPathDirectory]) continue;
		
		[array addObject:relativeFilePath];
	}
	return array;
}

- (BOOL)contentOfFile:(NSString*)first equalsFile:(NSString*)second
{
	NSMutableArray *differences = [NSMutableArray array];
	if(![self isContentOfFile:first
				 equalsToFile:second
				  differences:differences])
	{
		NSLog(@"Not identical %@ <---> %@", first, second);
		NSLog(@" -> %@", differences);
		return NO;
	} else {
		return YES;
	}
}

- (BOOL)contentOfPath:(NSString*)first equalsPath:(NSString*)second
{
	/*	NSPredicate *ignoreFilesPredicate = [NSPredicate predicateWithFormat:@"NOT SELF endswith '.DS_Store'"];
     NSArray *firstFiles = [[[NSFileManager defaultManager] subpathsAtPath:first] filteredArrayUsingPredicate:ignoreFilesPredicate];
     NSMutableArray *secondFiles = [NSMutableArray arrayWithArray:[[[NSFileManager defaultManager] subpathsAtPath:second] filteredArrayUsingPredicate:ignoreFilesPredicate]];
     */
	NSMutableArray *firstFiles = [self contentOfPath:first];
	NSMutableArray *secondFiles = [self contentOfPath:second];
	
	BOOL equals = YES;
	
	NSEnumerator *enumerator = [firstFiles objectEnumerator];
	NSString *file;
	while((file = [enumerator nextObject])) {
		if([secondFiles containsObject:file]) {
			NSMutableArray *differences = [NSMutableArray array];
			if(![self isContentOfFile:[first stringByAppendingPathComponent:file]
						 equalsToFile:[second stringByAppendingPathComponent:file]
						  differences:differences])
			{
				NSLog(@"Not identical %@ <---> %@", [first stringByAppendingPathComponent:file], [second stringByAppendingPathComponent:file]);
				NSLog(@" -> %@", differences);
				equals = NO;
			}
			[secondFiles removeObject:file];
		} else {
			NSLog(@"Non-existent in %@: %@", second, file);
			equals = NO;
		}
	}
	if([secondFiles count] > 0) {
		NSLog(@"Non-existent in %@: %@", first, secondFiles);
		equals = NO;
	}
	
    //	if(!equals) {
    //		exit(0);
    //	}
	
	return equals;
}

- (void)printExecutionTimeWithName:(NSString*)name block:(dispatch_block_t)block {
    NSTimeInterval interval = [self measureExecutionTime:block];
    NSLog(@"%@ took %f seconds", name, interval);
}

- (NSTimeInterval)measureExecutionTime:(dispatch_block_t)block {
    NSUInteger kNumberOfMeasurements = 20;
    NSTimeInterval totalTime = 0;
    for (NSUInteger index=0; index<kNumberOfMeasurements; index++) {
        NSDate *start = [NSDate date];
        block();
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:start];
        totalTime += duration;
    }
    return totalTime/kNumberOfMeasurements;
}

@end
