//
//  ProjectFiles.m
//  iLocalize
//
//  Created by Jean on 12/20/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectFilesController.h"
#import "ProjectWC.h"
#import "ProjectLabels.h"

#import "ProjectDocument.h"
#import "PreferencesGeneral.h"
#import "ProjectPrefs.h"
#import "ProjectFileWarningWC.h"
#import "ProjectModel.h"

#import "SaveAllOperation.h"
#import "LineEndingsConverterOperation.h"
#import "EncodingOperation.h"

#import "LanguageController.h"
#import "FileController.h"
#import "StringController.h"
#import "FMEditor.h"

#import "FileCustomCell.h"
#import "FileTypeCustomCell.h"
#import "FileEncodingCustomCell.h"
#import "FileContentCustomCell.h"
#import "FileStatusCustomCell.h"
#import "FileProgressCustomCell.h"
#import "FileLabelCustomCell.h"

#import "ContextualMenuCornerView.h"

#import "TableViewCustom.h"
#import "StringEncoding.h"
#import "StringEncodingTool.h"
#import "FileTool.h"
#import "Constants.h"
#import "AZStandardVersionComparator.h"
#import "AZArrayController.h"

#define FILE_COLUMN_TYPE_IDENTIFIER @"Type"
#define FILE_COLUMN_FILE_IDENTIFIER @"File"
#define FILE_COLUMN_CONTENT_IDENTIFIER @"Content"
#define FILE_COLUMN_STATUS_IDENTIFIER @"Status"
#define FILE_COLUMN_PROGRESS_IDENTIFIER @"Progress"
#define FILE_COLUMN_LABEL_IDENTIFIER @"Labels"

@implementation ProjectFilesController

@synthesize previousRelativePathForVersionMenu;

+ (ProjectFilesController*)newInstance:(ProjectWC*)projectWC
{
    ProjectFilesController *controller = [[ProjectFilesController alloc] initWithNibName:@"ProjectViewFiles" bundle:nil];
    controller.projectWC = projectWC;
    return controller;
}

- (void)awakeFromNib
{
    mPreviouslySelectedFiles = nil;
    
    mSelectedFiles = [[NSMutableArray alloc] init];
    mSelectedEncodingSet = [[NSMutableSet alloc] init];
    mProjectFileWarning = [[ProjectFileWarningWC alloc] init];

    [mFilesController setDelegate:self];

    // Note: disabled because otherwise the drag and drop from the Finder doesn't take above the file table.
    // Will need to work that out later on to re-introduce drag from the file table.
//    [mFilesTableView registerForDraggedTypes:[NSArray arrayWithObjects:PBOARD_DATA_LANGUAGE_STRINGS, 
//                                              PBOARD_DATA_FILES_STRINGS,
//                                              PBOARD_DATA_STRINGS, NSFilenamesPboardType, nil]];    
    
    [mFilesTableView setDelegate:self];
    [[mFilesTableView headerView] setMenu:mFilesColumnTableViewContextualMenu];
    
    [mFilesTableView setTarget:self];
    [mFilesTableView setAction:@selector(clickOnFilesTableView:)];
    [mFilesTableView setDoubleAction:@selector(doubleClickOnFilesTableView:)];    
    
    [[mFilesTableView tableColumnWithIdentifier:FILE_COLUMN_TYPE_IDENTIFIER] setDataCell:[FileTypeCustomCell cell]];
    [[mFilesTableView tableColumnWithIdentifier:FILE_COLUMN_FILE_IDENTIFIER] setDataCell:[FileCustomCell cell]];
    [[mFilesTableView tableColumnWithIdentifier:FILE_COLUMN_CONTENT_IDENTIFIER] setDataCell:[FileContentCustomCell cell]];
    [[mFilesTableView tableColumnWithIdentifier:FILE_COLUMN_STATUS_IDENTIFIER] setDataCell:[FileStatusCustomCell cell]];
    [[mFilesTableView tableColumnWithIdentifier:FILE_COLUMN_PROGRESS_IDENTIFIER] setDataCell:[FileProgressCustomCell cell]];
    [[mFilesTableView tableColumnWithIdentifier:FILE_COLUMN_LABEL_IDENTIFIER] setDataCell:[FileLabelCustomCell cell]];
    
    //[mFilesTableView setCornerView:[ContextualMenuCornerView cornerWithMenu:mFilesColumnTableViewContextualMenu]];

    mFileEncodingMenu = [[StringEncodingTool shared] availableEncodingsMenuWithTarget:[[self projectWC] projectMenuEdit] action:@selector(fileEncodingMenuAction:)];
    [mFileEncodingContextualMenuItem setSubmenu:mFileEncodingMenu];    

    mSelectedFilesSupportEncoding = NO;
    
    [self setFilesColumnInfo:[[self.projectWC projectPreferences] filesColumnInfo]];
    [self syncFilesTableColumns];    
        
    [mFilesTableView scrollRowToVisible:[mFilesTableView selectedRow]];    
}

