//
//  ProjectWindowProtocol.h
//  iLocalize
//
//  Created by Jean on 12/24/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

@protocol ProjectWindowProtocol <NSWindowDelegate>

- (NSString*)toolTipAtPosition:(NSPoint)pos;

- (NSDragOperation)windowDragOperationEnteredForPasteboard:(NSPasteboard*)pboard;
- (NSDragOperation)windowDragOperationUpdatedForPasteboard:(NSPasteboard*)pboard;
- (BOOL)windowDragOperationPerformWithPasteboard:(NSPasteboard*)pboard;
- (void)windowTableViewDragOperationEnded;

@end
