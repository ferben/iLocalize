//
//  XMLParserTesting.h
//  Tests
//
//  Created by Jean on 9/3/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "XMLParser.h"

@interface XMLParserTestHelper : NSObject <XMLParserDelegate> {
	NSMutableArray *mVerifyArray;
}
+ (BOOL)parseFile:(NSString*)file verifyFile:(NSString*)verify;
- (BOOL)verifyWithArray:(NSArray*)array;
@end
