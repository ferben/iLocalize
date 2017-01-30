//
//  ProjectDetailsGlossary.h
//  iLocalize
//
//  Created by Jean on 12/28/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectDetails.h"
#import "IGroupEngineManager.h"

@class GlossaryScope;
@class GlossaryScopeWC;

@interface ProjectDetailsGlossary : ProjectDetails <IGroupEngineManagerDelegate, NSTableViewDelegate>
{
	IBOutlet NSTableView *mTableView;
	IBOutlet NSArrayController *mResultsController;
	IBOutlet NSMenu *actionMenu;
	IBOutlet NSTextField *searchField;
    IBOutlet NSProgressIndicator *progressIndicator;
    NSTableColumn *scoreColumn;
	IGroupEngineManager *mGroupEngineManager;
	NSArray *sortDescriptors;
	NSArray *elements;
}

@property (strong) GlossaryScopeWC *scopeWC;
@property (strong) NSArray *elements;

- (IBAction)use:(id)sender;
- (IBAction)reveal:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)scope:(id)sender;
- (IBAction)search:(id)sender;

@end
