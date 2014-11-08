//
//  GlossaryManagerWC.h
//  iLocalize3
//
//  Created by Jean on 11.07.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "Protocols.h"

@class GlossaryMergeWC;
@class AZGlassView;
@class GMGlossaryNode;

@interface GlossaryManagerWC : NSWindowController<MenuForTableViewProtocol> {
	IBOutlet NSTreeController *mPathController;
	IBOutlet NSTreeController *mGlossaryController;
	IBOutlet NSOutlineView *mPathOutlineView;
	IBOutlet NSOutlineView *mGlossaryOutlineView;
	IBOutlet NSView *mSplitViewThumbView;		
	IBOutlet NSMenu *mPathMenu;
	IBOutlet NSMenu *mGlossaryMenu;	
    IBOutlet NSSearchField *searchField;
    
	// Elements to display the processing progress bar
	IBOutlet AZGlassView *glassView;
	NSTextField *processingTextField;
	NSProgressIndicator *processingIndicator;
	
	GlossaryMergeWC *mMergeGlossary;
    GMGlossaryNode *glossaryRootNode;
}

@property (strong) GMGlossaryNode *glossaryRootNode;

+ (GlossaryManagerWC*)shared;

- (void)show;
- (void)startProcessingFeedback;

- (void)buildSideBar;
- (void)refresh;
- (void)refreshGlossaries;

- (IBAction)search:(id)sender;

- (IBAction)pathRevealInFinder:(id)sender;
- (IBAction)pathAdd:(id)sender;
- (IBAction)pathRemove:(id)sender;

- (IBAction)glossaryOpen:(id)sender;
- (IBAction)glossaryRevealInFinder:(id)sender;
- (IBAction)glossaryMerge:(id)sender;
- (IBAction)glossaryDelete:(id)sender;

@end
