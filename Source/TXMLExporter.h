//
//  TXMLExporter.h
//  iLocalize
//
//  Created by Jean Bovet on 4/19/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XMLExporter.h"

@interface TXMLExporter : XMLExporter {
    NSDateFormatter *dateFormatter;
}

/**
 Returns a string that is escaped for the TXML specification. In other words:
 - all newline characters must be escaped with <ut type="unknown" x="1">\n</ut>
 */
+ (NSString*)escapedString:(NSString*)s;

@end
