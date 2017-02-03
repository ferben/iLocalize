//
//  StringsEngine.m
//  iLocalize3
//
//  Created by Jean on 21.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "StringsEngine.h"
#import "XMLStringsEngine.h"

#import "StringTool.h"
#import "StringEncodingTool.h"
#import "StringEncoding.h"

#import "StringModel.h"
#import "StringsContentModel.h"

#import "Constants.h"
#import "Console.h"

#import "Preferences.h"

#define C(x)    [self currentCharacterWithOffset:x]
#define S(x)    [NSString stringWithFormat:@"%C", C(x)]

#define NO_TYPE -1

@interface StringsEngine (PrivateMethods)
- (BOOL)nextCharacter;
- (unichar)currentCharacterWithOffset:(int)offset;

- (BOOL)isLetter;
- (BOOL)isLetterOrDigit;
- (BOOL)isPartOfIdentifier;
- (BOOL)isEndOfLine;
@end

@interface StringsEngine (Parsing)
- (BOOL)parseOldStyleNSArray;
- (StringsContentModel*)parse;
@end

@interface StringsEngine (Encoding)
- (NSString*)encode:(StringsContentModel*)strings base:(StringsContentModel*)baseStrings format:(NSUInteger)format encoding:(StringEncoding*)encoding;
@end

@implementation StringsEngine

- (id)initWithConsole:(Console*)console
{
    if(self = [super init]) {
        mText = NULL;
        mModelClass = [StringModel class];
        mConsole = console;
        self.eolType = NO_TYPE;
        self.format = STRINGS_FORMAT_APPLE_STRINGS;
    }
    return self;    
}


+ (StringsEngine*)engineWithConsole:(Console*)console
{
    return [[StringsEngine alloc] initWithConsole:console];
}

- (void)setModelClass:(Class)modelClass
{
    mModelClass = modelClass;
}

- (void)setText:(NSString*)text
{
    mText = text;
}

- (StringsContentModel*)parseStringModelsOfStringsFile:(NSString*)file
{
    return [self parseStringModelsOfStringsFile:file encodingUsed:nil defaultEncoding:[[Preferences shared] defaultEncoding]];
}

- (StringsContentModel*)parseStringModelsOfStringsFile:(NSString*)file encodingUsed:(StringEncoding**)encoding defaultEncoding:(StringEncoding*)defaultEncoding
{
    NSString *text = [StringEncodingTool stringWithContentOfFile:file encodingUsed:encoding defaultEncoding:defaultEncoding];
    if(text == nil) {
        text = [NSString stringWithContentsOfFile:file usedEncoding:nil error:nil];        
    }
        
    self.content = [self parseStringModelsOfText:text];
    return self.content;
}

- (StringsContentModel*)parseStringModelsOfStringsFile:(NSString*)file encoding:(StringEncoding*)encoding
{
    NSString *text = [StringEncodingTool stringWithContentOfFile:file encoding:encoding];
    if(text == nil) {
        text = [NSString stringWithContentsOfFile:file usedEncoding:nil error:nil];        
    }    
    self.content = [self parseStringModelsOfText:text];
    return self.content;
}

- (StringsContentModel*)parseStringModelsOfText:(NSString*)text
{
    return [self parseStringModelsOfText:text usingModel:mModelClass];
}

- (StringsContentModel*)parseStringModelsOfText:(NSString*)text usingModel:(Class)modelClass
{
    if([XMLStringsEngine canHandleContent:text]) {
        XMLStringsEngine *engine = [[XMLStringsEngine alloc] init];        
        self.content = [engine parseText:text modelClass:mModelClass];
        [self setFormat:[engine format]];
    } else {
        [self setFormat:STRINGS_FORMAT_APPLE_STRINGS];
        [self setModelClass:modelClass];
        [self setText:text];
        self.content = [self parse];
    }
    return self.content;
}

- (NSString*)encodeStringModels:(StringsContentModel*)strings baseStringModels:(StringsContentModel*)baseStrings skipEmpty:(BOOL)skipEmpty format:(NSUInteger)_format encoding:(StringEncoding*)encoding
{
    mSkipEmptyValue = skipEmpty;
    return [self encode:strings base:baseStrings format:_format encoding:encoding];
}

