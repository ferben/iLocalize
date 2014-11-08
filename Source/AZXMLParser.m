//
//  AZXMLParser.m
//  iLocalize
//
//  Created by Jean Bovet on 11/27/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import "AZXMLParser+Internal.h"

@interface AZXMLParser()

@property (nonatomic, strong) NSString *content;

@property (nonatomic, strong) NSString *parserText;

@property (nonatomic, strong) NSMutableString *lastParsedName;
@property (nonatomic, strong) NSMutableString *lastParsedElementName;
@property (nonatomic, strong) NSMutableString *lastParsedText;
@property (nonatomic, strong) NSMutableDictionary *lastParsedAttributes;

@property (nonatomic) NSUInteger parserIndex;
@property (nonatomic) NSInteger parserReportError;
@property (nonatomic, strong) NSString *parserXMLVersion;
@property (nonatomic) BOOL parserDebugVerbose;
@property (nonatomic, strong, readwrite) NSError *error;

@end

/** The implementation is following this reference document
 http://www.w3.org/TR/xml11/
 */
@implementation AZXMLParser

+ (AZXMLParser*)parserWithPath:(NSString*)path {
    return [self parserWithUrl:[NSURL fileURLWithPath:path]];
}

+ (AZXMLParser*)parserWithUrl:(NSURL*)url {
    AZXMLParser *parser = [[AZXMLParser alloc] init];
    NSStringEncoding usedEncoding;
    NSError *error;
    parser.content = [NSString stringWithContentsOfURL:url usedEncoding:&usedEncoding error:&error];
    if (nil == parser.content) {
        NSLog(@"Cannot read the content of %@ because %@", url, error);
        return nil;
    }
    [parser prepare];
    return parser;
}

+ (AZXMLParser*)parserWithText:(NSString*)text {
    AZXMLParser *parser = [[AZXMLParser alloc] init];
    parser.content = text;
    [parser prepare];
    return parser;
}

- (void)prepare {
    self.parserXMLVersion = nil;
    self.parserReportError = 0;
    self.parserText = self.content;
    self.parserIndex = 0;
    self.lastParsedName = nil;
    self.lastParsedText = nil;
    self.lastParsedAttributes = [[NSMutableDictionary alloc] init];
    self.stop = NO;
}

- (BOOL)parse {
    self.stop = NO;
    parseDocument(self);
    return nil == _error;
}

- (NSError*)error {
    if (nil == _error && self.parserIndex >= self.parserText.length) {
        _error = [NSError errorWithDomain:@"ch.arizona-software.iLocalize" code:AZXMLParserErrorCodeEndOfText userInfo:nil];
    }
    return _error;
}

- (unichar)currentCharacter {
    return currentCharacter(self);
}

- (NSString*)description {
    NSMutableString *context = [NSMutableString string];
    NSInteger loc = MAX(0, (NSInteger)self.parserIndex-10);
    NSInteger len = MIN((NSInteger)self.parserText.length-loc, 20);
    [context appendString:[self.parserText substringWithRange:NSMakeRange(loc, len)]];
    [context replaceOccurrencesOfString:@"\n" withString:@" " options:0 range:NSMakeRange(0, context.length)];
    [context replaceOccurrencesOfString:@"\r" withString:@" " options:0 range:NSMakeRange(0, context.length)];
    [context replaceOccurrencesOfString:@"\t" withString:@" " options:0 range:NSMakeRange(0, context.length)];
    [context appendString:@"\n"];
    for (NSUInteger index=loc; index<loc+len; index++) {
        if (index == self.parserIndex) {
            [context appendString:@"ˆ"];
        } else {
            [context appendString:@" "];
        }
    }
    return [NSString stringWithFormat:@"%p-%@\n%@", self, NSStringFromClass([self class]), context];
}

#define IS_EOS (parser.parserIndex >= parser.parserText.length)
#define ASSERT_NOT_EOS if (IS_EOS) { reportError(parser, @"Unexpected end of string reached", AZXMLParserErrorCodeEndOfText); return NO; }

#define ASSERT_TRUE(a, message) { if (parser.stop) return YES; if (!(a)) { reportError(parser, message, AZXMLParserErrorCodeMismatch); return NO; } }

#define CURRENT_CHAR currentCharacter(parser)
#define CHAR_AND_NEXT currentCharacterAndIncrement(parser)

#define ASSERT_CHAR(c, char) { if (c != char) { reportError(parser, [NSString stringWithFormat:@"Expected %c but got %c", char, c], AZXMLParserErrorCodeMismatch); return NO; } };
#define ASSERT_CHAR_AND_NEXT(char) { unichar c = CHAR_AND_NEXT; ASSERT_CHAR(c, char) };

