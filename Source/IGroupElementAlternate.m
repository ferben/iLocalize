//
//  IGroupElementAlternate.m
//  iLocalize
//
//  Created by Jean Bovet on 11/1/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroupElementAlternate.h"
#import "StringController.h"
#import "FileController.h"

@implementation IGroupElementAlternate

@synthesize score;
@synthesize file;

+ (IGroupElementAlternate*)elementWithDictionary:(NSDictionary*)dic
{
    IGroupElementAlternate *e = [[self alloc] init];
    e.file = [dic[@"fc"] relativeFilePath];
    e.source = [dic[@"sc"] base];
    e.target = [dic[@"sc"] translation];
    e.score = [dic[@"score"] floatValue];
    return e;
}


@end