- (void)dealloc
{
    [mFilesController unbind:@"contentArray"];
    
}

#pragma mark -

- (void)bindToLanguagesController:(NSArrayController*)controller
{
    [mFilesController bind:@"contentArray" toObject:controller withKeyPath:@"selection.filteredFileControllers" options:nil];
}

- (void)unbindFromLanguagesController
{
    [mFilesController unbind:@"contentArray"];
}

- (void)save
{
    [[self.projectWC projectPreferences] setSelectedFile:[[[self selectedFileControllers] firstObject] relativeFilePath]];
    [[self.projectWC projectPreferences] setFilesColumnInfo:[self filesColumnInfo]];
}

- (void)selectSavedFile
{
    NSUInteger selectedIndex = 0;
    NSString *selectedFile = [[self.projectWC projectPreferences] selectedFile];
    if(selectedFile) {
        int index = 0;
        for(FileController *fc in [mFilesController content]) {
            if([[fc relativeFilePath] isEqualCaseInsensitiveToString:selectedFile]) {
                selectedIndex = index;
                break;
            }            
            index++;
        }
    }
    [mFilesController setSelectionIndex:selectedIndex];        
    [mFilesTableView scrollRowToVisible:selectedIndex];
}

- (void)rememberSelectedFiles
{
    [mSelectedFiles removeAllObjects];
    for(FileController *fc in [self selectedFileControllers]) {
        [mSelectedFiles addObject:[fc relativeBaseFilePath]];
    }
}

- (void)selectRememberedFiles
{
    NSMutableArray *files = [NSMutableArray array];

    for(FileController *fc in [[self filesArrayController] content]) {
        // mSelectedFiles contains the relative file path in the base language reference
        // which will be used to identify all the files.
        for(NSString *selectedFile in mSelectedFiles) {
            if([selectedFile isEqualToString:[fc relativeBaseFilePath]]) {
                [files addObject:fc];
            }
        }
    }
    
    [[self filesArrayController] setSelectedObjects:files];
    [mFilesTableView scrollRowToVisible:[mFilesTableView selectedRow]];
}

- (void)prefsShowSmartPathDidChange
{
    [mFilesTableView setNeedsDisplay:YES];
    
/*    if([[PreferencesGeneral shared] tableViewShowSmartPath]) {
        [mFilesTableViewContextualMenu setMenuItemState:NSControlStateValueOff withTag:FILES_CONTEXTUAL_SHOW_FULL_PATH_TAG];
    } else {
        [mFilesTableViewContextualMenu setMenuItemState:NSControlStateValueOn withTag:FILES_CONTEXTUAL_SHOW_FULL_PATH_TAG];
    }*/
}

- (void)updateSelectedFilesEncoding
{
    mSelectedFilesSupportEncoding = YES;
    [mSelectedEncodingSet removeAllObjects];
    for(FileController *fc in [self selectedFileControllers]) {
        if([fc supportsEncoding]) {
            [mSelectedEncodingSet addObject:[fc encoding]];    
        } else {
            mSelectedFilesSupportEncoding = NO;
        }        
    }
}

- (BOOL)selectedFilesSupportEncoding
{
    return mSelectedFilesSupportEncoding;
}

