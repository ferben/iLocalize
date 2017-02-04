//
//  AZXMLParser+Internal.h
//  iLocalize
//
//  Created by Jean Bovet on 11/28/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import "AZXMLParser.h"

@interface AZXMLParser ()
{
}

@property (nonatomic, readonly) unichar currentCharacter;

// Exposed for unit tests only

extern BOOL parseCharRefAlphaNumeric(AZXMLParser *parser);

extern BOOL parseCharData(AZXMLParser *parser);

extern BOOL parseAttValue(AZXMLParser *parser);
extern BOOL parseDoctypedecl(AZXMLParser *parser);
extern BOOL parseName(AZXMLParser *parser);
extern BOOL parseNameStartChar(AZXMLParser *parser);
extern BOOL parseNameChar(AZXMLParser *parser);

@end
