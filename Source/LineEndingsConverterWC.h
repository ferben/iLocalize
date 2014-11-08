//
//  LineEndingsConverterWC.h
//  iLocalize3
//
//  Created by Jean on 23.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractWC.h"

@interface LineEndingsConverterWC : AbstractWC {
	IBOutlet NSButton	*mFromMacButton;
	IBOutlet NSButton	*mFromUnixButton;
	IBOutlet NSButton	*mFromWindowsButton;
	IBOutlet NSPopUpButton	*mToFormatPopUp;		
}
- (BOOL)fromMac;
- (BOOL)fromUnix;
- (BOOL)fromWindows;
- (int)toLineEnding;
- (IBAction)cancel:(id)sender;
- (IBAction)convert:(id)sender;
@end
