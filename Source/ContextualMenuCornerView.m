//
//  ContextualMenuCornerView.m
//  iLocalize3
//
//  Created by Jean on 12/14/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "ContextualMenuCornerView.h"

#import "ProjectWC.h"

#import "TableViewCustom.h"

@implementation ContextualMenuCornerView

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
