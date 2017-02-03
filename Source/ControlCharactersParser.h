//
//  ControlCharactersParser.h
//  iLocalize3
//
//  Created by Jean on 06.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//


@interface ControlCharactersParser : NSObject {
    NSMutableString        *mString;
    int                    mIndex;
}
+ (NSString*)showControlCharacters:(NSString*)string;
+ (NSString*)hideControlCharacters:(NSString*)string;
@end
