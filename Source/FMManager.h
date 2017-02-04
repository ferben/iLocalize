//
//  FMManager.h
//  iLocalize3
//
//  Created by Jean on 25.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@class FMModule;
@class FMEditor;
@class FMEngine;
@class FMController;

@class FileController;

@interface FMManager : NSObject
{
    NSMutableDictionary  *mFileModules;
    NSMutableDictionary  *mContexts;
}

+ (id)shared;

- (NSArray *)fileModules;
- (NSArray *)fileExtensionsForFileModule:(FMModule *)fm;

- (void)registerFileModule:(FMModule *)fm forFileExtension:(NSString *)extension;
- (FMModule *)fileModuleForFileExtension:(NSString *)extension;

- (FMEditor *)editorForFile:(NSString *)file;
- (FMEngine *)engineForFile:(NSString *)file;
- (FMController *)controllerForFile:(NSString *)file;

- (FileController *)defaultControllerForFile:(NSString *)file;

@end
