//
//  ProjectMenuProject.h
//  iLocalize
//
//  Created by Jean on 12/24/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectMenu.h"
#import "ExportProjectOVC.h"
#import "ProjectLabelsWC.h"
#import "HistoryManagerWC.h"

@interface ProjectMenuProject : ProjectMenu {
	ExportProjectOVC				*mProjectExport;	
	ProjectLabelsWC				*mProjectLabelsWC;
	HistoryManagerWC            *mHistoryManagerWC;	
}

- (IBAction)launch:(id)sender;
- (IBAction)exportProject:(id)sender;
- (IBAction)exportAgain:(id)sender;

- (IBAction)exportToXLIFF:(id)sender;
- (IBAction)exportFilesToXLIFF:(id)sender;

- (IBAction)exportToStrings:(id)sender;

- (IBAction)importUsingBundle:(id)sender;
- (IBAction)importUsingXLIFF:(id)sender;
- (IBAction)importFilesUsingXLIFF:(id)sender;
- (IBAction)importUsingFiles:(id)sender;

- (IBAction)reloadFiles:(id)sender;
- (IBAction)revertLocalizedFiles:(id)sender;

- (IBAction)addNewLanguage:(id)sender;
- (IBAction)addCustomLanguage:(id)sender;
- (IBAction)renameLanguage:(id)sender;
- (IBAction)renameCustomLanguage:(id)sender;
- (IBAction)removeLanguage:(id)sender;

- (IBAction)addFiles:(id)sender;
- (IBAction)addLocalFiles:(id)sender;
- (IBAction)updateLocalFiles:(id)sender;
- (IBAction)ignoreSelectedFiles:(id)sender;
- (IBAction)deleteSelectedFiles:(id)sender;

- (IBAction)convertLineEndings:(id)sender;
- (IBAction)clean:(id)sender;
- (IBAction)checkProject:(id)sender;
- (IBAction)statistics:(id)sender;
- (IBAction)projectLabels:(id)sender;
- (IBAction)createSnapshot:(id)sender;
- (IBAction)manageSnapshots:(id)sender;

@end
