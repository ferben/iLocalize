//
//  TMXImporter.m
//  iLocalize
//
//  Created by Jean Bovet on 4/20/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "TMXImporter.h"
#import "XMLImporterParser.h"

@implementation TMXImporter

/** Sample file:
 <header creationtool="AppleTrans" creationtoolversion="32" datatype="unknown" segtype="sentence" adminlang="en" srclang="en" o-tmf="AlairCorpus">
 </header>
 <body>
 <tu>
 <prop type="file">/Contents/Resources/fr.lproj/ImportFilesMultiMatch.nib</prop>
 <tuv xml:lang="en"><seg>Shortcut</seg></tuv>
 <tuv xml:lang="de"><seg>Kurzbefehl</seg></tuv>
 </tu>
 <tu>
 <prop type="file">/Contents/Resources/fr.lproj/Localizable.strings</prop>
 <tuv xml:lang="en"><seg>Go to</seg></tuv>
 <tuv xml:lang="de"><seg>Gehe zu</seg></tuv>
 </tu>
 
 More:
 
 <tu creationdate="20060918T163240Z" creationid="HNAKAHASHI">
 <tuv xml:lang="EN-US">
 <seg>Click on <bpt i="1" type="font">{\f214 </bpt>‘<ept i="1">}</ept>Buy Now<bpt i="2" type="font">{\f214 </bpt>’<ept i="2">}</ept> button whenever you would like to buy Skype Credit</seg>
 </tuv>
 <tuv xml:lang="ES-EM">
 <seg><bpt i="1" type="font">{\f2 </bpt>Cada vez que quieras comprar crédito de Skype, haz clic en el botón <ept i="1">}</ept><bpt i="2" type="font">{\f214 </bpt>‘<ept i="2">}</ept><bpt i="3" type="font">{\f2 </bpt>Comprar ahora<ept i="3">}</ept><bpt i="4" type="font">{\f214 </bpt>’<ept i="4">}</ept><bpt i="5" type="font">{\f2 </bpt>.<ept i="5">}</ept></seg>
 </tuv>
 </tu>
 
 */

- (NSArray*)readableExtensions
{
    return @[@"tmx"];
}

- (BOOL)canImportGenericDocument:(NSURL*)url error:(NSError**)error
{
    if (self.useFastXMLParser) {
        __block BOOL xmlDetected = NO;
        self.azXMLParser = [AZXMLParser parserWithUrl:url];
        if (nil == self.azXMLParser) {
            return NO;
        }
        
        self.azXMLParser.didStartElementBlock = ^(AZXMLParser *parser, NSString *elementName, NSDictionary *attributes) {
            xmlDetected = [elementName isEqualToString:@"tmx"];
            parser.stop = YES;
        };

        [self.azXMLParser parse];
        self.azXMLParser = nil;
        
        return xmlDetected;
    } else {
        // Try to find the type of file by parsing its content
        self.document = [[NSXMLDocument alloc] initWithContentsOfURL:url options:NSXMLDocumentTidyXML error:error];
        if(!self.document) {
            return NO;
        }
        
        NSArray *nodes = [self documentNodesForXPath:@"/tmx" error:error];
        if(nodes.count > 0) {
            return YES;
        }    
        
        self.document = nil;
        
        return NO;
    }
}

/**
 Returns a normalized language from TMX language. TMX format is IT-IT while
 iLocalize expect IT_IT.
 */
