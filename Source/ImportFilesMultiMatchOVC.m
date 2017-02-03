//
//  MultipleFileMatchWC.m
//  iLocalize3
//
//  Created by Jean on 09.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ImportFilesMultiMatchOVC.h"
#import "FileMatchItem.h"
#import "LanguageController.h"

@implementation ImportFilesMultiMatchOVC

@synthesize matchItems;

- (id)init
{
    if(self = [super initWithNibName:@"ImportFilesMultiMatch"]) {
        multiMatchItems = [[NSMutableArray alloc] init];
    }
    return self;
}


+ (NSArray*)matchesFiles:(NSArray*)files languageController:(LanguageController*)languageController multipleMatch:(BOOL*)multipleMatch
{
    *multipleMatch = NO;
    NSMutableArray *matches = [NSMutableArray array];    
    for(NSString *file in files) {
        NSArray *array = [languageController fileControllersMatchingName:[file lastPathComponent]];
        if([array count] > 0) {
            [matches addObject:[FileMatchItem itemWithFile:file matchingFileControllers:array]];
            if([array count] > 1) {
                *multipleMatch = YES;
            }
        }
    }
    return matches;
}

- (NSString*)nextButtonTitle
{
    return NSLocalizedString(@"Continue", nil);
}

- (void)willShow
{
    [multiMatchItems removeAllObjects];
    for(FileMatchItem *item in matchItems) {
        if([[item matchingFiles] count] > 1) {
            [multiMatchItems addObject:item];
        }
    }
    [tableView reloadData];
}

- (NSUInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [multiMatchItems count];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    [multiMatchItems[rowIndex] setMatchingValue:anObject];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)column row:(int)rowIndex
{
    if([[column identifier] isEqualToString:@"Files"])
        return [[multiMatchItems[rowIndex] file] lastPathComponent];
    else
        return [multiMatchItems[rowIndex] matchingValue];
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSString *path = [multiMatchItems[rowIndex] file];
    [aCell setImage:[[NSWorkspace sharedWorkspace] iconForFile:path]];
}

- (id)popUpContentForRow:(NSInteger)row
{
    // Called by PopupTableColumn (this object is it's delegate)
    return [multiMatchItems[row] matchingFiles];
}

@end
