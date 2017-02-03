//
//  GlossaryWC.m
//  iLocalize3
//
//  Created by Jean on 09.04.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "GlossaryWC.h"
#import "GlossaryNotification.h"
#import "GlossaryManager.h"
#import "GlossaryNotIndexedWC.h"
#import "Glossary.h"
#import "GlossaryEntry.h"

#import "Constants.h"
#import "StringController.h"
#import "StringModel.h"
#import "StringsContentModel.h"

#import "StringsEngine.h"
#import "StringsContentModel.h"

#import "ControlCharactersParser.h"
#import "StringTool.h"

#import "PreferencesGeneral.h"

#import "PasteboardProvider.h"

#import "AZArrayController.h"
#import "TableViewCustom.h"
#import "TableViewCustomCell.h"

#import "AddLanguageWC.h"
#import "CustomFieldEditor.h"
#import "RecentDocuments.h"
#import "LanguageTool.h"

#import "SEIManager.h"
#import "XMLExporter.h"

@interface GlossaryWC ()

@property (nonatomic, strong) GlossaryNotIndexedWC *indexedWC;

@end

@implementation GlossaryWC

@synthesize glossary;

+ (GlossaryWC *)controller
{
    return [[self alloc] init];
}

- (id)init
{
    if ((self = [super initWithWindowNibName:@"GlossaryWC"]))
    {
        [self window];
        
        mCustomFieldEditor = [[CustomFieldEditor alloc] init];

        mShowInvisibleCharacters = NO;
        mCheckWhenSaved = NO;
                
        mFilterValue = nil;
        [mEntriesController setDelegate:self];
        
        [mEntryTableView registerForDraggedTypes:@[PBOARD_DATA_LANGUAGE_STRINGS, 
                                                   PBOARD_DATA_FILES_STRINGS,
                                                   PBOARD_DATA_STRINGS]];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(glossaryDidChange:)
                                                     name:GlossaryDidChange
                                                   object:nil];        
        
        [self performSelector:@selector(checkIfGlossaryIsIndexed) withObject:nil afterDelay:0];
        [self updateInfo];        
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [[PasteboardProvider shared] removeOwner:self];
}

- (void)awakeFromNib
{
    [[mEntryTableView tableColumnWithIdentifier:@"Source"] setDataCell:[TableViewCustomCell textCell]];
    [[mEntryTableView tableColumnWithIdentifier:@"Target"] setDataCell:[TableViewCustomCell textCell]];    
}

- (NSString *)sourceLanguage
{
    return [[mGlossaryController content] sourceLanguage];
}

- (NSString *)targetLanguage
{
    return [[mGlossaryController content] targetLanguage];
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
    if ([self window] == [notification object])
    {
        [RecentDocuments documentOpened:[self document]];            
    }
}

- (void)windowWillClose:(NSNotification *)notif
{
    if ([notif object] == [self window])
    {
        [mEntryTableView abortEditing];
        [RecentDocuments documentClosed:[self document]];
    }
}

- (id)windowWillReturnFieldEditor:(NSWindow *)sender toObject:(id)anObject
{
    if ([anObject isKindOfClass:[TableViewCustom class]])
    {    
        // make sure it will behave like a text field editor (Enter will end editing)
        [mCustomFieldEditor setFieldEditor:YES];
        [mCustomFieldEditor setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];
        [mCustomFieldEditor setShowInvisibleCharacters:mShowInvisibleCharacters];        
        return mCustomFieldEditor;
    }
    return nil;
}

- (void)checkIfGlossaryIsIndexed
{
    NSString *filename = [[self document] fileURL].path;
    
    if(!filename)
    {
        return;
    }
        
    if ([[GlossaryManager sharedInstance] isGlossaryFileIndexed:filename])
    {
        [mTopRightWindowView removeFromSuperview];
    }
    else
    {
        // Establish the top-right corner view if the glossary is not indexed
        NSView *themeFrame = [[self.window contentView] superview];
        NSRect c = [themeFrame frame];  // c for "container"
        NSRect aV = [mTopRightWindowView frame];      // aV for "accessory view"
        
        NSRect newFrame = NSMakeRect(c.size.width  - aV.size.width,     // x position
                                     c.size.height - aV.size.height,    // y position
                                     aV.size.width,                     // width
                                     aV.size.height);                   // height
        [mTopRightWindowView setFrame:newFrame];
        [themeFrame addSubview:mTopRightWindowView];                        
    }
}

