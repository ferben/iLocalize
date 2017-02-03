//
//  ProjectExportMailScripts.m
//  iLocalize
//
//  Created by Jean on 12/17/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "ProjectExportMailScripts.h"
#import "FileTool.h"

@interface ProjectExportMailScripts (Private)
- (void)addMailProgram:(NSString*)name script:(NSString*)file;
@end

@implementation ProjectExportMailScripts

static ProjectExportMailScripts *shared = nil;

+ (ProjectExportMailScripts*)shared
{
    if(shared == nil) {
        @synchronized(self) {
            if(shared == nil) {
                shared = [[ProjectExportMailScripts alloc] init];
            }        
        }        
    }
    return shared;
}

- (id)init
{
    if(self = [super init]) {
        mMailPrograms = [[NSMutableArray alloc] init];
        [self update];
    }
    return self;
}


#define SCRIPT_PREFIX @"exlocemail_"
#define SCRIPT_EXT @"script"

- (void)addMailProgram:(NSString*)name script:(NSString*)file
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"name"] = name;
    dic[@"file"] = file;
    [mMailPrograms addObject:dic];
}

- (void)update
{
    [mMailPrograms removeAllObjects];
    
    [self addMailProgram:@"Mail" script:[[NSBundle mainBundle] pathForResource:@"exlocemail_Mail" ofType:SCRIPT_EXT]];
    
    NSString *path = [[FileTool systemApplicationSupportFolder] stringByAppendingPathComponent:@"/Scripts"];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    NSString *relativeFile;
    while(relativeFile = [enumerator nextObject]) {
        if([[relativeFile pathExtension] isEqualToString:SCRIPT_EXT] && [[relativeFile lastPathComponent] hasPrefix:SCRIPT_PREFIX]) {
            [self addMailProgram:[[[relativeFile lastPathComponent] stringByDeletingPathExtension] stringByRemovingPrefix:SCRIPT_PREFIX] 
                          script:[path stringByAppendingPathComponent:relativeFile]];
        }
    }        
}

- (NSArray*)programs
{
    NSMutableArray *programs = [NSMutableArray array];
    NSDictionary *dic;
    for(dic in mMailPrograms) {
        [programs addObject:dic[@"name"]];
    }
    return programs;
}

- (NSString*)scriptFileForPrograms:(NSString*)program
{
    NSDictionary *dic;
    for(dic in mMailPrograms) {
        if([dic[@"name"] isEqualToString:program]) {
            return dic[@"file"];
        }
    }
    return nil;
}

@end
