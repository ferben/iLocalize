//
//  ProjectDetailsString.m
//  iLocalize
//
//  Created by Jean on 12/28/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectDetailsString.h"
#import "LanguageController.h"
#import "StringController.h"
#import "Constants.h"

@implementation ProjectDetailsString

- (NSTextStorage*)textStorage
{
	return [mTextView textStorage];
}

- (void)stringSelectionDidChange:(NSNotification*)notif
{
	[self update];
}

- (void)update
{
	[self begin];
	
	NSArray *scs = [self.projectWC selectedStringControllers];
	LanguageController *lc = [self.projectWC selectedLanguageController];
	StringController *sc = [scs firstObject];
	switch([scs count]) {
		case 0:
			[self addDetail:NSLocalizedString(@"(no string selected)", @"String Information")];
			break;
		case 1:
			[self addDetail:NSLocalizedString(@"Key", @"String Information") value:[sc key]];
			[self addDetail:NSLocalizedString(@"Comment", @"String Information") value:[sc translationComment]];
			[self addDetail:[lc baseLanguage] value:[NSString stringWithFormat:@"%ld %@", [[sc base] length], NSLocalizedString(@"characters", nil)]];
			[self addDetail:[lc language] value:[NSString stringWithFormat:@"%ld %@", [[sc translation] length], NSLocalizedString(@"characters", nil)]];
			break;
		default:
			[self addDetail:NSLocalizedString(@"(multiple strings selected)", @"String Information")];
			break;
	}
	
	[self commit];
}

@end
