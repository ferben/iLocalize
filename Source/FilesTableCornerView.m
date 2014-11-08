//
//  FilesTableCornerView.m
//  iLocalize3
//
//  Created by Jean on 08.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FilesTableCornerView.h"

#import "ProjectWC.h"

#import "TableViewCustom.h"

@implementation FilesTableCornerView

- (id)initWithMenu:(NSMenu*)menu
{
	if(self = [super init]) {
		mMenu = menu;
	}
	return self;
}

+ (id)cornerWithMenu:(NSMenu*)menu
{
	return [[self alloc] initWithMenu:menu];
}

- (NSMenu*)popupMenu
{
	return mMenu;
}

- (NSString*)cornerImage
{
	return @"TableViewCornerIcon";
}

@end
