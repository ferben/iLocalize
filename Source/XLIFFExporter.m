//
//  XLIFFExporter.m
//  iLocalize
//
//  Created by Jean Bovet on 4/19/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XLIFFExporter.h"

@implementation XLIFFExporter

+ (NSString*)writableExtension
{
    return @"xlf";
}

- (void)buildHeader
{
    [self.content appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
    [self.content appendString:@"<xliff version=\"1.2\" xml:space=\"preserve\">\n"];
}

- (void)buildFooter
{
    [self.content appendString:@"</xliff>\n"];    
}

- (void)buildFileHeader:(id<FileControllerProtocol>)fc
{
    [self.content appendFormat:@"  <file original=\"%@\" source-language=\"%@\" target-language=\"%@\" datatype=\"x-ilocalize\" path=\"%@\">\n", [fc filename]?:@"", self.sourceLanguage,
     self.targetLanguage, [fc relativeFilePath]];
    [self.content appendString:@"    <body>\n"];    
}

- (void)buildFileFooter:(id<FileControllerProtocol>)fc
{
    [self.content appendString:@"    </body>\n"];
    [self.content appendString:@"  </file>\n"];        
}

- (void)buildStringWithString:(id<StringControllerProtocol>)sc index:(NSUInteger)index globalIndex:(NSUInteger)globalIndex file:(id<FileControllerProtocol>)fc
{
    [self.content appendFormat:@"      <trans-unit id=\"%ld\" resname=\"%@\">\n", index, [sc.key xmlEscaped]];
    [self.content appendFormat:@"        <source>%@</source>\n", [sc.base xmlEscaped]];
    [self.content appendFormat:@"        <target>%@</target>\n", [sc.translation xmlEscaped]];
    if (sc.baseComment.length > 0) {
        [self.content appendFormat:@"        <note>%@</note>\n", [sc.baseComment xmlEscaped]];        
    }
    [self.content appendString:@"      </trans-unit>\n"];
}

@end
