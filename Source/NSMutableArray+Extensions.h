//
//  NSMutableArray+Extensions.h
//  iLocalize3
//
//  Created by Jean on 05.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@interface NSMutableArray (iLocalize)
- (void)addObjectSafe:(id)object;
- (void)removeFirstObject;
- (NSMutableArray*)arrayByRemovingFirstObject;
- (BOOL)removePathOrEquivalent:(NSString*)path;
@end
