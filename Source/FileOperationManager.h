//
//  FileOperationManager.h
//  iLocalize
//
//  Created by Jean Bovet on 3/8/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

/**
 This class manages the file operations on a directory.
 */
@interface FileOperationManager : NSObject
{
}

+ (FileOperationManager *)manager;

/**
 Enumerates all the files in the source path and 
 creates the list of files to be processed.
 */
- (BOOL)enumerateDirectory:(NSString *)source files:(NSMutableArray *)files errorHandler:(BOOL (^)(NSURL *url, NSError *error))handler;

/**
 Excludes all the localized files that are in the specified languages.
 Non-localized files are not removed.
 */
- (BOOL)excludeLocalizedFilesFromLanguages:(NSArray *)languages files:(NSMutableArray *)files;

/**
 Includes all the localized files that are in the specified languages.
 Non-localized files are not removed.
 */
- (BOOL)includeLocalizedFilesFromLanguages:(NSArray *)languages files:(NSMutableArray *)files;

/**
 Excludes all non-localized files, that is, all the files not belonging to an lproj folder.
 */
- (BOOL)excludeNonLocalizedFiles:(NSMutableArray *)files;

/**
 Excludes all the files that do not belong to the specified array of paths.
 */
- (BOOL)excludeFiles:(NSMutableArray *)files notInPaths:(NSArray *)pathPrefixes;

/**
 Normalizes the specified languages. All the legacy names will become ISO names (e.g. "French" -> "fr").
 */
- (BOOL)normalizeLanguages:(NSArray *)languages files:(NSMutableArray *)files;

/**
 Copies the list of files from the source to the target.
 */
- (BOOL)copyFiles:(NSArray *)files source:(NSString *)_source target:(NSString *)_target errorHandler:(BOOL (^)(NSError *error))handler;
- (BOOL)copyFiles:(NSArray *)files source:(NSString *)source target:(NSString *)target errorHandler:(BOOL (^)(NSError *error))handler progressHandler:(void (^)(NSString *source, NSString *target))progress;

@end
