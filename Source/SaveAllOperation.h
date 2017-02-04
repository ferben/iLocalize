//
//  SaveAllOperation.h
//  iLocalize3
//
//  Created by Jean on 12.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractOperation.h"

@interface SaveAllOperation : AbstractOperation
{
}

- (void)saveAll:(NSArray *)files;
- (void)saveAll:(NSArray *)files createIfNotExisting:(BOOL)createIfNotExisting;

- (void)reloadAll:(NSArray *)files;

- (void)saveFiles;
- (void)saveFilesWithoutConfirmation;
- (void)checkAndSaveFilesWithConfirmation:(BOOL)confirmation completion:(dispatch_block_t)completion;

- (void)reloadFiles;
- (void)reloadFilesWithoutConfirmation;

@end
