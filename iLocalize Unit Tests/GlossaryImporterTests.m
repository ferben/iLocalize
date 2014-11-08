//
//  GlossaryImporterTests.m
//  iLocalize
//
//  Created by Jean Bovet on 11/29/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import "AbstractTests.h"
#import "XLIFFImporter.h"
#import "TMXImporter.h"
#import "TXMLImporter.h"
#import "ILGImporter.h"
#import "AppleGlotImporter.h"
#import "StringsImporter.h"

#import "XMLImporterElement.h"
#import "SEIManager.h"

#import "AZOrderedDictionary.h"

@interface GlossaryImporterTests : AbstractTests

@end

@implementation GlossaryImporterTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testImportFactory
{
	XCTAssertEqual(TMX, [[SEIManager sharedInstance] formatOfFile:[NSURL fileURLWithPath:[self pathForResource:@"SEI/TMX/sample.xml"]] error:nil], @"TMX format");
	XCTAssertEqual(XLIFF, [[SEIManager sharedInstance] formatOfFile:[NSURL fileURLWithPath:[self pathForResource:@"SEI/XLIFF/sample.xml"]] error:nil], @"XLIFF format");
	XCTAssertEqual(TXML, [[SEIManager sharedInstance] formatOfFile:[NSURL fileURLWithPath:[self pathForResource:@"SEI/TXML/sample.xml"]] error:nil], @"TXML format");
}

- (void)testImporterXLIFF
{
	XLIFFImporter *importer = [[XLIFFImporter alloc] init];
	XCTAssertTrue([importer importDocument:[NSURL fileURLWithPath:[self pathForResource:@"SEI/XLIFF/sample.xml"]] error:nil], @"Import XLIFF");
	[self assertImporterContent:importer];
}

- (void)testImporterTMX
{
    {
        TMXImporter *importer = [[TMXImporter alloc] init];
        XCTAssertTrue([importer importDocument:[NSURL fileURLWithPath:[self pathForResource:@"SEI/TMX/sample.xml"]] error:nil], @"Import TMX");
        [self assertImporterContent:importer];
    }
    
    {
        TMXImporter *importer = [[TMXImporter alloc] init];
        importer.useFastXMLParser = YES;
        XCTAssertTrue([importer importDocument:[NSURL fileURLWithPath:[self pathForResource:@"SEI/TMX/sample.xml"]] error:nil], @"Import TMX");
        [self assertImporterContent:importer];
    }
}

- (void)testImporterTMXGlossary
{
    {
        TMXImporter *importer = [[TMXImporter alloc] init];
        XCTAssertTrue([importer importDocument:[NSURL fileURLWithPath:[self pathForResource:@"SEI/TMX/sample-glossary.xml"]] error:nil], @"Import TMX Glossary");
        [self assertImportWithSampleGlossary:importer];
    }
    
    {
        TMXImporter *importer = [[TMXImporter alloc] init];
        importer.useFastXMLParser = YES;
        XCTAssertTrue([importer importDocument:[NSURL fileURLWithPath:[self pathForResource:@"SEI/TMX/sample-glossary.xml"]] error:nil], @"Import TMX Glossary");
        [self assertImportWithSampleGlossary:importer];
    }
}

- (void)testImporterTMXGlossaryEmpty
{
    {
        TMXImporter *importer = [[TMXImporter alloc] init];
        XCTAssertTrue([importer importDocument:[NSURL fileURLWithPath:[self pathForResource:@"SEI/TMX/sample-glossary-empty.xml"]] error:nil], @"Import TMX Glossary Empty");
        
        XCTAssertEqualObjects(@"en", importer.sourceLanguage, @"Source language");
        XCTAssertEqualObjects(@"fr_CH", importer.targetLanguage, @"Target language");
        
        XCTAssertEqual((int)importer.elementsPerFile.count, 0, @"Size of elements with file");
        XCTAssertEqual((int)importer.elementsWithoutFile.count, 0, @"Size of elements without file");
    }
    
    {
        TMXImporter *importer = [[TMXImporter alloc] init];
        importer.useFastXMLParser = YES;
        XCTAssertTrue([importer importDocument:[NSURL fileURLWithPath:[self pathForResource:@"SEI/TMX/sample-glossary-empty.xml"]] error:nil], @"Import TMX Glossary Empty");
        
        XCTAssertEqualObjects(@"en", importer.sourceLanguage, @"Source language");
        XCTAssertEqualObjects(@"fr_CH", importer.targetLanguage, @"Target language");
        
        XCTAssertEqual((int)importer.elementsPerFile.count, 0, @"Size of elements with file");
        XCTAssertEqual((int)importer.elementsWithoutFile.count, 0, @"Size of elements without file");
    }
}

- (void)testImporterTXML
{
	TXMLImporter *importer = [[TXMLImporter alloc] init];
	XCTAssertTrue([importer importDocument:[NSURL fileURLWithPath:[self pathForResource:@"SEI/TXML/sample.xml"]] error:nil], @"Import TXML");
	[self assertImporterContent:importer];
}

- (void)testImporterAppleGlot
{
	AppleGlotImporter *importer = [[AppleGlotImporter alloc] init];
	XCTAssertTrue([importer importDocument:[NSURL fileURLWithPath:[self pathForResource:@"SEI/AppleGlot/sample.ad"]] error:nil], @"Import AppleGlot");
	[self assertImporterContent:importer];
}

