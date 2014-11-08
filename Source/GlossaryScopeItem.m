//
//  GlossaryScopeItem.m
//  iLocalize
//
//  Created by Jean Bovet on 1/29/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "GlossaryScopeItem.h"
#import "Glossary.h"

@implementation GlossaryScopeItem

@synthesize state;
@synthesize glossary;
@synthesize folder;
@synthesize icon;

+ (GlossaryScopeItem*)itemWithGlossary:(Glossary*)g state:(int)state icon:(NSImage*)icon
{
	GlossaryScopeItem *item = [[GlossaryScopeItem alloc] init];
	item.glossary = g;
	item.state = state;
	item.icon = icon;
	return item;
}

+ (GlossaryScopeItem*)itemWithFolder:(GlossaryFolder*)f state:(int)state icon:(NSImage*)icon
{
	GlossaryScopeItem *item = [[GlossaryScopeItem alloc] init];
	item.folder = f;
	item.state = state;
	item.icon = icon;
	return item;	
}

@end
