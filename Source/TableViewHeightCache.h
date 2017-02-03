//
//  TableViewHeightCache.h
//  iLocalize
//
//  Created by Jean Bovet on 2/21/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TableViewHeightCache : NSObject<NSCopying> {
    NSDictionary *attributes;
    NSString *value;
    CGFloat width;
    NSUInteger hashValue;
}

@property (strong) NSDictionary *attributes;
@property (strong) NSString *value;
@property CGFloat width;

+ (CGFloat)heightForValue:(NSString*)value width:(CGFloat)width defaultHeight:(CGFloat)height attributes:(NSDictionary*)attributes;

@end
