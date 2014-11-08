//
//  FMStringsExtensions.h
//  iLocalize3
//
//  Created by Jean on 26.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FileModelContent.h"

@class StringModel;
@class StringController;

@interface NSArray (FMStringsExtension)
- (StringController*)stringControllerForKey:(NSString*)key;;
@end