#define IS_LETTER(c) (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')
#define IS_NUMBER(c) (c >= '0' && c <= '9')
#define IS_SPACE(c) (c == 0x20 || c == 0x9 || c == 0xD || c == 0xA)
#define IS_CHAR(c) (c >= 0x1 && c <= 0xD7FF) || (c >= 0xE000 && c <= 0xFFFD) // || (c >= 0x10000 && c <= 0x10FFFF);

#pragma mark - Helper methods

typedef BOOL (*function)(AZXMLParser *parser);

static inline void parseZeroOrMore(function f, AZXMLParser *parser) {
    if (parser.stop) return;
    
    NSUInteger oldIndex = parser.parserIndex;
    parser.parserReportError++;
    if (f(parser)) {
        oldIndex = parser.parserIndex;
        while (f(parser)) {
            if (parser.stop) return;
            oldIndex = parser.parserIndex;
        }
        parser.parserIndex = oldIndex;
    } else {
        parser.parserIndex = oldIndex;
    }
    parser.parserReportError--;
}

static inline NSUInteger parseZeroOrOne(function f, AZXMLParser *parser) {
    if (parser.stop) return 0;

    NSUInteger count = 0;
    NSUInteger oldIndex = parser.parserIndex;
    parser.parserReportError++;
    if (!f(parser)) {
        parser.parserIndex = oldIndex;
    } else {
        count = 1;
    }
    parser.parserReportError--;
    return count;
}

static inline BOOL parseOneOrMore(function f, AZXMLParser *parser, const char *name) {
    if (parser.stop) return YES;

    NSUInteger oldIndex = parser.parserIndex;
    if (f(parser)) {
        oldIndex = parser.parserIndex;
        while (f(parser)) {
            if (parser.stop) return YES;
            oldIndex = parser.parserIndex;
        }
        parser.parserIndex = oldIndex;
        return YES;
    } else {
        parser.parserIndex = oldIndex;
        reportError(parser, [NSString stringWithFormat:@"Expected at least one occurrence of %s", name], AZXMLParserErrorCodeMismatch);
        return NO;
    }
}

static unichar currentCharacter(AZXMLParser *parser) {
    ASSERT_NOT_EOS;
    return [parser.parserText characterAtIndex:parser.parserIndex];
}

static unichar currentCharacterAndIncrement(AZXMLParser *parser) {
    ASSERT_NOT_EOS;
    return [parser.parserText characterAtIndex:parser.parserIndex++];
}

static BOOL parseCString(const char * string, AZXMLParser *parser) {
    if (parser.stop) return YES;

    for (NSUInteger index=0; index < strlen(string); index++) {
        ASSERT_CHAR_AND_NEXT(string[index]);
    }
    return YES;
}

// Parse [0-9a-fA-F]
BOOL parseCharRefAlphaNumeric(AZXMLParser *parser) {
    unichar c = CHAR_AND_NEXT;
    return IS_NUMBER(c) || (c >= 'a' && c<= 'f') || (c >= 'A' && c <= 'F');
}

static inline BOOL parseNumeric(AZXMLParser *parser) {
    unichar c = CHAR_AND_NEXT;
    return IS_NUMBER(c);
}

static BOOL isCharPartOfSet(const unichar c, const char * set) {
    for (NSUInteger index=0; index < strlen(set); index++) {
        if (set[index] == c) {
            return YES;
        }
    }
    return NO;
}

static inline void emitFoundCharacters(AZXMLParser *parser, NSString *string) {
    [parser.delegate parser:parser foundCharacters:string];
    if (parser.foundCharactersBlock) parser.foundCharactersBlock(parser, string);
}

static void reportError(AZXMLParser *parser, NSString *message, AZXMLParserErrorCode code) {
    if (parser.parserReportError > 0) {
        return;
    }
    
    parser.error = [NSError errorWithDomain:@"ch.arizona-software.iLocalize" code:code userInfo:@{NSLocalizedDescriptionKey:message}];
    printParserInfo(parser, [NSString stringWithFormat:@"Failed because `%@`", message]);
    parser.stop = YES;
}

static void printDebugInfo(AZXMLParser *parser, NSString *message) {
    if (!parser.parserDebugVerbose) {
        return;
    }
    
    printParserInfo(parser, message);
}

static void printParserInfo(AZXMLParser *parser, NSString *message) {
    NSLog(@"%@\n%@", message, parser.description);
}

#pragma mark - XML parsing methods

// [1]   	document	   ::=   	 ( prolog element Misc* ) - ( Char* RestrictedChar Char* )
static inline BOOL parseDocument(AZXMLParser *parser) {
    if (parser.stop) return YES;

    parseZeroOrOne(&parseProlog, parser);
    ASSERT_TRUE(parseElement(parser), @"Expected element");
    parseZeroOrMore(&parseMisc, parser);
    return YES;
}

