//
//  ToolLaunchApp.h
//  iLocalize3
//
//  Created by Jean on 06.09.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@interface ToolLaunchApp : NSWindowController {
    IBOutlet NSPopUpButton  *mLanguagesPopUp;
}
- (void)launchApplication:(NSString*)path;
- (IBAction)cancel:(id)sender;
- (IBAction)launch:(id)sender;
@end
