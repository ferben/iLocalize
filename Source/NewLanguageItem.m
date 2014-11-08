//
//  NewLanguageItem.m
//  iLocalize3
//
//  Created by Jean on 05.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "NewLanguageItem.h"


@implementation NewLanguageItem

+ (id)itemWithLanguage:(NSString*)language
{
	NewLanguageItem *item = [[NewLanguageItem alloc] init];
	[item setLanguage:language];
	return item;
}

- (id)init
{
	if(self = [super init]) {
		mLanguage = NULL;
		mDisplay = NULL;
		mIsBaseLanguage = NO;
		mImport = NO;
	}
	return self;
}

- (void)setLanguage:(NSString*)language
{
	mLanguage = language;
}

- (NSString*)language
{
	return mLanguage;
}

- (void)setIsBaseLanguage:(BOOL)flag
{
	mIsBaseLanguage = flag;
}

- (BOOL)isBaseLanguage
{
	return mIsBaseLanguage;
}

- (void)setImport:(BOOL)flag
{
	mImport = flag;
}

- (BOOL)import
{
	if([self isBaseLanguage]) {
		return YES;
	} else {
		return mImport;		
	}
}

- (void)setDisplay:(NSString*)display
{
	mDisplay = display;
}

- (NSString*)display
{
	return mDisplay;
}

- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

- (id)objectForKey:(NSString*)key
{
	if([key isEqualToString:[AZListSelectionView selectedKey]]) {
		return @([self import]);
	} else {
		return [self display];
	}
}

- (void)setObject:(id)object forKey:(NSString*)key
{
	if([key isEqualToString:[AZListSelectionView selectedKey]]) {
		[self setImport:[object boolValue]];
	}
}

@end