// element	   ::=   	 EmptyElemTag | STag content ETag
static inline BOOL parseElement(AZXMLParser *parser) {
    if (parser.stop) return YES;

    if (parseZeroOrOne(&parseEmptyElemTag, parser) > 0) {
        return YES;
    } else {
        ASSERT_TRUE(parseSTag(parser), @"Expected STag");
        ASSERT_TRUE(parseContent(parser), @"Expected content");
        ASSERT_TRUE(parseETag(parser), @"Expected ETag");
        return YES;
    }
}

// [40]   	STag	   ::=   	'<' Name (S Attribute)* S? '>'
static inline BOOL parseSTag(AZXMLParser *parser) {
    if (parser.stop) return YES;

    ASSERT_CHAR_AND_NEXT('<');
    ASSERT_TRUE(parseElemTag(parser), @"Expected ElemTag")
    ASSERT_CHAR_AND_NEXT('>');
    
    if (parser.stop) return YES;
    [parser.delegate parser:parser didStartElement:parser.lastParsedElementName attributes:parser.lastParsedAttributes];
    
    if (parser.stop) return YES;
    if (parser.didStartElementBlock) parser.didStartElementBlock(parser, parser.lastParsedElementName, parser.lastParsedAttributes);
    
    return YES;
}

// [42]   	ETag	   ::=   	'</' Name S? '>'
static inline BOOL parseETag(AZXMLParser *parser) {
    if (parser.stop) return YES;

    ASSERT_CHAR_AND_NEXT('<');
    ASSERT_CHAR_AND_NEXT('/');
    ASSERT_TRUE(parseName(parser), @"Expected Name");
    parseZeroOrOne(&parseS, parser);
    ASSERT_CHAR_AND_NEXT('>');
    
    if (parser.stop) return YES;
    [parser.delegate parser:parser didEndElement:parser.lastParsedName];
    
    if (parser.stop) return YES;
    if (parser.didEndElementBlock) parser.didEndElementBlock(parser, parser.lastParsedName);
    
    return YES;
}

// [44]   	EmptyElemTag	   ::=   	'<' Name (S Attribute)* S? '/>'
static inline BOOL parseEmptyElemTag(AZXMLParser *parser) {
    if (parser.stop) return YES;

    ASSERT_CHAR_AND_NEXT('<');
    ASSERT_TRUE(parseElemTag(parser), @"Expected ElemTag")
    ASSERT_CHAR_AND_NEXT('/');
    ASSERT_CHAR_AND_NEXT('>');
    return YES;
}

// Internal parsing for an element: Name (S Attribute)* S?
static inline BOOL parseElemTag(AZXMLParser *parser) {
    if (parser.stop) return YES;

    [parser.lastParsedAttributes removeAllObjects];
    parser.lastParsedElementName = nil;
    ASSERT_TRUE(parseName(parser), @"Expected Name");
    parser.lastParsedElementName = parser.lastParsedName;
    while (YES) {
        if (parseZeroOrOne(&parseS, parser) > 0) {
            if (parseZeroOrOne(&parseAttribute, parser) > 0) {
                // Attribute, keep looping
            } else {
                // No attribute, that means we are done
                break;
            }
        } else {
            break;
        }
    }
    return YES;
}

// [43]   	content	   ::=   	 CharData? ((element | Reference | CDSect | PI | Comment) CharData?)*
static inline BOOL parseContent(AZXMLParser *parser) {
    if (parser.stop) return YES;

    parseZeroOrOne(&parseCharData, parser);
    while (YES) {
        // TODO CDSect and PI
        if (parseZeroOrOne(&parseElement, parser) > 0) {
        } else if (parseZeroOrOne(&parseReference, parser) > 0) {
        } else if (parseZeroOrOne(&parseComment, parser) > 0) {
        } else {
            // Nothing more parse
            break;
        }
        
        parseZeroOrOne(&parseCharData, parser);
    }
    printDebugInfo(parser, @"Content");
    return YES;
}

// [14]   	CharData	   ::=   	[^<&]* - ([^<&]* ']]>' [^<&]*)
BOOL parseCharData(AZXMLParser *parser) {
    if (parser.stop) return YES;

    parser.lastParsedText = [[NSMutableString alloc] init];
    parseZeroOrMore(&parseSingleCharData, parser);
    if (parser.lastParsedText.length > 0) {
        emitFoundCharacters(parser, parser.lastParsedText);
    }
    
    return YES;
}

