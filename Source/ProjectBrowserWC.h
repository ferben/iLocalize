//
//  BrowserWC.h
//  iLocalize3
//
//  Created by Jean on 15.11.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface ProjectBrowserWC : NSWindowController<NSTableViewDataSource,NSTableViewDelegate>
{
    IBOutlet NSView               *containerView;
    IBOutlet NSProgressIndicator  *progressIndicator;
    IBOutlet NSPopUpButton        *actionPopUpButton;
    IBOutlet NSSegmentedControl   *presentationControl;
    IBOutlet NSSearchField        *searchField;
    IBOutlet NSMenu               *actionMenu;
    IBOutlet NSMenuItem           *dateOrderMenuItem;
    IBOutlet NSMenuItem           *nameOrderMenuItem;
    IBOutlet NSSlider             *zoomSlider;
    
    NSScrollView                  *imageBrowserScrollView;
    NSScrollView                  *tableViewScrollView;
    IKImageBrowserView            *browserView;
    NSTableView                   *tableView;

    NSSortDescriptor              *sortDescriptor;
    
    NSOperationQueue              *imageOperationQueue;
    NSMutableArray                *queriedPaths;
    NSMutableArray                *projects;
    NSMutableArray                *importedProjects;
    NSMutableArray                *displayedProjects;
    
    NSDateFormatter               *dateFormatter;
    
    NSMetadataQuery               *query;
}

@property (strong) NSSortDescriptor *sortDescriptor;

+ (void)browse;

- (IBAction)new:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)reveal:(id)sender;
- (IBAction)open:(id)sender;
- (IBAction)zoom:(id)sender;

- (IBAction)sortByDate:(id)sender;
- (IBAction)sortByName:(id)sender;

- (IBAction)togglePresentation:(id)sender;

- (IBAction)search:(id)sender;

@end
