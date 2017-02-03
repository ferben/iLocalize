//
//  FileTool.m
//  iLocalize3
//
//  Created by Jean on 28.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "FileTool.h"
#import "LanguageTool.h"

#import "PreferencesEditors.h"

#import "Console.h"
#import "Constants.h"

@implementation FileTool

static FileTool *shared = nil;

+ (FileTool*)shared
{
    @synchronized(self) {
        if(shared == nil)
            shared = [[FileTool alloc] init];        
    }
    return shared;
}

- (id)init
{
    if((self = [super init])) {
        mAtomicExtensions = [[NSMutableArray alloc] init];
        
        [self addFileExtensionAsAtomic:@"nib"];
        [self addFileExtensionAsAtomic:@"rtfd"];        
    }
    return self;
}


+ (BOOL)isPathSVNFolder:(NSString*)path
{
    if([path isPathDirectory]) {
        return [[path lastPathComponent] isEqualToString:@".svn"];
    }
    return NO;
}

- (void)addFileExtensionAsAtomic:(NSString*)extension
{
    [mAtomicExtensions addObject:extension];
}

- (BOOL)isFileAtomic:(NSString*)file
{
    if([mAtomicExtensions containsObject:[file pathExtension]]) {
        return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:file error:nil] != nil;
    } else {
        return NO;
    }
}

- (void)preparePath:(NSString*)path atomic:(BOOL)atomic skipLastComponent:(BOOL)skipLastComponent
{
    NSString *directory = @"/";

    @autoreleasepool {

        NSArray *components = [path pathComponents];
        NSEnumerator *enumerator = [components objectEnumerator];
        NSString *component;
        while(component = [enumerator nextObject]) {
            directory = [directory stringByAppendingPathComponent:component];
            if(atomic && [self isFileAtomic:directory])
                break;
            
            if(skipLastComponent && [components lastObject] == component)
                break;
            
            if([[NSFileManager defaultManager] fileExistsAtPath:directory])
                continue;

            [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
        }

    }
}

- (BOOL)copySourceFile:(NSString*)sourceFile toReplaceFile:(NSString*)destFile console:(Console*)console
{
    BOOL success = YES;
    @autoreleasepool {

        [destFile removePathFromDisk];
        NSError *error = nil;
        if([[NSFileManager defaultManager] copyItemAtPath:sourceFile toPath:destFile error:&error] == NO) {
            [console addError:[NSString stringWithFormat:@"Failed to copy %@", [sourceFile lastPathComponent]]
                  description:[NSString stringWithFormat:@"Cannot copy/replace file \"%@\" to \"%@\" (%@)", sourceFile, destFile, error] 
                        class:[self class]];
            success = NO;
        }
        
        return success;
    }
}

- (BOOL)copySourceFile:(NSString*)sourceFile toFile:(NSString*)destFile console:(Console*)console
{
    BOOL success = YES;
    @autoreleasepool {

        [self preparePath:destFile atomic:YES skipLastComponent:YES];
        NSError *error = nil;
        if([[NSFileManager defaultManager] copyItemAtPath:sourceFile toPath:destFile error:&error] == NO) {
            [console addError:[NSString stringWithFormat:@"Failed to copy %@", [sourceFile lastPathComponent]]
                  description:[NSString stringWithFormat:@"Cannot copy file \"%@\" to \"%@\" (%@)", sourceFile, destFile, error]
                        class:[self class]];
            success = NO;
        }

        return success;
    }
}

- (BOOL)copySourcePath:(NSString*)sourcePath toPath:(NSString*)destPath languages:(NSArray*)languages console:(Console*)console
{
    // Copy a source item (application, folder, etc) to a destination folder. The copy includes:
    // - all non-languages files
    // - all languages files which language is contained in 'languages'
        
    BOOL success = YES;
    @autoreleasepool {

        NSString *destFile = [destPath stringByAppendingPathComponent:[sourcePath lastPathComponent]];    
        [destFile removePathFromDisk];
        
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:sourcePath];
        NSString *relativeFilePath;
        while(relativeFilePath = [enumerator nextObject]) {
            @autoreleasepool {

                NSString *sourceFile = [sourcePath stringByAppendingPathComponent:relativeFilePath];
                NSString *targetFile = [destFile stringByAppendingPathComponent:relativeFilePath];
                
                // Should this path be skipped ?
                NSString *language = [LanguageTool languageOfFile:sourceFile];
                if([language length]) {
                    BOOL isFolder = [sourceFile isPathDirectory];
                    
                    if([languages containsObject:language]) {
                        // Copy the language folder at once
                        [self preparePath:targetFile atomic:NO skipLastComponent:YES];
                        NSError *error = nil;
                        if([[NSFileManager defaultManager] copyItemAtPath:sourceFile toPath:targetFile error:&error] == NO) {
                            [console addError:[NSString stringWithFormat:@"Failed to copy folder %@", [sourceFile lastPathComponent]]
                                  description:[NSString stringWithFormat:@"Cannot copy folder \"%@\" to \"%@\" (%@)", sourceFile, targetFile, error]
                                        class:[self class]];
                            success = NO;
                            // Since 3.8: continue to read the project even in case of error (they will be reported later on)                    
//                    [subpool release];
//                    break;
                        }                
                    }
                    // Skip if it's a folder
                    if(isFolder) {
                        [enumerator skipDescendents];                            
                    }
                } else {
                    // Not a language file - copy it if it is a flat (i.e. regular, symbolic or alias) file
                    
                    if([sourceFile isPathFlat]) {
                        [self preparePath:targetFile atomic:NO skipLastComponent:YES];
                        NSError *error = nil;
                        if([[NSFileManager defaultManager] copyItemAtPath:sourceFile toPath:targetFile error:&error] == NO) {
                            [console addError:[NSString stringWithFormat:@"Failed to copy %@", [sourceFile lastPathComponent]]
                                  description:[NSString stringWithFormat:@"Cannot copy file \"%@\" to \"%@\" (%@)", sourceFile, targetFile, error]
                                        class:[self class]];
                            success = NO;
// Since 3.8: continue to read the project even in case of error (they will be reported later on)                    
//                    [subpool release];
//                    break;
                        }
                    }
                }
            }
        }
        
        // Remove all .svn folders
        enumerator = [[NSFileManager defaultManager] enumeratorAtPath:destFile];
        while(relativeFilePath = [enumerator nextObject]) {
            NSString *file = [destFile stringByAppendingPathComponent:relativeFilePath];
            if([FileTool isPathSVNFolder:file]) {
                [file removePathFromDisk];
                [enumerator skipDescendents];
            }
        }
        
        return success;
    }
}

