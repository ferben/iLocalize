//
//  HTMLEncodingTool.h
//  Tests
//
//  Created by Jean on 9/2/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "XMLParser.h"

@class StringEncoding;

@interface HTMLEncodingTool : NSObject <XMLParserDelegate> {
    NSMutableArray *mReplaceRanges;
    NSString *mScannerEncoding;
    int mInsideXMLHeader;
    int mInsideMeta;
    BOOL mLookingForEncoding;
}
+ (StringEncoding*)encodingOfFile:(NSString*)file hasEncoding:(BOOL*)hasEncoding;
+ (StringEncoding*)encodingOfContent:(NSString*)file hasEncoding:(BOOL*)hasEncoding;
+ (StringEncoding*)encodingOfContentInXMLHeader:(NSString*)file hasEncoding:(BOOL*)hasEncoding;
+ (NSString*)replaceEncodingInformationOfString:(NSString*)content fromEncoding:(StringEncoding*)source toEncoding:(StringEncoding*)target;
@end
