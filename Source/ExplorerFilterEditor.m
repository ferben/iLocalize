//
//  ExplorerSmartFilterEditor.m
//  iLocalize3
//
//  Created by Jean on 18.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ExplorerFilterEditor.h"
#import "ExplorerFilterManager.h"

#import "Explorer.h"
#import "ExplorerFilter.h"
#import "ExplorerItem.h"

#import "ProjectWC.h"
#import "ProjectExplorerController.h"

#import "AZPredicateEditorSingleRowTemplate.h"
#import "Constants.h"

@implementation ExplorerFilterEditor

- (id)init
{
    if(self = [super initWithWindowNibName:@"SmartFilterEditor"]) {
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)createCompoundTemplates:(NSMutableArray*)templates
{
    NSPredicateEditorRowTemplate *compoundTemplate = [[NSPredicateEditorRowTemplate alloc] initWithCompoundTypes:@[@(NSAndPredicateType),
                                                                                                                  [NSNumber numberWithInt:NSOrPredicateType], [NSNumber numberWithInt:NSNotPredicateType]]];
    [templates addObject:compoundTemplate];
}

- (NSArray*)stringOperators
{
    return @[[NSNumber numberWithInt:NSContainsPredicateOperatorType],
            [NSNumber numberWithInt:NSBeginsWithPredicateOperatorType],
            [NSNumber numberWithInt:NSEndsWithPredicateOperatorType],
            [NSNumber numberWithInt:NSEqualToPredicateOperatorType],
            [NSNumber numberWithInt:NSNotEqualToPredicateOperatorType],
            [NSNumber numberWithInt:NSMatchesPredicateOperatorType]];
}

- (void)createFilePredicateTemplates:(NSMutableArray*)templates
{
    NSArray *leftExpressions = @[[NSExpression expressionForKeyPath:@"pFile.pFileName"],
                                [NSExpression expressionForKeyPath:@"pFile.pFileType"]];
    NSPredicateEditorRowTemplate *t = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:leftExpressions
                                                                       rightExpressionAttributeType:NSStringAttributeType
                                                                                           modifier:NSDirectPredicateModifier
                                                                                          operators:[self stringOperators]
                                                                                            options:NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption];        
    
    NSPopUpButton *p = [[t templateViews] firstObject];
    [[p itemAtIndex:0] setTitle:@"File Name"];
    [[p itemAtIndex:1] setTitle:@"File Type"];
    
    [templates addObject:t];        
}

- (void)createFileLabelPredicateTemplates:(NSMutableArray*)templates
{
    NSPredicateEditorRowTemplate *t = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:@[[NSExpression expressionForKeyPath:@"pFile.pFileLabel"]]
                                                                       rightExpressionAttributeType:NSStringAttributeType
                                                                                           modifier:NSDirectPredicateModifier
                                                                                          operators:@[[NSNumber numberWithInt:NSContainsPredicateOperatorType]]
                                                                                            options:NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption];        
    
    NSPopUpButton *p = [[t templateViews] firstObject];
    [[p itemAtIndex:0] setTitle:@"File Label"];
    
    [templates addObject:t];        
}

- (void)createFileStatusPredicateTemplates:(NSMutableArray*)templates
{
    NSArray *leftExpressions = @[[NSExpression expressionForKeyPath:@"pFile.pStatus.checkLayout"],
                                [NSExpression expressionForKeyPath:@"pFile.pStatus.updateAdded"], 
                                [NSExpression expressionForKeyPath:@"pFile.pStatus.updateUpdated"], 
                                [NSExpression expressionForKeyPath:@"pFile.pStatus.warning"], 
                                [NSExpression expressionForKeyPath:@"pFile.pStatus.doNotExist"]];
    
    NSArray *operators = @[[NSNumber numberWithInt:NSEqualToPredicateOperatorType]];
    NSPredicateEditorRowTemplate *t = [[AZPredicateEditorSingleRowTemplate alloc] initWithLeftExpressions:leftExpressions
                                                                                   rightExpressions:@[[NSExpression expressionForConstantValue:@YES]] 
                                                                                           modifier:NSDirectPredicateModifier
                                                                                          operators:operators
                                                                                            options:0];    
    
    NSPopUpButton *p = [[t templateViews] firstObject];
    [[p itemAtIndex:0] setTitle:@"File layout needs to be checked"];
    [[p itemAtIndex:1] setTitle:@"File added during last update"];
    [[p itemAtIndex:2] setTitle:@"File updated during last update"];
    [[p itemAtIndex:3] setTitle:@"File has inconsistencies"];
    [[p itemAtIndex:4] setTitle:@"File does not exist on the disk"];
    [[p menu] insertItem:[NSMenuItem separatorItem] atIndex:0];
    
    [templates addObject:t];    
}

