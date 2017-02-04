//
//  AZSplitView.h
//  iLocalize
//
//  Created by Jean on 12/27/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "Stack.h"

@class AZAnimationRequest;

@interface AZSplitView : NSSplitView
{
    CGFloat              mPreviousPosition;
    NSString            *title;
    
    // Last rectangle of the divider
    NSRect               dividerRect;
    
    // The action menu is displayed in the thumbnail view
    NSMenu              *actionMenu;

    // List of requests to collapse or expand the split view
    NSMutableArray      *requests;
    
    // Current request being executed
    AZAnimationRequest  *currentRequest;
}

@property (strong) NSString *title;
@property (strong) NSMenu *actionMenu;
@property (strong) AZAnimationRequest *currentRequest;

- (CGFloat)bottomExpandedHeight;

- (void)collapse:(BOOL)collapse animation:(BOOL)animation completionBlock:(CallbackBlock)block;

@end
