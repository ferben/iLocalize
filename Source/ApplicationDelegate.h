//
//  Application.h
//  iLocalize3
//
//  Created by Jean on 31.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

@class NewProjectSettings;
@class ProjectDocument;

@interface ApplicationDelegate : NSObject<NSMenuDelegate> {
    IBOutlet NSMenuItem    *mOpenPreviousVersionMenuItem;
    IBOutlet NSMenuItem    *mViewLanguageMenuItem;
    IBOutlet NSMenuItem    *mEncodingMenuItem;
    
    IBOutlet NSMenu *mFileMenu;
    IBOutlet NSMenu *mOpenRecentProjectMenu;
    IBOutlet NSMenu *mOpenRecentGlossaryMenu;
    IBOutlet NSMenu *mHelpMenu;
    
    NSWindowController *mSymbolWindowController;
}

- (IBAction)aboutWindow:(id)sender;

- (IBAction)browseProjects:(id)sender;
- (IBAction)newProject:(id)sender;
- (IBAction)openAndRepair:(id)sender;

- (IBAction)manageGlossary:(id)sender;

- (IBAction)showPreferences:(id)sender;
- (IBAction)showSymbols:(id)sender;
- (IBAction)localizationOnMacOSX:(id)sender;
- (IBAction)appleGlossariesFTP:(id)sender;
- (IBAction)makeDonation:(id)sender;

@end
