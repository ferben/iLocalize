//
//  ExplorerSmartFilterManager.m
//  iLocalize3
//
//  Created by Jean on 19.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ExplorerFilterManager.h"
#import "ExplorerFilter.h"
#import "Explorer.h"

#import "ProjectModel.h"

#import "FileTool.h"

#import "Constants.h"

@implementation ExplorerFilterManager

static ExplorerFilterManager *shared = nil;

+ (id)shared
{
    @synchronized(self) {
        if(shared == nil)
            shared = [[ExplorerFilterManager alloc] init];        
    }
    return shared;
}

- (id)init
{
    if((self = [super init])) {
        mGlobalFilters = [[NSMutableArray alloc] init];
        mLocalFilters = [[NSMutableDictionary alloc] init];
        
        mExplorers = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)registerExplorer:(Explorer*)explorer
{
    [mExplorers addObject:[NSValue valueWithNonretainedObject:explorer]];
}

- (void)unregisterExplorer:(Explorer*)explorer
{
    [mExplorers removeObject:[NSValue valueWithNonretainedObject:explorer]];
}

- (void)enumerateAllExplorersExcept:(Explorer*)exceptExplorer block:(void(^)(Explorer *explorer))block {
    for(NSValue *value in mExplorers) {
        id explorer = [value nonretainedObjectValue];
        if(explorer == exceptExplorer)
            continue;
        
        block(explorer);
    }
}

#pragma mark -

- (void)copyGlobalFilterFromResourceNamed:(NSString*)name
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"xml"];
    if(path == nil) {
        NSLog(@"Path is nil for resource %@", name);
        return;
    }
    
    NSString *target = [[self globalPath] stringByAppendingPathComponent:[path lastPathComponent]];
    NSError *error = nil;
    if(![[NSFileManager defaultManager] copyItemAtPath:path toPath:target error:&error]) {
        NSLog(@"Couldn't copy path %@ to %@ because %@", path, target, error);
        return;        
    }
}

+ (NSArray*)defaultFilterNames
{
    // Note: if a new filter is added, don't forget to include its localized string (see below)
    return @[@"To translate", @"To check", @"Warnings", @"Nibs", @"Strings", @"HTML"];

    // Lines to generate the localization
    NSLocalizedStringFromTable(@"To translate", @"LocalizableFilters", @"Default Filter Name");
    NSLocalizedStringFromTable(@"To check", @"LocalizableFilters", @"Default Filter Name");
    NSLocalizedStringFromTable(@"Warnings", @"LocalizableFilters", @"Default Filter Name");
    NSLocalizedStringFromTable(@"Nibs", @"LocalizableFilters", @"Default Filter Name");
    NSLocalizedStringFromTable(@"Strings", @"LocalizableFilters", @"Default Filter Name");
    NSLocalizedStringFromTable(@"HTML", @"LocalizableFilters", @"Default Filter Name");
}

- (void)createDefaultFilters
{    
    [[NSFileManager defaultManager] createDirectoryAtPath:[self globalPath] withIntermediateDirectories:YES attributes:nil error:nil];

    for(NSString *name in [ExplorerFilterManager defaultFilterNames]) {
        [self copyGlobalFilterFromResourceNamed:name];        
    }
}

- (NSString*)globalPath
{
    return [[FileTool systemApplicationSupportFolder] stringByAppendingPathComponent:@"/Smart Filters"];
}

- (NSString*)localPathForExplorer:(Explorer*)explorer
{
    if(explorer == NULL)
        return [self globalPath];
    else {        
        return [[[[explorer projectProvider] projectModel] projectPath] stringByAppendingPathComponent:@"/Smart Filters"];
    }
}

- (NSArray*)loadFiltersFromPath:(NSString*)path
{
    NSMutableArray *filters = [NSMutableArray array];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    NSString *relativeFile;
    while((relativeFile = [enumerator nextObject])) {
        if([[relativeFile pathExtension] isEqualToString:SMART_FILTER_EXTENSION] == NO)
            continue;
        
        NSString *file = [path stringByAppendingPathComponent:relativeFile];
        
        ExplorerFilter *filter = [ExplorerFilter filter];
        filter.file = file;
        if(![filter setPropertyData:[NSData dataWithContentsOfFile:file]]) {
            // Skip filter if they have a problem
            NSLog(@"Problem loading smart filter %@", file);
            continue;            
        }
        
        [filters addObject:filter];
    }

    return filters;
}

