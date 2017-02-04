//
//  FileMergeOperationManager.h
//  iLocalize
//
//  Created by Jean Bovet on 6/28/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

/**
 This class handles the merging operation of a set of files
 into a target directory.
 */
@interface FileMergeOperationManager : NSObject
{
    @private
}

/**
 Returns a new instance of the manager.
 */
+ (FileMergeOperationManager *)manager;

/**
 Discovers all the files that can be merged. A file can be merged (that is, replaced by its project file correspondant) only if:
 1) The file has a project file correspondant (obviously)
 2) The file and its correspondant are not equals.
 3) The file is a localized file (inside a language project)
 This method allows to merge a project into a Finder directory by replacing only the localized files that have changed.
 
 @param mergeableFiles An array of files that can be merged safely (array of relative path to the project)
 @param target The target directory where the merge will happen
 @param projectFiles The project source files
 @param source Project absolute source path
 @return YES if the discovery was successfull, NO otherwise

 */
- (BOOL)discoverMergeableFiles:(NSMutableArray *)mergeableFiles inTarget:(NSString *)target usingProjectFiles:(NSArray *)projectFiles projectSource:(NSString *)source errorHandler:(BOOL (^)(NSURL *url, NSError *error))handler;

/**
 Perform the actually merging of the specified project files inside the target. The merging here means that each project file
 is going to replace the target file if, and only if, it exists and is different than the project file.
 @param projectFiles Array of relative path to the project
 @param source Project absolute source path
 @param target Target absolute path
 */
- (void)mergeProjectFiles:(NSArray *)projectFiles projectSource:(NSString *)source inTarget:(NSString *)target errorHandler:(BOOL (^)(NSError *error))handler progressHandler:(void (^)(NSString *source, NSString *target))progress;

@end
