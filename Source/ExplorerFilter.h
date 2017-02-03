//
//  ExplorerSmartFilter.h
//  iLocalize3
//
//  Created by Jean on 19.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ExplorerFilter.h"

@class ProjectWC;
@class StringController;
@class SearchContext;

@interface ExplorerFilter : NSObject {
    NSString *_name;
    NSPredicate *_predicate;
    BOOL _local;
    BOOL _temporary;
    NSString *_file;
    BOOL stringContentMatching;
    SearchContext *stringContentMatchingContext;

    NSMutableDictionary *dataDictionary;
    
    NSMutableSet    *mCachedFileLabelsIndexSet;    // cache
    NSMutableSet    *mCachedStringLabelsIndexSet;    // cache
    ProjectWC        *mCachedLabelProject;    // cache    
}

@property (strong) NSString *name;
@property (strong) NSPredicate *predicate;
@property BOOL local;
@property BOOL temporary;
@property (strong) NSString *file;
@property BOOL stringContentMatching;
@property (copy) SearchContext *stringContentMatchingContext;

+ (id)filter;
+ (id)filterWithContext:(SearchContext*)context string:(NSString*)value;

- (void)applyTo:(StringController*)sc;

- (BOOL)setPropertyData:(NSData*)data;
- (NSData*)propertyData;

@end