- (void)loadGlobalFilters
{
    [mGlobalFilters removeAllObjects];    
    [mGlobalFilters addObjectsFromArray:[self loadFiltersFromPath:[self globalPath]]];
            
    if([mGlobalFilters count] == 0) {
        [self createDefaultFilters];
        [mGlobalFilters addObjectsFromArray:[self loadFiltersFromPath:[self globalPath]]];
    }
}

- (NSArray*)globalFilters
{
    return mGlobalFilters;
}

- (void)loadLocalFiltersForExplorer:(Explorer*)explorer
{
    NSMutableArray *array = [self localFiltersForExplorer:explorer];
    [array removeAllObjects];
    [array addObjectsFromArray:[self loadFiltersFromPath:[self localPathForExplorer:explorer]]];
}

- (NSMutableArray*)localFiltersForExplorer:(Explorer*)explorer
{
    NSMutableArray *array = mLocalFilters[[NSValue valueWithNonretainedObject:explorer]];
    if(array == NULL) {
        array = [NSMutableArray array];
        mLocalFilters[[NSValue valueWithNonretainedObject:explorer]] = array;
    }    
    return array;
}

#pragma mark -

- (BOOL)registerFilter:(ExplorerFilter*)filter explorer:(Explorer*)explorer
{
    if(filter.local) {
        NSMutableArray *array = [self localFiltersForExplorer:explorer];
        if(![array containsObject:filter]) {
            [array addObject:filter];
            [explorer explorerFilterDidAdd:filter];
            return YES;
        }        
    } else {
        if(![mGlobalFilters containsObject:filter]) {
            [mGlobalFilters addObject:filter];
            [self enumerateAllExplorersExcept:nil block:^(Explorer *explorer) {
                [explorer explorerFilterDidAdd:filter];
            }];
            return YES;
        }
    }
    return NO;
}

- (void)removeFilter:(ExplorerFilter*)filter explorer:(Explorer*)explorer
{
    [filter.file removePathFromDisk];    

    if(filter.local) {
        [explorer explorerFilterDidRemove:filter];

        NSMutableArray *array = [self localFiltersForExplorer:explorer];
        [array removeObject:filter];    
    } else {
        [self enumerateAllExplorersExcept:nil block:^(Explorer *explorer) {
            [explorer explorerFilterDidRemove:filter];
        }];
        [mGlobalFilters removeObject:filter];
    }    
}

- (void)saveFilter:(ExplorerFilter*)filter explorer:(Explorer*)explorer
{
    // do not save temporary filters
    if(filter.temporary) return;

    BOOL wasGlobal = [filter.file hasPrefix:[self globalPath]];
    if(filter.file) {
        // Remove the previous file from disk
        [filter.file removePathFromDisk];        
    }

    // Retreive the correct path (global or local)
    NSString *path = filter.local?[self localPathForExplorer:explorer]:[self globalPath];
        
    // Make sure the new file is unique
    int count = 1;
    NSString *newName = filter.name;
    NSString *file;
    while([file = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", newName, SMART_FILTER_EXTENSION]] isPathExisting]) {
        newName = [filter.name stringByAppendingFormat:@"%d", count++];
    }

    filter.file = file;
    
    // Write the new file to the disk    
    [[FileTool shared] preparePath:file atomic:YES skipLastComponent:YES];
    [[filter propertyData] writeToFile:file atomically:YES];
    
    // If the file was previously a global filter and is now a local filter, remove it from all other explorers.
    // If the file was previously a local filter and is now a global filter, add it to all other explorers.
    
    if(wasGlobal && filter.local) {
        [mGlobalFilters removeObject:filter];
        [[self localFiltersForExplorer:explorer] addObject:filter];
        
        [self enumerateAllExplorersExcept:explorer block:^(Explorer *explorer) {
            [explorer explorerFilterDidRemove:filter];
        }];
    } else if(!wasGlobal && !filter.local) {
        [mGlobalFilters addObject:filter];
        [[self localFiltersForExplorer:explorer] removeObject:filter];
        [self enumerateAllExplorersExcept:explorer block:^(Explorer *explorer) {
            [explorer explorerFilterDidAdd:filter];
        }];
    } else {
        [self enumerateAllExplorersExcept:nil block:^(Explorer *explorer) {
            [explorer explorerFilterDidChange:filter];
        }];
    }
}

@end
