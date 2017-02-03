//
//  OperationProgressViewController.m
//  iLocalize
//
//  Created by Jean Bovet on 2/12/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationProgressViewController.h"
#import "Operation.h"

@implementation OperationProgressViewController

+ (OperationProgressViewController*)createWithOperation:(Operation*)op
{
    OperationProgressViewController *vc = [[self alloc] init];
    op.operationProgressVC = vc;
    vc.operation = op;
    return vc;
}

- (id)init
{
    if((self = [super initWithNibName:@"OperationProgress"])) {
        // Need to load the view now so the outlets are ready because
        // some methods can be invoked before the view is displayed
        // (e.g. setOperationName() so we need to have the outlets in place
        // for that.
        [self view];
    }
    return self;
}

- (void)dealloc
{
    self.operation = nil;
}

- (void)willShow
{
    [progressIndicator startAnimation:self];
    [cancelButton setEnabled:[self.operation cancellable]];
}

- (void)setOperationName:(NSString*)name
{
    [nameField performSelectorOnMainThread:@selector(setStringValue:) withObject:name waitUntilDone:NO];
}

- (void)setOperationProgress:(float)progress
{
    [self performSelectorOnMainThread:@selector(setProgressInMainThread:) withObject:@(progress) waitUntilDone:NO];
}

- (void)setProgressInMainThread:(NSNumber*)progress
{
    [progressIndicator setIndeterminate:NO];
    [progressIndicator setMinValue:0];
    [progressIndicator setMaxValue:1];
    [progressIndicator setDoubleValue:[progress floatValue]];    
}

- (IBAction)cancel:(id)sender
{
    self.operation.cancel = YES;
}

@end
