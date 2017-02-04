//
//  GMSidebarNode.h
//  iLocalize
//
//  Created by Jean on 3/29/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

@class GlossaryFolder;
@class ProjectDocument;

@interface GMSidebarNode : NSObject
{
    BOOL             _globalGroup;
    NSString        *_title;
    GlossaryFolder  *_folder;
    NSMutableArray  *_children;
}

@property (nonatomic, strong) NSString *title;
@property (strong) GlossaryFolder *folder;
@property (weak) ProjectDocument *document;
@property (readonly) NSMutableArray *children;

+ (GMSidebarNode *)projectGroup;
+ (GMSidebarNode *)globalGroup;
+ (GMSidebarNode *)nodeWithPath:(GlossaryFolder *)folder;
+ (GMSidebarNode *)nodeWithProjectDocument:(ProjectDocument *)doc;

- (NSImage *)image;
- (BOOL)isGlobal;
- (BOOL)isGroup;
- (BOOL)isGlobalGroup;

@end
