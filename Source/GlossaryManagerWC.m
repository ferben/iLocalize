//
//  GlossaryManagerWC.m
//  iLocalize3
//
//  Created by Jean on 11.07.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "GlossaryManagerWC.h"

#import "GlossaryManager.h"
#import "GlossaryFolder.h"
#import "Glossary.h"
#import "GlossaryNotification.h"

#import "GMSidebarNode.h"
#import "GMGlossaryNode.h"

#import "ImageAndTextCell.h"
#import "GlossaryMergeWC.h"
#import "ProjectDocument.h"

#import "FileTool.h"
#import "PreferencesWC.h"

#import "AZGlassView.h"

@implementation GlossaryManagerWC

@synthesize glossaryRootNode;

static GlossaryManagerWC *shared = nil;

+ (GlossaryManagerWC *)shared
{
    @synchronized(self)
    {
        if (shared == nil)
            shared = [[GlossaryManagerWC alloc] init];        
    }
    
    return shared;
}

- (id)init
{
    if ((self = [super initWithWindowNibName:@"GlossaryManager"]))
    {
        processingTextField = nil;
        processingIndicator = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(glossaryDidChange:)
                                                     name:GlossaryDidChange
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(glossaryProcessingDidChange:)
                                                     name:GlossaryProcessingDidChange
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(projectDocumentDidClose:)
                                                     name:ILNotificationProjectProviderDidClose
                                                   object:nil];        

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(projectDocumentDidOpen:)
                                                     name:ILNotificationProjectProviderDidOpen
                                                   object:nil];        
                
        [self window];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [[mPathOutlineView tableColumnWithIdentifier:@"Path"] setDataCell:[[ImageAndTextCell alloc] init]];

    for (NSTableColumn *column in [mGlossaryOutlineView tableColumns])
    {
        [column setDataCell:[[ImageAndTextCell alloc] init]];
    }

    [mPathOutlineView registerForDraggedTypes:@[NSFilenamesPboardType]];     
    [mGlossaryOutlineView registerForDraggedTypes:@[NSFilenamesPboardType]];   
    [mGlossaryOutlineView setDraggingSourceOperationMask:(NSDragOperationCopy | NSDragOperationMove) forLocal:NO];    
    
    [mGlossaryOutlineView setDoubleAction:@selector(doubleClickOnGlossariesOutlineView:)];    

    [self startProcessingFeedback];
}

- (void)show
{
    [self buildSideBar];
    [[self window] makeKeyAndOrderFront:self];
}

- (void)startProcessingFeedback
{
    if ([[GlossaryManager sharedInstance] processing])
    {
        NSRect rect = [glassView frame];
        
        if (!processingIndicator)
        {
            processingIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(10, rect.size.height / 2 - 7, 100, 14)];
            [processingIndicator setMinValue:0];
            [processingIndicator setMaxValue:100];
            [processingIndicator setDoubleValue:0];
            [processingIndicator setIndeterminate:NO];
        }
        
        [glassView addSubview:processingIndicator];

        if (!processingTextField)
        {
            processingTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(110, rect.size.height / 2 - 7, 100, 14)];
            [processingTextField setEditable:NO];
            [processingTextField setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];        
            [processingTextField setBordered:NO];
            [processingTextField setDrawsBackground:NO];            
            [processingTextField setStringValue:NSLocalizedString(@"Indexing…", @"Glossary Indexing Process")];
        }
        
        [glassView addSubview:processingTextField];
        
        [processingIndicator startAnimation:self];
    }
}

- (void)glossaryProcessingDidChange:(NSNotification *)notif
{
    GlossaryNotification *n = [notif object];
    
    if (n.action == PROCESSING_STARTED)
    {
        [self startProcessingFeedback];
    }
    else if (n.action == PROCESSING_STOPPED)
    {
        [processingTextField removeFromSuperview];
        [processingIndicator stopAnimation:self];
        [processingIndicator removeFromSuperview];
    }
    else if (n.action == PROCESSING_UPDATED)
    {
        [processingIndicator setDoubleValue:n.processingPercentage];        
    }
}

