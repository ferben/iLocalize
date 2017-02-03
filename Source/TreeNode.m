//
//  TreeNode.m
//  iLocalize3
//
//  Created by Jean on 18.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "TreeNode.h"

@implementation TreeNode

@synthesize payload;

+ (TreeNode*)rootNode
{
	TreeNode *node = [[self alloc] init];
	[node setIsRoot:YES];
	return node;
}

+ (TreeNode*)leafNode
{
	TreeNode *node = [[self alloc] init];
	[node setIsLeaf:YES];
	return node;	
}

+ (TreeNode*)node
{
	return [[self alloc] init];
}

+ (TreeNode*)nodeWithTitle:(NSString*)title
{
	TreeNode *node = [[self alloc] init];
	[node setTitle:title];
	return node;
}

- (id)init
{
	if(self = [super init]) {
		mTitle = NULL;
		mIsRoot = NO;
		mIsLeaf = NO;
		mParentNode = NULL;
		mNodes = NULL;
	}
	return self;
}


- (void)setTitle:(NSString*)title
{
	mTitle = title;
}

- (NSString*)title
{
	return mTitle;
}

- (NSUInteger)numberOfNodes
{
	return [mNodes count];
}

- (void)checkNodes
{
	if(mNodes == NULL)
		mNodes = [[NSMutableArray alloc] init];
}

- (void)addNode:(TreeNode*)node
{
	[self checkNodes];
	
	[node setParentNode:self];
	[mNodes addObject:node];
}

- (void)addNodes:(NSArray*)nodes
{
	[self checkNodes];
	
	[mNodes addObjectsFromArray:nodes];
}

- (void)deleteNode:(TreeNode*)node
{
	[mNodes removeObject:node];
}

- (void)deleteAllNodes
{
	[mNodes removeAllObjects];
}

- (TreeNode*)nodeAtIndex:(int)index
{
	return mNodes[index];
}

- (NSMutableArray*)nodes
{
	return mNodes;
}

- (TreeNode*)rootNode
{
	if([self isRoot])
		return self;
	else
		return [[self parentNode] rootNode];
}

- (void)setParentNode:(TreeNode*)parentNode
{
	mParentNode = parentNode;
}

- (TreeNode*)parentNode
{
	return mParentNode;
}

- (void)setIsLeaf:(BOOL)leaf
{
	mIsLeaf = leaf;
}

- (BOOL)isLeaf
{
	return mIsLeaf;
}

- (void)setIsRoot:(BOOL)root
{
	mIsRoot = root;
}

- (BOOL)isRoot
{
	return mIsRoot;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@{%@}", mTitle, mNodes];
}

@end
