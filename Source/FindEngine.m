//
//  FindEngine.m
//  iLocalize3
//
//  Created by Jean on 20.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FindEngine.h"

#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"
#import "StringController.h"
#import "ExplorerFilter.h"
#import "FindContentMatching.h"
#import "SearchContext.h"

@implementation FindEngine

- (void)resetContentMatching
{
    [[[self projectController] languageControllers] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        LanguageController *lc = obj;
        [[lc fileControllers] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            FileController *fc = obj;
            [[fc stringControllers] enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                StringController *sc = obj;
                sc.baseStringController.contentMatching = nil;
                sc.contentMatching = nil;
            }];
        }];
    }];
}

/**
 Applies the current find filter to all the string controllers. This is done in order to set for each matching
 string controller its content matching instance which describes which portion of the string is matched.
 */
- (void)findString:(NSString*)string context:(SearchContext*)context
{
    // First reset all previous content matching in all the string controllers.
    [self resetContentMatching];
    
    // Create the filter associated with the find string and context.
    ExplorerFilter *filter = [ExplorerFilter filterWithContext:context string:string];
    
    // Iterate over all the filtered files and strings. For each string matching the predicate,
    // create a list of all the matching ranges for that string so they can be later re-used
    // to display the matching words in red or be used for the replace function.
    NSArray *filteredFileControllers = [[[[self projectProvider] selectedLanguageController] fileControllers] filteredArrayUsingPredicate:filter.predicate];
    [filteredFileControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FileController *fc = obj;
        NSArray *filteredStringControllers = [[fc stringControllers] filteredArrayUsingPredicate:filter.predicate];
        [filteredStringControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            StringController *sc = obj;
            [filter applyTo:sc];
        }];
    }];    
}

#pragma mark -

- (void)replaceStringController:(StringController*)sc withString:(NSString*)replaceString context:(SearchContext*)context
{    
    FindContentMatching *cm;
    NSArray *ranges;
    
    if(context.scope & SCOPE_STRINGS_BASE) {
        cm = sc.baseStringController.contentMatching;
        ranges = [cm rangesForItem:SCOPE_STRINGS_BASE];
        if(ranges) {
            NSMutableString *content = [NSMutableString stringWithString:sc.baseStringController.translation];
            for(NSValue *range in ranges) {
                [content replaceCharactersInRange:[range rangeValue] withString:replaceString];
            }
            sc.baseStringController.translation = content;        
        }                            
    }
    
    if(context.scope & SCOPE_STRINGS_TRANSLATION) {
        ranges = [sc.contentMatching rangesForItem:SCOPE_STRINGS_TRANSLATION];
        if(ranges) {
            NSMutableString *content = [NSMutableString stringWithString:sc.translation];
            for(NSValue *range in ranges) {
                [content replaceCharactersInRange:[range rangeValue] withString:replaceString];
            }
            sc.translation = content;            
        }
    }

    if(context.scope & SCOPE_COMMENTS_BASE) {
        ranges = [sc.baseStringController.contentMatching rangesForItem:SCOPE_COMMENTS_BASE];
        if(ranges) {
            NSMutableString *content = [NSMutableString stringWithString:sc.translationComment];
            for(NSValue *range in ranges) {
                [content replaceCharactersInRange:[range rangeValue] withString:replaceString];
            }
            sc.translationComment = content;            
        }    
    }    

    if(context.scope & SCOPE_COMMENTS_TRANSLATION) {
        ranges = [sc.contentMatching rangesForItem:SCOPE_COMMENTS_TRANSLATION];
        if(ranges) {
            NSMutableString *content = [NSMutableString stringWithString:sc.baseStringController.translationComment];
            for(NSValue *range in ranges) {
                [content replaceCharactersInRange:[range rangeValue] withString:replaceString];
            }
            sc.baseStringController.translationComment = content;            
        }            
    }    
}

- (void)replaceWithString:(NSString*)replaceString context:(SearchContext*)context
{
    [[[self projectProvider] selectedStringControllers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self replaceStringController:obj withString:replaceString context:context];
    }];
}

- (void)replaceAllStrings:(NSString*)searchString withString:(NSString*)replaceString context:(SearchContext*)context
{
    ExplorerFilter *filter = [ExplorerFilter filterWithContext:context string:searchString];
    
    NSArray *filteredFileControllers = [[[[self projectProvider] selectedLanguageController] fileControllers] filteredArrayUsingPredicate:filter.predicate];
    [filteredFileControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FileController *fc = obj;
        NSArray *scs = [fc stringControllers];
        NSArray *filteredStringControllers = [scs filteredArrayUsingPredicate:filter.predicate];
        [filteredStringControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self replaceStringController:obj withString:replaceString context:context];
        }];
    }];
}


@end