static inline BOOL parseSingleCharData(AZXMLParser *parser) {
    if (parser.stop) return YES;

    unichar c = CURRENT_CHAR;
    if (parseChar(parser) && c != '<' && c != '&') {
        [parser.lastParsedText appendFormat:@"%c", c];
        return YES;
    } else {
        return NO;
    }
}

// [41]   	Attribute	   ::=   	 Name Eq AttValue
static inline BOOL parseAttribute(AZXMLParser *parser) {
    if (parser.stop) return YES;

    ASSERT_TRUE(parseName(parser), @"Expected Name");
    NSString *parsedName = parser.lastParsedName;
    ASSERT_TRUE(parseEq(parser), @"Expected =");

    parser.lastParsedText = [[NSMutableString alloc] init];
    ASSERT_TRUE(parseAttValue(parser), @"Expected AttValue");
    NSString *parsedValue = parser.lastParsedText;
    
    parser.lastParsedAttributes[parsedName] = parsedValue;
    
    return YES;
}

// [10]   	AttValue	   ::=   	'"' ([^<&"] | Reference)* '"'
//                                      |  "'" ([^<&'] | Reference)* "'"
BOOL parseAttValue(AZXMLParser *parser) {
    if (parser.stop) return YES;

    ASSERT_NOT_EOS;
    unichar c = CHAR_AND_NEXT;
    BOOL useSingleQuote = NO;
    if (c == '\'') {
        useSingleQuote = YES;
    } else if (c == '"') {
        useSingleQuote = NO;
    } else {
        reportError(parser, @"Expected ' or \"", AZXMLParserErrorCodeMismatch);
        return NO;
    }
    
    //
    while (YES) {
        if (parser.stop) return YES;

        ASSERT_NOT_EOS;
        unichar c = CURRENT_CHAR;
        if (useSingleQuote && c == '\'') {
            parser.parserIndex++;
            return YES; // Reached the end of the literal
        }
        
        if (!useSingleQuote && c == '"') {
            parser.parserIndex++;
            return YES; // Reached the end of the literal
        }

        NSUInteger count = parseZeroOrOne(&parseReference, parser);
        if (count == 1) {
            continue;
        }
        
        c = CURRENT_CHAR;
        if (parseChar(parser)) {
            if (c == '<' || c == '&') {
                reportError(parser, [NSString stringWithFormat:@"Illegal character found %c", c], AZXMLParserErrorCodeMismatch);
                return NO;
            } else {
                [parser.lastParsedText appendFormat:@"%c", c];
            }
        } else {
            return NO;
        }
    }
    
    //
    
    if (useSingleQuote) {
        ASSERT_CHAR_AND_NEXT('\'');
    } else {
        ASSERT_CHAR_AND_NEXT('"');
    }
    
    return YES;
}

// [67]   	Reference	   ::=   	 EntityRef | CharRef
static inline BOOL parseReference(AZXMLParser *parser) {
    if (parser.stop) return YES;

    NSUInteger index = parser.parserIndex;
    parser.parserReportError++;
    if (parseEntityRef(parser)) {
        parser.parserReportError--;
        return YES;
    }
    parser.parserIndex = index;
    
    if (parseCharRef(parser)) {
        parser.parserReportError--;
        return YES;
    }
    parser.parserReportError--;

    reportError(parser, @"Expecting EntityRef or CharRef", AZXMLParserErrorCodeMismatch);
    return NO;
}

// [68]   	EntityRef	   ::=   	'&' Name ';'
static inline BOOL parseEntityRef(AZXMLParser *parser) {
    if (parser.stop) return YES;

    ASSERT_CHAR_AND_NEXT('&');
    ASSERT_TRUE(parseName(parser), @"Expected Name");
    ASSERT_CHAR_AND_NEXT(';');
    
    // Translate predefined entities in XML
    // http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
    NSString *resolvedRef = parser.lastParsedName;
    if ([resolvedRef isEqualToString:@"quot"]) {
        resolvedRef = @"\"";
    } else if ([resolvedRef isEqualToString:@"amp"]) {
        resolvedRef = @"&";
    } else if ([resolvedRef isEqualToString:@"apos"]) {
        resolvedRef = @"'";
    } else if ([resolvedRef isEqualToString:@"lt"]) {
        resolvedRef = @"<";
    } else if ([resolvedRef isEqualToString:@"gt"]) {
        resolvedRef = @">";
    } else {
        NSLog(@"Unknown EntityRef %@", resolvedRef);
//        reportError(parser, @"Unknown EntityRef", AZXMLParserErrorCodeUnsupported);
    }
    emitFoundCharacters(parser, resolvedRef);
    
    return YES;
}

