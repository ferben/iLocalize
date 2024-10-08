//
//  BrowserWC.m
//  iLocalize3
//
//  Created by Jean on 15.11.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ProjectBrowserWC.h"
#import "ApplicationDelegate.h"
#import "Constants.h"
#import "FileTool.h"
#import "ProjectDiskOperations.h"
#import "ProjectModel.h"
#import "ProjectItem.h"

static NSString * const kSortOrderKey = @"SortOrder";
static NSString * const kSortOrderByNameValue = @"SortByName";
static NSString * const kSortOrderByDateValue = @"SortByDate";

@interface ProjectBrowserWC (PrivateMethods)
- (void)show;
@end

@interface ProjectBrowserWC (Threads)
- (void)startThread;
- (void)stopThread;
- (void)threadStopped;
- (void)threadedBrowse:(NSString*)folder;
@end

@implementation ProjectBrowserWC

static NSMutableDictionary *imageCache;
static ProjectBrowserWC *shared = nil;

@synthesize sortDescriptor;

+ (void)browse
{
    if(!shared) {
        shared = [[ProjectBrowserWC alloc] init];    
    }
    [shared show];
}

- (id)init
{
    if((self = [super initWithWindowNibName:@"ProjectBrowser"])) {        
        imageCache = [[NSMutableDictionary alloc] init];
        
        imageOperationQueue = [[NSOperationQueue alloc] init];
        [imageOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
        
        projects = [[NSMutableArray alloc] init];
        importedProjects = [[NSMutableArray alloc] init];
        displayedProjects = [[NSMutableArray alloc] init];
                
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        [[self window] center];

        // Setup the spotlight query
        query = [[NSMetadataQuery alloc] init];        
        NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
        [nf addObserver:self selector:@selector(queryNotification:) name:nil object:query];        
        [query setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:(id)kMDItemFSName ascending:YES]]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];


    [imageOperationQueue cancelAllOperations];
    [imageOperationQueue waitUntilAllOperationsAreFinished];


    
    
}

- (NSScrollView*)createScrollView
{
    NSRect rect = [containerView frame];
    
    NSScrollView *sv = [[NSScrollView alloc] initWithFrame:NSMakeRect(-1, 0, rect.size.width+2, rect.size.height+1)];
    [sv setBorderType:NSBezelBorder];
    [sv setHasVerticalScroller:YES];
    [sv setHasHorizontalScroller:NO];
    [sv setAutohidesScrollers:YES];
    [sv setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
    [containerView addSubview:sv];
    
    return sv;
}

- (NSSortDescriptor*)sortByNameDescriptor
{
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES comparator:(NSComparator)^(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch|NSCaseInsensitiveSearch];
    }];
    return nameDescriptor;
}

- (NSSortDescriptor*)sortByLocationDescriptor
{
    NSSortDescriptor *locationDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"path" ascending:YES comparator:(NSComparator)^(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch|NSCaseInsensitiveSearch];
    }];
    return locationDescriptor;
}

