//
//  FMEditorHTML.m
//  iLocalize3
//
//  Created by Jean on 28.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEditorHTML.h"

#import "FileController.h"

@implementation FMEditorHTML

- (NSString*)nibname
{
	return @"FMEditorHTML";
}

- (BOOL)allowsMultipleSelection
{
	return NO;
}

- (NSString*)baseString
{
	NSString *base = [[self fileController] baseModelContent];
	if(!base)
		return @"";    
    else
        return base;
}

- (NSString*)localizedString
{
	NSString *localized = [[self fileController] modelContent];
	if(!localized)
        return @"";    
    else
        return localized;
}

- (void)loadBasePreview
{
	NSString *baseURLFile = [[self fileController] absoluteBaseFilePath];
	if(baseURLFile != nil) {
		[[mBaseBaseWebView mainFrame] loadHTMLString:[self baseString] baseURL:[NSURL fileURLWithPath:baseURLFile]];	
		[[mLocalizedBaseWebView mainFrame] loadHTMLString:[self baseString] baseURL:[NSURL fileURLWithPath:baseURLFile]];			
	}
}

- (void)loadLocalizedPreview
{
	NSString *localizedURLFile = [[self fileController] absoluteFilePath];
	if(localizedURLFile != nil) {
		if([[[self fileController] absoluteFilePath] isPathExisting]) {
			[[mLocalizedTranslationWebView mainFrame] loadHTMLString:[self localizedString] baseURL:[NSURL fileURLWithPath:localizedURLFile]];	
		} else {
			// If I don't pass an existing path, the view doesn't get cleared (that's why I am using the baseURLFile)
			NSString *baseURLFile = [[self fileController] absoluteBaseFilePath];
			[[mLocalizedTranslationWebView mainFrame] loadHTMLString:@"" baseURL:[NSURL fileURLWithPath:baseURLFile]];	
		}		
	}
}

- (void)updateContent
{    
	NSString *base = [self baseString];
    [mBaseBaseTextView setString:base];
    [mLocalizedBaseTextView setString:base];		

	NSString *localized = [self localizedString];
	[mLocalizedTranslationTextView setString:localized];	

	[self loadBasePreview];
	[self loadLocalizedPreview];
}

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	int index = [tabView indexOfTabViewItem:tabViewItem];
		
	if(index == 1) {
		if(mReloadBasePreview) {
			[self loadBasePreview];
			mReloadBasePreview = NO;			
		}
		if(mReloadLocalizedPreview) {
			[self loadLocalizedPreview];
			mReloadLocalizedPreview = NO;
		}
	}
}

- (void)textDidChange:(NSNotification *)notif
{
	NSTextView *tv = [notif object];
	NSString *s = [[tv string] copy];
	if(tv == mLocalizedBaseTextView)
		[[self fileController] setBaseModelContent:s];		
	else
		[[self fileController] setModelContent:s];	
	
	if(tv == mBaseBaseTextView || tv == mLocalizedBaseTextView) {
		mReloadBasePreview = YES;
		[self loadBasePreview];
	} else {
		mReloadLocalizedPreview = YES;		
		[self loadLocalizedPreview];		
	}
}

- (IBAction)back:(id)sender
{
	[mLocalizedBaseWebView goBack];
	[mLocalizedTranslationWebView goBack];
}

- (IBAction)forward:(id)sender
{
	[mLocalizedBaseWebView goForward];
	[mLocalizedTranslationWebView goForward];
}

- (IBAction)makeLarger:(id)sender
{
	[mLocalizedBaseWebView makeTextLarger:self];
	[mLocalizedTranslationWebView makeTextLarger:self];
}

- (IBAction)makeSmaller:(id)sender
{
	[mLocalizedBaseWebView makeTextSmaller:self];	
	[mLocalizedTranslationWebView makeTextSmaller:self];
}

@end