- (NSString*)handleToolTipRequestedAtPosition:(NSPoint)pos
{
    NSRect tv = [mFilesTableView convertRect:[mFilesTableView visibleRect] toView:nil];
    
    if (NSPointInRect(pos, tv))
    {
        NSInteger row;
        NSInteger column;

        NSPoint posInCell = [Utils posInCellAtMouseLocation:pos row:&row column:&column tableView:mFilesTableView];
    
        if (!NSEqualPoints(posInCell, NSMakePoint(-1, -1)))
        {
            NSString *identifier = [(NSTableColumn*)[mFilesTableView tableColumns][column] identifier];
            FileController *fc = [[self filesArrayController] arrangedObjects][row];
            
            if ([identifier isEqualToString:@"Type"])
            {
                if ([fc supportsEncoding])
                {
                    return [fc encodingName];
                }
            }

            if ([identifier isEqualToString:@"Status"])
            {
                if ([fc displayStatus])
                {
                    return [fc statusDescriptionAtPosition:posInCell];
                }
            }
        }
    }    

    return nil;
}

- (void)setFilesListWithGlobalFlag:(BOOL)global
{
    NSArray *filesToSelect = mPreviouslySelectedFiles;
    mPreviouslySelectedFiles = [mFilesController selectedObjects];
    
    NSArrayController *lc = [self.projectWC languagesController];
    
    if(global) {
        [mFilesController bind:@"contentArray" toObject:lc withKeyPath:@"selection.filteredFileControllers" options:nil];
        if(filesToSelect) {
            [mFilesController setSelectedObjects:filesToSelect];            
        }                        
    } else {
        [mFilesController bind:@"contentArray" toObject:lc withKeyPath:@"selection.filteredLocalFileControllers" options:nil];        
        if(filesToSelect) {
            [mFilesController setSelectedObjects:filesToSelect];            
        } else {
            if([[mFilesController content] count] > 0) {
                [mFilesController setSelectionIndex:0];                                
            }
        }        
    }
    [self.projectWC refreshListOfFiles];    
}

#pragma mark -

- (TableViewCustom*)filesTableView
{
    return mFilesTableView;
}

- (NSArrayController*)filesArrayController
{
    return (NSArrayController*)mFilesController;
}

- (NSArray*)filesController
{
    return [mFilesController content];
}

- (NSArray*)selectedFileControllers
{
    return [mFilesController selectedObjects];
}

- (void)selectFileController:(FileController*)fc
{
    [mFilesController setSelectedObjects:@[fc]];
}

- (void)selectFirstFile
{
    [[self filesArrayController] setSelectionIndex:0];
}

- (void)deselectAll
{
    NSIndexSet *emptySelection = [NSIndexSet indexSet];
    [mFilesController setSelectionIndexes:emptySelection];
}

- (void)setNeedsDisplayToAllTableViews
{
    [mFilesTableView setNeedsDisplay:YES];    
}

#pragma mark -

- (NSString *)identifierColumnForTag:(NSInteger)tag
{
    switch (tag)
    {
        case 0: return FILE_COLUMN_TYPE_IDENTIFIER;
        case 1: return FILE_COLUMN_FILE_IDENTIFIER;
        case 2: return FILE_COLUMN_CONTENT_IDENTIFIER;
        case 3: return FILE_COLUMN_STATUS_IDENTIFIER;
        case 4: return FILE_COLUMN_PROGRESS_IDENTIFIER;
        case 5: return FILE_COLUMN_LABEL_IDENTIFIER;
    }
    
    NSLog(@"No identifier for file column with tag %ld", tag);

    return nil;
}

- (int)tagForFilesColumnIdentifier:(NSString*)identifier
{
    if([identifier isEqualToString:FILE_COLUMN_TYPE_IDENTIFIER]) return 0;
    if([identifier isEqualToString:FILE_COLUMN_FILE_IDENTIFIER]) return 1;
    if([identifier isEqualToString:FILE_COLUMN_CONTENT_IDENTIFIER]) return 2;
    if([identifier isEqualToString:FILE_COLUMN_STATUS_IDENTIFIER]) return 3;
    if([identifier isEqualToString:FILE_COLUMN_PROGRESS_IDENTIFIER]) return 4;
    if([identifier isEqualToString:FILE_COLUMN_LABEL_IDENTIFIER]) return 5;
    
    NSLog(@"No tag for file column with identifier %@", identifier);
    return -1;
}

- (void)syncFilesTableColumns
{
    for (NSTableColumn *column in [mFilesTableView tableColumns])
    {
        [mFilesColumnTableViewContextualMenu setMenuItemState:[column isHidden]?NSControlStateValueOff:NSControlStateValueOn
                                                      withTag:[self tagForFilesColumnIdentifier:[column identifier]]];        
    }
}

