//
//  LineEndingsConverterOperation.h
//  iLocalize3
//
//  Created by Jean on 23.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractOperation.h"

@interface LineEndingsConverterOperation : AbstractOperation
{
    NSArray  *mFileControllers;
}

- (void)convertFileControllers:(NSArray *)fileControllers;

@end
