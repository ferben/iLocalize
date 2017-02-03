//
//  ExplorerSmartFilter.m
//  iLocalize3
//
//  Created by Jean on 19.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ExplorerFilter.h"
#import "ProjectWC.h"
#import "ProjectLabels.h"

#import "FileController.h"
#import "StringController.h"

#import "ProjectViewSearchController.h"
#import "FindRegex.h"
#import "FindContentMatching.h"
#import "SearchContext.h"
#import "RegexKitLite.h"

@implementation ExplorerFilter

@synthesize name=_name;
@synthesize predicate=_predicate;
@synthesize local=_local;
@synthesize temporary=_temporary;
@synthesize file=_file;
@synthesize stringContentMatching;
@synthesize stringContentMatchingContext;

+ (id)filter
{
    return [[self alloc] init];
}

+ (BOOL)evaluateString:(NSString*)string context:(SearchContext*)context string:(NSString*)regex
{
    RKLRegexOptions options = context.ignoreCase?RKLCaseless:RKLNoOptions;
    NSRange range = [string rangeOfRegex:regex options:options inRange:NSMakeRange(0, [string length]) capture:0 error:nil];                                                    
    return range.location != NSNotFound;
}

+ (BOOL)evaluateStringController:(StringController*)sc context:(SearchContext*)context string:(NSString*)regex
{
    NSMutableArray *candidates = [NSMutableArray array];
    if(context.scope & SCOPE_STRINGS_BASE) {
        [candidates addObjectSafe:sc.pBase.pTranslation];
    }
    if(context.scope & SCOPE_STRINGS_TRANSLATION) {
        [candidates addObjectSafe:sc.pTranslation];
    }
    if(context.scope & SCOPE_COMMENTS_BASE) {
        [candidates addObjectSafe:sc.pBase.pComment];
    }
    if(context.scope & SCOPE_COMMENTS_TRANSLATION) {
        [candidates addObjectSafe:sc.pComment];
    }
    if(context.scope & SCOPE_KEY) {
        [candidates addObjectSafe:sc.pKey];
    }

    for(NSString *string in candidates) {
        if([ExplorerFilter evaluateString:string context:context string:regex]) {
            return YES;
        }
    }
    return NO;
}

+ (NSPredicate*)createRegexPredicateForContext:(SearchContext*)context string:(NSString*)regex
{
    return [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        __block BOOL match = NO;
        if([evaluatedObject isKindOfClass:[FileController class]]) {
            FileController *fc = evaluatedObject;
            if(context.scope & SCOPE_FILES) {
                match = [ExplorerFilter evaluateString:fc.pFileName context:context string:regex];
            }
            if(!match) {
                [[fc stringControllers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    *stop = match = [ExplorerFilter evaluateStringController:obj context:context string:regex];
                }];                
            }
        } else if([evaluatedObject isKindOfClass:[StringController class]]) {
            StringController *sc = evaluatedObject;
            match = [ExplorerFilter evaluateStringController:sc context:context string:regex];                
        }
        return match;
    }];
}

