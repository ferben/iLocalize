//
//  AddRemoveFilesOperation.h
//  iLocalize3
//
//  Created by Jean on 10.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractOperation.h"

@interface AddRemoveFilesOperation : AbstractOperation
{
    NSArray   *mFiles;
    NSArray   *mFileControllers;
    NSString  *mLanguage;
}

- (void)addFiles;
- (void)addFilesToLanguage:(NSString *)language;
- (void)removeFileControllers:(NSArray *)fileControllers;

@end
