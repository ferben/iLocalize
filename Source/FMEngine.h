//
//  FMEngine.h
//  iLocalize3
//
//  Created by Jean on 25.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"

@class ProjectPrefs;
@class Console;

@class FileModel;
@class FileModelContent;
@class FileController;

@class SynchronizeEngine;
@class StringsEngine;
@class NibEngine;
@class StringEncoding;

@interface FMEngine : NSObject
{
}

+ (id)engine;

@property (weak) id<ProjectProvider> projectProvider;

- (ProjectPrefs *)projectPrefs;
- (Console *)console;

- (StringEncoding *)encodingForLanguage:(NSString *)language;
- (StringEncoding *)encodingOfFile:(NSString *)file language:(NSString *)language;

- (SynchronizeEngine *)synchronizeEngine;
- (StringsEngine *)stringsEngine;
- (NibEngine *)nibEngine;

- (BOOL)loadContentsOnlyWhenDisplaying;
- (BOOL)supportsStringEncoding;
- (BOOL)supportsContentTranslation;

- (FileModelContent *)duplicateFileModelContent:(FileModelContent *)content emptyValue:(BOOL)emptyValue;

- (void)loadEncoding:(NSString *)file intoFileModel:(FileModel *)fileModel;
- (void)loadFile:(NSString *)file intoFileModel:(FileModel *)fileModel;
- (void)translateFileModel:(FileModel *)fileModel withLocalizedFile:(NSString *)localizedFile;
- (id)rebaseBaseFileController:(FileController *)baseFileController usingFile:(NSString *)file eolType:(int *)eolType;
- (void)rebaseFileContentWithContent:(id)contents fileController:(FileController *)fileController;
- (void)rebaseAndTranslateContentWithContent:(id)content fileController:(FileController *)fileController usingPreviousLayout:(BOOL)previousLayout;
- (void)reloadFileController:(FileController *)fileController usingFile:(NSString *)file;
- (void)saveFileController:(FileController *)fileController usingEncoding:(StringEncoding *)encoding;
- (BOOL)willConvertFileController:(FileController *)fileController toEncoding:(StringEncoding *)encoding;

@end
