//
//  ProjectDetailsProject.m
//  iLocalize
//
//  Created by Jean on 12/28/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectDetailsProject.h"
#import "LanguageController.h"
#import "FileController.h"
#import "StringController.h"
#import "Constants.h"

@implementation ProjectDetailsProject

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(stringSelectionDidChange:)
												 name:ILStringSelectionDidChange
											   object:nil];		
}

- (void)stringSelectionDidChange:(NSNotification *)notif
{
	[self update];
}

- (NSTextStorage *)textStorage
{
	return [mTextView textStorage];
}

- (NSString *)openForText
{
	int minutes = [self.projectWC elapsedMinutesSinceProjectWasOpened];
    int displayHours = minutes / 60;
    int displayMinutes = minutes - displayHours * 60;
    
    NSString *sminute = NSLocalizedString(@"minute", @"Project Information");
    NSString *pminute = NSLocalizedString(@"minutes", @"Project Information");
    NSString *shour = NSLocalizedString(@"hour", @"Project Information");
    NSString *phour = NSLocalizedString(@"hours", @"Project Information");
	
    NSString *info;
    
    if (displayHours > 0)
    {
        // Opened since 1 hour and 1 minute
        // Opened since 1 hour and 2 minutes
        // Opened since 2 hours and 1 minute
        // Opened since 2 hours and 3 minutes
		
        info = [NSString stringWithFormat:NSLocalizedString(@"%d %@ and %d %@", @"Project Information"), 
				displayHours, displayHours > 1 ? phour:shour,
				displayMinutes, displayMinutes > 1 ? pminute:sminute];        
    }
    else
    {
        // Opened since 1 minute
        // Opened since 12 minutes
		if (displayMinutes == 0)
        {
			info = NSLocalizedString(@"Less than a minute", @"Project Information");
		}
        else
        {
			info = [NSString stringWithFormat:NSLocalizedString(@"%d %@", @"Project Information"), 
					displayMinutes, displayMinutes > 1 ? pminute:sminute];			
		}
    }
	return info;
}

- (void)addProjectInformation
{
	LanguageController *lc = [self.projectWC selectedLanguageController];
    NSUInteger total = [lc totalNumberOfStrings];
    NSUInteger toTranslate = [lc totalNumberOfNonTranslatedStrings];
	NSUInteger toCheck = [lc totalNumberOfToCheckStrings];
	
	
	[self addDetail:NSLocalizedString(@"Strings", @"Project Information") value:[NSString stringWithFormat:@"%ld", total]];
	
    if (![lc isBaseLanguage])
    {
		[self addDetail:NSLocalizedString(@"To Translate", @"Project Information") value:[NSString stringWithFormat:@"%ld", toTranslate]];
		[self addDetail:NSLocalizedString(@"To Check", @"Project Information") value:[NSString stringWithFormat:@"%ld", toCheck]];
    }
	
    [self addDetail:NSLocalizedString(@"Open For", @"Project Information") value:[self openForText]];
}

- (void)update
{
	[self begin];
	[self addProjectInformation];
	[self commit];
}

@end