- (BOOL)nextCharacter
{
    position++;
    column++;
    if([self isEndOfLine]) {
        column = 0;
        row++;
    }
    return position<[mText length];
}

- (unichar)currentCharacterWithOffset:(int)offset
{
    int pos = position+offset;
    if(pos<0)
        return 0;
    else if(pos>=[mText length])
        return 0;
    else 
        return [mText characterAtIndex:pos];
}

- (BOOL)isLetter
{
    return [[NSCharacterSet letterCharacterSet] characterIsMember:C(0)];
}

- (BOOL)isLetterOrDigit
{
    return [[NSCharacterSet alphanumericCharacterSet] characterIsMember:C(0)];
}

- (BOOL)isPartOfIdentifier
{
    return C(0) == '_' || C(0) == '.' || C(0) == '-' || [self isLetterOrDigit] || C(0) == '/';
}

- (BOOL)isEndOfLine
{
    if(C(0) == CR && C(1) == LF) {
        // Windows end of line
        if(self.eolType == NO_TYPE)
            self.eolType = WINDOWS_LINE_ENDINGS;
        return YES;
    } else if(C(0) == LF && C(-1) != CR) {
        // Unix end of line
        if(self.eolType == NO_TYPE)
            self.eolType = UNIX_LINE_ENDINGS;
        return YES;
    } else if(C(0) == CR) {
        // Macintosh end of line
        if(self.eolType == NO_TYPE)
            self.eolType = MAC_LINE_ENDINGS;
        return YES;
    } else 
        return NO;
}

@end

@implementation StringsEngine (Parsing)
                
- (StringModel*)newStringModelInstance
{
    return [[mModelClass alloc] init];
}

- (StringModel*)currentStringModel
{
    if(mCurrentStringModel == NULL)
        mCurrentStringModel = [self newStringModelInstance];
    return mCurrentStringModel;
}

- (void)addAndCreateNextStringModel
{
    if(mCurrentStringModel) {
        [mStringModels addStringModel:mCurrentStringModel];
    }
    
    mCurrentStringModel = [self newStringModelInstance];
}

- (void)setSingleComment:(NSString*)comment atRow:(unsigned)r
{
    if(comment == NULL)
        return;
    
    [[self currentStringModel] addComment:comment as:COMMENT_SIMPLE atRow:r];
}

- (void)setComplexComment:(NSString*)comment atRow:(unsigned)r
{
    if(comment == NULL)
        return;
    
    [[self currentStringModel] addComment:comment as:COMMENT_COMPLEX atRow:r];
}

- (NSString*)parseSimpleComment
{
    [self nextCharacter];    // Skip the second { / }
    
    NSMutableString *s = [NSMutableString string];
    while([self nextCharacter]) {
        if([self isEndOfLine])
            break;
        [s appendString:S(0)];
    }
    return s;
}

- (NSString*)parseComplexComment
{
    [self nextCharacter];    // Skip { * }
    
    NSMutableString *s = [NSMutableString string];    
    BOOL escaped = NO;
    while([self nextCharacter]) {
        if(C(0) == '*' && C(1) == '/' && !escaped) {
            // End of the complex comment
            [self nextCharacter];
            break;
        }
        [s appendString:S(0)];
        
        if(escaped)
            escaped = NO;
        else if(C(0) == '\\')
            escaped = YES;        
    }
    return s;
}

- (NSString*)parseQuotedString
{
    NSMutableString *s = [NSMutableString string];    
    BOOL escaped = NO;
    while([self nextCharacter]) {
        if(C(0) == '"' && !escaped) {
            // End of quoted string
            [self nextCharacter];
            break;
        }        
        
        if(escaped) {
            escaped = NO;        
        } else if(C(0) == '\\') {
            escaped = YES;            
        }
        [s appendString:S(0)];
    }
    return [StringTool unescapeDoubleQuoteInString:s];
}

