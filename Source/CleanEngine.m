//
//  CleanEngine.m
//  iLocalize3
//
//  Created by Jean on 30.05.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "CleanEngine.h"

#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"
#import "StringController.h"

#import "OperationWC.h"
#import "StringTool.h"

@implementation CleanEngine

- (void)cleanString:(StringController*)sc
{
    if([sc lock] || [[sc translation] length] == 0)
        return;
    
    NSMutableString *s = [NSMutableString stringWithString:[sc translation]];
        
    if(mCleanNonbreakableSpace || mCleanDoubleQuotationMark) {
        BOOL left_quotation = NO;
        
        unsigned index;
        for(index=0; index<[s length]; index++) {
            unichar c = [s characterAtIndex:index];        
            
            if(mCleanNonbreakableSpace) {
                if((c == '!' || c == '?' | c == ':' || c == ';') && index > 0) {
                    unichar pc = [s characterAtIndex:index-1];
                    if(pc == ' ') {
                        // replace white-space by nonbreakable white-space
                        [s replaceCharactersInRange:NSMakeRange(index-1, 1) withString:[NSString stringWithFormat:@"%C", (unichar)0x00A0]];
                    }
                }                
            }
            
            if(mCleanDoubleQuotationMark) {
                if(c == '"') {
                    if(!left_quotation) {
                        left_quotation = YES;
                        [s replaceCharactersInRange:NSMakeRange(index, 1) withString:[NSString stringWithFormat:@"%C", (unichar)0x201C]];
                    } else {
                        left_quotation = NO;
                        [s replaceCharactersInRange:NSMakeRange(index, 1) withString:[NSString stringWithFormat:@"%C", (unichar)0x201D]];
                    }
                }
            }
            
            if(mCleanQuotationMark) {
                if(c == '\'') {
                    [s replaceCharactersInRange:NSMakeRange(index, 1) withString:[NSString stringWithFormat:@"%C", (unichar)0x2019]];                    
                }
            }
        }
    }

    if(mCleanEllipsis) {
        [s replaceOccurrencesOfString:@"..." withString:[NSString stringWithFormat:@"%C", (unichar)0x2026] options:0 range:NSMakeRange(0, [s length])];        
    }
    
    if(mCleanTrailingSpace) {
        int index = [s length]-1;
        while(index >= 0 && [s characterAtIndex:index] == ' ') {
            index--;
            if(index < 0)
                break;
        }
        index++;
        [s deleteCharactersInRange:NSMakeRange(index, [s length]-index)];
    }
        
    if(mCleanMarkModifiedStrings)
        [sc setAutomaticTranslation:s force:YES];
    else
        [sc setTranslation:s];
}

- (void)cleanStrings:(NSArray*)scs
{
    NSEnumerator *enumerator = [scs objectEnumerator];
    StringController *sc;
    while((sc = [enumerator nextObject]) && ![[self operation] shouldCancel]) {
        [self cleanString:sc];
    }    
}

- (void)cleanFiles:(NSArray*)fcs
{
    NSEnumerator *enumerator = [fcs objectEnumerator];
    FileController *fc;
    while((fc = [enumerator nextObject]) && ![[self operation] shouldCancel]) {
        [self cleanStrings:[fc filteredStringControllers]];
    }
}

- (void)cleanLanguage:(LanguageController*)lc
{
    [self cleanFiles:[lc fileControllers]];
}

- (void)cleanProject
{
    NSEnumerator *enumerator = [[[[self projectProvider] projectController] languageControllers] objectEnumerator];
    LanguageController *lc;
    while((lc = [enumerator nextObject]) && ![[self operation] shouldCancel]) {
        [self cleanLanguage:lc];
    }
}

- (void)cleanWithAttributes:(NSDictionary*)attributes
{
    // Note: currently doesn't use the attributes parameters (because it's already in the preferences)
    
    mCleanDoubleQuotationMark = [[NSUserDefaults standardUserDefaults] boolForKey:@"CleanDoubleQuotationMark"];
    mCleanQuotationMark = [[NSUserDefaults standardUserDefaults] boolForKey:@"CleanQuotationMark"];
    mCleanEllipsis = [[NSUserDefaults standardUserDefaults] boolForKey:@"CleanEllipsis"];
    mCleanNonbreakableSpace = [[NSUserDefaults standardUserDefaults] boolForKey:@"CleanNonBreakableSpace"];
    mCleanTrailingSpace = [[NSUserDefaults standardUserDefaults] boolForKey:@"CleanTrimLastSpace"];
    
    mCleanMarkModifiedStrings = [[NSUserDefaults standardUserDefaults] boolForKey:@"CleanMarkModifiedStrings"];    
        
    switch([[NSUserDefaults standardUserDefaults] integerForKey:@"CleanApplyTo"]) {
        case 0:
            [self cleanProject];
            break;
        case 1:
            [self cleanLanguage:[[self projectProvider] selectedLanguageController]];
            break;
        case 2:
            [self cleanFiles:[[self projectProvider] selectedFileControllers]];
            break;
        case 3:
            [self cleanStrings:[[self projectProvider] selectedStringControllers]];
            break;
    }
}

@end
