//
//  LineEndingsConverterWC.m
//  iLocalize3
//
//  Created by Jean on 23.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "LineEndingsConverterWC.h"
#import "Constants.h"

@implementation LineEndingsConverterWC

- (id)init
{
    if(self = [super initWithWindowNibName:@"LineEndingsConverter"]) {
    }
    return self;
}

- (BOOL)fromMac
{
    return [mFromMacButton state] == NSOnState;
}

- (BOOL)fromUnix
{
    return [mFromUnixButton state] == NSOnState;
}

- (BOOL)fromWindows
{
    return [mFromWindowsButton state] == NSOnState;
}

- (int)toLineEnding
{
    switch([mToFormatPopUp indexOfSelectedItem]) {
        case 0:
            return MAC_LINE_ENDINGS;
        case 1:
            return UNIX_LINE_ENDINGS;
        case 2:
            return WINDOWS_LINE_ENDINGS;
    }
    return MAC_LINE_ENDINGS;
}

- (IBAction)cancel:(id)sender
{
    [self hide];
}

- (IBAction)convert:(id)sender
{
    [self hideWithCode:1];
}

@end