// [66]   	CharRef	   ::=   	'&#' [0-9]+ ';'
//                              | '&#x' [0-9a-fA-F]+ ';'
static inline BOOL parseCharRef(AZXMLParser *parser) {
    if (parser.stop) return YES;

    ASSERT_CHAR_AND_NEXT('&');
    ASSERT_CHAR_AND_NEXT('#');
    unichar c = CHAR_AND_NEXT;
    if (c == 'x') {
        parseOneOrMore(&parseCharRefAlphaNumeric, parser, "[0-9a-fA-F]");
    } else {
        parseOneOrMore(&parseNumeric, parser, "[0-9]");
    }
    ASSERT_CHAR_AND_NEXT(';');
    return YES;
}

/**
[22]   	prolog	   ::=   	 XMLDecl Misc* (doctypedecl Misc*)?
 */
static inline BOOL parseProlog(AZXMLParser *parser) {
    if (parser.stop) return YES;

    ASSERT_TRUE(parseXMLDecl(parser), @"Expected XMLDecl");
    parseZeroOrMore(&parseMisc, parser);
    
    NSUInteger index = parser.parserIndex;
    if (parseDoctypedecl(parser)) {
        parseZeroOrMore(&parseMisc, parser);
    } else {
        parser.parserIndex = index;
    }
    return YES;
}

//     [27]   	Misc	   ::=   	 Comment | PI | S
static inline BOOL parseMisc(AZXMLParser *parser) {
    if (parser.stop) return YES;

    if (parseZeroOrOne(&parseComment, parser) > 0) {
        return YES;
    }

    // Processing Instruction not supported now
    // TODO
//    parserIndex = index;
//    if (parsePI()) {
//        return YES;
//    }

    if (parseZeroOrOne(&parseS, parser) > 0) {
        return YES;
    }

    return NO;
}

// [15]   	Comment	   ::=   	'<!--' ((Char - '-') | ('-' (Char - '-')))* '-->'
static inline BOOL parseComment(AZXMLParser *parser) {
    if (parser.stop) return YES;

    ASSERT_CHAR_AND_NEXT('<');
    ASSERT_CHAR_AND_NEXT('!');
    ASSERT_CHAR_AND_NEXT('-');
    ASSERT_CHAR_AND_NEXT('-');

    // Zero or more time
    while (YES) {
        unichar c = CURRENT_CHAR;
        if (IS_CHAR(c) && c != '-') {
            CHAR_AND_NEXT;
        } else if (c == '-') {
            CHAR_AND_NEXT;
            ASSERT_TRUE(parseCharExcept(parser, '-'), @"Expected Char");
        } else {
            break; // bail out
        }
    }
    
    ASSERT_CHAR_AND_NEXT('-');
    ASSERT_CHAR_AND_NEXT('-');
    ASSERT_CHAR_AND_NEXT('>');

    return YES;
}

// [2]   	Char	   ::=   	[#x1-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
static inline BOOL parseChar(AZXMLParser *parser) {
    unichar c = CHAR_AND_NEXT;
    return (c >= 0x1 && c <= 0xD7FF) || (c >= 0xE000 && c <= 0xFFFD); // || (c >= 0x10000 && c <= 0x10FFFF);
}

static inline BOOL parseCharExcept(AZXMLParser *parser, unichar except) {
    if (parser.stop) return YES;

    if (parseChar(parser)) {
        ASSERT_TRUE(CURRENT_CHAR != '-', @"Char must not be -");
        return YES;
    } else {
        return NO;
    }
}

// [23]   	XMLDecl	   ::=   	'<?xml' VersionInfo EncodingDecl? SDDecl? S? '?>'
static inline BOOL parseXMLDecl(AZXMLParser *parser) {
    if (parser.stop) return YES;

    ASSERT_TRUE(parseCString("<?xml", parser), @"Expected <?xml");
    
    ASSERT_TRUE(parseVersionInfo(parser), @"Expected VersionInfo");

    parseZeroOrOne(&parseEncodingDecl, parser);
    parseZeroOrOne(&parseSDDecl, parser);
    parseZeroOrOne(&parseS, parser);
    
    ASSERT_CHAR_AND_NEXT('?');
    ASSERT_CHAR_AND_NEXT('>');

    return YES;
}

