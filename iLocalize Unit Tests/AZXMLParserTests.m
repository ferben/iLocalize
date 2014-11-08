//
//  AZXMLParserTests.m
//  iLocalize
//
//  Created by Jean Bovet on 11/27/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import "AbstractTests.h"
#import "AZXMLParser+Internal.h"
#import "TMXImporter.h"

@interface AZXMLParserTests : AbstractTests <AZXMLParserDelegate>

@end

@implementation AZXMLParserTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}


- (void)testDoctypedecl {
    AZXMLParser *parser = [AZXMLParser parserWithText:@"<!DOCTYPE greeting SYSTEM \"hello.dtd\">"];
    XCTAssertTrue(parseDoctypedecl(parser), @"Doctypedecl failed");
}

- (void)testSimpleText {
    NSString *text = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?> <Proj> <ProjName>ZinPackageData</ProjName> </Proj>";
    AZXMLParser *parser = [AZXMLParser parserWithText:text];
    XCTAssertTrue([parser parse], @"Failed to parse");
}

- (void)testAppleGlotXML {
    AZXMLParser *parser = [AZXMLParser parserWithPath:[self pathForResource:@"AZXMLParser/glossary/appleglot.xml"]];
    XCTAssertTrue([parser parse], @"Failed to parse");
}

- (void)testTMXXML {
    NSString *tmxFile = [self pathForResource:@"AZXMLParser/glossary/tmx.xml"];

    {
        AZXMLParser *parser = [AZXMLParser parserWithPath:tmxFile];
        parser.delegate = self;
        XCTAssertTrue([parser parse], @"Failed to parse");
    }

    {
        TMXImporter *importer = [[TMXImporter alloc] init];
        importer.useFastXMLParser = YES;
        XCTAssertTrue([importer canImportDocument:[NSURL fileURLWithPath:tmxFile] error:nil], @"Can import failed");
    }

    {
        TMXImporter *importer = [[TMXImporter alloc] init];
        importer.useFastXMLParser = YES;
        XCTAssertTrue([importer importDocument:[NSURL fileURLWithPath:tmxFile] error:nil], @"Import failed");
        XCTAssertEqualObjects(importer.sourceLanguage, @"en", @"Source language mismatch");
        XCTAssertEqualObjects(importer.targetLanguage, @"fr", @"Source language mismatch");
    }
}

- (void)testCharData {
    NSString *s = @" abcdefg hij";
    AZXMLParser *parser = [AZXMLParser parserWithText:s];
    XCTAssertTrue(parseCharData(parser), @"CharData failed");
    XCTAssertEqual(parser.error.code, AZXMLParserErrorCodeEndOfText, @"End of text expected");
}

- (void)testCharRefAlphaNumeric {
    AZXMLParser *parser = [AZXMLParser parserWithText:@"0123456789abcdefABCDEFg*"];
    
    // [0-9a-fA-F]
    for (NSUInteger index=0; index<10; index++) {
        XCTAssertTrue(parseCharRefAlphaNumeric(parser), @"CharRefAlphaNumeric failed");
    }
    for (NSUInteger index='a'; index<='f'; index++) {
        XCTAssertTrue(parseCharRefAlphaNumeric(parser), @"CharRefAlphaNumeric failed");
    }
    for (NSUInteger index='A'; index<='F'; index++) {
        XCTAssertTrue(parseCharRefAlphaNumeric(parser), @"CharRefAlphaNumeric failed");
    }
    XCTAssertFalse(parseCharRefAlphaNumeric(parser), @"CharRefAlphaNumeric failed");
    XCTAssertFalse(parseCharRefAlphaNumeric(parser), @"CharRefAlphaNumeric failed");
    XCTAssertFalse(parseCharRefAlphaNumeric(parser), @"CharRefAlphaNumeric failed"); // EOF
    
    XCTAssertEqual(parser.error.code, AZXMLParserErrorCodeEndOfText, @"End of text expected");
}

