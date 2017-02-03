//
//  AbstractStringCustomCell.m
//  iLocalize3
//
//  Created by Jean on 04.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractStringCustomCell.h"

@implementation AbstractStringCustomCell

- (StringController *)stringController
{
    return [self representedObject];
}

@end
