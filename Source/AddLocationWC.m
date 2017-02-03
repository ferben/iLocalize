//
//  AddLocationWC.m
//  iLocalize3
//
//  Created by Jean on 10.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AddLocationWC.h"
#import "ProjectController.h"

@implementation AddLocationWC

- (id)init
{
    if (self = [super initWithWindowNibName:@"AddLocation"])
    {
    }
    
    return self;
}

- (void)willShow
{
    [mPopUpLocation removeAllItems];
    [mPopUpLocation addItemsWithTitles:[[[self projectProvider] projectController] smartPaths]];
}

- (NSString *)location
{
    return [mPopUpLocation titleOfSelectedItem];
}

- (IBAction)cancel:(id)sender
{
    [self hide];    
}

- (IBAction)add:(id)sender
{
    [self hideWithCode:1];    
}

@end
