//
//  ControlCharactersParser.m
//  iLocalize3
//
//  Created by Jean on 06.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ControlCharactersParser.h"
#import "Constants.h"

@implementation ControlCharactersParser

+ (NSString*)showControlCharacters:(NSString*)string
{    
	NSMutableString *output = [[NSMutableString alloc] initWithString:string];
	[output replaceOccurrencesOfString:@"\r\n" withString:@"\\r\\n" options:0 range:NSMakeRange(0, [output length])];
	[output replaceOccurrencesOfString:@"\r" withString:@"\\r" options:0 range:NSMakeRange(0, [output length])];
	[output replaceOccurrencesOfString:@"\n" withString:@"\\n" options:0 range:NSMakeRange(0, [output length])];
	[output replaceOccurrencesOfString:@"\t" withString:@"\\t" options:0 range:NSMakeRange(0, [output length])];
	return output;	
}

+ (NSString*)hideControlCharacters:(NSString*)string
{
	NSMutableString *output = [[NSMutableString alloc] initWithString:string];
	[output replaceOccurrencesOfString:@"\\r\\n" withString:@"\r\n" options:0 range:NSMakeRange(0, [output length])];
	[output replaceOccurrencesOfString:@"\\r" withString:@"\r" options:0 range:NSMakeRange(0, [output length])];
	[output replaceOccurrencesOfString:@"\\n" withString:@"\n" options:0 range:NSMakeRange(0, [output length])];
	[output replaceOccurrencesOfString:@"\\t" withString:@"\t" options:0 range:NSMakeRange(0, [output length])];
	return output;
}

@end
