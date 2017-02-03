//
//  AppleGlotImporter.m
//  iLocalize
//
//  Created by Jean Bovet on 4/29/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "AppleGlotImporter.h"


@implementation AppleGlotImporter

/* Sample file:
 
<?xml version="1.0" encoding="UTF-8"?>
<!-- Comment here. (1.0a10c2) -->
<Proj>
    <ProjName>50onPaletteIM</ProjName>
    <!--                                          -->
    <!--    50onPaletteIM/../InfoPlist.strings    -->
    <!--                                          -->
    <File>
        <Filepath>50onPaletteIM/System/Library/Components/50onPalette.component/Contents/Resources/English.lproj/InfoPlist.strings</Filepath>
        <TextItem>
            <Description> Localized versions of Info.plist keys </Description>
            <Position>CFBundleName</Position>
            <TranslationSet>
                <base loc="en">Japanese Kana Palette</base>
                <tran loc="fr" origin="OldLoc exact match">Palette pour le japonais</tran>
            </TranslationSet>
        </TextItem>
        <TextItem>
            <Description/>
            <Position>NSHumanReadableCopyright</Position>
            <TranslationSet>
                <base loc="en">Copyright 2003 Apple Computer, Inc.</base>
                <tran loc="fr" origin="OldLoc exact match">Copyright 2003 Apple Computer, Inc.</tran>
            </TranslationSet>
        </TextItem>
    </File>
 
 */

- (NSArray*)readableExtensions
{
    return @[@"ad", @"wg", @"lg"];
}

- (BOOL)parseSourceLanguage:(NSError**)error
{
    NSArray *nodes = [self documentNodesForXPath:@"/Proj/File/TextItem/TranslationSet/base[@loc]" error:error];
    if (nil == nodes || IS_ERROR(error)) {
        return NO;
    }
    
    // Pick the first element to decided on the base language
    NSXMLElement *element = [nodes firstObject];
    self.sourceLanguage = [[element attributeForName:@"loc"] stringValue];
    return YES;
}

- (BOOL)parseTargetLanguage:(NSError**)error
{
    NSArray *nodes = [self.document nodesForXPath:@"/Proj/File/TextItem/TranslationSet/tran[@loc]" error:error];
    if(IS_ERROR(error)) {
        return NO;
    } 
    
    // Pick the first element to decided on the base language
    NSXMLElement *element = [nodes firstObject];
    self.targetLanguage = [[element attributeForName:@"loc"] stringValue];
    return YES;
}

- (BOOL)parseDocument:(NSError**)error
{
    NSArray *nodes = [self.document nodesForXPath:@"/Proj/File" error:error];
    if(IS_ERROR(error)) {
        return NO;
    } 
        
    for(NSXMLNode *fileNode in nodes) {
        NSXMLNode *filePathNode = [[fileNode nodesForXPath:@"Filepath" error:error] firstObject];
        NSString *file = [self readElementContent:filePathNode];        
        
        for(NSXMLNode *translationNode in [fileNode nodesForXPath:@"TextItem/TranslationSet" error:error]) {
            // In each set of translation, pick the corresponding elements;
            NSString *base = nil;
            NSArray *baseNodes = [translationNode nodesForXPath:@"base" error:error];
            for(NSXMLElement *baseNode in baseNodes) {
                if([[[baseNode attributeForName:@"loc"] stringValue] isEqual:self.sourceLanguage]) {
                    base = [self readElementContent:baseNode];
                    break;
                }
            }
            
            NSString *translation = nil;
            NSArray *translationNodes = [translationNode nodesForXPath:@"tran" error:error];
            for(NSXMLElement *translationNode in translationNodes) {
                if([[[translationNode attributeForName:@"loc"] stringValue] isEqual:self.targetLanguage]) {
                    translation = [self readElementContent:translationNode];
                    break;
                }
            }
            
            if(base && translation) {
                [self addStringWithKey:nil base:base translation:translation file:file];
            }
        }
    }
    
    return YES;
}

@end
