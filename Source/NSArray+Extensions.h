//
//  NSArray+Extensions.h
//  iLocalize3
//
//  Created by Jean on 31.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

@interface NSArray (iLocalize)
- (id)firstObject;
- (NSArray*)arrayByRemovingPrefix:(NSString*)prefix;
- (NSArray*)arrayOfObjectsNotInArray:(NSArray*)objects;
- (NSArray*)objectsAtRows:(NSArray*)rows;
- (void)setMenuItemsState:(int)state;
- (NSImage*)imageUnion;

- (NSArray*)pathsIncludingOnlyBundles;
- (NSArray*)pathsExcludingBundles;
- (NSArray*)pathsExcludingExtensions:(NSArray*)extensions;

- (BOOL)supportOperation:(int)op;
- (NSArray*)buildArrayOfFileControllerPaths;
@end
