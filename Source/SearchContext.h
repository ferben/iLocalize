//
//  SearchContext.h
//  iLocalize
//
//  Created by Jean Bovet on 2/21/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@interface SearchContext : NSObject
{
    // Scope such as "file", "base", etc.
    NSInteger   scope;
    
    // Options such as "contains", "beginswith", etc.
    NSInteger   options;
    
    BOOL        ignoreCase;
}

@property NSInteger scope;
@property NSInteger options;
@property BOOL ignoreCase;

@end