#pragma mark -

NSInteger projectDocumentSort(id doc1, id doc2, void *context)
{
    NSString *fileName1 = [doc1 fileURL].path;
    NSString *fileName2 = [doc2 fileURL].path;
    
    return [fileName1 caseInsensitiveCompare:fileName2];
}

- (NSArray *)projectDocumentGlossaries
{
    return [[GlossaryManager orderedProjectDocuments] sortedArrayUsingFunction:projectDocumentSort context:nil];
}

- (GMSidebarNode *)addProjectDocumentGlossaries
{
    GMSidebarNode *group = [GMSidebarNode projectGroup];
    
    for (ProjectDocument *doc in [self projectDocumentGlossaries])
    {
        [group.children addObject:[GMSidebarNode nodeWithProjectDocument:doc]];
    }
    
    return group;
}

NSInteger glossaryPathSort(id doc1, id doc2, void *context)
{
    return [[doc1 path] caseInsensitiveCompare:[doc2 path]];
}

- (NSArray *)sortedGlobalFolders
{
    return [[[GlossaryManager sharedInstance] globalFolders] sortedArrayUsingFunction:glossaryPathSort context:nil];
}

- (GMSidebarNode *)addGlobalPathGlossaries
{
    GMSidebarNode *group = [GMSidebarNode globalGroup];    
    
    for (GlossaryFolder *folder in [self sortedGlobalFolders])
    {
        [group.children addObject:[GMSidebarNode nodeWithPath:folder]];
    }
    
    return group;
}

- (NSIndexPath *)indexPathOfNode:(id)node inArray:(NSArray *)array indexPath:(NSIndexPath *)parent
{
    int index = 0;
    
    for (id n in array)
    {
        if ([n isEqual:node])
        {
            return [parent indexPathByAddingIndex:index];
        }
        else if ([[n children] count] > 0)
        {
            NSIndexPath *path = [self indexPathOfNode:node inArray:[n children] indexPath:[parent indexPathByAddingIndex:index]];
            
            if (path)
            {
                return path;
            }
        }
        
        index++;
    }
    
    return nil;
}

- (NSIndexPath *)indexPathForSidebarNode:(GMSidebarNode *)node
{
    return [self indexPathOfNode:node inArray:[mPathController content] indexPath:[[NSIndexPath alloc] init]];
}

- (void)selectDefaultSidebarNode
{
    GMSidebarNode *projectNode = [mPathController content][0];
    GMSidebarNode *globalNode  = [mPathController content][1];

    if ([[projectNode children] count] > 0)
    {
        NSIndexPath *path = [NSIndexPath indexPathWithIndex:0];
        [mPathController setSelectionIndexPath:[path indexPathByAddingIndex:0]];
    }
    else if ([[globalNode children] count] > 0)
    {
        NSIndexPath *path = [NSIndexPath indexPathWithIndex:1];
        [mPathController setSelectionIndexPath:[path indexPathByAddingIndex:0]];
    }
}

- (void)buildSideBar
{
    NSMutableArray *rootItems = [NSMutableArray array];
    [rootItems addObject:[self addProjectDocumentGlossaries]];
    [rootItems addObject:[self addGlobalPathGlossaries]];
    
    [mPathController setContent:rootItems];
    [mPathController rearrangeObjects];
    [self selectDefaultSidebarNode];
    
    [mPathOutlineView expandItem:nil expandChildren:YES];
}

- (void)updateProjectDocumentGlossaries:(GMSidebarNode*)node
{
    [node.children removeAllObjects];
    
    for (ProjectDocument *doc in [self projectDocumentGlossaries])
    {
        [node.children addObject:[GMSidebarNode nodeWithProjectDocument:doc]];
    }    
}

- (void)updateGlobalPathGlossaries:(GMSidebarNode*)node
{
    [node.children removeAllObjects];
    
    for (GlossaryFolder *folder in [self sortedGlobalFolders])
    {
        [node.children addObject:[GMSidebarNode nodeWithPath:folder]];
    }    
}

