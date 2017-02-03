//
//  AbstractStringsEngine.h
//  iLocalize
//
//  Created by Jean Bovet on 4/5/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@class StringsContentModel;

@interface AbstractStringsEngine : NSObject {
    // Format in which the strings are layed out int he file
    NSUInteger format;
    
    // Type of end of line used (first EOL is used to detect the type)
    NSUInteger eolType;
    
    // Strings content model
    StringsContentModel *content;
}

@property NSUInteger format;
@property NSUInteger eolType;
@property (strong) StringsContentModel *content;

@end
