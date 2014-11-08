//
//  FileLabelCustomCell.m
//  iLocalize3
//
//  Created by Jean on 12/2/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "FileLabelCustomCell.h"
#import "LabelCustomCellRender.h"
#import "FileController.h"
#import "ProjectWC.h"

@implementation FileLabelCustomCell

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
							indexes:[[self fileController] labelIndexes]
							 labels:[[[[self fileController] projectProvider] projectWC] projectLabels]];
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
		o = [[self fileController] pFileLabel];
	}
	return o;	
}

@end
