//
//  ConsoleWC.h
//  iLocalize3
//
//  Created by Jean on 01.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"

@class ProjectController;
@class Console;

@interface ConsoleWC : NSWindowController
{
    id <ProjectProvider>     mProjectProvider;
    NSInteger                mDisplayType;
    
    IBOutlet NSPopUpButton  *mShowTypeButton;
    IBOutlet NSTextField    *mDeleteOldDays;
    
    IBOutlet NSOutlineView  *mOutlineView;
    IBOutlet NSTableView    *mOperationTableView;
    IBOutlet NSTableView    *mLogTableView;
    IBOutlet NSTextView     *mDetailedTextView;
    
    NSMutableArray          *mOperationArray;
    NSMutableArray          *mLogItemArray;
    NSMutableDictionary     *mLevelForItemDictionary;
    
    BOOL                     mHierarchical;
}

- (id)initWithProjectProvider:(id<ProjectProvider>)projectProvider;

- (Console *)console;

- (void)refresh;
- (void)show;

- (IBAction)hierarchical:(id)sender;
- (IBAction)showItems:(id)sender;
- (IBAction)deleteOldDays:(id)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)clearAll:(id)sender;
- (IBAction)export:(id)sender;

@end