#pragma mark -

+ (NSString *)generateTemporaryFileName
{
    NSProcessInfo *procInfo = [NSProcessInfo processInfo];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d_%@",
                                                                   [procInfo processName],
                                                                   [procInfo processIdentifier],
                                                                   [procInfo globallyUniqueString]]];
}

+ (NSString *)generateTemporaryFileNameWithExtension:(NSString*)ext
{
    NSProcessInfo *procInfo = [NSProcessInfo processInfo];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%d_%@.%@",
        [procInfo processName],
        [procInfo processIdentifier],
        [procInfo globallyUniqueString],
        ext]];
}

+ (NSString*)languageOfPath:(NSString*)path
{
    // Return the language of the last .lproj directory
    // Path must be of the form: .../xxx.lproj/...

    NSEnumerator *enumerator = [[path pathComponents] reverseObjectEnumerator];
    NSString *component;
    NSString *result = nil;
    while(component = [enumerator nextObject]) {
        if([component hasSuffix:LPROJ]) {
            result = [component substringToIndex:[component rangeOfString:@"."].location];
            break;
        }
    }
    return result;
}

+ (NSString*)languageFolderPathOfPath:(NSString*)path
{
    NSArray *components = [path pathComponents];
    int i;
    for(i = [components count]-1; i>=0; i--) {
        NSString *c = components[i];
        if([c hasSuffix:LPROJ]) {
            return [NSString pathWithComponents:[components subarrayWithRange:NSMakeRange(0, i+1)]];
        }        
    }
    return nil;
}

+ (NSString*)translatePath:(NSString*)path toLanguage:(NSString*)language
{
    return [FileTool translatePath:path toLanguage:language keepLanguageFormat:NO];
}

+ (NSString*)translatePath:(NSString*)path toLanguage:(NSString*)language keepLanguageFormat:(BOOL)keepFormat
{
    // Translate a path containing a .lproj to a specific language
    // Path must be of the form: .../xxx.lproj/...
    // Translated path will be: .../language.lproj/...
    // keepFormat is there to indicate if the format of the path must be preserved (ISO/legacy)

    NSString *adjustedLanguage = language;
    if(keepFormat) {
        if([[FileTool languageOfPath:path] isLegacyLanguage]) {
            adjustedLanguage = [language legacyLanguage];
        } else {
            adjustedLanguage = [language isoLanguage];            
        }
        if(adjustedLanguage == nil) {
            adjustedLanguage = language;
        }
    }
    
    NSMutableArray *translatedComponents = [[NSMutableArray alloc] init];
    
    NSEnumerator *enumerator = [[path pathComponents] reverseObjectEnumerator];
    NSString *component;
    while(component = [enumerator nextObject]) {
        if([component hasSuffix:LPROJ])
            [translatedComponents insertObject:[NSString stringWithFormat:@"%@%@", adjustedLanguage, LPROJ] atIndex:0];            
        else
            [translatedComponents insertObject:component atIndex:0];
    }
    
    NSString *result = [NSString pathWithComponents:translatedComponents];
    return result;
}

