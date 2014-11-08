//
//  AboutWindow.h
//  iLocalize
//
//  Created by Jean Bovet on 2/9/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@interface AboutWindow : NSWindowController {
	IBOutlet NSTextField *versionTextField;
	IBOutlet NSTextField *copyrightTextField;
    IBOutlet NSButton *licenseTextButton;
}
+ (void)show;
- (IBAction)showAcknowledgment:(id)sender;
- (IBAction)showLicenseAgreement:(id)sender;
@end
