//
//  WindowLayerWC.h
//  iLocalize3
//
//  Created by Jean on 08.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@class WindowLayerView;

@interface WindowLayerWC : NSWindowController {
	IBOutlet WindowLayerView	*mView;
	NSWindow					*mParentWindow;
	id							mDelegate;
}
- (void)setParentWindow:(NSWindow*)window;
- (void)setDelegate:(id)delegate;
- (void)setTitle:(NSString*)title;
- (void)setInfo:(NSString*)info;
- (void)show;
- (void)hide;
@end
