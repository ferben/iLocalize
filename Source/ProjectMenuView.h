//
//  ProjectMenuView.h
//  iLocalize
//
//  Created by Jean on 12/24/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectMenu.h"

@interface ProjectMenuView : ProjectMenu
{
}

- (IBAction)showInfoProject:(id)sender;
- (IBAction)showInfoFile:(id)sender;
- (IBAction)showInfoString:(id)sender;
- (IBAction)showInfoGlossary:(id)sender;
- (IBAction)showInfoAlternate:(id)sender;

- (IBAction)toggleTextZone:(id)sender;
- (IBAction)toggleKeyColumn:(id)sender;
- (IBAction)showInvisibleCharacters:(id)sender;

- (IBAction)showFilesCommonToAllLanguages:(id)sender;
- (IBAction)showFilesSpecificToCurrentLanguage:(id)sender;

- (IBAction)toggleStructureView:(id)sender;
- (IBAction)toggleStatusBar:(id)sender;

@end