- (NSString*)parseIdentifierString
{        
    NSMutableString *s = [NSMutableString string];    
    [s appendString:S(0)];
    while([self nextCharacter]) {
        if(![self isPartOfIdentifier]) {
            // End of identifier
            break;
        }
        [s appendString:S(0)];
    }
    return s;
}

// NSData: <0fbd777 1c2735ae>
- (BOOL)parseOldStyleNSData
{
    if(C(0) != '<') return NO;
    
    while([self nextCharacter]) {
        if(C(0) == '>') {
            [self nextCharacter];
            return YES;            
        }
    }
    return NO;
}

// NSString: "This is a string" or StringIsAStringWithoutSpace
- (BOOL)parseOldStyleNSString
{
    if(C(0) == '"') {
        [self parseQuotedString];
        return YES;
    } else if([self isLetter]) {
        [self parseIdentifierString];
        return YES;
    } else {
        return NO;
    }
}

// NSDictionary: { user = wshakesp; birth = 1564; death = 1616; }
- (BOOL)parseOldStyleNSDictionary
{
    if(C(0) != '{') return NO;
    
    while(YES) {
        // end of dictionary
        if(C(0) == '}') {
            [self nextCharacter];
            return YES;            
        }
        
        if(![self nextCharacter]) break;
        
        if([self parseOldStyleNSDictionary]) continue;
        if([self parseOldStyleNSArray]) continue;
        if([self parseOldStyleNSString]) continue;
        if([self parseOldStyleNSData]) continue;
    }
    
    return NO;
}

// NSArray: ("San Francisco", "New York", "Seoul", "London", "Seattle", "Shanghai")
- (BOOL)parseOldStyleNSArray
{
    if(C(0) != '(') return NO;
    
    while(YES) {
        // end of array
        if(C(0) == ')') {
            [self nextCharacter];
            return YES;            
        }

        if(![self nextCharacter]) break;

        if([self parseOldStyleNSDictionary]) continue;
        if([self parseOldStyleNSArray]) continue;
        if([self parseOldStyleNSString]) continue;
        if([self parseOldStyleNSData]) continue;        
    }
    
    return NO;
}

// Parse an old-style string as defined here: http://developer.apple.com/documentation/Cocoa/Conceptual/PropertyLists/Articles/OldStylePListsConcept.html#/
// Should begin with { or (
- (NSString*)parseOldStyleString
{        
    int beginPos = position;
    if([self parseOldStyleNSDictionary]) goto ok;
    if([self parseOldStyleNSArray]) goto ok;
    
ok:
    return [mText substringWithRange:NSMakeRange(beginPos, position-beginPos)];
}

- (void)parseStrings
{        
    int r = row;    // start of the key/value row
    
    if(C(0) == '"')
        [[self currentStringModel] setKey:[self parseQuotedString] as:STRING_QUOTED atRow:r-lastRow];
    else if([self isLetter])
        [[self currentStringModel] setKey:[self parseIdentifierString] as:STRING_IDENTIFIER atRow:r-lastRow];
        
    BOOL equalFound = NO;
    if(C(0) == '=') {
        equalFound = YES;
    } else {
        /** Ignore also comments that can be placed before the '=' */
        while([self nextCharacter]) {
            if(C(0) == '=') {
                equalFound = YES;
                break;
            } else if(C(0) == '/' && C(1) == '/') {
                [self parseSimpleComment];
            } else if(C(0) == '/' && C(1) == '*') {
                [self parseComplexComment];
            }
        }        
    }
    
    if(!equalFound) {
        [mConsole addError:[NSString stringWithFormat:@"Unexpected end of text"]
               description:[NSString stringWithFormat:@"Unexpected end of text (expected '=' at row %d and column %d for key \"%@\")", row, column, [[self currentStringModel] key]]
                     class:[self class]];
        return;
    }
    
    /** Ignore also comments that can be placed before the value string */
    while([self nextCharacter]) {
        if(C(0) == '"') {
            [[self currentStringModel] setValue:[self parseQuotedString] as:STRING_QUOTED atRow:r-lastRow];
            break;
        } else if([self isLetter]) {
            [[self currentStringModel] setValue:[self parseIdentifierString] as:STRING_IDENTIFIER atRow:r-lastRow];
            break;
        } else if(C(0) == '(' || C(0) == '{') {
            [[self currentStringModel] setValue:[self parseOldStyleString] as:STRING_OLDSTYLE atRow:r-lastRow];
            break;
        } else if(C(0) == '/' && C(1) == '/') {
            [self parseSimpleComment];
        } else if(C(0) == '/' && C(1) == '*') {
            [self parseComplexComment];
        }
    }
    
    [self addAndCreateNextStringModel];
    
    lastRow = r;
}

