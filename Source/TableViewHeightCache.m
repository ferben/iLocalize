//
//  TableViewHeightCache.m
//  iLocalize
//
//  Created by Jean Bovet on 2/21/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "TableViewHeightCache.h"


@implementation TableViewHeightCache

static NSMutableDictionary *cache = nil;

@synthesize attributes;
@synthesize value;
@synthesize width;

+ (CGFloat)heightForValue:(NSString*)value width:(CGFloat)width defaultHeight:(CGFloat)height attributes:(NSDictionary*)attributes
{
    if(value == nil) return height;
    
    @synchronized(self) {
        if(cache == nil) {
            cache = [[NSMutableDictionary alloc] init];
        }        
    }
    
    TableViewHeightCache *key = [[TableViewHeightCache alloc] init];
    key.attributes = attributes;
    key.value = value;
    key.width = width;
    NSNumber *foundHeight = cache[key];
    if(foundHeight) {
        return [foundHeight floatValue];
    }
    
    CGFloat cachedHeight;
    if([value length] < 30) {
        // if there are less than 30 characters, just count the number of \n to determine
        // the number of rows
        int lines = [value numberOfLines];
        if(lines <= 1) {
            cachedHeight = height;
        } else {
            cachedHeight = height*lines;
        }
    } else {
        // compute the exact height
        cachedHeight = [value heightForWidth:width withAttributes:attributes];        
    }
    // todo limit this cache in size with last access element
    cache[key] = [NSNumber numberWithFloat:cachedHeight];
    return cachedHeight;
}

- (id) init
{
    self = [super init];
    if (self != nil) {
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    TableViewHeightCache *c = [[TableViewHeightCache alloc] init];
    c.attributes = self.attributes;
    c.value = self.value;
    c.width = self.width;
    return c;
}

- (NSUInteger)hash
{
    if(hashValue == 0) {
        hashValue = 17*[self.attributes hash];
        hashValue += 17*[self.value hash];
        hashValue += 17*width;
    }
    return hashValue;        
}

- (BOOL)isEqual:(id)anObject
{
    if(![anObject isKindOfClass:[TableViewHeightCache class]]) {
        return NO;
    }
    
    TableViewHeightCache *other = anObject;
    
    return [other.attributes isEqual:self.attributes] && [other.value isEqualToString:self.value] && other.width == self.width;
}

@end
