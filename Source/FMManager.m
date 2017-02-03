//
//  FMManager.m
//  iLocalize3
//
//  Created by Jean on 25.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMManager.h"

#import "FMModule.h"

#import "FMStrings.h"
#import "FMNib.h"
#import "FMImage.h"
#import "FMRTF.h"
#import "FMHTML.h"
#import "FMTXT.h"

#import "FMEditorStrings.h"
#import "FMEditorImage.h"

#import "FMEngineStrings.h"
#import "FMEngineNib.h"

#import "FMControllerStrings.h"
#import "FMControllerNib.h"

#import "PreferencesEditors.h"

@interface FMManager (PrivateMethods)
- (void)initBuiltInModules;
- (void)addFileModule:(FMModule*)module;
@end

@implementation FMManager

static FMManager *shared = nil;

+ (id)shared
{
    @synchronized(self) {
        if(shared == nil)
            shared = [[FMManager alloc] init];        
    }
    return shared;
}

- (id)init
{
    if(self = [super init]) {
        mFileModules = [[NSMutableDictionary alloc] init];        
        mContexts = [[NSMutableDictionary alloc] init];        
        [self initBuiltInModules];
    }
    return self;
}


- (void)initBuiltInModules
{
    [[FMStrings moduleWithManager:self] load];
    [[FMNib moduleWithManager:self] load];
    [[FMImage moduleWithManager:self] load];
    [[FMRTF moduleWithManager:self] load];
    [[FMHTML moduleWithManager:self] load];
    [[FMTXT moduleWithManager:self] load];
}

- (NSArray*)fileModules
{
    NSMutableArray *array = [NSMutableArray array];
    NSEnumerator *enumerator = [[mFileModules allValues] objectEnumerator];
    FMModule *fm;
    while(fm = [enumerator nextObject]) {
        if(![array containsObject:fm])
            [array addObject:fm];
    }
    return array;
}

- (NSArray*)fileExtensionsForFileModule:(FMModule*)fm
{
    NSMutableArray *array = [NSMutableArray array];
    NSEnumerator *enumerator = [[mFileModules allKeys] objectEnumerator];
    NSString *ext;
    while(ext= [enumerator nextObject]) {
        if(mFileModules[ext] == fm)
            [array addObject:ext];
    }
    return array;
}

#pragma mark -

- (void)registerFileModule:(FMModule*)fm forFileExtension:(NSString*)extension
{
    mFileModules[extension] = fm;
}

- (FMModule*)fileModuleForFileExtension:(NSString*)extension
{
    FMModule *module = mFileModules[extension];
    if(module == nil) {
        // No default built-in module, look into the user-defined settings
        module = [[PreferencesEditors shared] moduleForExtension:extension];
    }

    return module;
}

- (FMEditor*)editorForFile:(NSString*)file
{
    return [[[[self fileModuleForFileExtension:[file pathExtension]] editorClass] alloc] init];
}

- (FMEngine*)engineForFile:(NSString*)file
{
    return [[[[self fileModuleForFileExtension:[file pathExtension]] engineClass] alloc] init];    
}

- (FMController*)controllerForFile:(NSString*)file
{
    return [[[[self fileModuleForFileExtension:[file pathExtension]] controllerClass] alloc] init];    
}

- (FileController*)defaultControllerForFile:(NSString*)file
{
    FileController *fileController = [[FMManager shared] controllerForFile:file];        
    if(fileController == NULL)
        fileController = [FileController controller];
    return fileController;
}

@end