- (void)refresh
{
    GMSidebarNode *selectedNode = [[mPathController selectedObjects] firstObject];

    NSArray *rootItems = [mPathController content];    
    [self updateProjectDocumentGlossaries:[rootItems firstObject]];
    [self updateGlobalPathGlossaries:rootItems[1]];

    [mPathController rearrangeObjects];    
    [mPathOutlineView expandItem:nil expandChildren:YES];
        
    NSIndexPath *path = [self indexPathForSidebarNode:selectedNode];
    
    if (path)
    {
        [mPathController setSelectionIndexPath:path];        
    }
    else
    {
        [self selectDefaultSidebarNode];
    }
    
    [self refreshGlossaries];
}

- (GMSidebarNode *)selectedSidebarNode
{
    return [[mPathController selectedObjects] firstObject];        
}

- (NSArray *)selectedGlossaries
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (GMGlossaryNode *node in [mGlossaryController selectedObjects])
    {
        if (node.glossary)
        {
            [array addObject:node.glossary];            
        }
    }
    
    return array;
}

- (BOOL)performDragOperation:(NSDragOperation)operation sourcePath:(NSString *)source targetFolderPath:(NSString *)targetFolder
{
    NSString *target = [targetFolder stringByAppendingPathComponent:[source lastPathComponent]];
    
    if ([target isPathExisting])
        return YES;
    
    [[FileTool shared] preparePath:target atomic:YES skipLastComponent:YES];
    
    switch (operation)
    {
        case NSDragOperationCopy:
            return [[NSFileManager defaultManager] copyItemAtPath:source toPath:target error:nil];
        case NSDragOperationMove:
            return [[NSFileManager defaultManager] moveItemAtPath:source toPath:target error:nil];
        case NSDragOperationLink:
            return [FileTool createAliasOfFile:source toFile:target];

        // unused so far
        case NSDragOperationAll_Obsolete:
        case NSDragOperationDelete:
        case NSDragOperationEvery:
        case NSDragOperationGeneric:
        case NSDragOperationNone:
        case NSDragOperationPrivate:
            ;
    }
    
    return NO;
}

- (BOOL)isSourcePathsWritable:(id <NSDraggingInfo>)info
{
    NSPasteboard *pboard = [info draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType])
    {
        for (NSString *path in [pboard propertyListForType:NSFilenamesPboardType])
        {
            if (![[NSFileManager defaultManager] isWritableFileAtPath:path])
            {
                return NO;
            }            
        }
    }
    
    return YES;        
}

- (NSDragOperation)dragOperationForFile:(id <NSDraggingInfo>)info
{
    NSDragOperation operation = [info draggingSourceOperationMask];
    
    if (![self isSourcePathsWritable:info])
    {
        return NSDragOperationCopy;
    }
    
    if (operation == (NSDragOperationGeneric | NSDragOperationCopy))
    {
        // Like in Finder when creating alias
        return NSDragOperationLink;
    }
    
    if (operation & NSDragOperationGeneric)
    {
        return NSDragOperationMove;
    }
    
    if (operation & NSDragOperationCopy)
    {
        return NSDragOperationCopy;
    }
    
    if (operation & NSDragOperationMove)
    {
        return NSDragOperationMove;
    }
    
    if (operation & NSDragOperationLink)
    {
        return NSDragOperationLink;
    }
    
    return NSDragOperationNone;    
}

#pragma mark -
#pragma mark Notifications

- (void)projectDocumentDidOpen:(NSNotification *)notif
{
    [self refresh];    
}

- (void)projectDocumentDidClose:(NSNotification *)notif
{
    [self refresh];    
}

- (void)glossaryDidChange:(NSNotification *)notif
{
    [self refresh];
}

#pragma mark -
#pragma mark Sidebar Actions

- (IBAction)search:(id)sender
{
    [self refreshGlossaries];
}

