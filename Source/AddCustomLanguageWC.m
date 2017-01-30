//
//  AddCustomLanguageWC.m
//  iLocalize3
//
//  Created by Jean on 7/29/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "AddCustomLanguageWC.h"
#import "ProjectController.h"

@implementation AddCustomLanguageWC

- (id)init
{
	if(self = [super initWithWindowNibName:@"AddCustomLanguage"]) {
	}
	return self;
}

- (void)willShow
{
	[mNameField setStringValue:@""];
}

- (void)setRenameLanguage:(BOOL)flag
{
	if (flag)
    {
		[mOKButton setTitle:NSLocalizedString(@"Rename", nil)];		
	}
    else
    {
		[mOKButton setTitle:NSLocalizedString(@"Add", nil)];
	}
}

- (NSString *)language
{
	return [mNameField stringValue];
}

- (BOOL)alreadyExists
{
	return [[[self projectProvider] projectController] isLanguageExisting:[self language]];
}

- (IBAction)cancel:(id)sender
{
	[self hide];	
}

- (IBAction)add:(id)sender
{
	if ([self alreadyExists])
    {
		NSRunAlertPanel(NSLocalizedString(@"Cannot add this language", nil),
						NSLocalizedString(@"This language already exists in the project.", nil),
						NSLocalizedString(@"OK", nil), NULL, NULL);		
	}
    else
    {
		[self hideWithCode:1];	
	}
}

@end
