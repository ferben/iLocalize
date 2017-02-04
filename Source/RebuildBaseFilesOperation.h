//
//  RebuildBaseFilesOperation.h
//  iLocalize3
//
//  Created by Jean on 12/10/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "AbstractOperation.h"

@interface RebuildBaseFilesOperation : AbstractOperation
{
    NSArray  *mFileControllers;
}

- (void)rebuildBaseFileControllers:(NSArray *)controllers;

@end
