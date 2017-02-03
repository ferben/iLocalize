//
//  XMLParserTesting.m
//  Tests
//
//  Created by Jean on 9/3/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "XMLParserTestHelper.h"

@implementation XMLParserTestHelper

+ (BOOL)parseFile:(NSString*)file verifyFile:(NSString*)verify
{
    NSAssert(file != nil, @"File is nil");
    NSAssert(verify != nil, @"Verify is nil");
    
    XMLParserTestHelper *testing = [[XMLParserTestHelper alloc] init];
    
    XMLParser *parser = [[XMLParser alloc] init];
    [parser setString:[NSString stringWithContentsOfFile:file usedEncoding:nil error:nil]];
    [parser setDelegate:testing];
    [parser parse];
    
    BOOL result = [testing verifyWithArray:[NSArray arrayWithContentsOfFile:verify]];
        
    return result;
}

- (id)init
{
    if(self = [super init]) {
        mVerifyArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)verifyWithArray:(NSArray*)array
{
    if([array isEqualToArray:mVerifyArray]) return YES;
    
    NSUInteger count = MAX([array count], [mVerifyArray count]);
    NSUInteger i;
    for(i=0; i<count; i++) {
        if(i >= [mVerifyArray count]) {
            NSLog(@"More actual elements (%lu instead of %lu)", (unsigned long)[mVerifyArray count], (unsigned long)[array count]);
            return NO;
        }
        if(i >= [array count]) {
            NSLog(@"More expected elements (%lu instead of %lu)", (unsigned long)[array count], (unsigned long)[mVerifyArray count]);
            return NO;
        }
        NSString *actual = [mVerifyArray objectAtIndex:i];
        NSString *expected = [array objectAtIndex:i];
        if(![actual isEqualToString:expected]) {
            NSLog(@"Mismatch '%@' != '%@'", expected, actual);
            return NO;
        }
    }
    return YES;
}

#pragma mark XMLParser Delegate

static BOOL verbose = NO;

- (void)parser:(XMLParser*)parser beginElement:(NSString*)name
{
    [mVerifyArray addObject:[NSString stringWithFormat:@"BE:%@", name]];
    if(verbose)    NSLog(@"%@", [mVerifyArray lastObject]);
}

- (void)parser:(XMLParser*)parser endElement:(NSString*)name
{
    [mVerifyArray addObject:[NSString stringWithFormat:@"EE:%@", name]];    
    if(verbose)    NSLog(@"%@", [mVerifyArray lastObject]);
}

- (void)parser:(XMLParser*)parser element:(NSString*)element attributeName:(NSString*)name content:(NSString*)content info:(id)info
{
    [mVerifyArray addObject:[NSString stringWithFormat:@"AK:%@", name]];        
    if(verbose)    NSLog(@"%@", [mVerifyArray lastObject]);

    [mVerifyArray addObject:[NSString stringWithFormat:@"AV:%@", content]];
    if(verbose)    NSLog(@"%@", [mVerifyArray lastObject]);
    
    //NSLog(@"Location %d -> %d", [[info objectForKey:INFO_START_LOCATION] intValue], [[info objectForKey:INFO_END_LOCATION] intValue]);
}

- (void)parser:(XMLParser*)parser content:(NSString*)content
{
    [mVerifyArray addObject:[NSString stringWithFormat:@"CO:%@", content]];    
    if(verbose)    NSLog(@"%@", [mVerifyArray lastObject]);
}

- (void)parser:(XMLParser*)parser comment:(NSString*)comment
{
    [mVerifyArray addObject:[NSString stringWithFormat:@"CM:%@", comment]];    
    if(verbose)    NSLog(@"%@", [mVerifyArray lastObject]);
}

- (void)parser:(XMLParser*)parser error:(NSString*)reason
{
    [mVerifyArray addObject:[NSString stringWithFormat:@"ERR:%@", reason]];    
    if(verbose)    NSLog(@"%@", [mVerifyArray lastObject]);
}

@end
