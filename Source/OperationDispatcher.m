//
//  OperationDispatcher.m
//  iLocalize3
//
//  Created by Jean on 06.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "OperationDispatcher.h"

#import "LanguageEngine.h"
#import "ImportBundlePreviewOp.h"
#import "ReplaceEngine.h"
#import "OptimizeEngine.h"
#import "SynchronizeEngine.h"
#import "FileEngine.h"
#import "FindEngine.h"
#import "CleanEngine.h"
#import "CheckEngine.h"
#import "ExportProjectOperation.h"

#import "ProjectController.h"

#import "Console.h"
#import "ConsoleItem.h"
#import "Operation.h"
#import "OperationWC.h"
#import "OperationReportWC.h"

#import "BackgroundUpdater.h"

typedef id(^DispatchBlock)();

@implementation OperationDispatcher

- (id)init
{
    if (self = [super init])
    {
    }
    
    return self;
}

- (EngineProvider *)engineProvider
{
    return [[self projectProvider] engineProvider];
}

- (Console *)console
{
    return [[self projectProvider] console];
}

- (OperationWC *)operationWC
{
    return [[self projectProvider] operation];
}

- (void)dispatch:(Operation *)op callback:(OperationCompletionCallbackBlock)callback
{
    [self dispatchOperation:op callback:callback];
}

#pragma mark -

- (void)addLanguage:(NSString *)language completion:(OperationDispatcherCompletionBlock)completion
{
    [self dispatchBlock:^id
    {
        [[[self engineProvider] languageEngine] addLanguage:language];
        return nil;
    } completion:completion];
}

- (void)renameLanguage:(NSString *)source toLanguage:(NSString *)target completion:(OperationDispatcherCompletionBlock)completion
{
    [self dispatchBlock:^id
    {
        [[[self engineProvider] languageEngine] renameLanguage:source
                                                    toLanguage:target];
        return nil;
    } completion:completion];
}

- (void)removeLanguage:(NSString *)language completion:(OperationDispatcherCompletionBlock)completion
{
    [self dispatchImmediatelyBlock:^id
    {
        [[[self engineProvider] languageEngine] removeLanguage:language];
        return nil;
    } completion:completion];
}

#pragma mark -

- (void)addFiles:(NSArray *)files language:(NSString *)language toSmartPath:(NSString *)smartPath completion:(OperationDispatcherCompletionBlock)completion
{
    [self dispatchImmediatelyBlock:^id
    {
        [[[self engineProvider] fileEngine] addFiles:files
                                            language:language
                                         toSmartPath:smartPath];
        return nil;
    } completion:completion];
}

- (void)removeFileControllers:(NSArray *)fileControllers completion:(OperationDispatcherCompletionBlock)completion
{
    [self dispatchImmediatelyBlock:^id
    {
        [[[self engineProvider] fileEngine] deleteFileControllers:fileControllers];
        return nil;
    } completion:completion];
}

#pragma mark -

- (void)synchronizeFileControllers:(NSArray *)fileControllers completion:(OperationDispatcherCompletionBlock)completion
{
    [self dispatchBlock:^id
    {
        [[[self engineProvider] synchronizeEngine] synchronizeFileControllers:fileControllers];
        return nil;
    } completion:completion];
}

#pragma mark -

- (void)replaceLocalizedFileControllersWithCorrespondingBase:(NSArray *)fileControllers keepLayout:(BOOL)layout completion:(OperationDispatcherCompletionBlock)completion
{
    [self dispatchImmediatelyBlock:^id
    {
        [[[self engineProvider] replaceEngine] replaceLocalizedFileControllersWithCorrespondingBase:fileControllers
                                                                                         keepLayout:layout];
        return nil;
    } completion:completion];
}

#pragma mark -

- (void)cleanWithAttributes:(NSDictionary *)attributes completion:(OperationDispatcherCompletionBlock)completion
{
    [self dispatchBlock:^id
    {
        [[[self engineProvider] cleanEngine] cleanWithAttributes:attributes];
        return nil;
    } completion:completion];
}

#pragma mark -

