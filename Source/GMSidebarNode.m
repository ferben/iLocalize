//
//  GMSidebarNode.m
//  iLocalize
//
//  Created by Jean on 3/29/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "GMSidebarNode.h"
#import "GlossaryFolder.h"
#import "GlossaryManager.h"
#import "ProjectDocument.h"

@implementation GMSidebarNode

@synthesize title=_title;
@synthesize folder=_folder;
@synthesize children=_children;

+ (GMSidebarNode*)projectGroup
{
	GMSidebarNode *node = [[GMSidebarNode alloc] init];
	node.title = NSLocalizedString(@"PROJECTS", @"Glossary Manager 'Projects' node");
	return node;	
}

+ (GMSidebarNode*)globalGroup
{
	GMSidebarNode *node = [[GMSidebarNode alloc] init];
	node.title = NSLocalizedString(@"GLOBAL FOLDERS", @"Glossary Manager 'Global Folders' node");
	node->_globalGroup = YES;
	return node;	
}

+ (GMSidebarNode*)nodeWithPath:(GlossaryFolder*)folder
{
	GMSidebarNode *node = [[GMSidebarNode alloc] init];
	node.folder = folder;
	return node;	
}

+ (GMSidebarNode*)nodeWithProjectDocument:(ProjectDocument*)doc
{
	GlossaryFolder *folder = [[[GlossaryManager sharedInstance] foldersForProject:doc] firstObject];
	GMSidebarNode *node = [GMSidebarNode nodeWithPath:folder];
	node.document = doc;
	return node;
}

- (id)init
{
	if(self = [super init]) {
		_globalGroup = NO;
		_title = nil;
		_folder = nil;
		_children = [[NSMutableArray alloc] init];
	}
	return self;
}


- (NSString*)title
{
	if([self isGroup]) {
		return _title;
	} else {
		if(self.document) {
			return [self.document applicationExecutableName];
		} else {
			return [self.folder name];			
		}
	}
}

- (NSImage*)image
{
	NSString *path = self.folder.path;
	if(self.document) {
		path = [self.document sourceApplicationPath];
	}
	return [[NSWorkspace sharedWorkspace] iconForFile:path];
}

- (BOOL)isGlobal
{
	return ![self isGroup] && self.document == nil;
}

- (BOOL)isGroup
{
	return _title != nil;
}

- (BOOL)isGlobalGroup
{
	return _globalGroup;
}

- (BOOL)isEqual:(id)anObject
{	
	if(![anObject isKindOfClass:[GMSidebarNode class]]) {
		return NO;
	}

	if([self isGroup]) {
		return [self.title isEqual:[anObject title]];
	} else if([self isGlobal]) {
		return [self.folder isEqual:[anObject folder]];		
	} else {
		return [self.document isEqual:[anObject document]];
	}
}

- (NSUInteger)hash
{
	if([self isGroup]) {
		return [self.title hash];
	} else if([self isGlobal]) {
		return [self.folder hash];
	} else {
		return [self.document hash];
	}	
}

- (NSString*)description
{
	if([self isGroup]) {
		return [NSString stringWithFormat:@"Node group %@", self.title];
	} else if([self isGlobal]) {
		return [NSString stringWithFormat:@"Node global %@", self.folder];
	} else {
		return [NSString stringWithFormat:@"Node document %@", self.document];
	}	
}

@end
