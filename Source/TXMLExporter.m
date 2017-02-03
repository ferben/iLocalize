//
//  TXMLExporter.m
//  iLocalize
//
//  Created by Jean Bovet on 4/19/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "TXMLExporter.h"
#import "StringTool.h"

@implementation TXMLExporter

/*
 Sample format

 <?xml version="1.0" encoding="UTF-8"?>
 <txml locale="en" targetlocale="fr" version="1.0" createdby="iLocalize 4" datatype="regexp">

 <skeleton>/Users/bovet/Test.app/Contents/Resources/English.lproj/Localizable.strings</skeleton>
 <translatable blockId="1">
 <segment segmentId="1">
 <source>Main Window</source>
 <target score="100">Fenetre &quot;principale&quot;</target>
 </segment>
 </translatable>
 
   <translatable blockId="3" satt_key="button.tooltip">
    <segment segmentId="1">
      <source>Button to choose<ut type="unknown" x="1">\n</ut>the file<ut type="unknown" x="2">\n</ut>and more</source>
 
      <comments>
            <comment creationid="vsimecek" creationdate="20130220T090351Z" type="text">test</comment>
      </comments>

    </segment>
  </translatable>


*/

+ (NSString*)writableExtension
{
    return @"txml";
}

- (id)init
{
    self = [super init];
    if (self) {
        dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"%Y%m%dT%H%M%SZ" allowNaturalLanguage:NO];        
    }
    return self;
}


- (void)buildHeader
{
    [self.content appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
    [self.content appendFormat:@"<txml segtype=\"sentence\" locale=\"%@\" targetlocale=\"%@\" version=\"1.0\" createdby=\"iLocalize 4\" datatype=\"regexp\" md5Checksum=\"1f316933c82a30caf58fb5730be47787\">\n",
     self.sourceLanguage, self.targetLanguage];
}

- (void)buildFooter
{
    [self.content appendString:@"</txml>\n"];
}

- (void)buildFileHeader:(id<FileControllerProtocol>)fc
{
    if([fc relativeFilePath]) {
        [self.content appendFormat:@"  <skeleton>%@</skeleton>\n", [fc relativeFilePath]];        
    }
}

- (void)buildFileFooter:(id<FileControllerProtocol>)fc
{
    // nothing to do
}

+ (NSString*)escapedString:(NSString*)s {
    NSMutableString *ms = [NSMutableString stringWithCapacity:[s length]];
    
    unsigned templateIndex = 0;
    NSString *template = @"<ut type=\"unknown\" x=\"%d\">%@</ut>";
    
    unsigned index;
    for(index=0; index<[s length]; index++) {
        unichar c0 = [s characterAtIndex:index];
        unichar c1 = 0;
        if(index+1<[s length])
            c1 = [s characterAtIndex:index+1];
        
        NSString *s0 = nil;
        if(index+2<[s length])
            s0 = [s substringWithRange:NSMakeRange(index, 2)];
        
        NSString *s1 = nil;
        if(index+4<[s length])
            s1 = [s substringWithRange:NSMakeRange(index+2, 2)];
        
        NSString *templateValue = nil;
        if(c0 == CR && c1 == LF) {
            // Windows
            index++;
            templateValue = @"\\r\\n";
        } else if([s0 isEqualToString:@"\\r"] && [s1 isEqualToString:@"\\n"]) {
            // Windows (visible)
            index+=3;
            templateValue = @"\\r\\n";
        } else if(c0 == LF) {
            // Unix
            templateValue = @"\\n";
        } else if([s0 isEqualToString:@"\\n"]) {
            // Unix (visible)
            index++;
            templateValue = @"\\n";
        } else if(c0 == CR) {
            // Mac
            templateValue = @"\\r";
        } else if([s0 isEqualToString:@"\\r"]) {
            // Mac (visible)
            index++;
            templateValue = @"\\r";
        } else {
            [ms appendString:[s substringWithRange:NSMakeRange(index, 1)]];
        }
        
        if (templateValue) {
            // replace the line break with its template
            [ms appendFormat:template, templateIndex++, templateValue];
        }
    }

    return ms;
}

- (void)buildStringWithString:(id<StringControllerProtocol>)sc index:(NSUInteger)index globalIndex:(NSUInteger)globalIndex file:(id<FileControllerProtocol>)fc
{
    int score;
    if([sc.base isEqual:sc.translation] || [sc.translation length] == 0) {
        score = 0;
    } else {
        score = 100;
    }

    NSString *escapedKey = [StringTool escapeDoubleQuoteInString:sc.key];
    NSString *creationid = @"ilocalize";
    NSString *creationdate = [dateFormatter stringForObjectValue:[NSDate date]];

    [self.content appendFormat:@"  <translatable blockId=\"%lu\" satt_key=\"%@\">\n", globalIndex+1, escapedKey];
    [self.content appendString:@"    <segment segmentId=\"1\">\n"];
    [self.content appendFormat:@"      <source>%@</source>\n", [TXMLExporter escapedString:[sc.base xmlEscaped]]];
    [self.content appendFormat:@"      <target score=\"%d\">%@</target>\n", score, [TXMLExporter escapedString:[sc.translation xmlEscaped]]];
    if ([sc.baseComment length] > 0 || [sc.translationComment length] > 0) {
        [self.content appendFormat:@"      <comments>\n"];
        if ([sc.baseComment length] > 0) {
            [self.content appendFormat:@"        <comment creationid=\"%@\" creationdate=\"%@\" type=\"text\">%@</comment>\n", creationid, creationdate, [TXMLExporter escapedString:[sc.baseComment xmlEscaped]]];
        }
        if ([sc.translationComment length] > 0 && ![sc.translationComment isEqualToString:sc.baseComment?:@""]) {
            [self.content appendFormat:@"        <comment creationid=\"%@\" creationdate=\"%@\" type=\"text\">%@</comment>\n", creationid, creationdate, [TXMLExporter escapedString:[sc.translationComment xmlEscaped]]];
        }
        [self.content appendFormat:@"      </comments>\n"];
    }
    [self.content appendString:@"    </segment>\n"];
    [self.content appendString:@"  </translatable>\n"];
}

@end
