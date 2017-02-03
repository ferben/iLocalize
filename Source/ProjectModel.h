//
//  ProjectModel.h
//  iLocalize3
//
//  Created by Jean on 30.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

@class LanguageModel;
@class FileModel;

@interface ProjectModel : NSObject <NSCoding> {
    NSString        *mName;
    
    NSString        *mSourceName;
    NSString        *mProjectPath;
    
    NSString        *mBaseLanguage;
    NSMutableArray    *mLanguageModelArray;
}

+ (ProjectModel*)model;

- (void)setName:(NSString*)name;
- (NSString*)name;

- (LanguageModel*)languageModelForLanguage:(NSString*)language;
- (void)addFileModel:(FileModel*)fileModel toLanguage:(NSString*)language;

- (void)setBaseLanguage:(NSString*)language;
- (NSString*)baseLanguage;
- (void)addLanguages:(NSArray*)languages;

- (void)addLanguageModel:(LanguageModel*)model;
- (void)removeLanguageModel:(LanguageModel*)model;

- (LanguageModel*)baseLanguageModel;
- (NSMutableArray*)languageModels;

- (void)setSourceName:(NSString*)name;
- (NSString*)sourceName;

- (void)setProjectPath:(NSString*)path;
- (NSString*)projectPath;

+ (NSString*)projectSourceFolderPathForProjectPath:(NSString*)pp;

- (NSString*)projectSourceFolderPath;
- (NSString*)projectSourceFilePath;

- (NSString*)projectGlossaryFolderPath;
- (NSString*)projectHistoryFolderPath;

- (NSString*)relativePathFromAbsoluteProjectPath:(NSString*)absPath;
- (NSString*)absoluteProjectPathFromRelativePath:(NSString*)relPath;
@end
