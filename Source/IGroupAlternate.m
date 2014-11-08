//
//  IGroupAlternate.m
//  iLocalize
//
//  Created by Jean Bovet on 10/18/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroupAlternate.h"
#import "IGroupEngineAlternate.h"
#import "IGroup.h"
#import "IGroupElementAlternate.h"
#import "FMEditor.h"
#import "StringController.h"
#import "IGroupView.h"

@implementation IGroupAlternate

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.name = @"Alternate";
		
		sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO]];		
	}
	return self;
}


- (void)newResults:(NSArray*)results forEngineManaged:(IGroupEngineManager*)manager
{
	// use a set so the results are unique
	NSMutableSet *mutableSet = [NSMutableSet setWithArray:elements];
	
	// add the new results to the set
	for(NSDictionary *r in results) {
		IGroupElement *element = [IGroupElementAlternate elementWithDictionary:r];
		// don't add elements that have identical source and target
		if([element.source isEqualToString:element.target]) continue;
		[mutableSet addObject:element];			
	}
	
	// get back a sorted array
	self.elements = [mutableSet sortedArrayUsingDescriptors:sortDescriptors];
	
	// ask to update the view
	[self.view setNeedsDisplay:YES];
}

- (void)clearResultsForEngineManaged:(IGroupEngineManager*)manager
{
	self.elements = nil;
	[self.view setNeedsDisplay:YES];
}

- (void)clickOnElement:(IGroupElement*)element
{
	NSArray *selectedStrings = [self.projectProvider selectedStringControllers];
	if([selectedStrings count] == 1) {
		[[selectedStrings firstObject] setTranslation:element.target];
		
		FMEditor *editor = [self.projectProvider currentFileModuleEditor];
		if([editor respondsToSelector:@selector(performAutoPropagation)]) {
			[editor performSelector:@selector(performAutoPropagation)];			
		}
		
		if([[NSUserDefaults standardUserDefaults] boolForKey:@"glossaryTranslateSelectNextString"]) {
			[editor selectNextItem];
		}
	}	
}

@end
