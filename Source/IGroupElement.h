//
//  IGroupElement.h
//  iLocalize
//
//  Created by Jean Bovet on 10/16/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//


@interface IGroupElement : NSObject {
    NSString *source;
    NSString *target;
}

@property (copy) NSString *source;
@property (copy) NSString *target;

+ (IGroupElement*)elementWithSource:(NSString*)source target:(NSString*)target;

@end