// [80]   	EncodingDecl	   ::=   	 S 'encoding' Eq ('"' EncName '"' | "'" EncName "'" )
// [81]   	EncName	   ::=   	[A-Za-z] ([A-Za-z0-9._] | '-')*	/* Encoding name contains only Latin characters */
static inline BOOL parseEncodingDecl(AZXMLParser *parser) {
    if (parser.stop) return YES;

    ASSERT_TRUE(parseS(parser), @"Expected whitespace");

    ASSERT_TRUE(parseCString("encoding", parser), @"Expected encoding");

    ASSERT_TRUE(parseEq(parser), @"Expected =");

    unichar c = CHAR_AND_NEXT;
    BOOL useSingleQuote = NO;
    if (c == '\'') {
        useSingleQuote = YES;
    } else if (c == '"') {
        useSingleQuote = NO;
    } else {
        reportError(parser, @"Expected ' or \"", AZXMLParserErrorCodeMismatch);
        return NO;
    }

    // Encoding name
    ASSERT_TRUE(parseLettersOnly(parser), @"Expected a letter");

    c = CURRENT_CHAR;
    while (IS_LETTER(c) || IS_NUMBER(c) || c == '.' || c == '_' || c == '-') {
        c = CHAR_AND_NEXT;
    }
    parser.parserIndex--;
    
    //
    
    if (useSingleQuote) {
        ASSERT_CHAR_AND_NEXT('\'');
    } else {
        ASSERT_CHAR_AND_NEXT('"');
    }
    
    return YES;
}

// [A-Za-z]
static inline BOOL parseLettersOnly(AZXMLParser *parser) {
    if (parser.stop) return YES;

    unichar c = CHAR_AND_NEXT;
    return IS_LETTER(c);
}

// [32]   	SDDecl	   ::=   	 S 'standalone' Eq (("'" ('yes' | 'no') "'") | ('"' ('yes' | 'no') '"'))
static inline BOOL parseSDDecl(AZXMLParser *parser) {
    if (parser.stop) return YES;

    ASSERT_TRUE(parseS(parser), @"Expected whitespace");

    ASSERT_TRUE(parseCString("standalone", parser), @"Expected standalone");
    
    ASSERT_TRUE(parseEq(parser), @"Expected =");
    
    unichar c = CHAR_AND_NEXT;
    BOOL useSingleQuote = NO;
    if (c == '\'') {
        useSingleQuote = YES;
    } else if (c == '"') {
        useSingleQuote = NO;
    } else {
        reportError(parser, @"Expected ' or \"", AZXMLParserErrorCodeMismatch);
        return NO;
    }

    c = CURRENT_CHAR;
    if (c == 'y') {
        ASSERT_TRUE(parseCString("yes", parser), @"Expected yes");
    } else if (c == 'n') {
        ASSERT_TRUE(parseCString("no", parser), @"Expected no");
    }

    if (useSingleQuote) {
        ASSERT_CHAR_AND_NEXT('\'');
    } else {
        ASSERT_CHAR_AND_NEXT('"');
    }
    
    return YES;
}

// [24]   	VersionInfo	   ::=   	 S 'version' Eq ("'" VersionNum "'" | '"' VersionNum '"')
// [26]   	VersionNum	   ::=   	'1.1'
static inline BOOL parseVersionInfo(AZXMLParser *parser) {
    if (parser.stop) return YES;

    ASSERT_TRUE(parseS(parser), @"Expected whitespace");
    
    ASSERT_TRUE(parseCString("version", parser), @"Expected version");

    ASSERT_TRUE(parseEq(parser), @"Expected =");
    
    unichar c = CHAR_AND_NEXT;
    BOOL useSingleQuote = NO;
    if (c == '\'') {
        useSingleQuote = YES;
    } else if (c == '"') {
        useSingleQuote = NO;
    } else {
        reportError(parser, @"Expected ' or \"", AZXMLParserErrorCodeMismatch);
        return NO;
    }

    ASSERT_CHAR_AND_NEXT('1');
    ASSERT_CHAR_AND_NEXT('.');
    c = CHAR_AND_NEXT;
    if (c == '0') {
        parser.parserXMLVersion = @"1.0";
    } else if (c == '1') {
        parser.parserXMLVersion = @"1.1";
    } else {
        reportError(parser, [NSString stringWithFormat:@"Invalid version character %c", c], AZXMLParserErrorCodeMismatch);
        return NO;
    }

    if (useSingleQuote) {
        ASSERT_CHAR_AND_NEXT('\'');
    } else {
        ASSERT_CHAR_AND_NEXT('"');
    }
    
    return YES;
}

// [25]   	Eq	   ::=   	 S? '=' S?
static inline BOOL parseEq(AZXMLParser *parser) {
    if (parser.stop) return YES;

    unichar c = CHAR_AND_NEXT;
    if (IS_SPACE(c)) {
        c = CHAR_AND_NEXT;
    }

    ASSERT_CHAR(c, '=');
    
    if (IS_SPACE(c)) {
        CHAR_AND_NEXT;
    }
    
    return YES;
}

