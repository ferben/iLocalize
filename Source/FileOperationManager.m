//
//  FileOperationManager.m
//  iLocalize
//
//  Created by Jean Bovet on 3/8/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "FileOperationManager.h"
#import "LanguageTool.h"
#import "FileTool.h"
#import "ILContext.h"

@implementation FileOperationManager

+ (FileOperationManager*)manager
{
	return [[self alloc] init];
}

- (BOOL)enumerateDirectory:(NSString*)inSource files:(NSMutableArray*)files errorHandler:(BOOL (^)(NSURL *url, NSError *error))handler
{
	__block BOOL success = YES;
	NSDirectoryEnumerationOptions options = NSDirectoryEnumerationSkipsHiddenFiles;
	NSDirectoryEnumerator *de = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:inSource]
													 includingPropertiesForKeys:nil 
																		options:options 
																   errorHandler:^(NSURL *url, NSError *err) {
																	   if(handler) {
																		   if(handler(url, err)) {
																			   return YES;
																		   }
																	   }
																	   success = NO;
																	   return NO;
																   }];
	if(!success) return NO;
	
	[files removeAllObjects];
    // IL-415 Don't resolve path because it will have the side effect
    // of resolving the alias which will cause the .framework to be
    // not copied correctly.
//    NSString *source = [inSource stringByResolvingSymlinksInPath];
    NSString *source = inSource;
	for(NSURL *url in de) {
        if(![url isFileURL]) {
            NSLog(@"Ignoring URL that doesn't represent a file: %@", url);
            continue;
        }

        // IL-415 Don't resolve path because it will have the side effect
        // of resolving the alias which will cause the .framework to be
        // not copied correctly.
//        NSString *path = [[url path] stringByResolvingSymlinksInPath];
        NSString *path = [url path];
        if(!path) {
            NSLog(@"Ignoring URL that doesn't return a path: %@", url);
            continue;
        }
        
		// Skip SVN folders and atomic files (such as nib or rtfd)
		if([FileTool isPathSVNFolder:path]) {
			// skip descendents and the file together
			[de skipDescendents];
			continue;
		} else if([[FileTool shared] isFileAtomic:path]) {
			// skip descendents but add this file
			[de skipDescendents];
		}
        
        // Ignore this specific folder
        if([[path lastPathComponent] isEqualToString:@"Resources Disabled"]) {
			[de skipDescendents];			
            continue;
		}
        
        if ([ILContext shared].runningUnitTests) {
            // Hack to ensure these two paths are the same (this happen only during unit testing)
            if ([path hasPrefix:@"/private/var"] && [source hasPrefix:@"/var"]) {
                path = [path substringFromIndex:@"/private".length];
            }
        }

		// Make a relative path		
		NSString *relativePath = [path stringByRemovingPrefixIgnoringCase:source];
		if([relativePath length] > 0 && [relativePath characterAtIndex:0] == '/') {
			relativePath = [relativePath substringFromIndex:1];
		}		
        if(relativePath) {
            [files addObject:relativePath];            
        } else {
            NSLog(@"Ignoring URL because a relative path cannot be extracted: %@ with source %@", path, source);
            continue;
        }
	}
	
	// Sort the paths in reverse order so the parent path are copied last and will be ignored
	// if they already exist on the disk because a child file was copied.
	[files sortUsingComparator:(NSComparator)^(id obj1, id obj2){
		return [obj2 compare:obj1]; 
	}];
	
	return YES;
}

- (BOOL)exclude:(BOOL)exclude languages:(NSArray*)languages files:(NSMutableArray*)files
{
	int index = 0;
	while(index < files.count) {
		NSString *relativePath = files[index];
		NSString *languageOfPath = [LanguageTool languageOfFile:relativePath];
		if([languageOfPath length] > 0) {
			BOOL found = NO;
			for(NSString *selectedLanguage in languages) {
				if ([selectedLanguage isEquivalentToLanguage:languageOfPath]) {
					found = YES;
					break;
				}
			}
			
			// Exclude mode: ignore files belonging to the languages
			if(exclude && found) {
				[files removeObjectAtIndex:index];
				continue;
			}
			
			// Include mode: ignore files NOT belonging to any of the languages
			if(!exclude && !found) {
				[files removeObjectAtIndex:index];
				continue;
			}
		}			
		index++;
	}
	return YES;
}

