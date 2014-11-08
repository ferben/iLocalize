//
//  StringEncodingTool.h
//  iLocalize3
//
//  Created by Jean on 23.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@class StringEncoding;

@interface StringEncodingTool : NSObject {
	NSMutableArray		*mAvailableEncodings;
}

+ (id)shared;

- (NSArray*)availableEncodings;

- (void)fillAvailableEncodingsToMenu:(NSMenu*)menu target:(id)target action:(SEL)action;
- (NSMenu*)availableEncodingsMenu;
- (NSMenu*)availableEncodingsMenuWithTarget:(id)target action:(SEL)action;

+ (NSString*)stringWithContentOfFile:(NSString*)file encoding:(StringEncoding*)encoding;
+ (NSString*)stringWithContentOfFile:(NSString*)file defaultEncoding:(StringEncoding*)defaultEncoding detectedEncoding:(StringEncoding**)detectedEncoding hasEncodingInformation:(BOOL*)hasEncoding;
+ (NSString*)stringWithContentOfFile:(NSString*)file encodingUsed:(StringEncoding**)encoding defaultEncoding:(StringEncoding*)defaultEncoding;

+ (StringEncoding*)encodingOfFile:(NSString*)file defaultEncoding:(StringEncoding*)defaultEncoding;
+ (StringEncoding*)encodingOfFile:(NSString*)file defaultEncoding:(StringEncoding*)defaultEncoding hasEncodingInformation:(BOOL*)hasEncoding;

+ (NSData*)encodeString:(NSString*)string toDataUsingEncoding:(StringEncoding*)encoding;

@end