// [10]   	AttValue	   ::=   	'"' ([^<&"] | Reference)* '"'
//                                      |  "'" ([^<&'] | Reference)* "'"
- (void)testAttValue {
    {
        AZXMLParser *parser = [AZXMLParser parserWithText:@"'this is a valid value'"];
        XCTAssertTrue(parseAttValue(parser), @"AttValue failed");
    }
    
    {
        AZXMLParser *parser = [AZXMLParser parserWithText:@"\"this is a valid value\""];
        XCTAssertTrue(parseAttValue(parser), @"AttValue failed");
    }

    {
        AZXMLParser *parser = [AZXMLParser parserWithText:@"''"];
        XCTAssertTrue(parseAttValue(parser), @"AttValue failed");
    }

    {
        AZXMLParser *parser = [AZXMLParser parserWithText:@"\"\""];
        XCTAssertTrue(parseAttValue(parser), @"AttValue failed");
    }

    {
        AZXMLParser *parser = [AZXMLParser parserWithText:@"'&#89;'"];
        XCTAssertTrue(parseAttValue(parser), @"AttValue failed");
    }

    {
        AZXMLParser *parser = [AZXMLParser parserWithText:@"'&#x89AB;'"];
        XCTAssertTrue(parseAttValue(parser), @"AttValue failed");
    }

    {
        AZXMLParser *parser = [AZXMLParser parserWithText:@"'&hello;'"];
        XCTAssertTrue(parseAttValue(parser), @"AttValue failed");
    }

    {
        AZXMLParser *parser = [AZXMLParser parserWithText:@"'&#x89AB'"];
        XCTAssertFalse(parseAttValue(parser), @"AttValue failed");
    }

    {
        AZXMLParser *parser = [AZXMLParser parserWithText:@"'&#89'"];
        XCTAssertFalse(parseAttValue(parser), @"AttValue failed");
    }

    {
        AZXMLParser *parser = [AZXMLParser parserWithText:@"'&#89A;'"];
        XCTAssertFalse(parseAttValue(parser), @"AttValue failed");
    }

    {
        AZXMLParser *parser = [AZXMLParser parserWithText:@"\"'"];
        XCTAssertFalse(parseAttValue(parser), @"AttValue failed");
        XCTAssertEqual(parser.error.code, AZXMLParserErrorCodeEndOfText, @"End of text expected");
    }
    
    {
        AZXMLParser *parser = [AZXMLParser parserWithText:@"'\""];
        XCTAssertFalse(parseAttValue(parser), @"AttValue failed");
        XCTAssertEqual(parser.error.code, AZXMLParserErrorCodeEndOfText, @"End of text expected");
    }
}

// Name	   ::=   	 NameStartChar (NameChar)*
- (void)testName {
    {
        AZXMLParser *parser = [AZXMLParser parserWithText:@"a123139"];
        XCTAssertTrue(parseName(parser), @"Name failed");
    }

    {
        AZXMLParser *parser = [AZXMLParser parserWithText:@"_123139"];
        XCTAssertTrue(parseName(parser), @"Name failed");
    }

    {
        AZXMLParser *parser = [AZXMLParser parserWithText:@"123139"];
        XCTAssertFalse(parseName(parser), @"Name failed");
    }
    
    {
        AZXMLParser *parser = [AZXMLParser parserWithText:@"_123139<a"];
        XCTAssertTrue(parseName(parser), @"Name failed"); // <a remains
        XCTAssertEqual(parser.currentCharacter, (unichar)'<', @"Last char doesn't match");
    }
}

- (void)testNameStartChar {
    NSString *validString = @"abcdef_:";
    NSString *invalidString = @"0123456789-.<>&";
    AZXMLParser *parser = [AZXMLParser parserWithText:[NSString stringWithFormat:@"%@%@", validString, invalidString]];
    for (NSUInteger index=0; index<validString.length; index++) {
        XCTAssertTrue(parseNameStartChar(parser), @"NameStartChar failed");
    }
    for (NSUInteger index=0; index<invalidString.length; index++) {
        XCTAssertFalse(parseNameStartChar(parser), @"NameStartChar failed");
    }
    XCTAssertFalse(parseNameStartChar(parser), @"NameStartChar failed"); // EOF
    XCTAssertEqual(parser.error.code, AZXMLParserErrorCodeEndOfText, @"End of text expected");
}

- (void)testNameChar {
    NSString *validString = @"abcdef_:-.0123456789";
    NSString *invalidString = @"<>&";
    AZXMLParser *parser = [AZXMLParser parserWithText:[NSString stringWithFormat:@"%@%@", validString, invalidString]];
    for (NSUInteger index=0; index<validString.length; index++) {
        XCTAssertTrue(parseNameChar(parser), @"NameChar failed");
    }
    for (NSUInteger index=0; index<invalidString.length; index++) {
        XCTAssertFalse(parseNameChar(parser), @"NameChar failed");
    }
    XCTAssertFalse(parseNameChar(parser), @"NameChar failed"); // EOF
    XCTAssertEqual(parser.error.code, AZXMLParserErrorCodeEndOfText, @"End of text expected");
}

#pragma mark - AZXMLParserDelegate

- (void)parser:(AZXMLParser*)parser didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributes {
//    NSLog(@"didStart `%@`: %@", elementName, attributes);
}

- (void)parser:(AZXMLParser*)parser didEndElement:(NSString *)elementName {
//    NSLog(@"didEnd `%@`", elementName);
}

- (void)parser:(AZXMLParser*)parser foundCharacters:(NSString *)string {
//    NSLog(@"Found: `%@`", string);
}


@end
