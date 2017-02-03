//
//  XMLImporterParser.h
//  iLocalize
//
//  Created by Jean Bovet on 4/30/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@class Stack;

typedef BOOL (^XMLParserStartElementCallback)(Stack *elements, NSDictionary *attributes);
typedef BOOL (^XMLParserEndElementCallback)(Stack *elements, NSString *textContent);
typedef void (^XMLParserErrorElementCallback)(NSError *error);

/**
 Event driven XML parser.
 */
@interface XMLImporterParser : NSObject<NSXMLParserDelegate> {
    Stack *elements;
    BOOL aborted;
    NSMutableString *textContent;
    XMLParserStartElementCallback startElementCallback;
    XMLParserEndElementCallback endElementCallback;    
    XMLParserErrorElementCallback errorElementCallback;
}

@property (copy) XMLParserStartElementCallback startElementCallback;
@property (copy) XMLParserEndElementCallback endElementCallback;
@property (copy) XMLParserErrorElementCallback errorElementCallback;

- (BOOL)parseURL:(NSURL*)url;;

- (void)setParseText:(BOOL)flag;

@end
