//
//  OperationDispatcher.h
//  iLocalize3
//
//  Created by Jean on 06.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"
#import "OperationDriver.h"

@class ProjectController;
@class FileController;
@class NewProjectSettings;
@class FindAttributes;
@class ImportBundlePreviewOp;
@class ImportDiff;
@class Operation;

typedef void(^OperationDispatcherCompletionBlock)(id results);

/**
 This class manages the execution of an operation in a background thread.
 */
@interface OperationDispatcher : NSObject
{
}

@property (weak) id<ProjectProvider> projectProvider;

- (void)dispatch:(Operation *)op callback:(OperationCompletionCallbackBlock)callback;

- (void)addLanguage:(NSString *)language completion:(OperationDispatcherCompletionBlock)completion;
- (void)renameLanguage:(NSString *)source toLanguage:(NSString *)target completion:(OperationDispatcherCompletionBlock)completion;
- (void)removeLanguage:(NSString *)language completion:(OperationDispatcherCompletionBlock)completion;

- (void)addFiles:(NSArray *)files language:(NSString *)language toSmartPath:(NSString *)smartPath completion:(OperationDispatcherCompletionBlock)completion;
- (void)removeFileControllers:(NSArray *)fileControllers completion:(OperationDispatcherCompletionBlock)completion;

- (void)replaceLocalizedFileControllersWithCorrespondingBase:(NSArray *)fileControllers keepLayout:(BOOL)layout completion:(OperationDispatcherCompletionBlock)completion;

- (void)synchronizeFileControllers:(NSArray *)fileControllers completion:(OperationDispatcherCompletionBlock)completion;

- (void)cleanWithAttributes:(NSDictionary *)attributes completion:(OperationDispatcherCompletionBlock)completion;
- (void)checkProjectLanguages:(NSArray *)languages completion:(OperationDispatcherCompletionBlock)completion;

@end