- (void)checkProjectLanguages:(NSArray *)languages completion:(OperationDispatcherCompletionBlock)completion
{
    [self dispatchBlock:^
    {
        NSUInteger warnings = [[[self engineProvider] checkEngine] checkLanguages:languages];
        
        return @(warnings);
    } completion:completion];
}

#pragma mark -

- (void)dispatchOperation:(Operation *)op callback:(OperationCompletionCallbackBlock)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        @autoreleasepool
        {
            [self executeOperation:op operationCallback:callback block:nil completion:nil];
        }
    });
}

- (void)dispatchBlock:(DispatchBlock)block completion:(OperationDispatcherCompletionBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
    {
        @autoreleasepool
        {
            [self executeOperation:nil operationCallback:nil block:block completion:completion];
        }
    });
}

- (void)dispatchImmediatelyBlock:(DispatchBlock)block completion:(OperationDispatcherCompletionBlock)completion
{
    [self executeOperation:nil operationCallback:nil block:block completion:completion];
}

- (void)executeOperation:(Operation *)operation
       operationCallback:(OperationCompletionCallbackBlock)operationCallback
                   block:(DispatchBlock)block
              completion:(OperationDispatcherCompletionBlock)completion
{
    if (operation)
    {
        [[NSThread currentThread] setName:[NSString stringWithFormat:@"%@", operation]];
    }
        
    // Note: the provider can be NULL only for the operations triggered from the New Project assistant
    // because the project does not exist.
    [self.projectProvider beginOperation];

    // Note: lock the background task during an operation to avoid any problem
    BOOL backgroundThreadLocked = NO;
    
    if (![[BackgroundUpdater shared] tryLockFor:5])
    {
        NSLog(@"Background updater thread still running after 5 seconds. Wait 20s more.");
        
        if (![[BackgroundUpdater shared] tryLockFor:20])
        {
            NSLog(@"Failed to acquire BackgroundUpdater lock for 20 seconds. Continue to process thread.");
        }
        else
        {
            backgroundThreadLocked = YES;
        }
    }
    else
    {
        backgroundThreadLocked = YES;
    }

    
    // Record all new entries in the console
    [[self console] mark];
    
    id results = nil;
    
    @try
    {
        if (operation)
        {
            [operation execute];
        }
        else if (block)
        {
            results = block();
        }
    }
    @catch (id exception)
    {
        [exception printStackTrace];
        
        if (operation)
        {
            [operation notifyException:exception];
        }
        else
        {
            [[self console] addError:[exception reason]
                         description:[NSString stringWithFormat:@"Exception in operation thread: %@", exception]
                               class:[self class]];                    
        }
    }
    @finally
    {
        if (backgroundThreadLocked)
        {
            [[BackgroundUpdater shared] unlock];        
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [self.projectProvider endOperation];
            [self finishExecutionWithResults:results operation:operation operationCallback:operationCallback completion:completion];
        });
    }
}

- (void)finishExecutionWithResults:(id)results
                         operation:(Operation *)operation
                 operationCallback:(OperationCompletionCallbackBlock)operationCallback
                        completion:(OperationDispatcherCompletionBlock)completion
{
    // Called in main thread
    
    BOOL cancelled = [[self operationWC] shouldCancel];
    
    if (cancelled)
    {
        [[self console] addLog:@"Operation cancelled by user" class:[self class]];        
    }
    
    Console *console = [self console];
    
    if ([console hasWarningsOrErrors])
    {
        if (operation)
        {
            // Report the errors at the operation driver WC level instead of displaying an ugly modal dialog
            for (ConsoleItem *item in [console allItemsSinceMark])
            {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[NSLocalizedDescriptionKey] = [item description];
                
                NSError *error = [NSError errorWithDomain:ILErrorDomain code:100 userInfo:dic];
                
                if ([item isWarning])
                {
                    [operation notifyWarning:error];
                }
                else
                {
                    [operation notifyError:error];
                }
            }
        }
        else
        {
            [OperationReportWC showConsoleIfWarningsOrErrorsSinceLastMark:[self console]];        
        }        
    }
    
    if (operationCallback)
    {
        int state = operation.cancel ? OPERATION_CANCEL : OPERATION_NEXT;
        operationCallback(state);
    }
    else if (completion)
    {
        completion(results);
    }
}

@end
