//
//  TreeNode.h
//  iLocalize3
//
//  Created by Jean on 18.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@interface TreeNode : NSObject {
	NSString		*mTitle;
	BOOL			mIsLeaf;
	BOOL			mIsRoot;
	TreeNode		*mParentNode;
	NSMutableArray	*mNodes;
	id				payload;
}

@property (strong) id payload;

+ (TreeNode*)rootNode;
+ (TreeNode*)leafNode;
+ (TreeNode*)node;
+ (TreeNode*)nodeWithTitle:(NSString*)title;

- (void)setTitle:(NSString*)title;
- (NSString*)title;

- (int)numberOfNodes;
- (void)addNode:(TreeNode*)node;
- (void)addNodes:(NSArray*)nodes;
- (void)deleteNode:(TreeNode*)node;
- (void)deleteAllNodes;
- (TreeNode*)nodeAtIndex:(int)index;
- (NSMutableArray*)nodes;

- (TreeNode*)rootNode;

- (void)setParentNode:(TreeNode*)parentNode;
- (TreeNode*)parentNode;

- (void)setIsLeaf:(BOOL)leaf;
- (BOOL)isLeaf;

- (void)setIsRoot:(BOOL)root;
- (BOOL)isRoot;

@end
