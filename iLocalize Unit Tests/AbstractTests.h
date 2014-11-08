//
//  AbstractTests.m
//  iLocalize
//
//  Created by Jean Bovet on 11/24/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface AbstractTests : XCTestCase

- (NSString*)ibtoolPath;
- (NSString*)pathForResource:(NSString*)resource;
- (BOOL)contentOfFile:(NSString*)first equalsFile:(NSString*)second;

- (void)printExecutionTimeWithName:(NSString*)name block:(dispatch_block_t)block;
- (NSTimeInterval)measureExecutionTime:(dispatch_block_t)block;

@end
