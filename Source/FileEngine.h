//
//  FileEngine.h
//  iLocalize3
//
//  Created by Jean on 13.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractEngine.h"

@class FileController;
@class FileModel;

@interface FileEngine : AbstractEngine
{
}

- (void)addFiles:(NSArray *)files language:(NSString *)language toSmartPath:(NSString *)smartPath;

- (void)addFileModel:(FileModel *)fm toLanguage:(NSString *)language;
- (NSArray *)addBaseFileModel:(FileModel *)baseFileModel copyFile:(BOOL)copyFile;

- (void)deleteFileController:(FileController *)fileController removeFromDisk:(BOOL)removeFromDisk;
- (void)deleteFileControllers:(NSArray *)fileControllers;

@end
