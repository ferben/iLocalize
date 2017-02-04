//
//  FilterBundleOp.h
//  iLocalize
//
//  Created by Jean Bovet on 5/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "Operation.h"

@class AZPathNode;

/**
 This operation takes as input a path and returns an AZPathNode that represents the tree of all
 the files and folders inside the input path. 
 */
@interface ScanBundleOp : Operation
{
    /**
     The source path.
     */
    NSString    *path;

    /**
     The node representing the source path content.
     */
    AZPathNode  *node;
}

@property (strong) NSString *path;
@property (strong) AZPathNode *node;

@end