- (void)reload
{
    [mEntriesController setContent:[NSMutableArray arrayWithArray:[self.glossary entries]]];
    
    [mGlossaryController addObject:self.glossary];
    
    [self updateInfo];    
}

- (void)applyChanges
{
    [self.glossary removeAllEntries];
    [self.glossary addEntries:mEntriesController.content];
}

- (void)selectEntryWithBase:(NSString *)base translation:(NSString *)translation
{
    for (GlossaryEntry *entry in [mEntriesController arrangedObjects])
    {
        if ([entry.source isEqualToString:base] && [entry.translation isEqualToString:translation])
        {
            [mEntriesController setSelectedObjects:@[entry]];
            NSUInteger row = [mEntriesController selectionIndex];
        
            [mEntryTableView scrollRowToVisible:row];
            break;
        }
    }
}

- (void)updateInfo
{
    NSUInteger total = [[mEntriesController content] count];
    NSUInteger arranged = [[mEntriesController arrangedObjects] count];
    NSString *title;
    
    if (total == arranged)
    {
        switch (total)
        {
            case 0:
                title = NSLocalizedString(@"No entry", @"Glossary Entries Information");
                break;
            case 1:
                title = NSLocalizedString(@"One entry", @"Glossary Entries Information");
                break;
            default:
                title = [NSString stringWithFormat:NSLocalizedString(@"%d entries", @"Glossary Entries Information"), total];
                break;
        }
    }
    else
    {
        switch (total)
        {
            case 0:
                title = NSLocalizedString(@"No entry", @"Glossary Entries Information");
                break;
            case 1:
                title = [NSString stringWithFormat:NSLocalizedString(@"%d of one entry", @"Glossary Entries Information"), arranged];
                break;
            default:
                title = [NSString stringWithFormat:NSLocalizedString(@"%d of %d entries", @"Glossary Entries Information"), arranged, total];
                break;
        }        
    }
    
    [mInfoField setStringValue:title];
}

- (IBAction)indexGlossary:(id)sender
{
    __weak GlossaryWC *weakSelf = self;
    
    self.indexedWC = [[GlossaryNotIndexedWC alloc] init];
    
    self.indexedWC.didCloseCallback = ^()
    {
        [[weakSelf document] setFileURL:[NSURL fileURLWithPath:[weakSelf.indexedWC targetPath]]];
        [weakSelf checkIfGlossaryIsIndexed];
    };
    
    [self.indexedWC setGlossaryPath:[[self document] fileURL].path];
    [self.indexedWC showWithParent:[self window]];
}

- (IBAction)add:(id)sender
{
    [sender setState:NSOffState];

    GlossaryEntry *entry = [[GlossaryEntry alloc] init];
    entry.source = @"";
    entry.translation = @"";
    [mEntriesController addObject:entry];
    
    [[self document] updateChangeCount:NSChangeDone];
    [self updateInfo];

    [mEntryTableView editColumn:0 row:[[mEntriesController content] count] - 1 withEvent:nil select:YES];
    [mEntryTableView makeSelectedRowVisible];
}

- (IBAction)remove:(id)sender
{
    [mEntriesController remove:sender];
    [mEntryTableView makeSelectedRowVisible];
    [[self document] updateChangeCount:NSChangeDone];
    [self updateInfo];
}

- (IBAction)search:(id)sender
{
    mFilterValue = [sender stringValue]; 
    [mEntriesController rearrangeObjects];
    [mEntryTableView rowsHeightChanged];
    [self updateInfo];
}

- (GlossaryEntry *)arrayControllerFilterObject:(GlossaryEntry *)entry
{
    if ([mFilterValue length] == 0)
        return entry;
    
    if ([entry.source rangeOfString:mFilterValue options:NSCaseInsensitiveSearch].location != NSNotFound)
        return entry;
    
    if ([entry.translation rangeOfString:mFilterValue options:NSCaseInsensitiveSearch].location != NSNotFound)
        return entry;
    
    return nil;
}