// Returns all the alternate path for a given language. For example:
// ../English.lproj/foo.nib
// ../en.lproj/foo.nib
+ (NSArray*)equivalentLanguagePaths:(NSString*)path
{
    NSMutableArray *equivalentPaths = [NSMutableArray array];

    @autoreleasepool {

        NSEnumerator *enumerator = [[LanguageTool equivalentLanguagesWithLanguage:[FileTool languageOfPath:path]] objectEnumerator];
        NSString *language;
        while(language = [enumerator nextObject]) {
            [equivalentPaths addObject:[FileTool translatePath:path toLanguage:language]];
        }    
        
        
        return equivalentPaths;
    }
}

/* Returns the real path to the file: it solves the issue when a file is expressed in a certain language, for example ISO,
while the real file is on the disk stored in legacy language.
*/
+ (NSString*)resolveEquivalentFile:(NSString*)file
{
    if([file isPathExisting]) return file;

    @autoreleasepool {
        for(NSString *resolved in [FileTool equivalentLanguagePaths:file]) {
            if([resolved isPathExisting]) {
                return resolved;            
            }
        }
        
        // IL-136 fix:
        // If no equivalent for the file exists, look at the parent folder of its .lproj to see if an equivalent lproj
        // already exists at that level.
        // For example:
        // Contents/Resources/French.lproj/localizable.strings -> does not exist
        // Contents/Resources/fr.lproj/localizable.strings -> does not exist either
        // Contents/Resources/fr.lproj/ -> however this folder exists (e.g. some other localized files already exist in it) so pick its language format
        // --> this is to avoid having two different lproj at the same level

        // Get the path to the lproj
        NSString *languagePath = [FileTool languageFolderPathOfPath:file];

        // Iterate over the equivalent paths
        for(NSString *resolved in [FileTool equivalentLanguagePaths:languagePath]) {
            if([resolved isPathExisting]) {
                // an existing path has been found. use it.
                
                NSString *language = [FileTool languageOfPath:resolved];
                return [FileTool translatePath:file toLanguage:language];
            }
        }

        return file;
    }
}

+ (NSString*)systemApplicationSupportFolder
{    
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/iLocalize/"];
}

+ (NSString*)systemCacheFolder
{    
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/iLocalize/"];
}

#pragma mark -

+ (BOOL)buildFSRef:(FSRef*)fsRef fromPath:(NSString*)path
{
    CFURLRef url = CFURLCreateWithFileSystemPath(NULL /*allocator*/, (CFStringRef)path, kCFURLPOSIXPathStyle, NO /*isDirectory*/);
    BOOL result = url != NULL && CFURLGetFSRef(url, fsRef);
    if(url) {
        CFRelease(url);        
    }
    return result;
}

+ (BOOL)isPathAnAlias:(NSString *)path
{
    Boolean isAlias = NO;

    NSURL *theURL = [NSURL fileURLWithPath:path];
    NSNumber *number = NULL;
    
    if ([theURL getResourceValue:&number forKey:NSURLIsAliasFileKey error:nil])
        isAlias = [number boolValue];
    
    return isAlias;
}

+ (NSString*)resolvedPathOfAliasPath:(NSString*)alias
{
    NSURL *url = nil;
    
    for(;;)
    {
        if ( alias == nil )
            break;
        
        url = [[NSURL fileURLWithPath:alias] URLByResolvingSymlinksInPath];
        
        if( url == nil )
            break;
        
        NSError * error = nil;
        NSNumber * isAlias = nil;
        if (![url getResourceValue:&isAlias forKey:NSURLIsAliasFileKey error:&error])
            break;
        
        if([isAlias boolValue])
        {
            NSData * bookmark = [NSURL bookmarkDataWithContentsOfURL:url error:&error];
            if (bookmark == nil)
                break;
            
            BOOL isStale = NO;
            NSURLBookmarkResolutionOptions options = NSURLBookmarkResolutionWithoutUI|NSURLBookmarkResolutionWithoutMounting;
            
            NSURL *resolvedURL = [NSURL URLByResolvingBookmarkData:bookmark options:options relativeToURL:nil bookmarkDataIsStale:&isStale error:&error];
            
            if (resolvedURL != nil)
                url = resolvedURL;
        }
        
        break;
    }
    
    if (url)
    {
        return [url path];
    }
    
    return NULL;
}