- (void)parseFile
{
    while([self nextCharacter]) {
        if(C(0) == '"')
            [self parseStrings];
        else if([self isLetter])
            [self parseStrings];
        else if(C(0) == '/' && C(1) == '/') {
            int r = row;
            [self setSingleComment:[self parseSimpleComment] atRow:r-lastRow];
            lastRow = r;
        } else if(C(0) == '/' && C(1) == '*') {
            int r = row;
            [self setComplexComment:[self parseComplexComment] atRow:r-lastRow];            
            lastRow = r;
        }
    }
}

- (StringsContentModel*)parse
{
    position = -1;
    row = 0;
    column = -1;
    lastRow = 0;
    self.eolType = NO_TYPE;
    
    mCurrentStringModel = NULL;
    mStringModels = [StringsContentModel model];
    if([mText length])
        [self parseFile];
    return mStringModels;
}

@end

@implementation StringsEngine (Encoding)

- (NSString*)eol
{
    switch(self.eolType) {
        case WINDOWS_LINE_ENDINGS: return WINDOWS_EOL;
        case UNIX_LINE_ENDINGS: return UNIX_EOL;
        case MAC_LINE_ENDINGS: return MAC_EOL;
    }
    return UNIX_EOL;
}

- (void)appendString:(NSString*)s
{
    mCurrentLine += [StringTool numberOfNewLineInString:s];
    [mEncodedString appendString:s];
}

- (unichar)lastCharacter
{
    if(mEncodedString == nil || [mEncodedString length] == 0)
        return 0;
    else
        return [mEncodedString characterAtIndex:[mEncodedString length]-1];
}

- (BOOL)isSingleLineComment:(NSString*)comment
{
    int index;
    for(index = 0; index < [comment length]; index++) {
        unichar c = [comment characterAtIndex:index];
        if(c == '\r' || c == '\n') return NO;
    }
    return YES;
}

- (void)encodeComment:(StringModel*)model
{
    if([[model comment] length] == 0)
        return;

    [model enumerateComments:^(NSString *comment, unsigned int ctype, int crow) {
           if((mCurrentLine-mLastLine)<crow) {
            while((mCurrentLine-mLastLine)<crow) {
                [self appendString:[self eol]];
            }
        } else {
            // Make sure to add some white space if the last character is not a white space:
            // this can happen when a comment is in the same line as a key=value pair.
            unichar c = [self lastCharacter];
            if(c != ' ' && c != '\r' && c != '\n' && c != '\t' && c != 0)
                [self appendString:@"   "];
        }
        
        if(ctype == COMMENT_SIMPLE) {
            // Double-check to see if the comment is really in one line. It happens that if there are duplicate keys,
            // a single comment might get assigned a multi-line comment: the result is that the multi-line comment
            // will be written using a single line comment and the file will be non-readable.
            if([self isSingleLineComment:comment]) {
                [self appendString:@"//"];
                [self appendString:comment];
            } else {
                // Change the type of comment
                [model setCommentType:COMMENT_COMPLEX];
                
                // And it will rewritten in complex layout by the following lines
            }
        } 
        
        if(ctype == COMMENT_COMPLEX) {
            [self appendString:@"/*"];        
            [self appendString:comment];
            [self appendString:@"*/"];        
        }
        
        mLastLine = mCurrentLine; 
    }];
}

