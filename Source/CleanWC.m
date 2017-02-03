//
//  CleanWC.m
//  iLocalize3
//
//  Created by Jean on 30.05.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "CleanWC.h"


@implementation CleanWC

- (id)init
{
    if(self = [super initWithWindowNibName:@"Clean"]) {
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"CleanDoubleQuotationMark"] == nil)
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CleanDoubleQuotationMark"];
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"CleanQuotationMark"] == nil)
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CleanQuotationMark"];
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"CleanEllipsis"] == nil)
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CleanEllipsis"];
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"CleanNonBreakableSpace"] == nil)
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CleanNonBreakableSpace"];
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"CleanTrimLastSpace"] == nil)
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CleanTrimLastSpace"];
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"CleanApplyTo"] == nil)
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"CleanApplyTo"];                
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"CleanMarkModifiedStrings"] == nil)
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CleanMarkModifiedStrings"];                
    }
    return self;
}

- (NSDictionary*)attributes
{
    return nil;
}

- (IBAction)cancel:(id)sender
{
    [self hide];    
}

- (IBAction)clean:(id)sender
{
    [self hideWithCode:1];    
}

@end
