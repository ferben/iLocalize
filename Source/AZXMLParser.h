//
//  AZXMLParser.h
//  iLocalize
//
//  Created by Jean Bovet on 11/27/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import <Foundation/Foundation.h>

/** The various errors that the parser can emit
 */
typedef NS_ENUM(NSInteger, AZXMLParserErrorCode)
{
    AZXMLParserErrorCodeNone          = 0,
    AZXMLParserErrorCodeEndOfText,
    AZXMLParserErrorCodeMismatch,
    AZXMLParserErrorCodeUnsupported,
};

@class AZXMLParser;

@protocol AZXMLParserDelegate <NSObject>

- (void)parser:(AZXMLParser *)parser didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributes;
- (void)parser:(AZXMLParser *)parser didEndElement:(NSString *)elementName;
- (void)parser:(AZXMLParser *)parser foundCharacters:(NSString *)string;

@end

typedef void(^AZXMLParserDidStartElementBlock)(AZXMLParser *parser, NSString *elementName, NSDictionary *attributes);
typedef void(^AZXMLParserDidEndElementBlock)(AZXMLParser *parser, NSString *elementName);
typedef void(^AZXMLParserFoundCharactersBlock)(AZXMLParser *parser, NSString *string);

/** This is the implementation of a very fast XML parser
 tailored at the needs of iLocalize
 */
@interface AZXMLParser : NSObject
{
}

/** The optional delegate
 */
@property (nonatomic, weak) id<AZXMLParserDelegate> delegate;

/** Block invoked when the start of an element has been parsed
 */
@property (nonatomic, copy) AZXMLParserDidStartElementBlock didStartElementBlock;

/** Block invoked when the end of an element has been parsed
 */
@property (nonatomic, copy) AZXMLParserDidEndElementBlock didEndElementBlock;

/** Block invoked when some text has been parsed
 */
@property (nonatomic, copy) AZXMLParserFoundCharactersBlock foundCharactersBlock;

/** The parser error or nil if no error
 */
@property (nonatomic, strong, readonly) NSError *error;

/** A property to stop the parser
 */
@property (nonatomic) BOOL stop;

+ (AZXMLParser *)parserWithPath:(NSString *)path;

+ (AZXMLParser *)parserWithUrl:(NSURL *)url;

+ (AZXMLParser *)parserWithText:(NSString *)text;

- (BOOL)parse;

@end
