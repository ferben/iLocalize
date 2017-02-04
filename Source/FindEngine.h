//
//  FindEngine.h
//  iLocalize3
//
//  Created by Jean on 20.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractEngine.h"

@class StringController;
@class SearchContext;

@interface FindEngine : AbstractEngine
{
}

/**
 Resets all the previous content matching in all the string controllers.
 */
- (void)resetContentMatching;

/**
 Find all the files containing the strings with the specified string in 
 the specified context.
 */
- (void)findString:(NSString *)string context:(SearchContext *)context;

/**
 Replaces the selected strings with the specified string.
 */
- (void)replaceWithString:(NSString *)replaceString context:(SearchContext *)context;

/**
 Replaces all matching strings with the specified string in 
 the specified context.
 */
- (void)replaceAllStrings:(NSString *)searchString withString:(NSString *)replaceString context:(SearchContext *)context;

@end
