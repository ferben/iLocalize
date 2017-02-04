//
//  ProjectMenuFile.h
//  iLocalize
//
//  Created by Jean on 1/8/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "ProjectMenu.h"

@interface ProjectMenuFile : ProjectMenu
{
}

- (IBAction)createNewSmartFilter:(id)sender;

- (IBAction)openFilesInExternalEditor:(id)sender;
- (IBAction)openPreviousAndCurrent:(id)sender;
- (IBAction)diffPreviousAndCurrent:(id)sender;
- (IBAction)revealFilesInFinder:(id)sender;
//- (IBAction)saveFile:(id)sender;
//- (IBAction)saveAllFiles:(id)sender;
- (IBAction)reloadFile:(id)sender;
- (IBAction)showWarning:(id)sender;

- (IBAction)filesColumnContextualMenuAction:(id)sender;

@end