- (IBAction)pathRevealInFinder:(id)sender
{
    GMSidebarNode *node = [self selectedSidebarNode];
    
    if(node)
    {
        [FileTool revealFile:node.folder.path];
    }
}

- (IBAction)pathAdd:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];
    [panel setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
    [panel beginSheetModalForWindow:[self window]
                  completionHandler:^(NSInteger result)
    {
        if (result == NSModalResponseOK)
        {
            NSString *dir = [[panel URL] path];
            [[GlossaryManager sharedInstance] addFolder:[GlossaryFolder folderForPath:dir name:[dir lastPathComponent]]];
            [[PreferencesWC shared] save];
        }
    }];
}

- (IBAction)pathRemove:(id)sender
{
    GMSidebarNode *node = [self selectedSidebarNode];
    
    if ([node isGlobal])
    {
        [[GlossaryManager sharedInstance] removeFolder:node.folder];
        [[PreferencesWC shared] save];
    }
}

#pragma mark -
#pragma mark Glossaries Actions

- (IBAction)glossaryOpen:(id)sender
{
    NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
    
    for (Glossary *g in [self selectedGlossaries])
    {
        [documentController openDocumentWithContentsOfURL:[NSURL fileURLWithPath:g.targetFile] display:YES completionHandler:
         ^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error)
         {
             if (error)
                 [documentController presentError:error];
         }];
    }
}

- (IBAction)glossaryRevealInFinder:(id)sender
{
    for (Glossary *g in [self selectedGlossaries])
    {
        [FileTool revealFile:g.file];
    }
}

- (IBAction)glossaryMerge:(id)sender
{
    if (!mMergeGlossary)
    {
        mMergeGlossary = [[GlossaryMergeWC alloc] init];        
    }
    
    [mMergeGlossary setGlossaries:[self selectedGlossaries]];
    [mMergeGlossary showWithParent:[self window]];
}

- (IBAction)glossaryDelete:(id)sender
{
    // compose alert
    NSAlert *alert = [NSAlert new];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert setMessageText:NSLocalizedStringFromTable(@"GlossaryManagerMoveTitle",@"Alerts",nil)];
    [alert setInformativeText:NSLocalizedStringFromTable(@"AlertNoUndoDescr",@"Alerts",nil)];
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextMoveToTrash",@"Alerts",nil)];     // 1st button
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextCancel",@"Alerts",nil)];          // 2nd button
    
    // show and evaluate alert
    if ([alert runModal] == NSAlertFirstButtonReturn)
    {
        GlossaryNotification *notif = [GlossaryNotification notificationWithAction:GLOSSARY_DELETED];
        NSMutableArray *deletedFiles = [NSMutableArray array];

        for (Glossary *g in [mGlossaryController selectedObjects])
        {
            [deletedFiles addObject:g.file];
        }
        
        notif.deletedFiles = deletedFiles;
        [[NSNotificationCenter defaultCenter] postNotificationName:GlossaryDidChange object:notif];        

        for (NSString *file in deletedFiles)
        {
            [file movePathToTrash];
        }
        
        [[GlossaryManager sharedInstance] reload];
        [self refresh];
    }        
}

- (void)doubleClickOnGlossariesOutlineView:(id)sender
{
    NSInteger row = [sender clickedRow];
    
    if (row < 0)
        return;

    [self glossaryOpen:sender];
}

#pragma mark -
#pragma mark SplitView

- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex
{
    NSRect r = [mSplitViewThumbView bounds];
    
    r.origin.x = r.origin.x + r.size.width - 15;
    r.size.width = 15;
    
    return [mSplitViewThumbView convertRect:r toView:splitView];         
}

#pragma mark -
#pragma mark Sidebar Outline View
    
- (NSArray *)glossaryNodesForPath:(GlossaryFolder *)folder
{
    self.glossaryRootNode = [GMGlossaryNode nodeWithPath:nil];
    
    for (Glossary *g in [folder glossaries])
    {
        [self.glossaryRootNode insert:g];
    }
    
    [self.glossaryRootNode applySearchString:[searchField stringValue]];
    return self.glossaryRootNode.children;
}

