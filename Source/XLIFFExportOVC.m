//
//  XLIFFExportOVC.m
//  iLocalize
//
//  Created by Jean Bovet on 3/23/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XLIFFExportOVC.h"
#import "XLIFFExportSettings.h"
#import "LanguageMenuProvider.h"
#import "SEIManager.h"

@implementation XLIFFExportOVC

@synthesize settings;

- (id)init
{
    if(self = [super initWithNibName:@"XLIFFExport"]) {
        sourceLanguageProvider = [[LanguageMenuProvider alloc] init];
        targetLanguageProvider = [[LanguageMenuProvider alloc] init];
    }
    return self;
}


- (NSString*)exportExtension
{
    SEI_FORMAT format = [[SEIManager sharedInstance] selectedFormat:formatPopup];
    return [[SEIManager sharedInstance] writableExtensionForFormat:format];
}

- (void)updateExtension
{
    NSString *file = self.settings.targetFile;
    if(file) {
        file = [[file stringByDeletingPathExtension] stringByAppendingPathExtension:[self exportExtension]];
    }
    self.settings.targetFile = file;
    if(self.settings.targetFile) {
        [filePathControl setURL:[NSURL fileURLWithPath:self.settings.targetFile]];        
    } else {
        [filePathControl setURL:nil];
    }    
}

- (IBAction)chooseFile:(id)sender
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes:@[[self exportExtension]]];
    if([panel runModal] == NSModalResponseOK) {
        [filePathControl setURL:[panel URL]];
        [self stateChanged];
    }    
}

- (IBAction)formatChanged:(id)sender
{
    [self updateExtension];
}

- (void)saveSettings
{
    self.settings.format = [[SEIManager sharedInstance] selectedFormat:formatPopup];
    self.settings.sourceLanguage = [sourceLanguageProvider selectedLanguage];
    self.settings.targetLanguage = [targetLanguageProvider selectedLanguage];
    self.settings.targetFile = [[filePathControl URL] path];
}

- (NSString*)nextButtonTitle
{
    return NSLocalizedString(@"Export", nil);
}

- (BOOL)canContinue
{
    return [filePathControl URL] != nil;
}

- (void)willShow
{    
    sourceLanguageProvider.popupButton = sourceLanguagePopup;
    targetLanguageProvider.popupButton = targetLanguagePopup;
    
    [sourceLanguageProvider refreshPopUp];
    [targetLanguageProvider refreshPopUp];
    
    [sourceLanguageProvider selectLanguage:[self.settings.sourceLanguage displayLanguageName]];
    [targetLanguageProvider selectLanguage:[self.settings.targetLanguage displayLanguageName]];
    
    [[SEIManager sharedInstance] populatePopup:formatPopup];
    [[SEIManager sharedInstance] selectPopup:formatPopup itemForFormat:self.settings.format];
        
    [self updateExtension];
}

- (void)willCancel
{
    [self saveSettings];
}

- (void)validateContinue:(ValidateContinueCallback)callback
{
    [self saveSettings];

//    if([self.settings.targetFile isPathExisting]) {
//        NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"The XLIFF file “%@” already exists", nil), [self.settings.targetFile lastPathComponent]]
//                                         defaultButton:NSLocalizedString(@"Cancel", nil)
//                                       alternateButton:NSLocalizedString(@"Overwrite", nil)
//                                           otherButton:nil
//                             informativeTextWithFormat:NSLocalizedString(@"Do you want to overwrite it? This action cannot be undone.", nil)];    
//        if([alert runModal] == NSAlertDefaultReturn) {
//            callback(NO);
//        } else {
//            callback(YES);
//        }        
//    } else {
//        callback(YES);
//    }
    callback(YES);
}

@end