- (void)setFilesColumnInfo:(NSArray *)info
{
    int index = 0;
    
    for (NSDictionary *dic in info)
    {
        NSString *identifier = dic[@"id"];
        NSTableColumn *column = [mFilesTableView tableColumnWithIdentifier:identifier];

        if (column == nil)
        {
            NSLog(@"No column found with identifier %@", identifier);
            continue;
        }
        
        [column setWidth:[dic[@"width"] intValue]];
        [column setHidden:[dic[@"hidden"] boolValue]];
        
        // move the colum if necessary
        NSInteger colIndex = [mFilesTableView columnWithIdentifier:identifier];
        
        if (colIndex != index && colIndex < [mFilesTableView numberOfColumns] && index < [mFilesTableView numberOfColumns])
        {
            [mFilesTableView moveColumn:colIndex toColumn:index];
        }
        
        index++;
    }

    [mFilesTableView sizeToFit];
}

- (NSArray*)filesColumnInfo
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(NSTableColumn *column in [mFilesTableView tableColumns]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"id"] = [column identifier];
        dic[@"width"] = [NSNumber numberWithInt:[column width]];
        dic[@"hidden"] = @([column isHidden]);
        [array addObject:dic];        
    }
    return array;
}

- (void)showFilesTableColumn:(NSString*)identifier
{
    [[mFilesTableView tableColumnWithIdentifier:identifier] setHidden:NO];
}

- (BOOL)hideFilesTableColumn:(NSString*)identifier
{
    if([[mFilesTableView tableColumns] count] > 1) {
        [[mFilesTableView tableColumnWithIdentifier:identifier] setHidden:YES];
        return YES;
    } else {
        return NO;
    }
}

- (void)showHideFilesTableColumn:(id)sender
{
    int state = [sender state];
    NSString *identifier = [self identifierColumnForTag:[sender tag]];    
    if(identifier == nil) {
        NSLog(@"No files column identifier found for tag %ld", (long) [sender tag]);
        return;
    }
    
    if(state == NSControlStateValueOn) {
        if([self hideFilesTableColumn:identifier]) {
            [sender setState:NSControlStateValueOff];                    
        }
    } else {
        [self showFilesTableColumn:identifier];
        [sender setState:NSControlStateValueOn];
    }
    [[self.projectWC document] setDirty];
}

#pragma mark -

- (int)ignoreStateForSelectedFiles
{
    BOOL first = YES;
    int state = NSControlStateValueOff;
    for(FileController *fc in [self selectedFileControllers]) {
        if(first) {
            first = NO;
            if([fc ignore])
                state = NSControlStateValueOn;
            else
                state = NSControlStateValueOff;
        } else {
            if([fc ignore] && state == NSControlStateValueOff) {
                state = NSControlStateValueMixed;                
            }
            if(![fc ignore] && state == NSControlStateValueOn) {
                state = NSControlStateValueMixed;
            }
        }        
    }
    return state;
}

- (int)encodingStateForSelectedFilesWithEncoding:(StringEncoding*)se
{
    if([mSelectedEncodingSet containsObject:se]) {
        return [mSelectedEncodingSet count]>1?NSControlStateValueMixed:NSControlStateValueOn;
    } else {
        return NSControlStateValueOff;
    }        
}

- (void)showWarning:(FileController*)fc
{
    [mProjectFileWarning setProjectProvider:[self.projectWC projectDocument]];
    [mProjectFileWarning setParentWindow:[self.projectWC window]];
    [mProjectFileWarning setFileController:fc];
    [mProjectFileWarning showAsSheet];    
}

- (void)removeFromOpenPreviousVersionMenu
{
    [mOpenPreviousVersionMenu removeAllItems];
    [mOpenPreviousVersionMenu addItemWithTitle:NSLocalizedString(@"No Previous Version", nil) action:nil keyEquivalent:@""];
}

/** Returns the version of the application
 @param path The path of the application
 @param language The language to use to fetch the version (usually the base language)
 @return The version string
 */
- (NSString*)versionAtPath:(NSString*)path language:(NSString*)language {
    NSString *shortVersionString = [FileTool shortVersionOfBundle:path language:language];
    NSString *versionString = [FileTool versionOfBundle:path language:language];
    NSString *version;
    if(shortVersionString) {
        version = shortVersionString;
    } else if(versionString) {
        version = versionString;
    } else {
        version = [path lastPathComponent];
    }
    return version;
}

