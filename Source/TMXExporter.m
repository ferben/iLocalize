//
//  TMXExporter.m
//  iLocalize
//
//  Created by Jean Bovet on 4/19/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "TMXExporter.h"


@implementation TMXExporter

/*
 <header creationtool="AppleTrans" creationtoolversion="32" datatype="unknown" segtype="sentence" adminlang="en" srclang="en" o-tmf="AlairCorpus">
 </header>
 
 <tu creationdate="20070212T144515Z" creationid="123456">
 <tuv xml:lang="EN-US">
 <seg>Free calls to phones, on us.</seg>
 </tuv>
 <tuv xml:lang="ES-EM">
 <seg>Llamadas gratuitas a teléfonos, cortesía nuestra.</seg>
 </tuv>
 </tu> 
 */

+ (NSString*)writableExtension
{
    return @"tmx";
}

/**
 Returns a normalized language to TMX language. TMX format is IT-IT while
 iLocalize expect IT_IT.
 */
- (NSString*)normalizedLanguageToTMXFormat:(NSString*)lang {
    if ([lang rangeOfString:@"_"].location != NSNotFound) {
        return [lang stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
    } else {
        return lang;
    }
}


- (void)buildHeader
{
    [self.content appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
    [self.content appendString:@"<tmx version=\"1.4\" xml:space=\"preserve\">\n"];
    [self.content appendFormat:@"  <header creationtool=\"iLocalize\" creationtoolversion=\"4\" segtype=\"sentence\" o-tmf=\"il_glossary\" adminlang=\"%@\" srclang=\"%@\" datatype=\"plaintext\">\n", 
     [self normalizedLanguageToTMXFormat:self.sourceLanguage], [self normalizedLanguageToTMXFormat:self.sourceLanguage]];
    // Specify target language is custom property because if there is no entry, the TMX file has no target language and
    // we need that for the glossary.
    [self.content appendFormat:@"    <prop type=\"x-target\">%@</prop>\n", [self normalizedLanguageToTMXFormat:self.targetLanguage]];
    [self.content appendString:@"  </header>\n"];
    [self.content appendString:@"  <body>\n"];
}

- (void)buildFooter
{
    [self.content appendString:@"  </body>\n"];
    [self.content appendString:@"</tmx>\n"];
}

- (void)buildFileHeader:(id<FileControllerProtocol>)fc
{

    // there is no nothing of file segment in TMX
}

- (void)buildFileFooter:(id<FileControllerProtocol>)fc
{
    // there is no nothing of file segment in TMX
}

- (void)buildStringWithString:(id<StringControllerProtocol>)sc index:(NSUInteger)index globalIndex:(NSUInteger)globalIndex file:(id<FileControllerProtocol>)fc
{
    // header    
    [self.content appendString:@"    <tu>\n"];
    if([fc relativeFilePath]) {
        [self.content appendFormat:@"      <prop type=\"file\">%@</prop>\n", [fc relativeFilePath]];        
    }
    
    // source language
    [self.content appendFormat:@"      <tuv xml:lang=\"%@\">\n", [self normalizedLanguageToTMXFormat:self.sourceLanguage]];
    if (sc.baseComment.length > 0) {
        [self.content appendFormat:@"        <note>%@</note>\n", [sc.baseComment xmlEscaped]];
    }
    [self.content appendFormat:@"        <seg>%@</seg>\n", [sc.base xmlEscaped]];
    [self.content appendString:@"      </tuv>\n"];
    
    // target language    
    [self.content appendFormat:@"      <tuv xml:lang=\"%@\">\n", [self normalizedLanguageToTMXFormat:self.targetLanguage]];
    if (sc.translationComment.length > 0) {
        [self.content appendFormat:@"        <note>%@</note>\n", [sc.translationComment xmlEscaped]];
    }
    [self.content appendFormat:@"        <seg>%@</seg>\n", [sc.translation xmlEscaped]];
    [self.content appendString:@"      </tuv>\n"];

    // footer
    [self.content appendString:@"    </tu>\n"];                
}

@end
