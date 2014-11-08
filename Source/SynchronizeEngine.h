//
//  SynchronizeEngine.h
//  iLocalize3
//
//  Created by Jean on 13.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractEngine.h"

@class FileController;

@interface SynchronizeEngine : AbstractEngine {

}
- (void)synchronizeToDisk:(FileController*)fileController;
- (void)synchronizeToDiskIfNeeded:(FileController*)fileController;

- (void)synchronizeFromDisk:(FileController*)fileController;
- (void)synchronizeFromDiskIfNeeded:(FileController*)fileController;

- (void)synchronizeFileController:(FileController*)fileController;
- (void)synchronizeFileControllers:(NSArray*)fileControllers;
@end
