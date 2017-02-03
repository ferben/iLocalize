//
//  Operation.m
//  iLocalize
//
//  Created by Jean Bovet on 2/12/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "Operation.h"
#import "OperationDriver.h"
#import "OperationProgressViewController.h"

@implementation Operation

@synthesize driver;
@synthesize operationProgressVC;
@synthesize projectProvider;
@synthesize cancel;
@synthesize mainOperation;

+ (Operation *)operation
{
    return [[self alloc] init];
}

- (id) init
{
    self = [super init];
    
    if (self != nil)
    {
        errors = [[NSMutableArray alloc] init];
        warnings = [[NSMutableArray alloc] init];
        alerts = [[NSMutableArray alloc] init];
    }
    
    return self;
}


#pragma mark Properties

- (ProjectController *)projectController
{
    return [self.projectProvider projectController];
}

- (ProjectModel *)projectModel
{
    return [self.projectProvider projectModel];
}

- (EngineProvider *)engineProvider
{
    return [self.projectProvider engineProvider];
}

- (Console *)console
{
    return [self.projectProvider console];
}

#pragma mark Operations

- (void)setSubOperation:(Operation *)subop
{
    subop.projectProvider = self.projectProvider;    
    subop.mainOperation = self;
}

- (void)setOperationName:(NSString *)name
{
    if (self.mainOperation)
    {
        [self.mainOperation setOperationName:name];
    }
    else
    {
        [self.operationProgressVC setOperationName:name];
    }
}

- (void)setOperationProgress:(float)value
{
    if (self.mainOperation)
    {
        [self.mainOperation setOperationProgress:value];
    }
    else
    {
        [self.operationProgressVC setOperationProgress:value];
    }
}

- (void)setProgressMax:(NSUInteger)max
{
    progressMax = max;
    progress = 0;
    
    [self setOperationProgress:(float)progress / progressMax];
}

- (void)progressIncrement
{
    progress++;
    [self setOperationProgress:(float)progress / progressMax];
}

- (BOOL)needsDisconnectInterface
{
    return NO;
}

- (void)notifyNewProjectProvider:(id<ProjectProvider>)provider
{
    self.projectProvider = provider;
    [driver notifyNewProjectProvider:provider];
}

- (void)notifyProjectDidBecomeDirty
{
    [((NSObject *)self.projectProvider) performSelectorOnMainThread:@selector(setDirty) withObject:nil waitUntilDone:YES];
}

- (NSArray *)errors
{
    return errors;
}

- (void)notifyException:(NSException *)exception
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[NSLocalizedDescriptionKey] = [exception reason];

    NSError *error = [NSError errorWithDomain:ILErrorDomain code:100 userInfo:dic];
    [self notifyError:error];
}

- (void)notifyError:(NSError *)error
{
    if (error)
    {
        [errors addObject:error];
    }
}

- (NSArray *)warnings
{
    return warnings;
}

- (void)notifyWarning:(NSError *)error
{
    if (error)
    {
        [warnings addObject:error];
    }
}

- (NSArray *)alerts
{
    return alerts;
}

- (void)reportInformativeAlertWithTitle:(NSString *)title message:(NSString *)message
{
    [alerts addObject:@{@"title": title, @"message": message}];
}

#pragma mark Subclass

- (void)execute
{
    NSLog(@"!!! This execute() method must be implemented by %@", self);
}

- (void)willExecute 
{
    
}

- (void)didExecute
{
    
}

- (BOOL)cancellable
{
    return NO;
}

@end