- (NSString*)normalizedLanguageFromTMXFormat:(NSString*)tmxLang {
    if ([tmxLang rangeOfString:@"-"].location != NSNotFound) {
        return [tmxLang stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    } else {
        return tmxLang;
    }
}

- (NSString*)readTuvElementLang:(NSXMLElement*)tuvElement
{
    NSString *lang = [[tuvElement attributeForName:@"lang"] stringValue];
    if(!lang) {
        lang = [[tuvElement attributeForName:@"xml:lang"] stringValue];
    }
    return [self normalizedLanguageFromTMXFormat:lang];
}

- (BOOL)parseTuElement:(NSXMLElement*)tuElement
{        
    NSString *base = nil;
    NSString *translation = nil;
    
    // Find the file the element belongs to
    NSString *file = nil;
    for(NSXMLElement *props in [tuElement elementsForName:@"prop"]) {
        if([[[props attributeForName:@"type"] stringValue] isEqualToString:@"file"]) {
            file = [self readElementContent:props];
            break;
        }
    }
    
    // Parse the strings
    for(NSXMLElement *tuvElement in [tuElement elementsForName:@"tuv"]) {
        NSString *lang = [self readTuvElementLang:tuvElement];        
        NSString *content = [self readElementContent:[[tuvElement elementsForName:@"seg"] firstObject]];
        
        if([lang isEqualToString:self.sourceLanguage]) {
            base = content;
        } else if([lang isEqualToString:self.targetLanguage]) {
            translation = content;
        } else {
            continue;
        }
    }
    
    [self addStringWithKey:nil base:base translation:translation file:file];
    
    return YES;
}

- (BOOL)parseSourceLanguage:(NSError**)error
{
    NSArray *nodes = [self documentNodesForXPath:@"/tmx/header" error:error];
    if((!nodes || IS_ERROR(error))) {
        return NO;
    }
    
    NSXMLElement *element = [nodes firstObject];
    self.sourceLanguage = [self normalizedLanguageFromTMXFormat:[[element attributeForName:@"srclang"] stringValue]];
    return self.sourceLanguage != nil;
}

- (BOOL)parseTargetLanguage:(NSError**)error
{
    NSArray *nodes = [self.document nodesForXPath:@"/tmx/body/tu/tuv" error:error];
    if((!nodes || IS_ERROR(error))) return NO;
    
    for(NSXMLElement *node in nodes) {
        NSString *lang = [[node attributeForName:@"lang"] stringValue];
        if(!lang) {
            lang = [[node attributeForName:@"xml:lang"] stringValue];            
            if(!lang) continue;
        }
        lang = [self normalizedLanguageFromTMXFormat:lang];
        if(![lang isEqualToString:self.sourceLanguage]) {
            self.targetLanguage = lang;
            return YES;
        }
    }
    
    // Return yes even if the target language couldn't not be found because
    // it is not an error: empty TMX will not exhibit a target language.
    // Note: in 4.1 we introduce a custom property element that will take care of that:
    
    NSArray *props = [self.document nodesForXPath:@"/tmx/header/prop" error:error];
    if((!props || IS_ERROR(error))) return YES;
    
    NSXMLElement *element = [props firstObject];
    if([[[element attributeForName:@"type"] stringValue] isEqualToString:@"x-target"]) {
        self.targetLanguage = [self normalizedLanguageFromTMXFormat:[self readElementContent:element]];
    }

    return YES;
}

- (BOOL)parseDocument:(NSError**)error
{
    NSArray *nodes = [self.document nodesForXPath:@"/tmx/body/tu" error:error];
    if((!nodes || IS_ERROR(error))) return NO;
    
    for(NSXMLElement *tuElement in nodes) {
        if(![self parseTuElement:tuElement]) return NO;
    }
    
    return YES;
}

#pragma mark - Fast parsing

- (NSString*)normalizedLanguageFromTMXAttribute:(NSDictionary*)attributes {
    NSString *lang = attributes[@"lang"];
    if (nil == lang) {
        lang = attributes[@"xml:lang"];
    }
    
    if (lang) {
        return [self normalizedLanguageFromTMXFormat:lang];
    } else {
        return nil;
    }
}

// Override this method to support the fast XML parser
- (BOOL)importDocument:(NSURL*)url error:(NSError**)error
{
    if (self.useFastXMLParser) {
        self.azXMLParser = [AZXMLParser parserWithUrl:url];
        if (nil == self.azXMLParser) {
            return NO;
        }
        
        NSMutableString *elementStack = [NSMutableString string];
        NSMutableString *accumulatedText = [NSMutableString string];
        NSMutableString *tuFile = [NSMutableString string];
        NSMutableString *tuSource = [NSMutableString string];
        NSMutableString *tuTarget = [NSMutableString string];
        
        __block BOOL accumulateText = NO;
        __block BOOL accumulateForSegSource = NO;
        __block BOOL accumulateForSegTarget = NO;
        
        __weak TMXImporter *weakSelf = self;
        self.azXMLParser.didStartElementBlock = ^(AZXMLParser *parser, NSString *elementName, NSDictionary *attributes) {
            [elementStack appendString:@"/"];
            [elementStack appendString:elementName];
            
            // Handle source language
            if ([elementStack isEqualToString:@"/tmx/header"]) {
                weakSelf.sourceLanguage = [weakSelf normalizedLanguageFromTMXFormat:attributes[@"srclang"]];
            }
            
            // Handle target language
            if (nil == weakSelf.targetLanguage) {
                if([elementStack isEqualToString:@"/tmx/body/tu/tuv"] && (attributes[@"lang"] || attributes[@"xml:lang"])) {
                    weakSelf.targetLanguage = [weakSelf normalizedLanguageFromTMXAttribute:attributes];
                }
                if([elementStack isEqualToString:@"/tmx/header/prop"] && [attributes[@"type"] isEqualToString:@"x-target"]) {
                    accumulateText = YES;
                    [accumulatedText deleteCharactersInRange:NSMakeRange(0, accumulatedText.length)];
                }
            }
            
            // Handle translation unit
            if([elementStack isEqualToString:@"/tmx/body/tu"]) {
                [tuFile deleteCharactersInRange:NSMakeRange(0, tuFile.length)];
                [tuSource deleteCharactersInRange:NSMakeRange(0, tuSource.length)];
                [tuTarget deleteCharactersInRange:NSMakeRange(0, tuTarget.length)];
            }
            
            // Handle translation file
            if([elementStack isEqualToString:@"/tmx/body/tu/prop"] && [attributes[@"type"] isEqualToString:@"file"]) {
                accumulateText = YES;
                [accumulatedText deleteCharactersInRange:NSMakeRange(0, accumulatedText.length)];
            }
            
            // Handle translation source/target
            if([elementStack isEqualToString:@"/tmx/body/tu/tuv"]) {
                NSString *lang = [weakSelf normalizedLanguageFromTMXAttribute:attributes];
                if ([lang isEqualToString:weakSelf.sourceLanguage]) {
                    accumulateForSegSource = YES;
                    [accumulatedText deleteCharactersInRange:NSMakeRange(0, accumulatedText.length)];
                }
                if ([lang isEqualToString:weakSelf.targetLanguage]) {
                    accumulateForSegTarget = YES;
                    [accumulatedText deleteCharactersInRange:NSMakeRange(0, accumulatedText.length)];
                }
            }
            
            if([elementStack isEqualToString:@"/tmx/body/tu/tuv/seg"]) {
                accumulateText = (accumulateForSegSource || accumulateForSegTarget);
            }
            
        };
        
        self.azXMLParser.didEndElementBlock = ^(AZXMLParser *parser, NSString *elementName) {
            // Handle target language
            if ([elementStack isEqualToString:@"/tmx/header/prop"] && accumulateText) {
                accumulateText = NO;
                weakSelf.targetLanguage = [weakSelf normalizedLanguageFromTMXFormat:[accumulatedText copy]];
            }
            
            // Handle translation unit
            if([elementStack isEqualToString:@"/tmx/body/tu"]) {
                [weakSelf addStringWithKey:nil base:[tuSource copy] translation:[tuTarget copy] file:[tuFile copy]];
            }
            
            // Handle translation file
            if([elementStack isEqualToString:@"/tmx/body/tu/prop"]) {
                accumulateText = NO;
                [tuFile appendString:[accumulatedText copy]];
            }

            // Handle translation source/target
            if([elementStack isEqualToString:@"/tmx/body/tu/tuv"]) {
                if (accumulateForSegSource) {
                    [tuSource appendString:[accumulatedText copy]];
                } else if (accumulateForSegTarget) {
                    [tuTarget appendString:[accumulatedText copy]];
                }
                accumulateForSegSource = accumulateForSegTarget = NO;
                accumulateText = NO;
            }

            if([elementStack isEqualToString:@"/tmx/body/tu/tuv/seg"]) {
                // Stop accumulating text when the seg element ends but
                // will accumulate again if another one comes up next
                accumulateText = NO;
            }

            // Pop stack
            [elementStack deleteCharactersInRange:NSMakeRange(elementStack.length-(elementName.length+1), elementName.length+1)];
        };

        self.azXMLParser.foundCharactersBlock = ^(AZXMLParser *parser, NSString *string) {
            if (accumulateText) {
                [accumulatedText appendString:string];
            }
        };
        
        return [self.azXMLParser parse];
    } else {
        return [super importDocument:url error:error];
    }
}

@end