- (NSSortDescriptor*)sortByDateDescriptor
{
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO comparator:(NSComparator)^(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    return dateDescriptor;
}

- (void)awakeFromNib
{
    // Image browser
    imageBrowserScrollView = [self createScrollView];
    NSSize contentSize = [imageBrowserScrollView contentSize];
    
    browserView = [[IKImageBrowserView alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
    [browserView setCellsStyleMask:IKCellsStyleTitled|IKCellsStyleSubtitled];
    [browserView setAnimates:YES];
    [browserView setDelegate:self];
    [browserView setDataSource:self];
    [imageBrowserScrollView setDocumentView:browserView];
    
    // Table view
    tableViewScrollView = [self createScrollView];
    contentSize = [tableViewScrollView contentSize];

    tableView = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, contentSize.width, contentSize.height)];
    [tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setAllowsMultipleSelection:NO];
    [tableView setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
    [tableView setDoubleAction:@selector(doubleClickOnTable:)];

    CGFloat width = contentSize.width;
    
    NSTableColumn *nameColumn = [[NSTableColumn alloc] initWithIdentifier:@"name"];
    [nameColumn setWidth:width*0.15];    
    [nameColumn setMinWidth:width*0.15];    
    [nameColumn setEditable:NO];
    [[nameColumn headerCell] setStringValue:NSLocalizedString(@"Name", @"Project Browser Column")];
    [nameColumn setSortDescriptorPrototype:[self sortByNameDescriptor]];                            
    [tableView addTableColumn:nameColumn];

    NSTableColumn *locationColumn = [[NSTableColumn alloc] initWithIdentifier:@"location"];
    [locationColumn setWidth:width*0.7];
    [locationColumn setEditable:NO];
    [[locationColumn headerCell] setStringValue:NSLocalizedString(@"Location", @"Project Browser Column")];
    [[locationColumn dataCell] setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [locationColumn setSortDescriptorPrototype:[self sortByLocationDescriptor]];                            
    [tableView addTableColumn:locationColumn];

    NSTableColumn *modifiedColumn = [[NSTableColumn alloc] initWithIdentifier:@"modified"];
    [modifiedColumn setWidth:width*.2];
    [modifiedColumn setMinWidth:width*0.15];
    [modifiedColumn setEditable:NO];
    [[modifiedColumn headerCell] setStringValue:NSLocalizedString(@"Modified Date", @"Project Browser Column")];
    [modifiedColumn setSortDescriptorPrototype:[self sortByDateDescriptor]];                            
    [tableView addTableColumn:modifiedColumn];
        
    [tableViewScrollView setDocumentView:tableView];
    [tableView sizeToFit];
}

- (void)switchPresentation
{
    if([presentationControl selectedSegment] == 0) {
        [imageBrowserScrollView setHidden:NO];
        [tableViewScrollView setHidden:YES];
        [zoomSlider setHidden:NO];
    } else {
        [imageBrowserScrollView setHidden:YES];
        [tableViewScrollView setHidden:NO];
        [zoomSlider setHidden:YES];
    }
}

- (void)setActiveSortDescriptor:(NSSortDescriptor *)sd
{
    self.sortDescriptor = sd;
    [tableView setSortDescriptors:@[sd]];
}

- (void)updateBrowserView
{
    [displayedProjects removeAllObjects];
    [displayedProjects addObjectsFromArray:projects];
    
    if(self.sortDescriptor) {
        [displayedProjects sortUsingDescriptors:@[self.sortDescriptor]];        
    }

    // Filter
    NSString *filter = [searchField stringValue];
    if([filter length] > 0) {
        [displayedProjects filterUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", filter]];        
    }
    
    // Reload the data
    [browserView reloadData];
    [tableView reloadData];
}

/**
 Fetches the icon of the source of the project if available.
 */
- (void)fetchImage:(ProjectItem*)pi
{
    NSString *path = pi.path;
    @synchronized(imageCache) {
        if(imageCache[path]) {
            pi.image = imageCache[path];
            return;
        } 
    }
    
    @try {
        ProjectModel *model = [ProjectDiskOperations readModelFromPath:path];
        NSString *p = [model projectSourceFilePath];
        NSImage *image = nil;
        if([p isPathExisting]) {
            image = [[NSWorkspace sharedWorkspace] iconForFile:p];
        }
        if(!image && [path isPathExisting]) {
            image = [[NSWorkspace sharedWorkspace] iconForFile:path];
        }
        pi.image = image;
        @synchronized(imageCache) {
            imageCache[path] = pi.image;        
        }
    }
    @catch (NSException * e) {
        EXCEPTION2(([NSString stringWithFormat:@"Unable to get the project image from: %@", path]), e);
    }            
 }

- (void)queryUpdateResults:(NSNotification*)notif
{
    [importedProjects removeAllObjects];

    NSArray* results = [(NSMetadataQuery*)[notif object] results];
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMetadataItem *item = obj;
        NSString *path = [[item valueForAttribute:(NSString*)kMDItemPath] stringByResolvingSymlinksInPath];
        NSDate *lastUsedDate = [item valueForAttribute:(NSString*)kMDItemLastUsedDate];
        if(![path hasSuffix:@"~.ilocalize"]) {
            ProjectItem *pi = [[ProjectItem alloc] init];
            pi.name = [[path lastPathComponent] stringByDeletingPathExtension];
            pi.path = path;
            if(!lastUsedDate) {
                lastUsedDate = [path pathModificationDate];
            }
            if(lastUsedDate) {
                pi.date = lastUsedDate;
            } else {
                pi.date = nil;
            }
            pi.dateFormatter = dateFormatter;
            [importedProjects addObject:pi];
            
            [imageOperationQueue addOperationWithBlock:^(void) {
                [self fetchImage:pi];
                [browserView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }];            
        }
    }];

    [projects removeAllObjects];
    [projects addObjectsFromArray:importedProjects];
    
    [self updateBrowserView];        
}

- (void)queryNotification:(NSNotification*)note
{
    // the NSMetadataQuery will send back a note when updates are happening.
    
    // by looking at the [note name], we can tell what is happening
    if ([[note name] isEqualToString:NSMetadataQueryDidStartGatheringNotification])
    {
        // the query has just started
        [progressIndicator startAnimation:self];
    }
    else if ([[note name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification])
    {
        // at this point, the query will be done. You may receive an update later on.
        [self queryUpdateResults:note];
        [progressIndicator stopAnimation:self];
    }
    else if ([[note name] isEqualToString:NSMetadataQueryGatheringProgressNotification])
    {
        // the query is still gathering results...
    }
    else if ([[note name] isEqualToString:NSMetadataQueryDidUpdateNotification])
    {
        // an update will happen when Spotlight notices that a file as added,
        // removed, or modified that affected the search results.
        [self queryUpdateResults:note];
    }    
}

- (void)show
{
    // Ensure default selection
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if([ud objectForKey:@"presentationMode"] == nil) {
        [ud setInteger:0 forKey:@"presentationMode"];
    }
    if([ud objectForKey:@"zoomValue"] == nil) {
        [ud setFloat:0.5 forKey:@"zoomValue"];
    }
    if([ud objectForKey:kSortOrderKey] == nil) {
        [ud setObject:kSortOrderByDateValue forKey:kSortOrderKey];
    }
    
    if ([[ud objectForKey:kSortOrderKey] isEqual:kSortOrderByDateValue]) {
        [self setActiveSortDescriptor:[self sortByDateDescriptor]];
    }
    if ([[ud objectForKey:kSortOrderKey] isEqual:kSortOrderByNameValue]) {
        [self setActiveSortDescriptor:[self sortByNameDescriptor]];
    }
    [browserView setZoomValue:[zoomSlider floatValue]];

    // Start the query
    [query setPredicate: [NSPredicate predicateWithFormat: @"(kMDItemKind like \"iLocalize 3 Project\")"]];
    [query startQuery];        
    
    [self switchPresentation];
    
    [[self window] makeKeyAndOrderFront:self];    
}

- (ProjectItem*)selectedProjectItem
{
    NSIndexSet *indexes;
    if([tableViewScrollView isHidden]) {
        indexes = [browserView selectionIndexes];
    } else {
        indexes = [tableView selectedRowIndexes];        
    }
    NSUInteger index = [indexes firstIndex];
    if(index != NSNotFound) {
        return displayedProjects[index];
    } else {
        return nil;
    }
}

- (void)openSelectedProject
{
    ProjectItem *item = [self selectedProjectItem];
    
    if (!item)
        return;
    
    NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
    
    [documentController openDocumentWithContentsOfURL:[NSURL fileURLWithPath:item.path] display:YES completionHandler:
    ^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error)
    {
        if (error)
        {
            [documentController presentError:error];
            // [[NSAlert alertWithError:error] beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
            [[self window] close];
        }
    }];
}

- (void)keyDown:(NSEvent *)theEvent
{
    NSString *keyString = [theEvent charactersIgnoringModifiers];
    unichar   keyChar = [keyString characterAtIndex:0];
    if(keyChar == '\r' || keyChar == 3) {
        [self openSelectedProject];
    }
}

- (IBAction)new:(id)sender
{
    [[self window] close];        
    [(ApplicationDelegate*)[NSApp delegate] newProject:sender];
}

- (IBAction)delete:(id)sender
{
    // compose alert
    NSAlert *alert = [NSAlert new];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert setMessageText:NSLocalizedStringFromTable(@"ProjectBrowserDeleteTitle",@"Alerts",nil)];
    [alert setInformativeText:NSLocalizedStringFromTable(@"ProjectBrowserDeleteDescr",@"Alerts",nil)];
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextCancel",@"Alerts",nil)];      // 1st button
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextMoveToTrash",@"Alerts",nil)]; // 2nd button
    
    // show alert
    NSInteger alertReturnCode = [alert runModal];

    if (alertReturnCode == NSAlertSecondButtonReturn)    // Move to Trash
    {
        NSString *projectPath = [[self selectedProjectItem].path stringByDeletingLastPathComponent];
        [projectPath movePathToTrash];
    }        
}

- (IBAction)reveal:(id)sender
{
    [FileTool revealFile:[self selectedProjectItem].path];
}

- (IBAction)open:(id)sender
{
    [self openSelectedProject];
}

- (IBAction)zoom:(id)sender 
{
    [browserView setZoomValue:[sender floatValue]];  
}

- (IBAction)sortByDate:(id)sender
{
    [self setActiveSortDescriptor:[self sortByDateDescriptor]];
    [self updateBrowserView];
    [[NSUserDefaults standardUserDefaults] setObject:kSortOrderByDateValue forKey:kSortOrderKey];
}

- (IBAction)sortByName:(id)sender
{
    [self setActiveSortDescriptor:[self sortByNameDescriptor]];
    [self updateBrowserView];
    [[NSUserDefaults standardUserDefaults] setObject:kSortOrderByNameValue forKey:kSortOrderKey];
}

- (IBAction)togglePresentation:(id)sender
{
    [self switchPresentation];
}

- (IBAction)search:(id)sender
{
    [self updateBrowserView];    
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    SEL action = [menuItem action];
    BOOL enabled = YES;
    NSString *sortKey = [self.sortDescriptor key];
    
    if (action == @selector(sortByDate:))
    {
        if ([sortKey isEqual:@"date"])
        {
            [menuItem setState:NSControlStateValueOn];
        }
        else
        {
            [menuItem setState:NSControlStateValueOff];            
        }
    }
    else if(action == @selector(sortByName:))
    {
        if ([sortKey isEqual:@"name"])
        {
            [menuItem setState:NSControlStateValueOn];
        }
        else
        {
            [menuItem setState:NSControlStateValueOff];            
        }
    }
    else
    {
        enabled = [self selectedProjectItem] != nil;
    }

    return enabled;
}

#pragma mark Image Browser

- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *)aBrowser
{
    return [displayedProjects count];
}

- (id) imageBrowser:(IKImageBrowserView *)aBrowser itemAtIndex:(NSUInteger)index
{
    return displayedProjects[index];
}

- (void) imageBrowser:(IKImageBrowserView *)aBrowser cellWasDoubleClickedAtIndex:(NSUInteger) index
{
    [self openSelectedProject];
}

- (void) imageBrowser:(IKImageBrowserView *)aBrowser cellWasRightClickedAtIndex:(NSUInteger) index withEvent:(NSEvent *)event
{
    [NSMenu popUpContextMenu:actionMenu withEvent:event forView:aBrowser];
}

#pragma mark Table View

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [displayedProjects count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    ProjectItem *item = displayedProjects[rowIndex];
    NSString *identifier = [aTableColumn identifier];
    
    if ([identifier isEqualToString:@"name"])
    {
        return [item name];
    }
    
    if ([identifier isEqualToString:@"location"])
    {
        return [[[item path] stringByAbbreviatingWithTildeInPath] stringByDeletingLastPathComponent];
    }
    
    if ([identifier isEqualToString:@"modified"])
    {
        return [item imageSubtitle];
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    self.sortDescriptor = [[aTableView sortDescriptors] firstObject];
    [self updateBrowserView];
}

- (void)doubleClickOnTable:(id)sender
{
    [self openSelectedProject];
}

@end