+ (NSPredicate*)createPredicateForContext:(SearchContext*)context string:(NSString*)value
{
    NSString *op;
    switch (context.options) {
        case SEARCH_BEGINSWITH:
            op = @"BEGINSWITH";
            break;
        case SEARCH_ENDSWITH:
            op = @"ENDSWITH";
            break;
        case SEARCH_IS:
            op = @"==";
            break;
        case SEARCH_IS_NOT:
            op = @"!=";
            break;
        case SEARCH_CONTAINS:
        default:
            op = @"CONTAINS";
            break;
    }
    
    NSString *suffix = [[NSString stringWithFormat:@"%@%@", op, (context.ignoreCase?@"[cd]":@"")] stringByAppendingString:@" %@"];
    
    NSMutableArray *predicates = [NSMutableArray array];
    if(context.scope & SCOPE_FILES) {
        [predicates addObject:[NSPredicate predicateWithFormat:[@"pFile.pFileName " stringByAppendingString:suffix], value]];
    }
    if(context.scope & SCOPE_STRINGS_BASE) {
        [predicates addObject:[NSPredicate predicateWithFormat:[@"ANY pString.pBase.pTranslation " stringByAppendingString:suffix], value]];
    }
    if(context.scope & SCOPE_STRINGS_TRANSLATION) {
        [predicates addObject:[NSPredicate predicateWithFormat:[@"ANY pString.pTranslation " stringByAppendingString:suffix], value]];
    }
    if(context.scope & SCOPE_COMMENTS_BASE) {
        [predicates addObject:[NSPredicate predicateWithFormat:[@"ANY pString.pBase.pComment " stringByAppendingString:suffix], value]];
    }
    if(context.scope & SCOPE_COMMENTS_TRANSLATION) {
        [predicates addObject:[NSPredicate predicateWithFormat:[@"ANY pString.pComment " stringByAppendingString:suffix], value]];
    }
    if(context.scope & SCOPE_KEY) {
        [predicates addObject:[NSPredicate predicateWithFormat:[@"ANY pString.pKey " stringByAppendingString:suffix], value]];
    }
    return [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
}

+ (id)filterWithContext:(SearchContext*)context string:(NSString*)value
{
    ExplorerFilter *filter = [ExplorerFilter filter];
    filter.name = value;
    filter.local = YES;    
    filter.temporary = YES;
    filter.stringContentMatching = YES;
    filter.stringContentMatchingContext = context;
    
    if(context.options == SEARCH_MATCHES) {
        filter.predicate = [ExplorerFilter createRegexPredicateForContext:context string:value];
    } else {
        filter.predicate = [ExplorerFilter createPredicateForContext:context string:value];
    }
    return filter;
}

- (id)init
{
    if((self = [super init])) {
        self.local = YES;
        self.stringContentMatching = NO;
        dataDictionary = [[NSMutableDictionary alloc] init];
        mCachedFileLabelsIndexSet = nil;
        mCachedStringLabelsIndexSet = nil;
        mCachedLabelProject = nil;
    }
    return self;
}


- (BOOL)isEqual:(id)anObject
{
    ExplorerFilter *other = anObject;
    if(self.temporary) {
        return [self.name isEqual:other.name] && other.temporary;        
    } else {
        return [self.name isEqual:other.name] && ([self.predicate isEqual:other.predicate] || (self.predicate == nil && other.predicate == nil)) && !other.temporary;
    }
}

- (NSUInteger)hash
{
    if(self.temporary) {
        return 17 + 37 * [self.name hash];
    } else {
        return 17 + 37 * [self.name hash] + 37 * [self.predicate hash];        
    }
}

- (BOOL)setPropertyData:(NSData*)data
{
    NSDictionary *dic = [NSPropertyListSerialization propertyListFromData:data
                                                         mutabilityOption:NSPropertyListMutableContainers
                                                                   format:nil
                                                         errorDescription:nil];

    if(dic == nil) return NO;

    // save all the entries for BC with version 3.x
    [dataDictionary removeAllObjects];
    [dataDictionary addEntriesFromDictionary:dic];
    
    self.name = dic[@"name"];
    self.local = [dic booleanForKey:@"local"];
    
    if(dic[@"predicate"]) {
        @try {
            self.predicate = [NSPredicate predicateWithFormat:dic[@"predicate"]];            
        }
        @catch (NSException * e) {
            return NO;
        }
    } else {
        // convert old data into a NSPredicate. Use the same notation as the old one.
        NSMutableString *r1 = [NSMutableString string];
        
        if([dic[@"fileNameContains"] length]) {
            [r1 appendFormat:@"(pFile.pFileName CONTAINS[cd] '%@')", dic[@"fileNameContains"]];        
        }
        
        if(![dic[@"fileAllTypes"] boolValue]) {
            if([r1 length] > 0) [r1 appendString:@" && "];
            [r1 appendString:@"("];
            BOOL first = YES;
            for(NSDictionary *type in dic[@"fileTypes"]) {
                if([type[@"checked"] boolValue]) {
                    if(first) {
                        first = NO;
                    } else {
                        [r1 appendString:@" || "];
                    }
                    [r1 appendFormat:@"pFile.pFileType CONTAINS[cd] '%@'", type[@"extension"]];                            
                }
            }
            [r1 appendString:@")"];
        }

        NSMutableString *r2 = [NSMutableString string];

        if([dic[@"fileLabels"] length]) {
            for(NSString *label in [dic[@"fileLabels"] componentsSeparatedByString:@","]) {
                if([r2 length] == 0) {
                    [r2 appendString:@"("];
                } else if([r2 length] > 0) {
                    [r2 appendString:@" OR "];                    
                }
                [r2 appendFormat:@"pFile.pFileLabel CONTAINS[cd] '%@'", label];                        
            }
            if([r2 length] > 0) {
                [r2 appendString:@")"];                
            }
        }

        if([dic[@"fileCheckLayout"] boolValue]) {        
            if([r2 length] > 0) [r2 appendString:@" OR "];
            [r2 appendString:@"pFile.pStatus.checkLayout == 1"];
        }
        if([dic[@"fileUpdateAdded"] boolValue]) {        
            if([r2 length] > 0) [r2 appendString:@" OR "];
            [r2 appendString:@"pFile.pStatus.updateAdded == 1"];
        }
        if([dic[@"fileUpdateUpdated"] boolValue]) {        
            if([r2 length] > 0) [r2 appendString:@" OR "];
            [r2 appendString:@"pFile.pStatus.updateUpdated == 1"];
        }
        if([dic[@"fileHasWarning"] boolValue]) {        
            if([r2 length] > 0) [r2 appendString:@" OR "];
            [r2 appendString:@"pFile.pStatus.warning == 1"];
        }
        if([dic[@"fileNotFound"] boolValue]) {        
            if([r2 length] > 0) [r2 appendString:@" OR "];
            [r2 appendString:@"pFile.pStatus.doNotExist == 1"];
        }

        NSMutableString *fp = [NSMutableString string];
        if(r1.length > 0 && r2.length > 0) {
            [fp appendFormat:@"%@ AND %@", r1, r2];
        } else if(r1.length > 0 && r2.length == 0) {
            [fp appendString:r1];
        } else if(r1.length == 0 && r2.length > 0) {
            [fp appendString:r2];            
        }
        
        NSMutableString *sp = [NSMutableString string];
        
        if([dic[@"stringLabels"] length]) {
            for(NSString *label in [dic[@"stringLabels"] componentsSeparatedByString:@","]) {
                if([sp length] == 0) {
                    [sp appendString:@"("];
                } else if([sp length] > 0) {
                    [sp appendString:@" OR "];                    
                }
                [sp appendFormat:@"ANY pString.pLabel CONTAINS[cd] '%@'", label];                        
            }
            if([sp length] > 0) {
                [sp appendString:@")"];                
            }
        }
        
        if([dic[@"stringToTranslate"] boolValue]) {        
            if([sp length] > 0) [sp appendString:@" OR "];
            [sp appendString:@"ANY pString.pStatus.toTranslate == 1"];
        }
        if([dic[@"stringAutoTranslated"] boolValue]) {        
            if([sp length] > 0) [sp appendString:@" OR "];
            [sp appendString:@"ANY pString.pStatus.translated == 1"];
            [sp appendString:@" && ANY pString.pStatus.toCheck == 1"];
        }
        if([dic[@"stringAutoInvariant"] boolValue]) {        
            if([sp length] > 0) [sp appendString:@" OR "];
            [sp appendString:@"ANY pString.pStatus.invariant == 1"];
            [sp appendString:@" && ANY pString.pStatus.toCheck == 1"];
        }
        if([dic[@"stringInvariant"] boolValue]) {        
            if([sp length] > 0) [sp appendString:@" OR "];
            [sp appendString:@"ANY pString.pStatus.invariant == 1"];
        }
        if([dic[@"stringBaseChanged"] boolValue]) {        
            if([sp length] > 0) [sp appendString:@" OR "];
            [sp appendString:@"ANY pString.pStatus.baseModified == 1"];
        }
        if([dic[@"stringHasWarning"] boolValue]) {        
            if([sp length] > 0) [sp appendString:@" OR "];
            [sp appendString:@"ANY pString.pStatus.warning == 1"];
        }
        if([dic[@"stringLocked"] boolValue]) {        
            if([sp length] > 0) [sp appendString:@" OR "];
            [sp appendString:@"ANY pString.pStatus.locked == 1"];
        }
                
        NSMutableString *p = [NSMutableString string];
        if(fp.length > 0 && sp.length > 0) {
            [p appendFormat:@"(%@) AND (%@)", fp, sp];  
        } else if(fp.length == 0 && sp.length > 0) {
            [p appendFormat:@"%@", sp];
        } else if(fp.length > 0 && sp.length == 0) {
            [p appendString:fp];
        }
        
        if([p length]) {
            @try {
                self.predicate = [NSPredicate predicateWithFormat:p];                        
            } @catch (id e) {
                NSLog(@"Error while loading filter '%@': %@", self.name, e);
                return NO;
            }
        } else {
            self.predicate = nil;
        }
    }
        
    return YES;
}

- (NSData*)propertyData
{
    dataDictionary[@"version"] = @101;

    [dataDictionary setObjectOrNil:self.name forKey:@"name"];
    [dataDictionary setObjectOrNil:[self.predicate predicateFormat] forKey:@"predicate"];    
    [dataDictionary setBoolean:self.local forKey:@"local"];
    
    return [NSPropertyListSerialization dataFromPropertyList:dataDictionary
                                                      format:NSPropertyListXMLFormat_v1_0
                                            errorDescription:NULL];
}

#pragma mark -

/**
 Returns the regex pattern corresponding to this filter.
 */
- (NSString*)pattern
{
    NSMutableString *pattern = [NSMutableString string];    
    [pattern appendString:self.name];
    return pattern;
}

/**
 Applies this filter to the specified string controller, content matching and item.
 */
- (void)applyTo:(StringController *)sc contentMatching:(FindContentMatching*)cm item:(int)item
{
    NSString *content = nil;
    switch (item) {
        case SCOPE_STRINGS_BASE:
            content = sc.baseStringController.translation;
            break;
        case SCOPE_STRINGS_TRANSLATION:
            content = sc.translation;
            break;
        case SCOPE_COMMENTS_BASE:
            content = sc.baseStringController.translationComment;
            break;
        case SCOPE_COMMENTS_TRANSLATION:
            content = sc.translationComment;
            break;
        case SCOPE_KEY:
            content = sc.key;
            break;
    }
    if(content) {
        FindRegex *regex = [[FindRegex alloc] initWithPattern:[self pattern] ignoreCase:YES];
        NSArray *ranges = [regex regexRangesInString:content];
        [cm addRanges:ranges item:item];
    }
}

/**
 Applies this filter to the specified string controller.
 */
- (void)applyTo:(StringController*)sc
{    
    FindContentMatching *cmBase = [FindContentMatching content];
    FindContentMatching *cmTranslation = [FindContentMatching content];
    if(stringContentMatching) {
        if(stringContentMatchingContext.scope & SCOPE_FILES) {
        }
        if(stringContentMatchingContext.scope & SCOPE_STRINGS_BASE) {
            [self applyTo:sc contentMatching:cmBase item:SCOPE_STRINGS_BASE];
        }
        if(stringContentMatchingContext.scope & SCOPE_STRINGS_TRANSLATION) {
            [self applyTo:sc contentMatching:cmTranslation item:SCOPE_STRINGS_TRANSLATION];
        }
        if(stringContentMatchingContext.scope & SCOPE_COMMENTS_BASE) {
            [self applyTo:sc contentMatching:cmBase item:SCOPE_COMMENTS_BASE];
        }
        if(stringContentMatchingContext.scope & SCOPE_COMMENTS_TRANSLATION) {
            [self applyTo:sc contentMatching:cmTranslation item:SCOPE_COMMENTS_TRANSLATION];
        }
        if(stringContentMatchingContext.scope & SCOPE_KEY) {
            [self applyTo:sc contentMatching:cmBase item:SCOPE_KEY];
        }        
    }
    sc.baseStringController.contentMatching = cmBase;
    sc.contentMatching = cmTranslation;    
}

#pragma mark -

- (void)clearLabelCache
{
    mCachedFileLabelsIndexSet = nil;

    mCachedStringLabelsIndexSet = nil;
}

- (void)buildLabelCache:(NSMutableSet*)cache withString:(NSString*)labels project:(ProjectWC*)project
{    
    NSEnumerator *enumerator = [[labels componentsSeparatedByString:@","] objectEnumerator];
    NSString *identifier;
    while((identifier = [enumerator nextObject])) {
        identifier = [identifier stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [cache addObject:@([[project projectLabels] labelIndexForIdentifier:identifier])];
    }            
}

- (NSSet*)cachedFileLabelIndexesForProject:(ProjectWC*)project
{
    if(project != mCachedLabelProject) {
        mCachedLabelProject = project;
        [self clearLabelCache];
    }
    
    if(mCachedFileLabelsIndexSet == nil) {
        mCachedFileLabelsIndexSet = [[NSMutableSet alloc] init];
//        [self buildLabelCache:mCachedFileLabelsIndexSet withString:mFileLabels project:project];
    }    
    
    return mCachedFileLabelsIndexSet;
}

- (NSSet*)cachedStringLabelIndexesForProject:(ProjectWC*)project
{
    if(project != mCachedLabelProject) {
        mCachedLabelProject = project;
        [self clearLabelCache];
    }
    
    if(mCachedStringLabelsIndexSet == nil) {
        mCachedStringLabelsIndexSet = [[NSMutableSet alloc] init];
//        [self buildLabelCache:mCachedStringLabelsIndexSet withString:mStringLabels project:project];
    }    
    
    return mCachedStringLabelsIndexSet;
}

- (void)contentDidChange
{
    [self clearLabelCache];
}

- (void)projectLabelsDidChange:(NSNotification*)notif
{
    [self clearLabelCache];    
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@, predicate = %@, temporary=%d, stringContentMatching=%d", self.name, self.predicate, self.temporary, self.stringContentMatching];
}

@end
