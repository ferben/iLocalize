//
//  ProjectDetailsAlternate.h
//  iLocalize
//
//  Created by Jean Bovet on 1/23/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ProjectDetails.h"
#import "IGroupEngineManager.h"

@interface ProjectDetailsAlternate : ProjectDetails<IGroupEngineManagerDelegate,NSTableViewDelegate> {
    IBOutlet NSTableView *mTableView;
    IBOutlet NSArrayController *mResultsController;
    IBOutlet NSTextField *searchField;
    IGroupEngineManager *mGroupEngineManager;
    NSArray *sortDescriptors;
    NSArray *elements;
}
@property (strong) NSArray *elements;
- (IBAction)search:(id)sender;
@end