- (void)createStringPredicateTemplates:(NSMutableArray*)templates
{
    NSArray *leftExpressions = @[[NSExpression expressionForKeyPath:@"pString.pTranslation"],
                                [NSExpression expressionForKeyPath:@"pString.pBase.pTranslation"],
                                [NSExpression expressionForKeyPath:@"pString.pComment"],
                                [NSExpression expressionForKeyPath:@"pString.pBase.pComment"]];
    
    NSPredicateEditorRowTemplate *t = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:leftExpressions
                                                                       rightExpressionAttributeType:NSStringAttributeType
                                                                                           modifier:NSAnyPredicateModifier
                                                                                          operators:[self stringOperators]
                                                                                            options:NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption];    
    
    NSPopUpButton *p = [[t templateViews] firstObject];
    [[p itemAtIndex:0] setTitle:@"String Value"];
    [[p itemAtIndex:1] setTitle:@"String Base Value"];
    [[p itemAtIndex:2] setTitle:@"String Comment"];
    [[p itemAtIndex:3] setTitle:@"String Base Comment"];
    
    [[p menu] insertItem:[NSMenuItem separatorItem] atIndex:0];
    
    [templates addObject:t];    
}

- (void)createStringLabelPredicateTemplates:(NSMutableArray*)templates
{
    NSPredicateEditorRowTemplate *t = [[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:@[[NSExpression expressionForKeyPath:@"pString.pLabel"]]
                                                                       rightExpressionAttributeType:NSStringAttributeType
                                                                                           modifier:NSAnyPredicateModifier
                                                                                          operators:@[[NSNumber numberWithInt:NSContainsPredicateOperatorType]]
                                                                                            options:NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption];        
    
    NSPopUpButton *p = [[t templateViews] firstObject];
    [[p itemAtIndex:0] setTitle:@"String Label"];
    
    [templates addObject:t];        
}

- (void)createStringStatusPredicateTemplates:(NSMutableArray*)templates
{
    NSArray *leftExpressions = @[[NSExpression expressionForKeyPath:@"pString.pStatus.toTranslate"], 
                                [NSExpression expressionForKeyPath:@"pString.pStatus.translated"],
                                [NSExpression expressionForKeyPath:@"pString.pStatus.toCheck"],
                                [NSExpression expressionForKeyPath:@"pString.pStatus.invariant"],
                                [NSExpression expressionForKeyPath:@"pString.pStatus.baseModified"],
                                [NSExpression expressionForKeyPath:@"pString.pStatus.warning"],
                                [NSExpression expressionForKeyPath:@"pString.pStatus.locked"]];
    
    NSArray *operators = @[[NSNumber numberWithInt:NSEqualToPredicateOperatorType]];
    NSPredicateEditorRowTemplate *t = [[AZPredicateEditorSingleRowTemplate alloc] initWithLeftExpressions:leftExpressions
                                                                                   rightExpressions:@[[NSExpression expressionForConstantValue:@YES]] 
                                                                                           modifier:NSAnyPredicateModifier
                                                                                          operators:operators
                                                                                            options:0];    
    
    NSPopUpButton *p = [[t templateViews] firstObject];
    [[p itemAtIndex:0] setTitle:@"String is not translated"];
    [[p itemAtIndex:1] setTitle:@"String is translated"];
    [[p itemAtIndex:2] setTitle:@"String needs to be checked"];
    [[p itemAtIndex:3] setTitle:@"String is an invariant"];
    [[p itemAtIndex:4] setTitle:@"String has base modified"];
    [[p itemAtIndex:5] setTitle:@"String has inconsistencies"];
    [[p itemAtIndex:6] setTitle:@"String is locked"];
    
    [[p menu] insertItem:[NSMenuItem separatorItem] atIndex:0];
    
    [templates addObject:t];    
}

#pragma mark -

- (void)willShow
{
    /** 
     Note: when a template is modified, added or removed, uncomment the line below that generates the strings using a private method.
     
     References:
     Localization for the NSPredicateEditor.
     See http://funwithobjc.tumblr.com/post/1482915398/localizing-nspredicateeditor.
     
        
     */

    
    NSMutableArray *templates = [NSMutableArray array];
    
    [self createCompoundTemplates:templates];
    [self createFilePredicateTemplates:templates];
    [self createFileLabelPredicateTemplates:templates];
    [self createFileStatusPredicateTemplates:templates];
    [self createStringPredicateTemplates:templates];
    [self createStringLabelPredicateTemplates:templates];
    [self createStringStatusPredicateTemplates:templates];

    [mPredicateEditor setRowTemplates:templates];

    [mPredicateEditor setFormattingStringsFilename:@"LocalizablePredicateEditor"];
    
    // Note: use this line to generate the strings for the NSPredicateEditor
    //[[mPredicateEditor _generateFormattingDictionaryStringsFile] writeToFile:@"/editor.strings" atomically:NO];

    NSPredicate *p = self.filter.predicate;
    if(p) {
        [mPredicateEditor setObjectValue:p];    
    } else {
        [mPredicateEditor addRow:self];        
    }    
    
    [mNameField setStringValue:self.filter.name];
    [mGlobalButton setState:self.filter.local?NSControlStateValueOff:NSControlStateValueOn];    
}

#pragma mark -

- (IBAction)cancel:(id)sender
{
    [self hide];
}

- (IBAction)ok:(id)sender
{
    //NSLog(@"Apply predicate %@", [mPredicateEditor objectValue]);    
    
    self.filter.predicate = [mPredicateEditor objectValue];
    self.filter.name = [mNameField stringValue];
    self.filter.local = [mGlobalButton state] == NSControlStateValueOff;
    
    [[ExplorerFilterManager shared] registerFilter:self.filter explorer:self.explorer];    
    [[ExplorerFilterManager shared] saveFilter:self.filter explorer:self.explorer];

    [self.controller selectExplorerFilter:self.filter];

    [self hideWithCode:1];
}

@end
