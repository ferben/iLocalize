//
//  NSString+ExtensionsSmall.h
//  iLocalize3
//
//  Created by Jean on 6/25/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

@interface NSString (iLocalizeExtensionsSmall)
- (BOOL)isPathExisting;
- (NSString*)parentPath;
- (int)numberOfLines;
@end