//
//  NibStringModel.m
//  iLocalize3
//
//  Created by Jean on 23.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "NibStringModel.h"

static NSString *NIB_ITEM_TYPE = @"nib_item_type";

@implementation NibStringModel

#define S(c)    [NSString stringWithFormat:@"%C", c]

- (void)setType:(NSString*)type
{
    mAttributes[NIB_ITEM_TYPE] = type;
}

- (NSString*)type
{
    return mAttributes[NIB_ITEM_TYPE];
}

- (NSString*)parseType
{
    NSString *comment = [self comment];
    NSMutableString *type = [NSMutableString string];
    
    unsigned index = 0;
    while(index<[comment length]) {
        unichar c = [comment characterAtIndex:index++];
        if(![[NSCharacterSet letterCharacterSet] characterIsMember:c])
            continue;
        
        [type appendString:S(c)];
        while(index<[comment length]) {
            c = [comment characterAtIndex:index++];
            if(![[NSCharacterSet alphanumericCharacterSet] characterIsMember:c]) {
                return type;
            }
            [type appendString:S(c)];
        }                        
    }
    return @"";        
}

- (void)setComment:(NSString*)comment
{
    [super setComment:comment];
    [self setType:[self parseType]];
}

- (NSComparisonResult)compareKeys:(id)other
{
    return [[self key] compare:[other key]];
}

@end