/** Returns a sorted array of applications in the history folder in increasing order (v1, v2, v3, etc)
 */
- (NSArray*)sortedHistoryApplications {
    NSMutableArray *sortedApps = [NSMutableArray array];
    NSString *historyPath = [[[self.projectWC projectDocument] projectModel] projectHistoryFolderPath];
    NSString *language = [[[self.projectWC projectDocument] projectModel] baseLanguage];

    for(NSString *name in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:historyPath error:nil]) {
        // Get the version
        NSString *previousApp = [historyPath stringByAppendingPathComponent:name];
        [sortedApps addObject:previousApp];
    }
    
    [sortedApps sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *v1 = [self versionAtPath:obj1 language:language];
        NSString *v2 = [self versionAtPath:obj2 language:language];
        return [[AZStandardVersionComparator defaultComparator] compareVersion:v1 toVersion:v2];
    }];
    
    return sortedApps;
}

/** Returns the path for the previous version of the specified file controller, or nil if none exists
 */
- (NSString*)previousPathForFileController:(FileController*)fc {
    NSString *relativePath = [fc relativeFilePath];
    for (NSString *app in [[self sortedHistoryApplications] reverseObjectEnumerator]) {
        // Get the absolute path to the previous version
        NSString *previousPath = [app stringByAppendingPathComponent:relativePath];
        if([previousPath isPathExisting]) {
            return previousPath;
        }
    }
    return nil;
}

- (void)openPreviousVersionMenuNeedsUpdate:(NSMenu*)menu
{
    mOpenPreviousVersionMenu = menu;
        
    [menu removeAllItems];
    NSString *relativePath = [[[self selectedFileControllers] firstObject] relativeFilePath];
    if(relativePath != nil) {
        NSString *language = [[[self.projectWC projectDocument] projectModel] baseLanguage];
        for (NSString *app in [self sortedHistoryApplications]) {
            // Get the absolute path to the previous version
            NSString *previousPath = [app stringByAppendingPathComponent:relativePath];
            if([previousPath isPathExisting]) {
                NSString *title = [NSString stringWithFormat:@"%@ - %@", [relativePath lastPathComponent], [self versionAtPath:app language:language]];
                NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(openPreviousVersion:) keyEquivalent:@""];
                [item setTarget:self];
                [item setRepresentedObject:previousPath];
                [menu addItem:item];
            }
        }
    }
    
    if([menu numberOfItems] == 0) {
        [menu addItemWithTitle:NSLocalizedString(@"No Previous Version", nil) action:nil keyEquivalent:@""];
    }
}

- (IBAction)openPreviousVersion:(id)sender
{
    [[self.projectWC projectDocument] openFileWithExternalEditor:[sender representedObject]];
}

#pragma mark -

- (void)clickOnFilesTableView:(id)sender
{
}

