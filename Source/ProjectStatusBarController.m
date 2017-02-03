//
//  ProjectStatusBarController.m
//  iLocalize
//
//  Created by Jean Bovet on 3/25/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ProjectStatusBarController.h"
#import "ProjectWC.h"
#import "LanguageController.h"

@implementation ProjectStatusBarController

+ (ProjectStatusBarController *)newInstance:(ProjectWC *)projectWC
{
    ProjectStatusBarController *controller = [[ProjectStatusBarController alloc] initWithNibName:@"ProjectStatusBar" bundle:nil];
    controller.projectWC = projectWC;
    return controller;
}

- (void)awakeFromNib
{
    [self update];
}

- (NSString *)openForText
{
    int minutes = [self.projectWC elapsedMinutesSinceProjectWasOpened];
    int displayHours = minutes / 60;
    int displayMinutes = minutes - displayHours * 60;
    
    NSString *sminute = NSLocalizedString(@"minute", @"Status Bar");
    NSString *pminute = NSLocalizedString(@"minutes", @"Status Bar");
    NSString *shour = NSLocalizedString(@"hour", @"Status Bar");
    NSString *phour = NSLocalizedString(@"hours", @"Status Bar");
    
    NSString *info;
    
    if (displayHours > 0)
    {
        // Opened since 1 hour and 1 minute
        // Opened since 1 hour and 2 minutes
        // Opened since 2 hours and 1 minute
        // Opened since 2 hours and 3 minutes
        
        info = [NSString stringWithFormat:NSLocalizedString(@"Open for %d %@ and %d %@", @"Status Bar"), 
                displayHours, displayHours > 1 ? phour:shour,
                displayMinutes, displayMinutes > 1 ? pminute:sminute];        
    }
    else
    {
        // Opened since 1 minute
        // Opened since 12 minutes
        if (displayMinutes == 0)
        {
            info = NSLocalizedString(@"Open for less than a minute", @"Status Bar");
        }
        else
        {
            info = [NSString stringWithFormat:NSLocalizedString(@"Open for %d %@", @"Status Bar"), 
                    displayMinutes, displayMinutes > 1 ? pminute:sminute];            
        }
    }
    
    return info;
}

- (void)update
{
    LanguageController *lc = [self.projectWC selectedLanguageController];
    
    NSUInteger total       = [lc totalNumberOfStrings];
    NSUInteger toTranslate = [lc totalNumberOfNonTranslatedStrings];
    NSUInteger toCheck     = [lc totalNumberOfToCheckStrings];
    
    NSString *elapsed = [self openForText];
    
    NSMutableString *info = [NSMutableString string];
    [info appendFormat:NSLocalizedString(@"%d strings", @"Status Bar"), total];
    
    if (![lc isBaseLanguage])
    {
        if (toTranslate > 0)
        {
            [info appendFormat:NSLocalizedString(@" of which %d need to be translated", @"Status Bar"), toTranslate];        
        }
        
        if (toCheck > 0)
        {
            if (toTranslate > 0)
            {
                [info appendFormat:NSLocalizedString(@" and %d need to be verified", @"Status Bar"), toCheck];        
            }
            else
            {
                [info appendFormat:NSLocalizedString(@" of which %d need to be verified", @"Status Bar"), toCheck];                    
            }
        }        
    }
    
    [leftSideTextField setStringValue:info];
    
    [rightSideTextField setStringValue:elapsed];
}

@end
