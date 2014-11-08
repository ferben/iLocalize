//
//  XLIFFImportElement.m
//  iLocalize
//
//  Created by Jean Bovet on 4/21/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XLIFFImportFileElement.h"
#import "FileController.h"

@implementation XLIFFImportFileElement

@synthesize selected;
@synthesize fc;
@synthesize stringElements;

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.selected = YES;
	}
	return self;
}

- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}

- (id)objectForKey:(NSString*)key
{
	if([key isEqualToString:[AZListSelectionView selectedKey]]) {
		return @(self.selected);
	} else if ([key isEqualToString:[AZListSelectionView imageKey]]) {
		return [[fc absoluteFilePath] imageOfPath];
	} else {
		return [fc relativeFilePath];
	}
}

- (void)setObject:(id)object forKey:(NSString*)key
{
	if([key isEqualToString:[AZListSelectionView selectedKey]]) {
		self.selected = [object boolValue];
	}
}

@end
