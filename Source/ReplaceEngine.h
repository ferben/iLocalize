//
//  ReplaceEngine.h
//  iLocalize3
//
//  Created by Jean on 13.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractEngine.h"

@class FileController;

@interface ReplaceEngine : AbstractEngine
{
}

- (void)replaceLocalizedFileControllersWithCorrespondingBase:(NSArray *)fileControllers keepLayout:(BOOL)layout;
- (void)replaceLocalizedFileControllerAndCheckAgainWithCorrespondingBase:(FileController *)fileController keepLayout:(BOOL)layout;
- (void)replaceLocalizedFileControllerWithCorrespondingBase:(FileController *)fileController keepLayout:(BOOL)layout;

@end