- (void)refreshGlossaries
{
    // Save expanded nodes
    NSMutableArray *expandedItems = [NSMutableArray array];
    
    for (int row = 0; row < [mGlossaryOutlineView numberOfRows]; row++)
    {
        id item = [mGlossaryOutlineView itemAtRow:row];
    
        if ([mGlossaryOutlineView isItemExpanded:item])
        {
            [expandedItems addObject:[item representedObject]];            
        }
    }
        
    GMSidebarNode *node = [self selectedSidebarNode];
    
    if (node)
    {
        [mGlossaryController setContent:[self glossaryNodesForPath:node.folder]];
    }
    else
    {
        self.glossaryRootNode = nil;
        [mGlossaryController setContent:nil];
    }        
    
    [mGlossaryController rearrangeObjects];
    
    // Restore expanded nodes
    for (int row = 0; row < [mGlossaryOutlineView numberOfRows]; row++)
    {
        id item = [mGlossaryOutlineView itemAtRow:row];
    
        for (GMGlossaryNode *node in expandedItems)
        {
            if ([[item representedObject] isEqualTo:node])
            {
                [mGlossaryOutlineView expandItem:item];
            }            
        }
    }
    
    [mGlossaryOutlineView expandItem:[mGlossaryOutlineView itemAtRow:0]];    
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    if ([notification object] == mPathOutlineView)
    {
        [self refreshGlossaries];
    }
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if (outlineView == mPathOutlineView)
    {
        GMSidebarNode *node = [item representedObject];
    
        if ([node isGroup])
        {
            [cell setImage:nil];
        }
        else
        {
            [cell setImage:node.image];            
        }
    }
    else
    {
        if ([[tableColumn identifier] isEqualToString:@"Name"])
        {
            [cell setImage:[[NSWorkspace sharedWorkspace] iconForFile:[[item representedObject] file]]];        
        }        
    }    
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    if (outlineView == mPathOutlineView)
    {
        return [[item representedObject] isGroup];        
    }
    else
    {
        return NO;
    }
}

- (BOOL)outlineView:(NSOutlineView *)ov shouldSelectItem:(id)item
{
    if (ov == mPathOutlineView)
    {
        return ![[item representedObject] isGroup];        
    }
    else
    {
        return YES;
    }
}

- (NSMenu *)menuForTableView:(NSTableView *)tv column:(NSInteger)column row:(NSInteger)row
{
    if (tv == mPathOutlineView)
    {
        return mPathMenu;
    }
    else if (tv == mGlossaryOutlineView)
    {
        return mGlossaryMenu;
    }
    else
    {
        return nil;
    }
}

#pragma mark -
#pragma mark Drag and Drop

- (BOOL)isDraggingFolder:(id <NSDraggingInfo>)info
{
    NSPasteboard *pboard = [info draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType])
    {
        for (NSString *path in [pboard propertyListForType:NSFilenamesPboardType])
        {
            if (![path isPathDirectory]) return NO;
        }
    }
    
    return YES;
}

