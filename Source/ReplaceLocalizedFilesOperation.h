//
//  ReplaceLocalizedFilesOperation.h
//  iLocalize3
//
//  Created by Jean on 09.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractOperation.h"

@interface ReplaceLocalizedFilesOperation : AbstractOperation
{
    NSArray  *mFileControllers;
}

- (void)replaceLocalizedFileControllersFromCorrespondingBase:(NSArray *)controllers;

@end