- (void)assertImporterPureGlossaryContent:(XMLImporter*)importer hasLanguageInfo:(BOOL)hasLanguageInfo
{
	if(hasLanguageInfo) {
		XCTAssertEqualObjects(@"en", importer.sourceLanguage, @"Source language");
		XCTAssertEqualObjects(@"fr_CH", importer.targetLanguage, @"Target language");
	} else {
		XCTAssertNil(importer.sourceLanguage, @"Source language");
		XCTAssertNil(importer.targetLanguage, @"Target language");
	}
	
	XCTAssertEqual(0, (int)importer.elementsPerFile.count, @"Size of elements with file");
	XCTAssertEqual(3, (int)importer.elementsWithoutFile.count, @"Size of elements without file");
	
	NSArray *e1List = importer.elementsWithoutFile;
	XMLImporterElement *e11 = [e1List objectAtIndex:0];
	XCTAssertEqualObjects(@"Main Window", e11.source, @"Source");
	XCTAssertEqualObjects(@"Fenetre \"principale\"", e11.translation, @"Translation");
	
	XMLImporterElement *e21 = [e1List objectAtIndex:1];
	XCTAssertEqualObjects(@"Choose", e21.source, @"Source");
	XCTAssertEqualObjects(@"Choisir", e21.translation, @"Translation");
	
	XMLImporterElement *e22 = [e1List objectAtIndex:2];
	XCTAssertEqualObjects(@"Button to choose the file", e22.source, @"Source");
	XCTAssertEqualObjects(@"Bouton pour choisir le fichier", e22.translation, @"Translation");
}

- (void)testImporterILG
{
	ILGImporter *importer = [[ILGImporter alloc] init];
	NSError *error = nil;
	XCTAssertTrue([importer importDocument:[NSURL fileURLWithPath:[self pathForResource:@"SEI/ilg/sample.ilg"]] error:&error], @"Import ILG");
	[self assertImporterPureGlossaryContent:importer hasLanguageInfo:YES];
}

- (void)testImporterStrings
{
	StringsImporter *importer = [[StringsImporter alloc] init];
	XCTAssertTrue([importer importDocument:[NSURL fileURLWithPath:[self pathForResource:@"SEI/Strings/sample.strings"]] error:nil], @"Import Strings");
	[self assertImporterPureGlossaryContent:importer hasLanguageInfo:NO];
}

#pragma mark - Helper

- (void)assertImportWithSampleGlossary:(XMLImporter*)importer {
    XCTAssertEqualObjects(@"en", importer.sourceLanguage, @"Source language");
	XCTAssertEqualObjects(@"fr_CH", importer.targetLanguage, @"Target language");
	
	XCTAssertEqual((int)importer.elementsPerFile.count, 1, @"Size of elements with file");
	XCTAssertEqual((int)importer.elementsWithoutFile.count, 2, @"Size of elements without file");
	
	NSArray *e1List = [importer.elementsPerFile objectForKey:@"/Users/bovet/Test.app/Contents/Resources/English.lproj/Localizable.strings"];
	XCTAssertEqual((int)e1List.count, 1, @"Localizable.strings");
	
	XMLImporterElement *e11 = [e1List objectAtIndex:0];
	XCTAssertEqualObjects(@"Main Window", e11.source, @"Source");
	XCTAssertEqualObjects(@"Fenetre \"principale\"", e11.translation, @"Translation");
	
	NSArray *e2List = importer.elementsWithoutFile;
	XCTAssertEqual((int)e2List.count, 2, @"Elements without file");
	
	XMLImporterElement *e21 = [e2List objectAtIndex:0];
	XCTAssertEqualObjects(@"Choose", e21.source, @"Source");
	XCTAssertEqualObjects(@"Choisir", e21.translation, @"Translation");
	
	XMLImporterElement *e22 = [e2List objectAtIndex:1];
	XCTAssertEqualObjects(@"Button to choose the file", e22.source, @"Source");
	XCTAssertEqualObjects(@"  Bouton pour choisir le fichier  ", e22.translation, @"Translation");
}

- (void)assertImporterContent:(XMLImporter*)importer
{
	XCTAssertEqualObjects(@"en", importer.sourceLanguage, @"Source language");
	XCTAssertEqualObjects(@"fr_CH", importer.targetLanguage, @"Target language");
	
	XCTAssertEqual((int)importer.elementsPerFile.count, 2, @"Size of elements with file");
	XCTAssertEqual((int)importer.elementsWithoutFile.count, 0, @"Size of elements without file");
	
	NSArray *e1List = [importer.elementsPerFile objectForKey:@"/Users/bovet/Test.app/Contents/Resources/English.lproj/Localizable.strings"];
	XCTAssertEqual((int)e1List.count, 1, @"Localizable.strings");
	
	XMLImporterElement *e11 = [e1List objectAtIndex:0];
	XCTAssertEqualObjects(@"Main Window", e11.source, @"Source");
	XCTAssertEqualObjects(@"Fenetre \"principale\"", e11.translation, @"Translation");
	
	NSArray *e2List = [importer.elementsPerFile objectForKey:@"/Users/bovet/Test.app/Contents/Resources/English.lproj/Another.strings"];
	XCTAssertEqual(2, (int)e2List.count, @"Another.strings");
	
	XMLImporterElement *e21 = [e2List objectAtIndex:0];
	XCTAssertEqualObjects(@"Choose", e21.source, @"Source");
	XCTAssertEqualObjects(@"Choisir", e21.translation, @"Translation");
	
	XMLImporterElement *e22 = [e2List objectAtIndex:1];
	XCTAssertEqualObjects(@"Button to choose the file", e22.source, @"Source");
	XCTAssertEqualObjects(@"Bouton pour choisir le fichier", e22.translation, @"Translation");
}

@end
