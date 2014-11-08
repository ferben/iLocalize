//
//  Toolbar.h
//  iLocalize3
//
//  Created by Jean on 27.03.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@interface Toolbar : NSObject<NSToolbarDelegate> {
	NSWindow			*mWindow;
	NSToolbar			*mToolbar;
	NSMutableDictionary	*mViewDic;
	NSMutableArray		*mIdentifiers;

	BOOL				mResizeContent;
	id					mDelegate;
}

- (void)setResizeContent:(BOOL)resize;

- (void)setDelegate:(id)delegate;
- (void)setWindow:(NSWindow*)window;

- (void)addIdentifier:(NSString*)identifier;
- (void)addView:(NSView*)view image:(NSImage*)image identifier:(NSString*)ident name:(NSString*)name;
- (void)setupToolbarWithIdentifier:(NSString*)identifier displayMode:(NSToolbarDisplayMode)displayMode;

- (void)selectViewWithIdentifier:(NSString*)ident;

@end
