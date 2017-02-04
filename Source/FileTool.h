//
//  FileTool.h
//  iLocalize3
//
//  Created by Jean on 28.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

@class Console;

@interface FileTool : NSObject
{
    NSMutableArray  *mAtomicExtensions;
}

+ (FileTool *)shared;

+ (BOOL)isPathSVNFolder:(NSString *)path;

- (void)addFileExtensionAsAtomic:(NSString *)extension;
- (BOOL)isFileAtomic:(NSString *)file;

- (void)preparePath:(NSString *)path atomic:(BOOL)atomic skipLastComponent:(BOOL)skipLastComponent;
- (BOOL)copySourceFile:(NSString *)sourceFile toReplaceFile:(NSString *)destFile console:(Console *)console;
- (BOOL)copySourceFile:(NSString *)sourceFile toFile:(NSString *)destFile console:(Console *)console;
- (BOOL)copySourcePath:(NSString *)sourcePath toPath:(NSString *)destPath languages:(NSArray *)languages console:(Console *)console;

+ (NSString *)generateTemporaryFileName;
+ (NSString *)generateTemporaryFileNameWithExtension:(NSString *)ext;

+ (NSString *)languageOfPath:(NSString *)path;
+ (NSString *)languageFolderPathOfPath:(NSString *)path;
+ (NSString *)translatePath:(NSString *)path toLanguage:(NSString *)language;
+ (NSString *)translatePath:(NSString *)path toLanguage:(NSString *)language keepLanguageFormat:(BOOL)keepFormat;
+ (NSArray *)equivalentLanguagePaths:(NSString *)path;
+ (NSString *)resolveEquivalentFile:(NSString *)file;
+ (NSString *)systemApplicationSupportFolder;
+ (NSString *)systemCacheFolder;

+ (BOOL)buildFSRef:(FSRef *)fsRef fromPath:(NSString *)path;
+ (BOOL)isPathAnAlias:(NSString *)path;
+ (NSString *)resolvedPathOfAliasPath:(NSString *)alias;
+ (BOOL)createAliasOfFile:(NSString *)source toFile:(NSString *)target;

+ (void)revealFile:(NSString *)file;
+ (void)openFile:(NSString *)file suggestedApp:(NSString *)app;
+ (void)openFile:(NSString *)file;
+ (BOOL)diffFiles:(NSArray *)files;
+ (BOOL)zipPath:(NSString *)source toFileName:(NSString *)target recursive:(BOOL)folder;

+ (NSString *)shortVersionOfBundle:(NSString *)path language:(NSString *)language;
+ (NSString *)versionOfBundle:(NSString *)path language:(NSString *)language;

@end
