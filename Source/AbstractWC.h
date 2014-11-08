//
//  AbstractWC.h
//  iLocalize3
//
//  Created by Jean on 06.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"

@class ProjectController;

@interface AbstractWC : NSWindowController {
	NSWindow				*mParentWindow;
	
	SEL						mDidOKSelector;
	id						mDidOKTarget;
	
	SEL						mDidCloseSelector;
	id						mDidCloseTarget;
	
	int						mHideCode;
	BOOL					mClosed;
	
	CallbackBlock			didCloseCallback;
}

@property (copy) CallbackBlock didCloseCallback;
@property (weak) id<ProjectProvider> projectProvider;

- (void)setParentWindow:(NSWindow*)window;
- (NSWindow*)parentWindow;

- (IBAction)cancel:(id)sender;
- (IBAction)ok:(id)sender;

- (int)hideCode;

- (void)setDidOKSelector:(SEL)selector target:(id)target;
- (void)setDidCloseSelector:(SEL)selector target:(id)target;

- (void)showAsSheet;
- (void)showAndCenter:(BOOL)center;
- (void)show;
- (void)showModal;

- (void)hide;
- (void)hideWithCode:(int)code;

- (BOOL)isVisible;

@end
