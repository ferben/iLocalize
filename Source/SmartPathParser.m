//
//  SmartPathParser.m
//  iLocalize3
//
//  Created by Jean on 05.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "SmartPathParser.h"

@interface SmartPathParser (PrivateMethods)
- (id)initWithPath:(NSString*)path;
- (void)setIncludeLProj:(BOOL)lproj;
- (BOOL)parseContent;
- (NSString*)parse;
@end

@implementation SmartPathParser

+ (NSString*)smartPath:(NSString*)path
{
	SmartPathParser *parser = [[SmartPathParser alloc] initWithPath:path];
	return [parser parse];
}

+ (NSString*)smartPath:(NSString*)path lproj:(BOOL)lproj
{
	SmartPathParser *parser = [[SmartPathParser alloc] initWithPath:path];
	[parser setIncludeLProj:lproj];
	return [parser parse];
}

- (id)initWithPath:(NSString*)path
{
	if(self = [super init]) {
		mComponents = [path pathComponents];
		mSmartPathComponents = [[NSMutableArray alloc] init];
		mIncludeLProj = NO;
	}
	return self;
}


- (void)setIncludeLProj:(BOOL)lproj
{
	mIncludeLProj = lproj;
}

- (BOOL)nextComponent
{
	mCurrentComponentIndex++;
	return mCurrentComponentIndex<[mComponents count];
}

- (NSString*)currentComponentAtIndex:(int)offset
{
	unsigned index = mCurrentComponentIndex+offset;
	if(index>=[mComponents count])
		return NULL;
	else
		return mComponents[mCurrentComponentIndex];
}

#define C(index) [self currentComponentAtIndex:index]
#define EQUAL(string) [C(0) isEqualToString:string]

- (void)addToSmartPath
{
	[mSmartPathComponents addObject:C(0)];
}

- (NSString*)parse
{
	mCurrentComponentIndex = -1;
	[mSmartPathComponents removeAllObjects];

	while([self nextComponent]) {
		if(EQUAL(@"/"))
			continue;
		
		if(EQUAL(@"Contents"))
			continue;

		if(!mIncludeLProj && [C(0) isPathLanguageProject])
			break;

		[self addToSmartPath];
		if([[C(0) pathExtension] isEqualToString:@"framework"]) {
			[self nextComponent];	// Versions
			[self nextComponent];	// A
		}
	}
	
	return [NSString pathWithComponents:mSmartPathComponents];
}

@end