- (IBAction)showInvisibleCharacters:(id)sender
{
    mShowInvisibleCharacters = !mShowInvisibleCharacters;
    [mEntryTableView setNeedsDisplay:YES];
}

#pragma mark -

- (void)updateEntry:(GlossaryEntry *)entry
{
    for (GlossaryEntry *e in [mEntriesController content])
    {
        if ([e.source isEqualToString:entry.source])
        {
            e.translation = entry.translation;
        }
    }
}

- (void)glossaryDidChange:(NSNotification *)notif
{
    GlossaryNotification *gn = [notif object];
    
    if (gn.action == GLOSSARY_DELETED)
    {
        // Close this window if the glossary was deleted
        if ([gn.deletedFiles containsObject:self.glossary.file])
        {
            [self close];
            return;
        }
    }
    
    if (gn.source == self.glossary)
    {
        // Ignore if notification was emitted for this glossary instance (it means
        // this document was saved so we already have the latest representation).
        [self reload];
        return;
    }

    // Check if the document is indexed
    [self checkIfGlossaryIsIndexed];

    // Revert the document if it changed
    NSString *file = [[self document] fileURL].path;
    
    if ([gn.modifiedFiles containsObject:file])
    {
        NSError *err = nil;
    
        if ([self.document revertToContentsOfURL:[NSURL fileURLWithPath:file] ofType:[self.document fileType] error:&err])
        {
            [self reload];
        }
        else
        {
            NSAlert *alert = [NSAlert alertWithError:err];
            
            [alert beginSheetModalForWindow:[self window] completionHandler:NULL];
        }
    }
}

- (void)renameLanguageWithSelector:(SEL)sel
{
    if (mAddLanguageWC == nil)
    {
        mAddLanguageWC = [[AddLanguageWC alloc] init];        
    }
    
    [mAddLanguageWC setParentWindow:[self window]];
    [mAddLanguageWC setProjectProvider:nil];
    [mAddLanguageWC setCheckForExistingLanguage:NO];
    [mAddLanguageWC setDidCloseSelector:sel target:self];
    [mAddLanguageWC setRenameLanguage:YES];
    
    if (sel == @selector(performRenameSourceLanguage))
    {
        [mAddLanguageWC setInitialLanguageSelection:[[self sourceLanguage] displayLanguageName]];        
    }
    else
    {
        [mAddLanguageWC setInitialLanguageSelection:[[self targetLanguage] displayLanguageName]];
    }

    [mAddLanguageWC showAsSheet];    
}

- (void)performRenameSourceLanguage
{
    if ([mAddLanguageWC hideCode] != 1)
        return;
    
    [[mGlossaryController content] setSourceLanguage:[mAddLanguageWC language]];    
    [self updateInfo];
    [[self document] updateChangeCount:NSChangeDone];
}

- (void)performRenameTargetLanguage
{
    if ([mAddLanguageWC hideCode] != 1)
        return;
        
    [[mGlossaryController content] setTargetLanguage:[mAddLanguageWC language]];    
    [self updateInfo];
    [[self document] updateChangeCount:NSChangeDone];    
}

- (IBAction)renameSourceLanguage:(id)sender
{
    [self renameLanguageWithSelector:@selector(performRenameSourceLanguage)];
}

- (IBAction)renameTargetLanguage:(id)sender
{
    [self renameLanguageWithSelector:@selector(performRenameTargetLanguage)];
}

int entrySort(id e1, id e2, void *context)
{
    return [[e1 source] compare:[e2 source]];
}

- (IBAction)removeDuplicateEntries:(id)sender
{
    // compose alert
    NSAlert *alert = [NSAlert new];
    
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert setMessageText:NSLocalizedStringFromTable(@"GlossaryRemoveTitle",@"Alerts",nil)];
    [alert setInformativeText:NSLocalizedStringFromTable(@"AlertNoUndoDescr",@"Alerts",nil)];
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextRemove",@"Alerts",nil)];  // 1st button
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextCancel",@"Alerts",nil)];  // 2nd button
    
    // show and evaluate alert
    if ([alert runModal] == NSAlertFirstButtonReturn)
    {
        if ([self.glossary removeDuplicateEntries])
        {
            [mEntriesController rearrangeObjects];
            [[self document] updateChangeCount:NSChangeDone];
            [self updateInfo];            
        }
    }        
}