- (BOOL)isDraggingFile:(id <NSDraggingInfo>)info
{
    NSPasteboard *pboard = [info draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType])
    {
        for (NSString *path in [pboard propertyListForType:NSFilenamesPboardType])
        {
            if (![path isPathRegular])
                return NO;
        }
    }
    
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int)index
{
    GMSidebarNode *node = [item representedObject];

    if ([self isDraggingFolder:info])
    {
        if ([node isGlobalGroup] || [node isGlobal])
        {
            if ([node isGlobal])
            {
                // if the item for the drop is a global path, redirect the drop to the global group item
                [outlineView setDropItem:[mPathOutlineView parentForItem:item] dropChildIndex:NSOutlineViewDropOnItemIndex];            
            }
            
            return NSDragOperationLink;
        }
    }
    else if ([self isDraggingFile:info])
    {
        if ([node isGlobal])
        {
            return [self dragOperationForFile:info];        
        }        
    }
    
    return NSDragOperationNone;        
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(int)index
{
    if ([self isDraggingFolder:info])
    {
        NSPasteboard *pboard = [info draggingPasteboard];
    
        for (NSString *path in [pboard propertyListForType:NSFilenamesPboardType])
        {
            [[GlossaryManager sharedInstance] addFolder:[GlossaryFolder folderForPath:path name:[path lastPathComponent]]];
//            [[GlossaryManager shared] addGlobalPath:[GlossaryPath pathWithPath:path name:[path lastPathComponent] deletable:YES]];
        }        
        
        return YES;
    }
    else if ([self isDraggingFile:info])
    {
        NSPasteboard *pboard = [info draggingPasteboard];
        GMSidebarNode *node = [item representedObject];
        NSString *targetFolderPath = node.folder.path;
    
        for (NSString *path in [pboard propertyListForType:NSFilenamesPboardType])
        {
            [self performDragOperation:[self dragOperationForFile:info] sourcePath:path targetFolderPath:targetFolderPath];
        }        
        
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark -
#pragma mark Glossary Drag and drop

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
    return [self dragOperationForFile:info];
}

- (void)dragOperationError:(NSString *)title info:(NSString *)info
{
    // compose alert
    NSAlert *alert = [NSAlert new];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert setMessageText:title];
    [alert setInformativeText:info];
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextOK",@"Alerts",nil)];     // 1st button
    
    // show alert
    [alert runModal];
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard *pboard = [info draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType])
    {
        GMSidebarNode *node = [self selectedSidebarNode];
        NSString *targetFolder = node.folder.path;
        
        for (NSString *path in [pboard propertyListForType:NSFilenamesPboardType])
        {
            if (![self performDragOperation:operation sourcePath:path targetFolderPath:targetFolder])
            {
                [self dragOperationError:NSLocalizedString(@"An error has occurred while executing the drag and drop operation", nil) 
                                    info:[NSString stringWithFormat:NSLocalizedString(@"Path = %@", nil), path]];
                break;
            }
        }
        
        [[GlossaryManager sharedInstance] reload];
//        [[GlossaryManager shared] updatePaths];
        return YES;
    }
    else
    {
        return NO;            
    }
}

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    NSMutableArray *files = [NSMutableArray array];

    NSUInteger index = [rowIndexes firstIndex];
    
    while (index != NSNotFound)
    {
        Glossary *g = [mGlossaryController content][index];
        [files addObject:[g file]];
        index = [rowIndexes indexGreaterThanIndex:index];
    }
        
    if ([files count] > 0)
    {
        [pboard declareTypes:@[NSFilenamesPboardType] owner:nil];
        [pboard setPropertyList:files forType:NSFilenamesPboardType];        
    }
    
    return ([files count] > 0);
}

#pragma mark -
#pragma mark Validation

- (BOOL)validateMenuItem:(NSMenuItem*)anItem
{
    SEL action = [anItem action];
    BOOL pathSelected = [self selectedSidebarNode] != nil;
    NSUInteger countGlossarySelected = [[mGlossaryController selectedObjects] count];
    BOOL glossarySelected = countGlossarySelected > 0;
    BOOL globalNode = [[self selectedSidebarNode] isGlobal];
    
    if (action == @selector(pathRevealInFinder:))
    {
        return pathSelected;
    }
    
    if (action == @selector(pathRemove:))
    {
        return pathSelected && globalNode;
    }

    if (action == @selector(glossaryOpen:))
    {
        return glossarySelected;
    }
    
    if (action == @selector(glossaryRevealInFinder:))
    {
        return glossarySelected;
    }
    
    if (action == @selector(glossaryMerge:))
    {
        return (countGlossarySelected > 1);
    }
    
    if (action == @selector(glossaryDelete:))
    {
        return glossarySelected;
    }
    
    return YES;
}

@end