- (BOOL)excludeLocalizedFilesFromLanguages:(NSArray*)languages files:(NSMutableArray*)files
{
	return [self exclude:YES languages:languages files:files];
}

- (BOOL)includeLocalizedFilesFromLanguages:(NSArray*)languages files:(NSMutableArray*)files
{
	return [self exclude:NO languages:languages files:files];
}

- (BOOL)excludeNonLocalizedFiles:(NSMutableArray*)files
{
	int index = 0;
	while(index < files.count) {
		NSString *relativePath = files[index];
		NSString *languageOfPath = [LanguageTool languageOfFile:relativePath];
		if([languageOfPath length] == 0) {
			// Remove file because it doesn't belong to any language
			[files removeObjectAtIndex:index];
			continue;			
		}			
		index++;
	}
	return YES;	
}

- (BOOL)excludeFiles:(NSMutableArray*)files notInPaths:(NSArray*)pathPrefixes
{
	int index = 0;
	while(index < files.count) {
		NSString *relativePath = files[index];
		BOOL found = NO;
		for(NSString *prefixPath in pathPrefixes) {
			if([relativePath hasPrefix:prefixPath]) {
				found = YES;
				break;
			}
		}
		if(!found) {
			// Remove file because it doesn't belong to any path
			[files removeObjectAtIndex:index];
			continue;						
		}
		index++;
	}
	return YES;	
}

- (BOOL)normalizeLanguages:(NSArray*)languages files:(NSMutableArray*)files
{
	int index = 0;
	while(index < files.count) {
		NSString *relativePath = files[index];
		NSString *languageOfPath = [LanguageTool languageOfFile:relativePath];
		if([languageOfPath length] > 0) {
			NSString *iso = [languageOfPath isoLanguage];
			NSString *isoRelativePath = [FileTool translatePath:relativePath toLanguage:iso];
			files[index] = isoRelativePath;
		}			
		index++;
	}	
	return YES;
}

- (BOOL)copyFiles:(NSArray*)files source:(NSString*)_source target:(NSString*)_target errorHandler:(BOOL (^)(NSError *error))handler
{
	return [self copyFiles:files source:_source target:_target errorHandler:handler progressHandler:nil];
}

- (BOOL)copyFiles:(NSArray*)files source:(NSString*)_source target:(NSString*)_target errorHandler:(BOOL (^)(NSError *error))handler progressHandler:(void (^)(NSString *source, NSString *target))progress
{
	NSFileManager *fm = [NSFileManager defaultManager];
	for(NSString* relativePath in files) {
		NSString *source = [_source stringByAppendingPathComponent:relativePath];
		NSString *target = [_target stringByAppendingPathComponent:relativePath];
		
		if(progress) {
			progress(source, target);
		}
		
		// Don't copy the path if it already exists at the destination. This happens
		// when a path was copied and then one of its parent is copied.
		if([target isPathExisting]) continue;
		
		// Check if the source path exists.
		if(![source isPathExisting]) {
			// It is possible for the source path to be missing if the languages were normalized.
			// Let's try to find the source using the alternate language names.
			source = [FileTool resolveEquivalentFile:source];
		}
		
		// Copy the file only if it exists
		if([source isPathExisting]) {			
			[[FileTool shared] preparePath:target atomic:YES skipLastComponent:YES];
			NSError *error = nil;
			if(![fm copyItemAtPath:source toPath:target error:&error]) {
				NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
				dic[@"Cause"] = [NSString stringWithFormat:@"Cannot copy file %@ to %@", source, target];
				NSError *fullError = [NSError errorWithDomain:error.domain code:error.code userInfo:dic];
				if(handler) {
					if(handler(fullError)) continue;
				}
				return NO;
			}				
		} else {
			NSMutableDictionary *dic = [NSMutableDictionary dictionary];
			dic[@"Cause"] = [NSString stringWithFormat:@"Cannot find source file %@", source];
			NSError *fullError = [NSError errorWithDomain:ILErrorDomain code:100 userInfo:dic];
			if(handler) {
				if(handler(fullError)) continue;
			}
			return NO;
		}			
	}
	
	return YES;
}

@end
