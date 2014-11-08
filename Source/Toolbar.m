//
//  PreferencesToolbar.m
//  iLocalize3
//
//  Created by Jean on 27.03.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "Toolbar.h"

@implementation Toolbar

- (id)init
{
	if(self = [super init]) {
		mWindow = nil;
		mToolbar = nil;
		mViewDic = [[NSMutableDictionary alloc] init];
		mIdentifiers = [[NSMutableArray alloc] init];
		mDelegate = nil;
		mResizeContent = YES;
	}
	return self;
}


- (void)setResizeContent:(BOOL)resize
{
	mResizeContent = resize;
}

- (void)setDelegate:(id)delegate
{
	mDelegate = delegate;
}

- (void)setWindow:(NSWindow*)window
{
	mWindow = window;
}

- (void)addIdentifier:(NSString*)identifier
{
	[mIdentifiers addObject:identifier];
}

- (void)addView:(NSView*)view image:(NSImage*)image identifier:(NSString*)ident name:(NSString*)name
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"view"] = view;
	dic[@"image"] = image;
	dic[@"name"] = name;
	mViewDic[ident] = dic;	
}

#pragma mark -

- (void)setupToolbarWithIdentifier:(NSString*)identifier displayMode:(NSToolbarDisplayMode)displayMode
{	
    mToolbar = [[NSToolbar alloc] initWithIdentifier:identifier];
    
    [mToolbar setAllowsUserCustomization: NO];
    [mToolbar setAutosavesConfiguration: NO];
    [mToolbar setDisplayMode: displayMode];
    
    [mToolbar setDelegate: self];
    
    [mWindow setToolbar: mToolbar];	
}

- (NSToolbarItem *) toolbar: (NSToolbar *)toolbar itemForItemIdentifier: (NSString *) itemIdent willBeInsertedIntoToolbar:(BOOL) willBeInserted
{
    NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdent];
	
	NSDictionary *dic = mViewDic[itemIdent];
	if(dic) {
		NSSize itemSize = [dic[@"view"] frame].size;
		
		[toolbarItem setLabel:dic[@"name"]];
		[toolbarItem setPaletteLabel:dic[@"name"]];
		
		[toolbarItem setImage:dic[@"image"]];
		[toolbarItem setMinSize:itemSize];
		[toolbarItem setMaxSize:itemSize];
		
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(selectView:)];
		
		return toolbarItem;
	} else
		return nil;
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
{
	return mIdentifiers;	
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
	NSMutableArray *array = [NSMutableArray array];
	[array addObjectsFromArray:mIdentifiers];
	[array addObject:NSToolbarFlexibleSpaceItemIdentifier];
	[array addObject:NSToolbarSpaceItemIdentifier];
	[array addObject:NSToolbarSeparatorItemIdentifier];
	return array;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return mIdentifiers;
}

#pragma mark -

- (void)setContentView:(NSView*)view
{
	[mWindow setContentView:view resize:mResizeContent animate:NO];
}

- (void)selectView:(id)sender
{
	[self selectViewWithIdentifier:[sender itemIdentifier]];
}

- (void)selectViewWithIdentifier:(NSString*)ident
{
	[mToolbar setSelectedItemIdentifier:ident];	
	[self setContentView:mViewDic[ident][@"view"]];
	[mDelegate performSelector:@selector(toolbarDidSelectViewWithIdentifier:) withObject:ident];
}

@end
