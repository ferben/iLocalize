//
//  DragAndDropOperation.h
//  iLocalize3
//
//  Created by Jean on 10.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractOperation.h"

@class WindowLayerWC;

@interface DragAndDropOperation : AbstractOperation
{
    WindowLayerWC         *mWindowLayerWC;
    NSMutableDictionary   *mParameters;
    int                    mOperation;
    BOOL                   mOptionKeyMask;
    
    NSMutableArray        *mFilterApplicationPathsCache;
    NSMutableArray        *mFilterResourcePathsCache;
}

- (void)modifierFlagsChanged:(NSEvent *)event;
- (NSDragOperation)dragOperationEnteredForPasteboard:(NSPasteboard *)pboard;
- (NSDragOperation)dragOperationUpdatedForPasteboard:(NSPasteboard *)pboard;
- (BOOL)dragOperationPerformWithPasteboard:(NSPasteboard *)pboard;
- (void)dragOperationEnded;

@end
