//
//  StringExportImportTests.m
//  iLocalize
//
//  Created by Jean Bovet on 11/24/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "XLIFFExportSettings.h"
#import "XLIFFExportOperation.h"

#import "XLIFFImportSettings.h"
#import "XLIFFImportPreviewOperation.h"

#import "SEIManager.h"

#import "TMXExporter.h"
#import "TXMLExporter.h"
#import "XLIFFExporter.h"
#import "ILGExporter.h"
#import "StringsExporter.h"

#import "FileController.h"
#import "StringController.h"
#import "SimpleStringController.h"
#import "SimpleFileController.h"

#import "AZOrderedDictionary.h"

#import "AbstractTests.h"

@interface GlossaryExporterTests : AbstractTests

@end

@implementation GlossaryExporterTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)addLocalizableFile:(NSMutableArray*)fcs
{
	SimpleFileController *fc = [[SimpleFileController alloc] init];
	fc.path = @"/Users/bovet/Test.app/Contents/Resources/English.lproj/Localizable.strings";
	[fcs addObject:fc];
	
	SimpleStringController *sc = [[SimpleStringController alloc] init];
	sc.key = @"title";
	sc.base = @"Main Window";
	sc.translation = @"Fenetre \"principale\"";
	
	[fc addString:sc];
}

- (void)addAnotherFile:(NSMutableArray*)fcs
{
	SimpleFileController *fc = [[SimpleFileController alloc] init];
	fc.path = @"/Users/bovet/Test.app/Contents/Resources/English.lproj/Another.strings";
	[fcs addObject:fc];
	
	SimpleStringController *sc = [[SimpleStringController alloc] init];
	sc.key = @"button.title";
	sc.base = @"Choose";
	sc.translation = @"Choisir";
	[fc addString:sc];
    
	sc = [[SimpleStringController alloc] init];
	sc.key = @"button.tooltip";
	sc.base = @"Button to choose the file";
	sc.translation = @"Bouton pour choisir le fichier";
	[fc addString:sc];
}

- (NSString*)exportWithFormat:(int)format
{
	NSMutableArray *fcs = [NSMutableArray array];
	[self addLocalizableFile:fcs];
	[self addAnotherFile:fcs];
	
	XLIFFExportSettings *settings = [[XLIFFExportSettings alloc] init];
	settings.format = format;
	settings.sourceLanguage = @"en";
	settings.targetLanguage = @"fr_CH";
	settings.files = fcs;
	
	XLIFFExportOperation *op = [XLIFFExportOperation operation];
	op.settings = settings;
	
	return [op buildXLIFF];
}

#pragma mark Test individual exporters

- (void)testExportXLIFF
{
	NSString *content = [self exportWithFormat:XLIFF];
	
	NSString *samplePath = [self pathForResource:@"SEI/XLIFF/sample.xml"];
	NSString *sample = [NSString stringWithContentsOfFile:samplePath usedEncoding:nil error:nil];
	XCTAssertEqualObjects(sample, content, @"Export XLIFF");
}

- (void)testExportTXML
{
	NSString *content = [self exportWithFormat:TXML];
    //	NSLog(@"%@", content);
	
	NSString *samplePath = [self pathForResource:@"SEI/TXML/sample.xml"];
	NSString *sample = [NSString stringWithContentsOfFile:samplePath usedEncoding:nil error:nil];
	XCTAssertEqualObjects(sample, content, @"Export TXML");
}

- (void)testExportTXMLLineBreakEscaping
{
    NSString *t1 = @"Line with no break";
    XCTAssertEqualObjects([TXMLExporter escapedString:t1], t1, @"Line break escaping mismatch when nothing is expected to be escaped");
    
    NSString *t2 = [NSString stringWithContentsOfFile:[self pathForResource:@"SEI/TXML/linebreak-sample.txt"] usedEncoding:nil error:nil];
    NSString *te2 = [NSString stringWithContentsOfFile:[self pathForResource:@"SEI/TXML/linebreak-escape.xml"] usedEncoding:nil error:nil];
    
    XCTAssertEqualObjects([TXMLExporter escapedString:t2], te2, @"Line break escaping mismatch");
}

- (void)testExportTMX
{
	NSString *content = [self exportWithFormat:TMX];
	//	NSLog(@"%@", content);
	
	NSString *samplePath = [self pathForResource:@"SEI/TMX/sample.xml"];
	NSString *sample = [NSString stringWithContentsOfFile:samplePath usedEncoding:nil error:nil];
	XCTAssertEqualObjects(sample, content, @"Export TMX");
}

- (void)testExportILG
{
	NSString *content = [self exportWithFormat:ILG];
	//	NSLog(@"%@", content);
	
	NSString *samplePath = [self pathForResource:@"SEI/ilg/sample.ilg"];
	NSString *sample = [NSString stringWithContentsOfFile:samplePath usedEncoding:nil error:nil];
	XCTAssertEqualObjects(sample, content, @"Export ILG");
}

- (void)testExportStrings
{
	NSString *content = [self exportWithFormat:STRINGS];
	//	NSLog(@"%@", content);
	
	NSString *samplePath = [self pathForResource:@"SEI/Strings/sample.strings"];
	NSString *sample = [NSString stringWithContentsOfFile:samplePath usedEncoding:nil error:nil];
	XCTAssertEqualObjects(sample, content, @"Export Strings");
}

- (void)testExportFactory
{
	XCTAssertTrue([[[SEIManager sharedInstance] exporterForFormat:TMX] isKindOfClass:[TMXExporter class]], @"TMX format");
	XCTAssertTrue([[[SEIManager sharedInstance] exporterForFormat:XLIFF] isKindOfClass:[XLIFFExporter class]], @"XLIFF format");
	XCTAssertTrue([[[SEIManager sharedInstance] exporterForFormat:TXML] isKindOfClass:[TXMLExporter class]], @"TXML format");
	XCTAssertTrue([[[SEIManager sharedInstance] exporterForFormat:ILG] isKindOfClass:[ILGExporter class]], @"ILG format");
	XCTAssertTrue([[[SEIManager sharedInstance] exporterForFormat:STRINGS] isKindOfClass:[StringsExporter class]], @"STRINGS format");
}

@end
