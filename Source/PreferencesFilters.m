//
//  PreferencesFilters.m
//  iLocalize3
//
//  Created by Jean on 28.05.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "PreferencesFilters.h"
#import "StringController.h"

#import "Constants.h"
#import "Constants.h"
#import "FindRegex.h"

#define REGEX    @"regex"
#define REGEX_ELEMENT @"element"

#define ELEMENT_ALL        0
#define ELEMENT_KEY        1
#define ELEMENT_COMMENT    2
#define ELEMENT_VALUE    3

@interface PreferencesFilters (PrivateMethods)
- (void)clearQuoteCache;
@end

@implementation PreferencesFilters

static PreferencesFilters* prefs = nil;

+ (id)shared
{
    @synchronized(self) {
        if(prefs == nil)
            prefs = [[PreferencesFilters alloc] init];        
    }
    return prefs;
}

+ (NSMutableDictionary*)filterForElement:(int)element regex:(NSString*)regex
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"enable"] = @YES;
    dic[@"element"] = @(element);
    dic[@"regex"] = regex;
    return dic;
}

+ (NSMutableArray*)defaultFilters
{
    NSMutableArray *filters = [NSMutableArray array];
    
    // IL 3.1.3: don't filter NSIBHelpConnector by default because tooltip are not visible anymore
    //[filters addObject:[PreferencesFilters newFilterForElement:ELEMENT_COMMENT regex:@"^(\\s*NSIBHelpConnector)"]];
    [filters addObject:[PreferencesFilters filterForElement:ELEMENT_KEY regex:@"^(\\d)*\\.NSValueTransformerName"]];
    [filters addObject:[PreferencesFilters filterForElement:ELEMENT_KEY regex:@"^(\\d)*\\.NSPredicateFormat"]];
    [filters addObject:[PreferencesFilters filterForElement:ELEMENT_COMMENT regex:@"<do not localize."]];
        
    return filters;
}

+ (void)initialize
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    dic[@"FilterStringsEmptyBase"] = @YES;
    dic[@"FilterStringsNoLetter"] = @NO;
    dic[@"FilterStringsOneLetter"] = @NO;
    dic[@"FilterStringsRegex"] = [PreferencesFilters defaultFilters];    
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:dic];
}

- (id)init
{
    if (self = [super init])
    {
        prefs = self;

        NSBundle *bundle = [NSBundle bundleForClass:[self class]];

        if (![bundle loadNibNamed:@"PreferencesFilters" owner:self topLevelObjects:nil])
        {
            // throw exception
            @throw [NSException exceptionWithName:@"View initialization failed"
                                           reason:@"PreferencesFilters: Could not load resources!"
                                         userInfo:nil];
        }

        mCachedRegexArray = [[NSMutableArray alloc] init];
        mUpdateRegexCache = YES;
        
        mMatchStringsWithEmptyBase = YES;
        mMatchStringsWithNoLetter = YES;
        mMatchStringsWithOnlyOneLetter = NO;
        
        mCachedLetterCharacterSet = [NSCharacterSet letterCharacterSet];        
    }
    return self;
}


#pragma mark -

- (void)clearRegexCache
{
    mUpdateRegexCache = YES;
}

- (IBAction)addFilter:(id)sender
{
    [mRegexController addObject:[mRegexController newObject]];
    
    int row = [[mRegexController content] count]-1;
    [mRegexTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    [mRegexTableView editColumn:2 row:row withEvent:nil select:YES];
    
    [self filterAction:sender];
}

- (IBAction)removeFilter:(id)sender
{
    [mRegexController remove:self];
    [self filterAction:sender];
}

- (IBAction)filterAction:(id)sender
{
    [self clearRegexCache];
    [[NSNotificationCenter defaultCenter] postNotificationName:ILStringsFilterDidChange
                                                        object:nil];
}

- (NSArray*)regexArray
{
    @synchronized(self) {
        if(mUpdateRegexCache) {        
            mUpdateRegexCache = NO;        
            [mCachedRegexArray removeAllObjects];
            
            NSEnumerator *enumerator = [[mRegexController content] objectEnumerator];
            NSDictionary *dic;
            while(dic = [enumerator nextObject]) {
                if(![dic[@"enable"] boolValue])
                    continue;
                
                NSMutableDictionary *regex_dic = [NSMutableDictionary dictionary];
                regex_dic[REGEX_ELEMENT] = dic[@"element"];
                FindRegex *regex = [FindRegex regexWithPattern:dic[@"regex"] ignoreCase:YES];
                if(regex) {
                    regex_dic[REGEX] = regex;
                    [mCachedRegexArray addObject:regex_dic];                
                } else {
                    NSLog(@"PreferencesFilters: nil regex for pattern %@", dic[@"regex"]);
                }
            }
            
            mMatchStringsWithEmptyBase = [[NSUserDefaults standardUserDefaults] boolForKey:@"FilterStringsEmptyBase"];
            mMatchStringsWithNoLetter = [[NSUserDefaults standardUserDefaults] boolForKey:@"FilterStringsNoLetter"];
            mMatchStringsWithOnlyOneLetter = [[NSUserDefaults standardUserDefaults] boolForKey:@"FilterStringsOneLetter"];
        }        
    }
    return mCachedRegexArray;
}

- (BOOL)string:(NSString*)s matchRegex:(FindRegex*)regex
{
    return [regex regexMatch:s];
}

- (BOOL)stringHasNoLetter:(NSString*)s
{
    if([s length])
        return [s rangeOfCharacterFromSet:mCachedLetterCharacterSet options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])].location == NSNotFound;
    else
        return NO;
}

- (BOOL)stringHasOnlyOneLetter:(NSString*)s
{    
    NSRange r = [s rangeOfCharacterFromSet:mCachedLetterCharacterSet options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    if(r.location == NSNotFound)
        return NO;
    
    r = NSMakeRange(r.location+1, [s length]-r.location-1);
    r = [s rangeOfCharacterFromSet:mCachedLetterCharacterSet options:NSCaseInsensitiveSearch range:r];
    return r.location == NSNotFound;
}

- (BOOL)stringControllerMatchAnyRegex:(StringController*)sc
{
    BOOL match = NO;
    
    NSEnumerator *enumerator = [[self regexArray] objectEnumerator];
    NSDictionary *dic;
    while(dic = [enumerator nextObject]) {
        FindRegex *regex = dic[REGEX];
        switch([dic[REGEX_ELEMENT] intValue]) {
            case ELEMENT_ALL:
                match = [self string:[sc key] matchRegex:regex];
                if(!match)
                    match = [self string:[sc translationComment] matchRegex:regex];
                    if(!match)
                        match = [self string:[sc translation] matchRegex:regex];
                        break;
            case ELEMENT_KEY:
                match = [self string:[sc key] matchRegex:regex];
                break;
            case ELEMENT_COMMENT:
                match = [self string:[sc translationComment] matchRegex:regex];
                break;
            case ELEMENT_VALUE:
                match = [self string:[sc translation] matchRegex:regex];
                break;
        }
        
        if(match)
            return YES;
    }

    if(mMatchStringsWithEmptyBase)
        match = [[sc base] length] == 0;
    if(match)
        return YES;
    
    if(mMatchStringsWithNoLetter)
        match = [self stringHasNoLetter:[sc translation]];
    if(match)
        return YES;
    
    if(mMatchStringsWithOnlyOneLetter)
        match = [self stringHasOnlyOneLetter:[sc translation]];
    if(match)
        return YES;
    
    return match;
}

#pragma mark -

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    [self filterAction:nil];
    return YES;
}

@end