#pragma mark -

- (void)tableViewDeleteSelectedRows:(NSTableView*)tv
{
    [self remove:self];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    return NULL;
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
    [[PasteboardProvider shared] declareTypes:@[PBOARD_DATA_ROW_INDEXES, PBOARD_DATA_STRINGS]
                                        owner:self
                                   pasteboard:pboard];
    [pboard setData:[NSArchiver archivedDataWithRootObject:rowIndexes] forType:PBOARD_DATA_ROW_INDEXES];
    return YES;
}

- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type
{
    if (![[sender types] containsObject:PBOARD_DATA_ROW_INDEXES])
    {
        NSLog(@"No rows found in pasteboard!");
        return;
    }
    
    NSIndexSet *rowIndexes = [NSUnarchiver unarchiveObjectWithData:[sender dataForType:PBOARD_DATA_ROW_INDEXES]];
    
    if ([type isEqualToString:PBOARD_DATA_STRINGS])
    {
        NSArray *scs = [[mEntriesController arrangedObjects] objectsAtIndexes:rowIndexes];
        NSMutableArray *array = [NSMutableArray array];
    
        for (GlossaryEntry *entry in scs)
        {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[PBOARD_SOURCE_KEY] = entry.source;
            dic[PBOARD_TARGET_KEY] = entry.translation;
            [array addObject:dic];
        }
        
        [sender setData:[NSArchiver archivedDataWithRootObject:array] forType:type];
    }
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    if (operation == NSTableViewDropOn)
        [tableView setDropRow:MIN(row+1, [[mEntriesController arrangedObjects] count] - 1) dropOperation:NSTableViewDropAbove];

    NSPasteboard *pboard = [info draggingPasteboard];
    
    if ([[pboard types] containsObject:PBOARD_DATA_LANGUAGE_STRINGS])
        return NSDragOperationCopy;

    if ([[pboard types] containsObject:PBOARD_DATA_FILES_STRINGS])
        return NSDragOperationCopy;

    if ([[pboard types] containsObject:PBOARD_DATA_STRINGS])
        return NSDragOperationCopy;
    
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
    NSArray *scs = nil;
    
    NSPasteboard *pboard = [info draggingPasteboard];

    if ([[pboard types] containsObject:PBOARD_DATA_LANGUAGE_STRINGS])
    {
        scs = [NSUnarchiver unarchiveObjectWithData:[pboard dataForType:PBOARD_DATA_LANGUAGE_STRINGS]];        
    }
    else if([[pboard types] containsObject:PBOARD_DATA_FILES_STRINGS])
    {
        scs = [NSUnarchiver unarchiveObjectWithData:[pboard dataForType:PBOARD_DATA_FILES_STRINGS]];
    }
    else if([[pboard types] containsObject:PBOARD_DATA_STRINGS])
    {
        scs = [NSUnarchiver unarchiveObjectWithData:[pboard dataForType:PBOARD_DATA_STRINGS]];
    }
    
    BOOL dirty = NO;
    
    NSEnumerator *enumerator = [scs reverseObjectEnumerator];
    NSDictionary *dic;
    
    while ((dic = [enumerator nextObject]))
    {
        GlossaryEntry *entry = [[GlossaryEntry alloc] init];
        entry.source = dic[PBOARD_SOURCE_KEY];
        entry.translation = dic[PBOARD_TARGET_KEY];

        if (![[mEntriesController content] containsObject:entry])
        {
            dirty = YES;
            [mEntriesController insertObject:entry atArrangedObjectIndex:row];
            
            if ([mFilterValue length])
                [mEntriesController rearrangeObjects];
        }
    }
    
    if (dirty)
    {
        [self updateInfo];
        [[self document] updateChangeCount:NSChangeDone];
    }
    
    return scs != nil;
}

- (BOOL)shouldStopOnEntry:(GlossaryEntry *)entry
{
    return [entry.translation length] == 0;
}

