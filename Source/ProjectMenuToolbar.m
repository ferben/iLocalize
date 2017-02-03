//
//  ProjectMenuToolbar.m
//  iLocalize
//
//  Created by Jean on 1/8/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "ProjectMenuToolbar.h"
#import "ProjectWC.h"

@implementation ProjectMenuToolbar

- (IBAction)languageAction:(id)sender
{
    [self.projectWC selectLanguageAtIndex:[sender indexOfSelectedItem]];
}

@end
