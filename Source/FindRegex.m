//
//  FindRegex.m
//  iLocalize3
//
//  Created by Jean on 3/12/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "FindRegex.h"
#import "RegexKitLite.h"

@implementation FindRegex

@synthesize regex;
@synthesize ignoreCase;

+ (FindRegex*)regexWithPattern:(NSString*)pattern ignoreCase:(BOOL)ignoreCase
{
    FindRegex *regex = [[FindRegex alloc] initWithPattern:pattern ignoreCase:ignoreCase];
    return regex;
}

- (id)initWithPattern:(NSString*)pattern ignoreCase:(BOOL)flag
{
    if(self = [super init]) {
		self.regex = pattern;
		self.ignoreCase = flag;
    }
    return self;
}


- (BOOL)regexMatch:(NSString*)string
{
    if(!string) {
        return NO;		
	}
    
	return [string isMatchedByRegex:regex];
}

- (NSMutableArray*)regexRangesInString:(NSString*)string
{
    if(!string) {
        return nil;		
	}

	NSMutableArray *ranges = [NSMutableArray array];

	[string enumerateStringsMatchedByRegex:regex 
								   options:ignoreCase?RKLCaseless:RKLNoOptions
								   inRange:NSMakeRange(0, [string length])
									 error:nil
						enumerationOptions:RKLRegexEnumerationNoOptions
								usingBlock:^(NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop) {
									for(int i=0; i<captureCount; i++) {
										[ranges addObject:[NSValue valueWithRange:capturedRanges[i]]];			
									}
								}];
	
	return ranges;
}

@end
