//
//  XLIFFImportOVC.m
//  iLocalize
//
//  Created by Jean Bovet on 3/24/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XLIFFImportOVC.h"
#import "XLIFFImportSettings.h"
#import "XLIFFImporter.h"
#import "SEIManager.h"

@implementation XLIFFImportOVC

@synthesize settings;

- (id)init
{
    if((self = [super initWithNibName:@"XLIFFImport"])) {
    }
    return self;
}


- (void)awakeFromNib {
    self.useResnameInsteadOfSource.state = NSOffState;
    self.useResnameInsteadOfSource.hidden = YES;
}

- (void)stateChanged {
    [super stateChanged];
    self.useResnameInsteadOfSource.hidden = ![[XLIFFImporter importer] canImportDocument:[filePathControl URL] error:nil];
}

- (IBAction)chooseFile:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:[[SEIManager sharedInstance] allImportableExtensions]];
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if(result == NSFileHandlingPanelOKButton) {
            [filePathControl setURL:[panel URL]];
            [self stateChanged];
        }                    
    }];
}

- (void)filePathChanged:(id)sender
{
    [self stateChanged];    
}

- (void)saveSettings
{
    self.settings.file = [[filePathControl URL] path];
    self.settings.useResnameInsteadOfSource = self.useResnameInsteadOfSource.state == NSOnState;
}

- (BOOL)canContinue
{
    return [filePathControl URL] != nil;
}

- (void)willShow
{        
    if(self.settings.file) {
        [filePathControl setURL:[NSURL fileURLWithPath:self.settings.file]];        
    } else {
        [filePathControl setURL:nil];
    }
    
    self.useResnameInsteadOfSource.state = self.settings.useResnameInsteadOfSource?NSOnState:NSOffState;

    [filePathControl setTarget:self];
    [filePathControl setAction:@selector(filePathChanged:)];
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