- (void)appendString:(NSString*)s type:(int)type
{
    // First check to see if the string can still be in the requested format.
    // i.e. { this is a string } has to be represented as a quoted string "this is a string"
    // and not in the format STRING_IDENTIFIER.
    
    if(type == STRING_OLDSTYLE) {
        // do not change the content of this old-style format
        [self appendString:s];
        return;
    }
    
    if(type != STRING_QUOTED && [[s componentsSeparatedByString:@" "] count]>1)
        type = STRING_QUOTED;
    
    // Escape the string
    s = [StringTool escapeDoubleQuoteInString:s];
    
    if(type == STRING_QUOTED) {
        [self appendString:@"\""];        
        [self appendString:s];
        [self appendString:@"\""];        
    } else {
        [self appendString:s];
    }
}

- (void)encodeKeyValue:(StringModel*)model baseValue:(StringModel*)baseModel
{
    // Note: Skip empty value depending on the mSkipEmptyValue flag.
    // When writing a strings file to translate a nib file, it is important to skip empty value, otherwise
    // the nib file cannot be translated anymore (bug in nibtool?) - one workaround is to rebuild the nib from the base language.
    if(mSkipEmptyValue && [[model value] length] == 0)
        return;
    
    while((mCurrentLine-mLastLine)<[model keyRow]) {
        [self appendString:[self eol]];
    }
    
    NSString *value = [[model value] length]?[model value]:[baseModel value];
    
    [self appendString:[model key] type:[model keyType]];
    [self appendString:@" = "];
    [self appendString:value type:[model valueType]];
    [self appendString:@";"];
    
    mLastLine = mCurrentLine;
}

- (NSString*)encode:(StringsContentModel*)strings base:(StringsContentModel*)baseStrings format:(NSUInteger)_format encoding:(StringEncoding*)encoding
{
    mEncodedString = [NSMutableString string];
    mCurrentLine = 0;
    mLastLine = 0;

    NSString *ianaName = (NSString*)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(encoding.encoding));

    switch(_format) {
        case STRINGS_FORMAT_APPLE_XML:
            [mEncodedString appendFormat:@"<?xml version=\"1.0\" encoding=\"%@\"?>\n", ianaName];
            [mEncodedString appendString:@"<!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"];                        
            [mEncodedString appendString:@"<plist version=\"1.0\">\n"];                        
            [mEncodedString appendString:@"<dict>\n"];                        
            break;
        case STRINGS_FORMAT_ABVENT_XML:
            [mEncodedString appendFormat:@"<?xml version=\"1.0\" encoding=\"%@\"?>\n", ianaName];
            [mEncodedString appendString:@"<AbventLocalizableStrings>\n"];                        
            break;
    }
    
    unsigned index;
    for(index = 0; index<[strings numberOfStrings]; index++) {
        StringModel *baseModel = [baseStrings stringModelAtIndex:index];
        StringModel *model = [strings stringModelAtIndex:index];
        switch(_format) {
            case STRINGS_FORMAT_APPLE_STRINGS:
                [self encodeComment:model];
                [self encodeKeyValue:model baseValue:baseModel];        
                break;
            case STRINGS_FORMAT_APPLE_XML:
                [mEncodedString appendFormat:@"    <key>%@</key>\n", [model key]];
                [mEncodedString appendFormat:@"    <string>%@</string>\n", [[model value] length]?[model value]:[baseModel value]];
                break;
            case STRINGS_FORMAT_ABVENT_XML:
                [mEncodedString appendString:@"    <LocalizableString>\n"];                        
                [mEncodedString appendFormat:@"        <ID>%@</ID>\n", [model key]];
                [mEncodedString appendFormat:@"        <text>%@</text>\n", [[model value] length]?[model value]:[baseModel value]];
                [mEncodedString appendString:@"    </LocalizableString>\n"];                        
                break;
        }
    }

    switch(_format) {
        case STRINGS_FORMAT_APPLE_XML:
            [mEncodedString appendString:@"</dict>\n"];                        
            [mEncodedString appendString:@"</plist>\n"];                        
            break;
        case STRINGS_FORMAT_ABVENT_XML:
            [mEncodedString appendString:@"</AbventLocalizableStrings>\n"];                        
            break;
    }
    
    return mEncodedString;
}

@end
