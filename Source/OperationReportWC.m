//
//  OperationReportWC.m
//  iLocalize3
//
//  Created by Jean on 6/3/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "OperationReportWC.h"
#import "OperationCustomCell.h"
#import "Console.h"
#import "ConsoleItem.h"
#import "TableViewCustom.h"

@implementation OperationReportWC

+ (void)showConsoleIfWarningsOrErrorsSinceLastMark:(Console *)console
{
    if ([console hasWarningsOrErrors])
    {
        OperationReportWC *report = [[OperationReportWC alloc] init];
        [report setConsole:console fromIndex:[console indexMark]];
        [report display];
    }    
}

+ (void)showConsoleIfWarningsOrErrorsSinceLastMarkWithDelay:(Console *)console
{
    [self performSelector:@selector(showConsoleIfWarningsOrErrorsSinceLastMark:) withObject:console afterDelay:0];
}


- (id)init
{
    if (self = [super initWithWindowNibName:@"OperationReport"])
    {
        [self window];
        [mTableView setDelegate:self];
        mConsole = nil;    // not retained
        mFromIndex = 0;
        mToIndex = 0;
    }
    
    return self;
}

- (void)setConsole:(Console * )console fromIndex:(NSUInteger)index
{
    mConsole = console;
    mFromIndex = index;
    
    // fd:20170203: we're using NSUInteger now and count on base 1.
    // mToIndex = [mConsole numberOfItems] - 1;
    
    mToIndex = [mConsole numberOfItems];
}

- (int)displayType
{
    return 1 << CONSOLE_ERROR | 1 << CONSOLE_WARNING;
}

- (void)render:(id)item
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"item"] = item;
    info[@"type"] = [item isWarning]?[NSImage imageNamed:@"_warning"]:[NSImage imageNamed:@"_warning_red"];
    info[@"title"] = [item title]==nil?[item description]:[item title];
    info[@"entry"] = [item description];
    
    [mLogsController addObject:info];    
}

- (void)refresh
{
    [mLogsController removeObjects:[mLogsController content]];
    
    NSArray *items = [mConsole allItemsOfStrictType:[self displayType] range:NSMakeRange(mFromIndex, mToIndex - mFromIndex + 1)];
    
    id item;
    
    for (item in items)
    {
        [self render:item];
    }
    
    [mLogsController setSelectionIndex:0];
}

- (void)updateDetailedView
{
    NSString *string = NULL;
    
    if ([mTableView selectedRow] >= 0)
    {
        ConsoleItem *item = [[mLogsController selectedObjects] firstObject][@"item"];
        string = [NSString stringWithFormat:@"[%@] %@", [item dateDescription], [item description]];        
    }
    
    [mDetailedTextView setString:string?string:@""];            
}

- (void)display
{
    [[mTableView tableColumnWithIdentifier:@"description"] setDataCell:[OperationCustomCell cell]];

    [self refresh];
    [self updateDetailedView];
    [NSApp runModalForWindow:[self window]];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notif
{
    [self updateDetailedView];
}

- (IBAction)export:(id)sender
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes:@[@"txt"]];
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result)
    {
        if (result != NSFileHandlingPanelOKButton)
            return;
                      
        NSMutableString *content = [NSMutableString string];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"%m/%d/%Y %H:%M:%S" allowNaturalLanguage:NO];
        [content appendFormat:@"Log on %@", [dateFormatter stringForObjectValue:[NSDate date]]];
        NSEnumerator *enumerator = [[mLogsController content] objectEnumerator];
        NSDictionary *dic;
        
        while (dic = [enumerator nextObject])
        {
            [content appendFormat:@"\n%@", dic[@"entry"]];
        }
        
        [content writeToFile:[[panel URL] path] atomically:NO encoding:[content smallestEncoding] error:nil];
    }];
}

- (IBAction)close:(id)sender
{
    [NSApp stopModal];
    [[self window] orderOut:self];    
}

#pragma mark - 

- (void)customTableView:(NSTableView *)tv willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if ([cell isKindOfClass:[OperationCustomCell class]])
    {
        [cell setCustomValue:[mLogsController arrangedObjects][rowIndex]];            
    }
}

@end
