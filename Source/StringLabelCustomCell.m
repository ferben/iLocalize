//
//  StringLabelCustomCell.m
//  iLocalize3
//
//  Created by Jean on 3/21/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "StringLabelCustomCell.h"
#import "LabelCustomCellRender.h"
#import "StringController.h"
#import "ProjectWC.h"

@implementation StringLabelCustomCell

- (void)awake
{
	[super awake];
	mRender = [[LabelCustomCellRender alloc] init];
}


- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[super drawInteriorWithFrame:cellFrame
						  inView:controlView];
	
	[mRender drawLabelCellWithFrame:cellFrame
							indexes:[[self stringController] labelIndexes]
							 labels:[[[[self stringController] projectProvider] projectWC] projectLabels]];
}

- (NSArray *)accessibilityAttributeNames
{
	id o = [super accessibilityAttributeNames];
	// add value attribute to describe the status
	return [o arrayByAddingObject:NSAccessibilityValueAttribute];	
}

- (id)accessibilityAttributeValue:(NSString *)attribute
{
	id o = [super accessibilityAttributeValue:attribute];	
	if([attribute isEqualToString:NSAccessibilityRoleAttribute]) {
		o = NSAccessibilityTextFieldRole;
	} else if([attribute isEqualToString:NSAccessibilityRoleDescriptionAttribute]) {
		o = NSAccessibilityRoleDescription(NSAccessibilityTextFieldRole, nil);
	} else if([attribute isEqualToString:NSAccessibilityValueAttribute]) {
		o = [[self stringController] pLabel];
	}
	return o;	
}

@end
