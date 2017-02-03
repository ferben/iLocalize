//
//  ProjectFileWarning.m
//  iLocalize3
//
//  Created by Jean on 5/28/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "ProjectFileWarningWC.h"

#import "FileController.h"
#import "FileModel.h"
#import "FileModelContent.h"
#import "StringsContentModel.h"
#import "StringModel.h"

#import "FMStringsExtensions.h"

#import "CheckEngine.h"

@implementation ProjectFileWarningWC

- (id)init
{
    if(self = [super initWithWindowNibName:@"FileWarning"]) {
        [self window];
        mFileController = nil;
    }
    return self;
}

- (void)setFileController:(FileController*)fc
{
    mFileController = fc;
}

#define SHOW_DUPLICATE 0
#define SHOW_MISSING 1
#define SHOW_UNUSED 2
#define SHOW_FORMATTING 3
#define SHOW_READONLY 4
#define SHOW_COMPILEDNIB 5

- (NSSet*)keysForIndex:(int)index
{
    NSDictionary *info = [mFileController auxiliaryDataForKey:@"warning_info"];
    NSSet *keys = nil;
    switch(index) {
        case SHOW_DUPLICATE:
            keys = info[WARNING_DUPLICATE_KEYS];
            break;
        case SHOW_MISSING:
            keys = info[WARNING_MISSING_KEYS];
            break;
        case SHOW_UNUSED:
            keys = info[WARNING_MISMATCH_KEYS];
            break;
        case SHOW_FORMATTING:
            keys = info[WARNING_MISMATCH_FORMATTING_CHARS];
            break;
        case SHOW_READONLY:
            keys = info[WARNING_READONLY_FILE];
            break;
        case SHOW_COMPILEDNIB:
            keys = info[WARNING_COMPILEDNIB_FILE];
            break;
    }    
    return keys;
}

- (NSString*)nameForIndex:(int)index
{
    switch(index) {
        case SHOW_DUPLICATE:
            return NSLocalizedString(@"Duplicate keys", @"String warning");
        case SHOW_MISSING:
            return NSLocalizedString(@"Missing keys", @"String warning");
        case SHOW_UNUSED:
            return NSLocalizedString(@"Unused keys", @"String warning");
        case SHOW_FORMATTING:
            return NSLocalizedString(@"Formatting characters", @"String warning");
        case SHOW_READONLY:
            return NSLocalizedString(@"File is read-only", @"File Warning Dialog");
        case SHOW_COMPILEDNIB:
            return NSLocalizedString(@"Nib file is compiled", @"File Warning Dialog");
    }    
    return nil;
}

- (NSArray*)arrayOfKeysValuesForIndex:(int)index
{
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *info = [mFileController auxiliaryDataForKey:@"warning_info"];
    NSEnumerator *enumerator = [[self keysForIndex:index] objectEnumerator];
    NSString *key;
    while(key = [enumerator nextObject]) {        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"key"] = key;
        if(index == SHOW_DUPLICATE || index == SHOW_FORMATTING) {
            StringModel *sm = [[[[mFileController fileModel] fileModelContent] stringsContent] stringModelForKey:key];
            id value = [sm value];
            dic[@"value"] = value?value:@"";
        } else {
            id value = info[@"values"][key];
            dic[@"value"] = value?value:@"";            
        }
        [array addObject:dic];
    }
    return array;
}

- (NSString*)exportableStringForKind:(int)kind
{
    NSMutableString *s = [NSMutableString string];    
    
    NSDictionary *info = [mFileController auxiliaryDataForKey:@"warning_info"];
    NSEnumerator *enumerator = [[self keysForIndex:kind] objectEnumerator];
    NSString *key;
    id value;
    while(key = [enumerator nextObject]) {
        if(kind == SHOW_DUPLICATE || kind == SHOW_FORMATTING) {
            StringModel *sm = [[[[mFileController fileModel] fileModelContent] stringsContent] stringModelForKey:key];
            value = [sm value];
        } else
            value = info[@"values"][key];
        [s appendFormat:@"%@ = %@\n", key, value?value:@""];
    }
    
    return s;    
}

- (NSMutableDictionary*)addKeysValues:(int)index
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"keysvalues"] = [self arrayOfKeysValuesForIndex:index];
    dic[@"name"] = [self nameForIndex:index];
    return dic;
}

- (void)willShow
{
    [mWarningsController removeObjects:[mWarningsController content]];

    if([[self keysForIndex:SHOW_DUPLICATE] count])
        [mWarningsController addObject:[self addKeysValues:SHOW_DUPLICATE]];
    if([[self keysForIndex:SHOW_MISSING] count])
        [mWarningsController addObject:[self addKeysValues:SHOW_MISSING]];
    if([[self keysForIndex:SHOW_UNUSED] count])
        [mWarningsController addObject:[self addKeysValues:SHOW_UNUSED]];
    if([[self keysForIndex:SHOW_FORMATTING] count])
        [mWarningsController addObject:[self addKeysValues:SHOW_FORMATTING]];
    if([[self keysForIndex:SHOW_READONLY] count])
        [mWarningsController addObject:[self addKeysValues:SHOW_READONLY]];
    if([[self keysForIndex:SHOW_COMPILEDNIB] count])
        [mWarningsController addObject:[self addKeysValues:SHOW_COMPILEDNIB]];
}

- (NSString*)exportableString
{
    NSMutableString *s = [NSMutableString string];    
    // FIX CASE 11
    [s appendString:[NSString stringWithFormat:@"File: %@\n\n", [mFileController absoluteFilePath]]];
    
    if([[self keysForIndex:SHOW_DUPLICATE] count]) {
        [s appendString:@"* Duplicate keys*\n\n"];
        [s appendString:[self exportableStringForKind:SHOW_DUPLICATE]];        
    }
    if([[self keysForIndex:SHOW_MISSING] count]) {
        [s appendString:@"\n* Missing keys*\n\n"];
        [s appendString:[self exportableStringForKind:SHOW_MISSING]];        
    }
    if([[self keysForIndex:SHOW_UNUSED] count]) {
        [s appendString:@"\n* Unused keys*\n\n"];
        [s appendString:[self exportableStringForKind:SHOW_UNUSED]];        
    }
    if([[self keysForIndex:SHOW_FORMATTING] count]) {
        [s appendString:@"\n* Formatting Characters*\n\n"];
        [s appendString:[self exportableStringForKind:SHOW_FORMATTING]];        
    }
    return s;
}

- (IBAction)help:(id)sender
{
    NSString *locBookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"];
    [[NSHelpManager sharedHelpManager] openHelpAnchor:@"filewarning"  inBook:locBookName];
}

- (IBAction)export:(id)sender
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes:@[@"txt"]];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSString *text = [self exportableString];
            [text writeToFile:[[panel URL] path] atomically:NO encoding:[text smallestEncoding] error:nil];
        } 
    }];
}

- (IBAction)ok:(id)sender
{
    [self hide];
}

@end
