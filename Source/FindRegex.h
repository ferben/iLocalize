//
//  FindRegex.h
//  iLocalize3
//
//  Created by Jean on 3/12/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

@interface FindRegex : NSObject {
	NSString *regex;
	BOOL ignoreCase;
}
@property (strong) NSString *regex;
@property BOOL ignoreCase;
+ (FindRegex*)regexWithPattern:(NSString*)pattern ignoreCase:(BOOL)ignoreCase;
- (id)initWithPattern:(NSString*)pattern ignoreCase:(BOOL)ignoreCase;
- (BOOL)regexMatch:(NSString*)string;
- (NSMutableArray*)regexRangesInString:(NSString*)string;
@end