- (NSUInteger)indexOfNextNonTranslatedEntry
{
    NSArray *content = [mEntriesController arrangedObjects];
    
    BOOL backwards = ([[[NSApplication sharedApplication] currentEvent] modifierFlags] & NSShiftKeyMask) > 0;    
    
    NSUInteger startIndex = [content indexOfObject:[[mEntriesController selectedObjects] firstObject]];
    NSUInteger maxIndex = [content count];
    NSUInteger index = startIndex;
    
    while (YES)
    {
        if (backwards)
        {
            index--;
        }
        else
        {
            index++;            
        }
                
        if (index >= maxIndex)
            index = 0;
        
        if (index == 0)
            index = maxIndex - 1;
        
        if (index == startIndex)
        {
            // Back at the start position -> no more strings to translate
            if (![self shouldStopOnEntry:content[index]])
            {
                if (backwards)
                {
                    if (index > 0)
                        return index - 1;
                    else
                        return maxIndex - 1;
                }
                else
                {
                    if (index + 1 < maxIndex)
                        return index + 1;
                    else
                        return 0;
                }
            }
            
            break;            
        }
        
        if ([self shouldStopOnEntry:content[index]])
        {
            break;
        }
    }
    
    return index;
}

- (void)tableViewDidHitEnterKey:(NSTableView *)tv
{
    // Select the next string to translate or the next line if no strings remain to translate.
    NSUInteger index = [self indexOfNextNonTranslatedEntry];
    
    NSUInteger row = index;
    
    [mEntryTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    [mEntryTableView editColumn:1 row:row withEvent:nil select:YES];
}

- (void)tableViewTextDidBeginEditing:(NSTableView *)tv columnIdentifier:(NSString *)identifier rowIndex:(NSInteger)rowIndex textView:(TextViewCustom *)textView
{
    NSString *language = nil;
    NSString *keypath = nil;
    
    if ([identifier isEqualToString:@"Source"])
    {
        language = [self sourceLanguage];
        keypath = @"selection.source";
    }
    
    if ([identifier isEqualToString:@"Target"])
    {
        language = [self targetLanguage];
        keypath = @"selection.translation";
    }    
    
    if (language)
    {
        [LanguageTool setSpellCheckerLanguage:language];        
    }
    
    [textView setRichText:NO];
    [textView setFont:[NSFont fontWithName:@"Lucida Grande" size:13]];
    [textView bind:@"value"
          toObject:mEntriesController
       withKeyPath:keypath
           options:@{NSContinuouslyUpdatesValueBindingOption: @YES}];    
    
    [textView selectAll:self];
}

- (void)tableViewTextDidEndEditing:(NSTableView *)tv textView:(TextViewCustom *)textView
{
    [textView unbind:@"value"];
}

- (void)tableViewTextDidEndEditing:(NSTableView *)tv
{
    [[self document] updateChangeCount:NSChangeDone];

    [mEntryTableView selectedRowsHeightChanged];
    
    NSEvent *event = [NSApp currentEvent];
    
    if ([event type] == NSKeyDown)
    {
        NSString *chars = [event charactersIgnoringModifiers];
    
        if ([chars length] > 0 && [chars characterAtIndex:0] == NSEnterCharacter)
        {
            [self tableViewDidHitEnterKey:tv];
        }        
    }
}

- (void)customTableView:(NSTableView *)aTableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    GlossaryEntry *entry = [mEntriesController arrangedObjects][row];
    
    if ([[tableColumn identifier] isEqualToString:@"Source"])
    {
        [cell setValue:entry.source];        
    }
    
    if ([[tableColumn identifier] isEqualToString:@"Target"])
    {
        [cell setValue:entry.translation];        
    }
    
    if ([cell isHighlighted])
    {
        [cell setForegroundColor:[NSColor whiteColor]];
    }
    else
    {
        [cell setForegroundColor:[NSColor blackColor]];        
    }        
    
    [cell setShowInvisibleCharacters:mShowInvisibleCharacters];
}

- (BOOL)validateMenuItem:(NSMenuItem*)anItem
{
    SEL action = [anItem action];
    
    if (action == @selector(showInvisibleCharacters:))
    {
        if (mShowInvisibleCharacters)
        {
            [anItem setTitle:NSLocalizedString(@"Hide Invisible Characters", nil)];
        }
        else
        {
            [anItem setTitle:NSLocalizedString(@"Show Invisible Characters", nil)];
        }
        
        return YES;
    }
    
    if (action == @selector(saveFile:))
    {
        return [[self document] isDocumentEdited];
    }
    
    return YES;
}

@end
