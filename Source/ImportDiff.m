//
//  ImportDiff.m
//  iLocalize3
//
//  Created by Jean on 25.12.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ImportDiff.h"
#import "SmartPathParser.h"

@implementation ImportDiff

@synthesize source;

- (id)init
{
    if(self = [super init]) {
        items = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)clear
{
    [items removeAllObjects];
}

- (void)addFiles:(NSArray*)files operation:(unsigned)op
{
    for(NSString *file in files) {
        ImportDiffItem *item = [[ImportDiffItem alloc] init];
        item.enabled = YES;
        item.operation = op;
        item.file = file;                
        item.source = source;
        [items addObject:item];
    }
}

- (void)addFilesToAdd:(NSArray*)files
{
    [self addFiles:files operation:OPERATION_ADD];
}

- (void)addFilesToDelete:(NSArray*)files
{
    [self addFiles:files operation:OPERATION_DELETE];
}

- (void)addFilesToUpdate:(NSArray*)files
{
    [self addFiles:files operation:OPERATION_UPDATE];
}

- (void)addFilesIdentical:(NSArray*)files
{
    [self addFiles:files operation:OPERATION_IDENTICAL];
}

- (NSArray*)allFilesWithOperation:(unsigned)op
{
    NSMutableArray *files = [NSMutableArray array];
    for(ImportDiffItem *item in items) {
        if(item.enabled && item.operation == op) {
            [files addObject:item.file];
        }
    }
    return files;
}

- (NSArray*)allFilesToAdd
{
    return [self allFilesWithOperation:OPERATION_ADD];
}

- (NSArray*)allFilesToDelete
{
    return [self allFilesWithOperation:OPERATION_DELETE];    
}

- (NSArray*)allFilesToUpdate
{
    return [self allFilesWithOperation:OPERATION_UPDATE];
}

- (NSArray*)allFilesIdentical
{
    return [self allFilesWithOperation:OPERATION_IDENTICAL];
}

- (NSArray*)allExistingFiles
{
    // Returns all files that are existing in both the source and the project.
    // That is: all files to update and also those who are identical
    
    NSMutableArray *files = [NSMutableArray array];
    [files addObjectsFromArray:[self allFilesToUpdate]];
    [files addObjectsFromArray:[self allFilesIdentical]];
    return files;
}

- (NSArray*)items
{
    return items;
}

- (NSString*)description
{
    NSMutableString *s = [NSMutableString string];
    [s appendFormat:@"Source=%@", self.source];
    [s appendString:@"\n"];
    [s appendFormat:@"Items=%@", self.items];    
    return s;
}

@end