- (void)doubleClickOnFilesTableView:(id)sender
{
    NSInteger row = [sender clickedRow];
    
    if (row < 0)
        return;
    
    NSTableColumn *column = [sender tableColumns][[sender clickedColumn]];
    
    if ([[column identifier] isEqualToString:FILE_COLUMN_STATUS_IDENTIFIER])
    {
        FileController *fc = [mFilesController arrangedObjects][row];
    
        if ([fc statusWarning])
            [self showWarning:fc];
    }
    else
    {
        [[NSApplication sharedApplication] sendAction:@selector(openFilesInExternalEditor:) to:nil from:self];        
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notif
{
    [self updateSelectedFilesEncoding];
    [self.projectWC fmEditorDidChange];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tv
{
    return 0;
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return NULL;
}

#pragma mark Drag and Drop

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
    [pboard declareTypes:@[PBOARD_DATA_FILES_STRINGS, PBOARD_DATA_ROW_INDEXES, PBOARD_OWNER_POINTER, NSFilenamesPboardType]
                   owner:self];        
    
    // FIX CASE 23
    [pboard setPropertyList:[[[mFilesController arrangedObjects] objectsAtIndexes:rowIndexes] buildArrayOfFileControllerPaths] forType:NSFilenamesPboardType];
    
    [pboard setData:[NSKeyedArchiver archivedDataWithRootObject:rowIndexes] forType:PBOARD_DATA_ROW_INDEXES];
    [pboard setPropertyList:@((long)self) forType:PBOARD_OWNER_POINTER];
    return YES;
}

- (NSArray*)buildArrayOfStringModelsForFileControllers:(NSArray*)fcs
{
    NSMutableArray *array = [NSMutableArray array];
    
    FileController *fc;
    for(fc in fcs) {
        NSEnumerator *enumeratorSC = [[fc visibleStringControllers] objectEnumerator];
        StringController *sc;
        while(sc = [enumeratorSC nextObject]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[PBOARD_SOURCE_KEY] = [sc base];
            dic[PBOARD_TARGET_KEY] = [sc translation];
            [array addObject:dic];            
        }
    }
    
    return array;
}

- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type
{
    if(![[sender types] containsObject:PBOARD_DATA_ROW_INDEXES]) {
        NSLog(@"No rows found in pasteboard!");
        return;
    }
    
    NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:[sender dataForType:PBOARD_DATA_ROW_INDEXES]];
    
    if([type isEqualToString:PBOARD_DATA_LANGUAGE_STRINGS]) {
        LanguageController *lc = [[self.projectWC languagesController] arrangedObjects][[rowIndexes firstIndex]];
        NSArray *scs = [self buildArrayOfStringModelsForFileControllers:[lc fileControllers]];
        [sender setData:[NSKeyedArchiver archivedDataWithRootObject:scs] forType:type];
    } else if([type isEqualToString:PBOARD_DATA_FILES_STRINGS]) {
        NSArray *scs = [self buildArrayOfStringModelsForFileControllers:[[self filesController] objectsAtIndexes:rowIndexes]];
        [sender setData:[NSKeyedArchiver archivedDataWithRootObject:scs] forType:type];
    }
}

- (NSMenu *)customTableViewContextualMenu:(id)tv row:(NSInteger)row column:(NSInteger)column
{
    if (row == -1)
        return nil;
    
    if (column != -1 && [[(NSTableColumn *)[tv tableColumns][column] identifier] isEqualToString:FILE_COLUMN_LABEL_IDENTIFIER])
    {
        return [[self.projectWC projectLabels] fileLabelsMenu];
    }
    else
    {
        return mFilesTableViewContextualMenu;            
    }            
}

- (void)customTableView:(NSTableView *)tv willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if([cell isKindOfClass:[AbstractFileCustomCell class]]) {
        [cell setProjectWC:self.projectWC];
    }
}

- (id)arrayControllerFilterObject:(id)entry
{
/*    NSString *searchString = [mSearchField stringValue];
    if([searchString length] == 0 || mSearchContext != SEARCH_FILES)
        return entry;
    
    if([[entry filename] rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound)
        return entry;
    
    return nil;*/
    return entry;
}

- (void)performExportToStrings:(NSString*)targetFolder
{
    NSEnumerator *enumerator = [[self selectedFileControllers] objectEnumerator];
    FileController *fc;
    while(fc = [enumerator nextObject]) {
        NSString *sourcePath = [fc absoluteFilePath];
        NSString *filename = [[[sourcePath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"strings"];
        NSString *targetPath = [targetFolder stringByAppendingPathComponent:filename];
        [[self.projectWC currentFileEditor] exportFile:sourcePath toStringsFile:targetPath];
    }    
}

- (void)exportToStrings
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setMessage:NSLocalizedString(@"Choose the folder where to export the selected file(s)", nil)];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];
    [panel setPrompt:NSLocalizedString(@"Export", nil)];
    [panel beginSheetModalForWindow:[self.projectWC window]
                  completionHandler:^(NSInteger result) {
                      if(result == NSModalResponseOK) {
                          [self performSelector:@selector(performExportToStrings:) withObject:[[panel URL] path] afterDelay:0];
                      }
                  }];
}

- (void)translateUsingStringsFile
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAccessoryView:mTranslateWithFileStringsView];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowedFileTypes:@[@"strings"]];
    [panel beginSheetModalForWindow:[self.projectWC window]
                  completionHandler:^(NSInteger result) {
        if(result == NSModalResponseOK) {
                          [self performSelector:@selector(performTranslateUsingStringsFile:) withObject:[[panel URL] path] afterDelay:0];
                      }
                  }];
}

- (void)performTranslateUsingStringsFile:(NSString*)file
{
    [[self.projectWC currentFileEditor] translateUsingStringsFile:file];
}

@end
