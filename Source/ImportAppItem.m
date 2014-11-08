//
//  ImportAppItem.m
//  iLocalize3
//
//  Created by Jean on 12.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ImportAppItem.h"
#import "LanguageTool.h"

@implementation ImportAppItem

- (id)initWithLanguage:(NSString*)language
{
	if(self = [super init]) {
		mLanguage = language;
		mImport = NO;
	}
	return self;
}


+ (id)itemWithLanguage:(NSString*)language
{
	return [[ImportAppItem alloc] initWithLanguage:language];
}

- (NSString*)language
{
	return mLanguage;
}

- (NSString*)displayLanguage
{
	return [[self language] displayLanguageName];
}

- (void)setImport:(BOOL)import
{
	mImport = import;
}

- (BOOL)import
{
	return mImport;
}

- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

- (id)objectForKey:(NSString*)key
{
	if([key isEqualToString:[AZListSelectionView selectedKey]]) {
		return @([self import]);
	} else {
		return [self displayLanguage];
	}
}

- (void)setObject:(id)object forKey:(NSString*)key
{
	if([key isEqualToString:[AZListSelectionView selectedKey]]) {
		[self setImport:[object boolValue]];
	}
}

@end