// [3]   	S	   ::=   	(#x20 | #x9 | #xD | #xA)+
static inline BOOL parseS(AZXMLParser *parser) {
    if (parser.stop) return YES;

    unichar c = CHAR_AND_NEXT;
    ASSERT_TRUE(IS_SPACE(c), @"Expected a white space");
    
    c = CURRENT_CHAR;
    while (IS_SPACE(c) && !IS_EOS) {
        c = CHAR_AND_NEXT;
        if (!IS_SPACE(c)) {
            parser.parserIndex--;
        }
    }
    
    return YES;
}

// [28]   	doctypedecl	   ::=   	'<!DOCTYPE' S Name (S ExternalID)? S? ('[' intSubset ']' S?)? '>'
BOOL parseDoctypedecl(AZXMLParser *parser) {
    if (parser.stop) return YES;

    ASSERT_TRUE(parseCString("<!DOCTYPE", parser), @"Expected <!DOCTYPE");
    
    ASSERT_TRUE(parseS(parser), @"Expected a white space");

    ASSERT_TRUE(parseName(parser), @"Expected Name");
    
    { // (S ExternalID)?
        NSUInteger index = parser.parserIndex;
        if (parseS(parser) && parseExternalID(parser)) {
            // Good
        } else {
            parser.parserIndex = index;
        }
    }
    
    { // S?
        parseZeroOrOne(&parseS, parser);
    }
    
    { // ('[' intSubset ']' S?)?
        unichar c = CURRENT_CHAR;
        if (c == '[') {
            ASSERT_TRUE(parseIntSubset(parser), @"Expected intSubset");
            ASSERT_CHAR_AND_NEXT(']');
            parseZeroOrOne(&parseS, parser);
        }
    }
    
    ASSERT_CHAR_AND_NEXT('>');

    return YES;
}

// [75]   	ExternalID	   ::=   	'SYSTEM' S SystemLiteral
//                                  | 'PUBLIC' S PubidLiteral S SystemLiteral
BOOL parseExternalID(AZXMLParser *parser) {
    if (parser.stop) return YES;

    unichar c = CURRENT_CHAR;
    if (c == 'S') {
        ASSERT_TRUE(parseCString("SYSTEM", parser), @"Expected SYSTEM");
        ASSERT_TRUE(parseS(parser), @"Expected a white space");
        ASSERT_TRUE(parseSystemLiteral(parser), @"Expected SystemLiteral");
    } else if (c == 'P') {
        ASSERT_TRUE(parseCString("PUBLIC", parser), @"Expected PUBLIC");
        ASSERT_TRUE(parseS(parser), @"Expected a white space");
        ASSERT_TRUE(parsePubidLiteral(parser), @"Expected PubidLiteral");
        ASSERT_TRUE(parseS(parser), @"Expected a white space");
        ASSERT_TRUE(parseSystemLiteral(parser), @"Expected SystemLiteral");
    } else {
        reportError(parser, @"Expected SYSTEM or PUBLIC", AZXMLParserErrorCodeMismatch);
        return NO;
    }
    
    return YES;
}

// [11]   	SystemLiteral	   ::=   	('"' [^"]* '"') | ("'" [^']* "'")
BOOL parseSystemLiteral(AZXMLParser *parser) {
    if (parser.stop) return YES;

    unichar c = CHAR_AND_NEXT;
    BOOL useSingleQuote = NO;
    if (c == '\'') {
        useSingleQuote = YES;
    } else if (c == '"') {
        useSingleQuote = NO;
    } else {
        reportError(parser, @"Expected ' or \"", AZXMLParserErrorCodeMismatch);
        return NO;
    }
    
    //
    while (YES) {
        if (parser.stop) return YES;

        unichar c = CURRENT_CHAR;
        if (useSingleQuote && c == '\'') {
            parser.parserIndex++;
            return YES; // Reached the end of the literal
        }
        
        if (!useSingleQuote && c == '"') {
            parser.parserIndex++;
            return YES; // Reached the end of the literal
        }
        
        NSUInteger index = parser.parserIndex;
        if (parseChar(parser)) {
            continue;
        }
        parser.parserIndex = index;
        break;
    }
    
    //
    
    if (useSingleQuote) {
        ASSERT_CHAR_AND_NEXT('\'');
    } else {
        ASSERT_CHAR_AND_NEXT('"');
    }
    
    return YES;
}

