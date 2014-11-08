//
//  GlossaryScopeItem.h
//  iLocalize
//
//  Created by Jean Bovet on 1/29/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@class Glossary;
@class GlossaryFolder;

/**
 Class that groups the attributes of a single scope item.
 */
@interface GlossaryScopeItem : NSObject {
	NSInteger state;
	Glossary *glossary;
	GlossaryFolder *folder;
	NSImage *icon;
}

@property (assign) NSInteger state;
@property (strong) Glossary *glossary;
@property (strong) GlossaryFolder *folder;
@property (strong) NSImage *icon;

+ (GlossaryScopeItem*)itemWithGlossary:(Glossary*)g state:(int)state icon:(NSImage*)icon;
+ (GlossaryScopeItem*)itemWithFolder:(GlossaryFolder*)f state:(int)state icon:(NSImage*)icon;

@end
