//
//  ILContext.h
//  iLocalize
//
//  Created by Jean Bovet on 3/8/14.
//  Copyright (c) 2014 Arizona Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ILContext : NSObject

+ (instancetype)shared;

/** YES if iLocalize is running as unit tests
 */
@property (nonatomic) BOOL runningUnitTests;

@end