// [12]   	PubidLiteral	   ::=   	'"' PubidChar* '"' | "'" (PubidChar - "'")* "'"
BOOL parsePubidLiteral(AZXMLParser *parser) {
    if (parser.stop) return YES;

    unichar c = CHAR_AND_NEXT;
    BOOL useSingleQuote = NO;
    if (c == '\'') {
        useSingleQuote = YES;
    } else if (c == '"') {
        useSingleQuote = NO;
    } else {
        reportError(parser, @"Expected ' or \"", AZXMLParserErrorCodeMismatch);
        return NO;
    }
    
    //
    while (YES) {
        if (parser.stop) return YES;

        if (useSingleQuote) {
            unichar c = CURRENT_CHAR;
            if (c == '\'') {
                reportError(parser, [NSString stringWithFormat:@"Invalid character %c", c], AZXMLParserErrorCodeMismatch);
                return NO;
            }
            NSUInteger index = parser.parserIndex;
            if (parsePubidChar(parser)) {
                continue;
            }
            parser.parserIndex = index;
            break;
        } else {
            NSUInteger index = parser.parserIndex;
            if (parsePubidChar(parser)) {
                continue;
            }
            parser.parserIndex = index;
            break;
        }
    }
    
    //
    
    if (useSingleQuote) {
        ASSERT_CHAR_AND_NEXT('\'');
    } else {
        ASSERT_CHAR_AND_NEXT('"');
    }
    
    return YES;
}

// [13]   	PubidChar	   ::=   	#x20 | #xD | #xA | [a-zA-Z0-9] | [-'()+,./:=?;!*#@$_%]
BOOL parsePubidChar(AZXMLParser *parser) {
    if (parser.stop) return YES;

    unichar c = CURRENT_CHAR;
    if (isCharPartOfSet(c, "-'()+,./:=?;!*#@$_%")) {
        return YES;
    }
    return c == 0x20 || c == 0xD || c == 0xA || IS_LETTER(c) || IS_NUMBER(c);
}

BOOL parseIntSubset(AZXMLParser *parser) {
    if (parser.stop) return YES;

    reportError(parser, @"IntSubset is not supported yet", AZXMLParserErrorCodeUnsupported);
    // TODO

    return NO;
}

// Name	   ::=   	 NameStartChar (NameChar)*
BOOL parseName(AZXMLParser *parser) {
    if (parser.stop) return YES;

    parser.lastParsedName = nil;
    parser.lastParsedText = [NSMutableString string];
    ASSERT_TRUE(parseNameStartChar(parser), @"Expected NameStartChar");
    parseZeroOrMore(&parseNameChar, parser);
    parser.lastParsedName = parser.lastParsedText;
    return YES;
}

// [4]   	NameStartChar	   ::=   	":" | [A-Z] | "_" | [a-z] | [#xC0-#xD6] | [#xD8-#xF6] | [#xF8-#x2FF] | [#x370-#x37D] | [#x37F-#x1FFF] | [#x200C-#x200D] | [#x2070-#x218F] | [#x2C00-#x2FEF] | [#x3001-#xD7FF] | [#xF900-#xFDCF] | [#xFDF0-#xFFFD] | [#x10000-#xEFFFF]
BOOL parseNameStartChar(AZXMLParser *parser) {
    if (parser.stop) return YES;

    unichar c = CHAR_AND_NEXT;
    if (c == ':' || c == '_' || IS_LETTER(c) || (c >= 0xC0 && c <= 0xD6) || (c >= 0xD8 && c <= 0xF6) ||
    (c >= 0xF8 && c <= 0x2FF) || (c >= 0x370 && c <= 0x37D) || (c >= 0x37F && c <= 0x1FFF) || (c >= 0x200C && c <= 0x200D) ||
    (c >= 0x2070 && c <= 0x218F) || (c >= 0x2C00 && c <= 0x2FEF) || (c >= 0x3001 && c <= 0xD7FF) || (c >= 0xF900 && c <= 0xFDCF) ||
    (c >= 0xFDF0 && c <= 0xFFFD)) // Outside of unichar range || (c >= 0x10000 && c <= 0xEFFFF);
    {
        [parser.lastParsedText  appendFormat:@"%c", c];
        return YES;
    } else {
        return NO;
    }
}

// NameChar	   ::=   	 NameStartChar | "-" | "." | [0-9] | #xB7 | [#x0300-#x036F] | [#x203F-#x2040]
BOOL parseNameChar(AZXMLParser *parser) {
    if (parser.stop) return YES;

    NSUInteger index = parser.parserIndex;
    if (parseNameStartChar(parser)) {
        return YES;
    } else {
        parser.parserIndex = index;
        unichar c = CHAR_AND_NEXT;
        if (c == '-' || c == '.' || IS_NUMBER(c) || c == 0xB7 || (c >= 0x0300 && c <= 0x036F) || (c >= 0x203F && c <= 0x2040)) {
            [parser.lastParsedText  appendFormat:@"%c", c];
            return YES;
        } else {
            return NO;
        }
    }
}

@end
