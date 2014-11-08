//
//  CheckProjectWC.m
//  iLocalize3
//
//  Created by Jean on 5/28/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "CheckProjectWC.h"

#import "ProjectController.h"
#import "LanguageController.h"
#import "AZListSelectionView.h"

@implementation CheckProjectWC

- (id)init
{
	if(self = [super initWithWindowNibName:@"CheckProject"]) {
		selectionView = [[AZListSelectionView alloc] init];
	}
	return self;
}


- (void)willShow
{
	NSMutableArray *elements = [NSMutableArray array];
	
	for(LanguageController *languageController in [[[self projectProvider] projectController] languageControllers]) {
		NSMutableDictionary *dic = [NSMutableDictionary dictionary];
		dic[@"name"] = [languageController language];
		dic[@"displayName"] = [languageController displayLanguage];
		dic[[AZListSelectionView selectedKey]] = @YES;

		[elements addObject:dic];
	}
	
	selectionView.delegate = self;
	selectionView.outlineView = outlineView;
	selectionView.elements = elements;
	[selectionView reloadData];
}

- (NSArray*)checkLanguages
{
	NSMutableArray *array = [NSMutableArray array];
	[[selectionView selectedElements] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[array addObject:obj[@"name"]];
	}];
	return array;
}

- (void)elementsSelectionChanged:(BOOL)noSelection
{
	[checkButton setEnabled:!noSelection];
}

- (IBAction)cancel:(id)sender
{
	[self hide];	
}

- (IBAction)check:(id)sender
{
	[self hideWithCode:1];	
}

@end
