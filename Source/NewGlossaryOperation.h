//
//  NewGlossaryOperation.h
//  iLocalize
//
//  Created by Jean Bovet on 11/30/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import "Operation.h"

@interface NewGlossaryOperation : Operation
{
}

@property (nonatomic, strong) NSArray *languages;

/** Returns YES if at least one glossary already
 exists on disk and needs to be overwritten
 */
- (BOOL)needsToOverwrite;

@end
