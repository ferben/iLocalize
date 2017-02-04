//
//  ModelEngine.h
//  iLocalize3
//
//  Created by Jean on 13.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractEngine.h"
#import "BundleSource.h"

@class LanguageModel;
@class FileModel;

@interface ModelEngine : AbstractEngine
{
}

- (LanguageModel *)createLanguageModelForLanguage:(NSString *)language;
- (LanguageModel *)createLanguageModelForLanguage:(NSString *)language identical:(BOOL)identical layout:(BOOL)layout copyOnlyIfExists:(BOOL)copyOnlyIfExists source:(BundleSource *)source;

- (FileModel *)createFileModelFromProjectFile:(NSString *)file;
- (FileModel *)createFileModelForLanguage:(NSString *)language sourceFileModel:(FileModel *)sourceFileModel;
- (FileModel *)createFileModelForLanguage:(NSString *)language sourceFileModel:(FileModel *)sourceFileModel copyFile:(BOOL)copyFile;
- (FileModel *)createFileModelForLanguage:(NSString *)language sourceFileModel:(FileModel *)sourceFileModel copyOnlyIfExists:(BOOL)copyOnlyExists translateFromSourcePath:(NSString *)sourcePath;
- (FileModel *)createFileModelForLanguage:(NSString *)language sourceFileModel:(FileModel *)sourceFileModel layout:(BOOL)layout copyOnlyIfExists:(BOOL)copyOnlyIfExists updateFromSourcePath:(NSString *)sourcePath;

- (FileModel *)createFileModelForLanguage:(NSString *)language sourceFileModel:(FileModel *)sourceFileModel usingLocalizedFile:(NSString *)localizedFile;

@end
