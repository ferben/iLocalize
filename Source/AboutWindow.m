//
//  AboutWindow.m
//  iLocalize
//
//  Created by Jean Bovet on 2/9/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "AboutWindow.h"


@implementation AboutWindow

static AboutWindow *aboutWindow = nil;

+ (void)show
{
	if(aboutWindow == nil) {
		aboutWindow = [[AboutWindow alloc] initWithWindowNibName:@"About"];		
		[[aboutWindow window] center];
	}
	[[aboutWindow window] makeKeyAndOrderFront:self];
}

- (void)awakeFromNib
{
    NSString *shortVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"];
    NSString *copyright = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"NSHumanReadableCopyright"];
	
	[versionTextField setStringValue:[NSString stringWithFormat:@"%@ %@ (%@)", NSLocalizedString(@"Version", @"About Box Version"), shortVersion, buildNumber]];
	[copyrightTextField setStringValue:copyright];

#warning Do we still need the License Text button?
    // [licenseTextButton setHidden:YES];
}

- (NSBundle *)helpBundle
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    return [NSBundle bundleWithPath:[[mainBundle bundlePath] stringByAppendingPathComponent:@"Contents/Resources/iLocalize.help"]];
}

- (IBAction)showAcknowledgment:(id)sender
{
	[[NSWorkspace sharedWorkspace] openFile:[[self helpBundle] pathForResource:@"Acknowledgments" ofType:@"html" inDirectory:@"misc"]];
}

- (IBAction)showLicenseAgreement:(id)sender
{
	[[NSWorkspace sharedWorkspace] openFile:[[self helpBundle] pathForResource:@"LicenseAgreement" ofType:@"html" inDirectory:@"misc"]];	
}

@end
