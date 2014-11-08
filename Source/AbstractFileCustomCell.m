//
//  AbstractFileCustomCell.m
//  iLocalize3
//
//  Created by Jean on 04.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractFileCustomCell.h"
#import "PreferencesGeneral.h"

@implementation AbstractFileCustomCell

- (FileController*)fileController
{
	return [[self objectValue] nonretainedObjectValue];
}

@end