+ (BOOL)createAliasOfFile:(NSString*)source toFile:(NSString*)target
{
    /*NDAlias *alias = [NDAlias aliasWithPath:source];
    return [alias writeToFile:target];*/
    
    NSMutableString *command = [NSMutableString string];
    [command appendString:@"tell application \"Finder\"\n"];
    [command appendFormat:@"make new alias file at (\"%@\" as POSIX file)", [target stringByDeletingLastPathComponent]];
    [command appendFormat:@" to file (\"%@\"as POSIX file)\n", source];
    [command appendString:@"end tell"];
    
    NSDictionary *errorInfo;
    NSAppleScript *as = [[NSClassFromString(@"NSAppleScript") alloc] initWithSource:command];
    NSAppleEventDescriptor *aedesc = [as executeAndReturnError:&errorInfo];    
    if (aedesc == nil) {
        NSLog(@"FileTool: error while creating an alias = %@", [errorInfo description]);
        return NO;
    }
        
    NSString *aliasName = [[aedesc descriptorAtIndex:3] stringValue];
    NSString *aliasPath = [[target stringByDeletingLastPathComponent] stringByAppendingPathComponent:aliasName];
    if([aliasPath isEqualToString:target])
        return YES;
    else
        return [[NSFileManager defaultManager] moveItemAtPath:aliasPath toPath:target error:nil];
}

#pragma mark -

+ (void)revealFile:(NSString*)file
{
    /* WWDC - QUESTIONS:
        Need to call twice this method otherwise the Finder only opens the window with the root folder but
        does not select the file
    */
    [[NSWorkspace sharedWorkspace] selectFile:file inFileViewerRootedAtPath:file];    
    if(![file isPathDirectory])
        [[NSWorkspace sharedWorkspace] selectFile:file inFileViewerRootedAtPath:file];            
}

+ (void)openFile:(NSString*)file suggestedApp:(NSString*)app
{
    if(app == nil) {
        app = [[PreferencesEditors shared] editorForExtension:[file pathExtension]];        
    }
    
    if(!app || [[NSWorkspace sharedWorkspace] openFile:file withApplication:app] == NO) {
        [[NSWorkspace sharedWorkspace] openFile:file];                            
    }                
}

+ (void)openFile:(NSString*)file
{
    return [FileTool openFile:file suggestedApp:nil];
}

+ (BOOL)diffFiles:(NSArray*)files {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"diffPath"]];
    [task setArguments:files];
    //The magic line that keeps your log where it belongs (http://www.cocoadev.com/index.pl?NSTask)
    [task setStandardInput:[NSPipe pipe]];
    
    [task launch];
    [task waitUntilExit];
    int status = [task terminationStatus];
    
    return status == 0;
}

+ (BOOL)zipPath:(NSString*)source toFileName:(NSString*)target recursive:(BOOL)recursive
{
    [target removePathFromDisk];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"zipPath"]];
    [task setCurrentDirectoryPath:[source stringByDeletingLastPathComponent]];
    [task setArguments:@[recursive?@"-qyr":@"-qyj", [target lastPathComponent], [source lastPathComponent]]];
    //The magic line that keeps your log where it belongs (http://www.cocoadev.com/index.pl?NSTask)
    [task setStandardInput:[NSPipe pipe]];

    [task launch];
    [task waitUntilExit];
    int status = [task terminationStatus];
    
    return status == 0;
}

+ (NSString*)localizedInfoPlistAtPath:(NSString*)path language:(NSString*)language
{
    NSString *relativePath = [NSString stringWithFormat:@"/Contents/Resources/%@.lproj/InfoPlist.strings", language];
    return [path stringByAppendingPathComponent:relativePath];    
}

+ (NSString*)defaultInfoPlistAtPath:(NSString*)path
{
    return [path stringByAppendingPathComponent:@"/Contents/Info.plist"];    
}

+ (NSString*)infoValueForKey:(NSString*)key path:(NSString*)path language:(NSString*)language
{
    // Do not use NSBundle because it cannot be unloaded so if the Info Plist file changes on the disk, the changes
    // won't be reflected here until iLocalize is restarted.
    NSDictionary *localizedBundleDic = [NSDictionary dictionaryWithContentsOfFile:[FileTool localizedInfoPlistAtPath:path language:language]];
    if(localizedBundleDic[key]) {
        return localizedBundleDic[key];
    }
    return [NSDictionary dictionaryWithContentsOfFile:[FileTool defaultInfoPlistAtPath:path]][key];        
}
                
+ (NSString*)shortVersionOfBundle:(NSString*)path language:(NSString*)language
{
    return [FileTool infoValueForKey:@"CFBundleShortVersionString" path:path language:language];        
}

+ (NSString*)versionOfBundle:(NSString*)path language:(NSString*)language
{
    return [FileTool infoValueForKey:@"CFBundleVersion" path:path language:language];            
}

@end

