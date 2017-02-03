//
//  ToolTests.m
//  iLocalize
//
//  Created by Jean Bovet on 11/24/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FileModelAttributes.h"
#import "XMLParserTestHelper.h"
#import "LanguageTool.h"
#import "FileTool.h"
#import "StringTool.h"
#import "HTMLEncodingTool.h"
#import "StringEncodingTool.h"
#import "Glossary.h"
#import "GlossaryEntry.h"
#import "Constants.h"
#import "FMManager.h"
#import "FMEngine.h"
#import "AZPathNode.h"
#import "StringEncoding.h"

#import "FileOperationManager.h"
#import "FileMergeOperationManager.h"
#import "ScanBundleOp.h"

#import "PropagationEngine.h"
#import "SimpleStringController.h"
#import "FindContentMatching.h"

#import "AbstractTests.h"

@interface ToolTests : AbstractTests

@end

@implementation ToolTests

#pragma mark Encoding HTML

- (BOOL)doTestReplaceHTMLEncodingWithFileName:(NSString*)filename toEncoding:(StringEncoding*)targetEncoding
{
    BOOL hasEncoding = NO;
    NSString *sourcePath = [self pathForResource:filename];
    StringEncoding* sourceEncoding = [HTMLEncodingTool encodingOfFile:sourcePath hasEncoding:&hasEncoding];
    NSString *sourceContent = [StringEncodingTool stringWithContentOfFile:sourcePath encoding:sourceEncoding];
    NSString *modifiedContent = [HTMLEncodingTool replaceEncodingInformationOfString:sourceContent fromEncoding:sourceEncoding toEncoding:targetEncoding];
    
    NSString *verifyFileName = [NSString stringWithFormat:@"%@/replaced_%@", [filename stringByDeletingLastPathComponent], [filename lastPathComponent]];
    NSString *verifyPath = [self pathForResource:verifyFileName];
    StringEncoding* verifyEncoding = [HTMLEncodingTool encodingOfFile:verifyPath hasEncoding:&hasEncoding];
    XCTAssertEqualObjects((ENCODING_UTF8), verifyEncoding, @"Target encoding: %@", targetEncoding);
    NSString *verifyContent = [StringEncodingTool stringWithContentOfFile:verifyPath encoding:sourceEncoding];
    
    if([modifiedContent length] == 0) return NO;
    if([verifyContent length] == 0) return NO;
    
    return [verifyContent isEqualToString:modifiedContent];
}

- (void)assertFileModelAttributeEncoding:(StringEncoding*)encoding
{
    FileModelAttributes *fma = [[FileModelAttributes alloc] init];
    [fma setEncoding:encoding];
    XCTAssertEqualObjects(encoding, [fma encoding], @"Encoding");
}

- (void)testEncodingFileModelAttribute
{
    [self assertFileModelAttributeEncoding:ENCODING_UTF8];
    [self assertFileModelAttributeEncoding:ENCODING_UTF8_BOM];
    
    [self assertFileModelAttributeEncoding:ENCODING_UTF16LE];
    [self assertFileModelAttributeEncoding:ENCODING_UTF16LE_BOM];
    
    [self assertFileModelAttributeEncoding:ENCODING_UTF16BE];
    [self assertFileModelAttributeEncoding:ENCODING_UTF16BE_BOM];
    
    [self assertFileModelAttributeEncoding:ENCODING_UTF32BE];
    [self assertFileModelAttributeEncoding:ENCODING_UTF32BE_BOM];
    
    [self assertFileModelAttributeEncoding:ENCODING_UTF32LE];
    [self assertFileModelAttributeEncoding:ENCODING_UTF32LE_BOM];
    
    [self assertFileModelAttributeEncoding:ENCODING_UNICODE];
    [self assertFileModelAttributeEncoding:ENCODING_UNICODE_BOM];
    
    [self assertFileModelAttributeEncoding:ENCODING_MACOS_ROMAN];
}

- (void)testEncodingHTML
{
    BOOL hasEncoding = NO;
    
    XCTAssertEqualObjects(nil, [HTMLEncodingTool encodingOfContent:[self pathForResource:@"EncodingHTML/foo2.html" ] hasEncoding:&hasEncoding], @"non-existing");
    XCTAssertEqualObjects(ENCODING_UTF8, [HTMLEncodingTool encodingOfContent:[self pathForResource:@"EncodingHTML/malformed.html" ] hasEncoding:&hasEncoding], @"malformed");
    XCTAssertEqualObjects(ENCODING_UTF8, [HTMLEncodingTool encodingOfContent:[self pathForResource:@"EncodingHTML/noencoding.html" ] hasEncoding:&hasEncoding], @"nonencoding");
    
    XCTAssertEqualObjects(ENCODING_UTF8, [HTMLEncodingTool encodingOfFile:[self pathForResource:@"EncodingHTML/html_utf8.html" ] hasEncoding:&hasEncoding], @"utf8");
    XCTAssertEqualObjects(ENCODING_UTF16BE_BOM, [HTMLEncodingTool encodingOfFile:[self pathForResource:@"EncodingHTML/html_utf16.html" ] hasEncoding:&hasEncoding], @"utf16");
    
    XCTAssertEqualObjects(ENCODING_UTF8, [HTMLEncodingTool encodingOfFile:[self pathForResource:@"EncodingHTML/hazel_aboutFolders.html" ] hasEncoding:&hasEncoding], @"hazel about folders utf8");
    XCTAssertEqualObjects(ENCODING_UTF8, [HTMLEncodingTool encodingOfFile:[self pathForResource:@"EncodingHTML/hazel_index.html" ] hasEncoding:&hasEncoding], @"hazel index utf8");
    
    XCTAssertEqualObjects(ENCODING_ISO_LATIN, [HTMLEncodingTool encodingOfContentInXMLHeader:[self pathForResource:@"EncodingHTML/xhtml_iso-8859-1.html" ] hasEncoding:&hasEncoding], @"xml header iso-8859-1");
    NSAssert(hasEncoding, @"xml header iso-8859-1");
    
    XCTAssertEqualObjects(ENCODING_UTF8, [HTMLEncodingTool encodingOfContentInXMLHeader:[self pathForResource:@"EncodingHTML/xhtml_utf8.html" ] hasEncoding:&hasEncoding], @"xml header utf-8");
    NSAssert(hasEncoding, @"xml header utf-8");
    
    XCTAssertEqualObjects(ENCODING_UNICODE, [HTMLEncodingTool encodingOfContentInXMLHeader:[self pathForResource:@"EncodingHTML/xhtml_utf16.html" ] hasEncoding:&hasEncoding], @"xml header utf-16");
    NSAssert(hasEncoding, @"xml header utf-16");
    
    XCTAssertEqualObjects(ENCODING_ISO_LATIN, [HTMLEncodingTool encodingOfContent:[self pathForResource:@"EncodingHTML/xhtml_iso-8859-1.html" ] hasEncoding:&hasEncoding], @"html content iso-8859-1");
    NSAssert(hasEncoding, @"html content iso-8859-1");
    
    XCTAssertEqualObjects(ENCODING_UTF8, [HTMLEncodingTool encodingOfContent:[self pathForResource:@"EncodingHTML/xhtml_utf8.html" ] hasEncoding:&hasEncoding], @"html content utf-8");
    NSAssert(hasEncoding, @"html content utf-8");
    
    XCTAssertEqualObjects(ENCODING_UNICODE, [HTMLEncodingTool encodingOfContent:[self pathForResource:@"EncodingHTML/xhtml_utf16.html" ] hasEncoding:&hasEncoding], @"html content utf-16");
    NSAssert(hasEncoding, @"html content utf-16");
    
    NSAssert([self doTestReplaceHTMLEncodingWithFileName:@"EncodingHTML/html_iso-8859-1.html" toEncoding:ENCODING_UTF8], @"replace HTML ISO -> UTF-8");
    NSAssert([self doTestReplaceHTMLEncodingWithFileName:@"EncodingHTML/html_utf8.html" toEncoding:ENCODING_ISO_LATIN], @"replace HTML UTF8 -> ISO");
    NSAssert([self doTestReplaceHTMLEncodingWithFileName:@"EncodingHTML/xhtml_iso-8859-1.html" toEncoding:ENCODING_UTF8], @"replace XHTML ISO -> UTF-8");
    NSAssert([self doTestReplaceHTMLEncodingWithFileName:@"EncodingHTML/xhtml_utf8.html" toEncoding:ENCODING_ISO_LATIN], @"replace XHTML UTF8 -> ISO");
}

- (StringEncoding*)encodingOfFile:(NSString*)file
{
    FMEngine *engine = [[FMManager shared] engineForFile:file];
    return [engine encodingOfFile:file language:@"English"];
}

- (void)testEncodingUsingEngine
{
    XCTAssertEqualObjects([self encodingOfFile:[self pathForResource:@"EncodingHTML/html_utf8.html" ]], ENCODING_UTF8, @"NSUTF8StringEncoding");
    XCTAssertEqualObjects([self encodingOfFile:[self pathForResource:@"EncodingHTML/xhtml_iso-8859-1.html" ]], ENCODING_ISO_LATIN, @"NSISOLatin1StringEncoding");
    XCTAssertEqualObjects([self encodingOfFile:[self pathForResource:@"EncodingHTML/html_utf16le.html" ]], ENCODING_UTF16LE_BOM, @"NSStringEncodingUTF16LE");
}

#pragma mark Encoding Text

- (void)_assertEncoding:(StringEncoding*)encoding writeReadString:(NSString*)s
{
    NSString *tempFile = [FileTool generateTemporaryFileName];
    NSData *data = [StringEncodingTool encodeString:s toDataUsingEncoding:encoding];
    [data writeToFile:tempFile atomically:NO];
    //NSLog(@"%@ -> %@", encoding, data);
    StringEncoding *encodingUsed;
    NSString *readString = [StringEncodingTool stringWithContentOfFile:tempFile encodingUsed:&encodingUsed defaultEncoding:ENCODING_UTF8];
    XCTAssertEqualObjects(encodingUsed, encoding, @"test r/w 1");
    NSAssert([readString isEqualToString:s], @"test r/w 2");
    [tempFile removePathFromDisk];
}

- (void)testEncoding
{
    StringEncoding *def = ENCODING_UTF8;
    XCTAssertEqualObjects(ENCODING_UTF8, [StringEncodingTool encodingOfFile:[self pathForResource:@"EncodingText/macos_roman.txt"] defaultEncoding:def], @"macos_roman");
    XCTAssertEqualObjects(ENCODING_UTF8, [StringEncodingTool encodingOfFile:[self pathForResource:@"EncodingText/utf8.txt"] defaultEncoding:def], @"utf8");
    XCTAssertEqualObjects(ENCODING_UTF8_BOM, [StringEncodingTool encodingOfFile:[self pathForResource:@"EncodingText/utf8_bom.txt"] defaultEncoding:def], @"utf8_bom");
    XCTAssertEqualObjects(ENCODING_UTF16BE_BOM, [StringEncodingTool encodingOfFile:[self pathForResource:@"EncodingText/utf16_bom_be.txt"] defaultEncoding:def], @"utf16_bom_be");
    XCTAssertEqualObjects(ENCODING_UTF16LE_BOM, [StringEncodingTool encodingOfFile:[self pathForResource:@"EncodingText/utf16_bom_le.txt"] defaultEncoding:def], @"utf16_bom_le");
    XCTAssertEqualObjects(ENCODING_UTF32BE_BOM, [StringEncodingTool encodingOfFile:[self pathForResource:@"EncodingText/utf32_bom_be.txt"] defaultEncoding:def], @"utf32_bom_be");
    XCTAssertEqualObjects(ENCODING_UTF32LE_BOM, [StringEncodingTool encodingOfFile:[self pathForResource:@"EncodingText/utf32_bom_le.txt"] defaultEncoding:def], @"utf32_bom_le");
    
    NSString *s1 = [NSString stringWithUTF8String:"This is in UTF-8 without BOM but e aigu: \u00e9"];
    
    NSAssert([[StringEncodingTool stringWithContentOfFile:[self pathForResource:@"EncodingText/utf8_bom.txt"] encoding:ENCODING_UTF8] isEqualToString:@"This is in UTF-8 with BOM"], @"test 1");
    NSAssert([[StringEncodingTool stringWithContentOfFile:[self pathForResource:@"EncodingText/utf8.txt"] encoding:ENCODING_UTF8] isEqualToString:s1], @"test 2");
    
    [self _assertEncoding:ENCODING_UTF8_BOM writeReadString:s1];
    [self _assertEncoding:ENCODING_UTF8 writeReadString:s1];
    
    // Note: with no bom, the UTF-16 and 32 can actually be read with UTF-8 (smaller encoding).
    // To make these tests valid, we should use a string character that cannot be encoded in UTF-8.
    //    [self _assertEncoding:ENCODING_UTF16BE writeReadString:s1];
    [self _assertEncoding:ENCODING_UTF16BE_BOM writeReadString:s1];
    
    //    [self _assertEncoding:ENCODING_UTF16LE writeReadString:s1];
    [self _assertEncoding:ENCODING_UTF16LE_BOM writeReadString:s1];
    
    //    [self _assertEncoding:ENCODING_UTF32LE writeReadString:s1];
    [self _assertEncoding:ENCODING_UTF32LE_BOM writeReadString:s1];
    
    //    [self _assertEncoding:ENCODING_UTF32BE writeReadString:s1];
    [self _assertEncoding:ENCODING_UTF32BE_BOM writeReadString:s1];
}

#pragma mark XML Parser

- (void)testXMLParser
{
    NSAssert([XMLParserTestHelper parseFile:[self pathForResource:@"XMLParser/test_input_a.xml"]
                              verifyFile:[self pathForResource:@"XMLParser/test_verify_a.xml"]],
             @"test_input_a");
    NSAssert([XMLParserTestHelper parseFile:[self pathForResource:@"XMLParser/test_input_b.xml"]
                              verifyFile:[self pathForResource:@"XMLParser/test_verify_b.xml"]],
             @"test_input_b");
    NSAssert([XMLParserTestHelper parseFile:[self pathForResource:@"XMLParser/test_input_c.xml"]
                              verifyFile:[self pathForResource:@"XMLParser/test_verify_c.xml"]],
             @"test_input_c");
    NSAssert([XMLParserTestHelper parseFile:[self pathForResource:@"XMLParser/test_input_d.xml"]
                              verifyFile:[self pathForResource:@"XMLParser/test_verify_d.xml"]],
             @"test_input_d");
    NSAssert([XMLParserTestHelper parseFile:[self pathForResource:@"XMLParser/test_input_e.xml"]
                              verifyFile:[self pathForResource:@"XMLParser/test_verify_e.xml"]],
             @"test_input_e");
}

- (void)testXMLEscaping
{
    XCTAssertEqualObjects(@"Hello &amp; World", [@"Hello & World" xmlEscaped], @"XML escaped");
    XCTAssertEqualObjects(@"Hello &amp; World", [@"Hello &amp; World" xmlEscaped], @"XML escaped");
    XCTAssertEqualObjects(@"Hello &lt; &gt; World", [@"Hello < > World" xmlEscaped], @"XML escaped");
    XCTAssertEqualObjects(@"Hello &quot;World&quot;", [@"Hello \"World\"" xmlEscaped], @"XML escaped");
    XCTAssertEqualObjects(@"Hello &apos;World&apos;", [@"Hello 'World'" xmlEscaped], @"XML escaped");
}

- (void)testXMLUnescaping
{
    XCTAssertEqualObjects(@"Hello & World", [@"Hello &amp; World" xmlUnescaped], @"XML unescaped");
    XCTAssertEqualObjects(@"Hello < > World", [@"Hello &lt; &gt; World" xmlUnescaped], @"XML unescaped");
    XCTAssertEqualObjects(@"Hello & World", [@"Hello & World" xmlUnescaped], @"XML unescaped");
    XCTAssertEqualObjects(@"Hello \"World\"", [@"Hello &quot;World&quot;" xmlUnescaped], @"XML unescaped");
    XCTAssertEqualObjects(@"Hello 'World'", [@"Hello &apos;World&apos;" xmlUnescaped], @"XML unescaped");
}

#pragma mark Glossary

- (GlossaryEntry*)createEntryWithSource:(NSString*)source target:(NSString*)target
{
    GlossaryEntry *entry = [[GlossaryEntry alloc] init];
    entry.source = source;
    entry.translation = target;
    return entry;
}

- (int)countEntry:(id)entry inArray:(NSArray*)array
{
    int count = 0;
    int i;
    for(i=0; i<[array count]; i++) {
        if([[array objectAtIndex:i] isEqual:entry]) count++;
    }
    return count;
}

- (void)testRemoveDuplicateGlossaryEntries
{
    NSMutableArray *entries = [NSMutableArray array];
    [entries addObject:[self createEntryWithSource:@"d" target:@"b"]];
    [entries addObject:[self createEntryWithSource:@"a" target:@"|b"]];
    [entries addObject:[self createEntryWithSource:@"a" target:@"b"]];
    [entries addObject:[self createEntryWithSource:@"a|" target:@"b"]];
    [entries addObject:[self createEntryWithSource:@"a|" target:@"b"]];
    [entries addObject:[self createEntryWithSource:@"d" target:@"b"]];
    [entries addObject:[self createEntryWithSource:@"d" target:@"b"]];
    [entries addObject:[self createEntryWithSource:@"d" target:@"e"]];
    
    NSAssert([self countEntry:[self createEntryWithSource:@"d" target:@"b"] inArray:entries] == 3, @"d4");
    
    Glossary *g = [[Glossary alloc] init];
    [g addEntries:entries];
    [g removeDuplicateEntries];
    
    [entries removeAllObjects];
    [entries addObjectsFromArray:[g entries]];
    
    NSAssert([self countEntry:[self createEntryWithSource:@"a" target:@"|b"] inArray:entries] == 1, @"d1");
    NSAssert([self countEntry:[self createEntryWithSource:@"a" target:@"b"] inArray:entries] == 1, @"d2");
    NSAssert([self countEntry:[self createEntryWithSource:@"a|" target:@"b"] inArray:entries] == 1, @"d3");
    NSAssert([self countEntry:[self createEntryWithSource:@"d" target:@"b"] inArray:entries] == 1, @"d4");
    NSAssert([self countEntry:[self createEntryWithSource:@"d" target:@"e"] inArray:entries] == 1, @"d5");
}

#pragma mark File/Bundle operations

- (void)testFileOperationManager
{
    FileOperationManager *m = [FileOperationManager manager];
    
    NSString *source = [self pathForResource:@"Contents/FileOperationManager.app"];
    NSMutableArray *originalFiles = [NSMutableArray array];
    
    XCTAssertTrue([m enumerateDirectory:source files:originalFiles errorHandler:nil], @"Enumerate directory");
    XCTAssertEqualObjects(originalFiles, ([NSArray arrayWithObjects:
                                          @"Contents/Resources/fr.lproj/version1.rtf",
                                          @"Contents/Resources/fr.lproj/special.xml",
                                          @"Contents/Resources/fr.lproj/Unchanged.strings",
                                          @"Contents/Resources/fr.lproj/MainMenu.nib",
                                          @"Contents/Resources/fr.lproj",
                                          @"Contents/Resources/en.lproj/version1.rtf",
                                          @"Contents/Resources/en.lproj/special.xml",
                                          @"Contents/Resources/en.lproj/image.tiff",
                                          @"Contents/Resources/en.lproj/Unchanged.strings",
                                          @"Contents/Resources/en.lproj/MainMenu.nib",
                                          @"Contents/Resources/en.lproj/Localizable.strings",
                                          @"Contents/Resources/en.lproj/InfoPlist.strings",
                                          @"Contents/Resources/en.lproj/Credits.html",
                                          @"Contents/Resources/en.lproj/Complex.rtfd",
                                          @"Contents/Resources/en.lproj",
                                          @"Contents/Resources/French.lproj/Panel.nib",
                                          @"Contents/Resources/French.lproj/Others.strings",
                                          @"Contents/Resources/French.lproj",
                                          @"Contents/Resources",
                                          @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/fr.lproj/GCTWAINSourceWindow.nib",
                                          @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/fr.lproj/GCTWAINMainMenu.nib",
                                          @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/fr.lproj",
                                          @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/English.lproj/GCTWAINSourceWindow.nib",
                                          @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/English.lproj/GCTWAINMainMenu.nib",
                                          @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/English.lproj",
                                          @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources",
                                          @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/MacOS/GCTWAIN_PPC",
                                          @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/MacOS",
                                          @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Info.plist",
                                          @"Contents/PlugIns/GCTWAIN_PPC.app/Contents",
                                          @"Contents/PlugIns/GCTWAIN_PPC.app",
                                          @"Contents/PlugIns",
                                          @"Contents/PkgInfo",
                                          @"Contents/MacOS/MyApp",
                                          @"Contents/MacOS",
                                          @"Contents/Info.plist",
                                          @"Contents",
                                          nil]), @"Directory content");
    
    NSArray *languages = [NSArray arrayWithObjects:@"fr", nil];
    NSMutableArray *files = [NSMutableArray arrayWithArray:originalFiles];
    XCTAssertTrue([m includeLocalizedFilesFromLanguages:languages files:files], @"Include languages");
    XCTAssertEqualObjects(files, ([NSArray arrayWithObjects:
                                  @"Contents/Resources/fr.lproj/version1.rtf",
                                  @"Contents/Resources/fr.lproj/special.xml",
                                  @"Contents/Resources/fr.lproj/Unchanged.strings",
                                  @"Contents/Resources/fr.lproj/MainMenu.nib",
                                  @"Contents/Resources/fr.lproj",
                                  @"Contents/Resources/French.lproj/Panel.nib",
                                  @"Contents/Resources/French.lproj/Others.strings",
                                  @"Contents/Resources/French.lproj",
                                  @"Contents/Resources",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/fr.lproj/GCTWAINSourceWindow.nib",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/fr.lproj/GCTWAINMainMenu.nib",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/fr.lproj",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/MacOS/GCTWAIN_PPC",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/MacOS",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Info.plist",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app",
                                  @"Contents/PlugIns",
                                  @"Contents/PkgInfo",
                                  @"Contents/MacOS/MyApp",
                                  @"Contents/MacOS",
                                  @"Contents/Info.plist",
                                  @"Contents",
                                  nil]), @"Directory content after including languages");
    
    files = [NSMutableArray arrayWithArray:originalFiles];
    XCTAssertTrue([m excludeLocalizedFilesFromLanguages:languages files:files], @"Exclude languages");
    XCTAssertEqualObjects(files, ([NSArray arrayWithObjects:
                                  @"Contents/Resources/en.lproj/version1.rtf",
                                  @"Contents/Resources/en.lproj/special.xml",
                                  @"Contents/Resources/en.lproj/image.tiff",
                                  @"Contents/Resources/en.lproj/Unchanged.strings",
                                  @"Contents/Resources/en.lproj/MainMenu.nib",
                                  @"Contents/Resources/en.lproj/Localizable.strings",
                                  @"Contents/Resources/en.lproj/InfoPlist.strings",
                                  @"Contents/Resources/en.lproj/Credits.html",
                                  @"Contents/Resources/en.lproj/Complex.rtfd",
                                  @"Contents/Resources/en.lproj",
                                  @"Contents/Resources",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/English.lproj/GCTWAINSourceWindow.nib",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/English.lproj/GCTWAINMainMenu.nib",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/English.lproj",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/MacOS/GCTWAIN_PPC",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/MacOS",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Info.plist",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app",
                                  @"Contents/PlugIns",
                                  @"Contents/PkgInfo",
                                  @"Contents/MacOS/MyApp",
                                  @"Contents/MacOS",
                                  @"Contents/Info.plist",
                                  @"Contents",
                                  nil]), @"Directory content after excluding languages");
    
    files = [NSMutableArray arrayWithArray:originalFiles];
    XCTAssertTrue([m excludeNonLocalizedFiles:files], @"Exclude non-localized files");
    XCTAssertEqualObjects(files, ([NSArray arrayWithObjects:
                                  @"Contents/Resources/fr.lproj/version1.rtf",
                                  @"Contents/Resources/fr.lproj/special.xml",
                                  @"Contents/Resources/fr.lproj/Unchanged.strings",
                                  @"Contents/Resources/fr.lproj/MainMenu.nib",
                                  @"Contents/Resources/fr.lproj",
                                  @"Contents/Resources/en.lproj/version1.rtf",
                                  @"Contents/Resources/en.lproj/special.xml",
                                  @"Contents/Resources/en.lproj/image.tiff",
                                  @"Contents/Resources/en.lproj/Unchanged.strings",
                                  @"Contents/Resources/en.lproj/MainMenu.nib",
                                  @"Contents/Resources/en.lproj/Localizable.strings",
                                  @"Contents/Resources/en.lproj/InfoPlist.strings",
                                  @"Contents/Resources/en.lproj/Credits.html",
                                  @"Contents/Resources/en.lproj/Complex.rtfd",
                                  @"Contents/Resources/en.lproj",
                                  @"Contents/Resources/French.lproj/Panel.nib",
                                  @"Contents/Resources/French.lproj/Others.strings",
                                  @"Contents/Resources/French.lproj",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/fr.lproj/GCTWAINSourceWindow.nib",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/fr.lproj/GCTWAINMainMenu.nib",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/fr.lproj",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/English.lproj/GCTWAINSourceWindow.nib",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/English.lproj/GCTWAINMainMenu.nib",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/English.lproj",
                                  nil]), @"Directory content after excluding non-localized files");
    
    files = [NSMutableArray arrayWithArray:originalFiles];
    NSArray *paths = [NSArray arrayWithObjects:@"Contents/Resources", nil];
    XCTAssertTrue([m excludeFiles:files notInPaths:paths], @"Exclude path prefixes");
    XCTAssertEqualObjects(files, ([NSArray arrayWithObjects:
                                  @"Contents/Resources/fr.lproj/version1.rtf",
                                  @"Contents/Resources/fr.lproj/special.xml",
                                  @"Contents/Resources/fr.lproj/Unchanged.strings",
                                  @"Contents/Resources/fr.lproj/MainMenu.nib",
                                  @"Contents/Resources/fr.lproj",
                                  @"Contents/Resources/en.lproj/version1.rtf",
                                  @"Contents/Resources/en.lproj/special.xml",
                                  @"Contents/Resources/en.lproj/image.tiff",
                                  @"Contents/Resources/en.lproj/Unchanged.strings",
                                  @"Contents/Resources/en.lproj/MainMenu.nib",
                                  @"Contents/Resources/en.lproj/Localizable.strings",
                                  @"Contents/Resources/en.lproj/InfoPlist.strings",
                                  @"Contents/Resources/en.lproj/Credits.html",
                                  @"Contents/Resources/en.lproj/Complex.rtfd",
                                  @"Contents/Resources/en.lproj",
                                  @"Contents/Resources/French.lproj/Panel.nib",
                                  @"Contents/Resources/French.lproj/Others.strings",
                                  @"Contents/Resources/French.lproj",
                                  @"Contents/Resources",
                                  nil]), @"Directory content after excluding path prefixes");
    
    files = [NSMutableArray arrayWithArray:originalFiles];
    languages = [NSArray arrayWithObjects:@"fr", nil];
    XCTAssertTrue([m excludeLocalizedFilesFromLanguages:languages files:files], @"Exclude languages");
    XCTAssertEqualObjects(files, ([NSArray arrayWithObjects:
                                  @"Contents/Resources/en.lproj/version1.rtf",
                                  @"Contents/Resources/en.lproj/special.xml",
                                  @"Contents/Resources/en.lproj/image.tiff",
                                  @"Contents/Resources/en.lproj/Unchanged.strings",
                                  @"Contents/Resources/en.lproj/MainMenu.nib",
                                  @"Contents/Resources/en.lproj/Localizable.strings",
                                  @"Contents/Resources/en.lproj/InfoPlist.strings",
                                  @"Contents/Resources/en.lproj/Credits.html",
                                  @"Contents/Resources/en.lproj/Complex.rtfd",
                                  @"Contents/Resources/en.lproj",
                                  @"Contents/Resources",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/English.lproj/GCTWAINSourceWindow.nib",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/English.lproj/GCTWAINMainMenu.nib",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/English.lproj",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/MacOS/GCTWAIN_PPC",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/MacOS",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Info.plist",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app",
                                  @"Contents/PlugIns",
                                  @"Contents/PkgInfo",
                                  @"Contents/MacOS/MyApp",
                                  @"Contents/MacOS",
                                  @"Contents/Info.plist",
                                  @"Contents",
                                  nil]), @"Directory content after excluding languages");
    
    files = [NSMutableArray arrayWithArray:originalFiles];
    languages = [NSArray arrayWithObjects:@"fr", nil];
    XCTAssertTrue([m normalizeLanguages:languages files:files], @"Normalize languages");
    XCTAssertEqualObjects(files, ([NSArray arrayWithObjects:
                                  @"Contents/Resources/fr.lproj/version1.rtf",
                                  @"Contents/Resources/fr.lproj/special.xml",
                                  @"Contents/Resources/fr.lproj/Unchanged.strings",
                                  @"Contents/Resources/fr.lproj/MainMenu.nib",
                                  @"Contents/Resources/fr.lproj",
                                  @"Contents/Resources/en.lproj/version1.rtf",
                                  @"Contents/Resources/en.lproj/special.xml",
                                  @"Contents/Resources/en.lproj/image.tiff",
                                  @"Contents/Resources/en.lproj/Unchanged.strings",
                                  @"Contents/Resources/en.lproj/MainMenu.nib",
                                  @"Contents/Resources/en.lproj/Localizable.strings",
                                  @"Contents/Resources/en.lproj/InfoPlist.strings",
                                  @"Contents/Resources/en.lproj/Credits.html",
                                  @"Contents/Resources/en.lproj/Complex.rtfd",
                                  @"Contents/Resources/en.lproj",
                                  @"Contents/Resources/fr.lproj/Panel.nib",
                                  @"Contents/Resources/fr.lproj/Others.strings",
                                  @"Contents/Resources/fr.lproj",
                                  @"Contents/Resources",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/fr.lproj/GCTWAINSourceWindow.nib",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/fr.lproj/GCTWAINMainMenu.nib",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/fr.lproj",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/en.lproj/GCTWAINSourceWindow.nib",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/en.lproj/GCTWAINMainMenu.nib",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/en.lproj",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/MacOS/GCTWAIN_PPC",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/MacOS",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Info.plist",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app/Contents",
                                  @"Contents/PlugIns/GCTWAIN_PPC.app",
                                  @"Contents/PlugIns",
                                  @"Contents/PkgInfo",
                                  @"Contents/MacOS/MyApp",
                                  @"Contents/MacOS",
                                  @"Contents/Info.plist",
                                  @"Contents",
                                  nil]), @"Directory content after normalizing languages");
    
    NSString *target = [@"/tmp/" stringByAppendingPathComponent:@"copy.app"];
    [target movePathToTrash];
    XCTAssertTrue([m excludeNonLocalizedFiles:files], @"Exclude non-localized files");
    XCTAssertTrue([m includeLocalizedFilesFromLanguages:[NSArray arrayWithObject:@"fr"] files:files], @"Include fr");
    XCTAssertTrue([m copyFiles:files source:source target:target errorHandler:nil], @"Copy files");
    
    NSString *expectedTarget = [self pathForResource:@"Contents/FileOperationCopyExpected.app"];
    XCTAssertTrue([[NSFileManager defaultManager] contentsEqualAtPath:target andPath:expectedTarget], @"Copy assertion");
}

- (void)testFileMergeOperationManager
{
    FileMergeOperationManager *m = [FileMergeOperationManager manager];
    
    NSString *source = [self pathForResource:@"Contents/FileOperationManager.app"];
    NSMutableArray *mergeableFiles = [NSMutableArray array];
    NSMutableArray *projectFiles = [NSMutableArray array];
    [projectFiles addObject:@"Contents/Resources/fr.lproj/version1.rtf"];
    [projectFiles addObject:@"Contents/Resources/en.lproj/InfoPlist.strings"];
    [projectFiles addObject:@"Contents/Resources/fr.lproj/anotherone.nib"];
    [projectFiles addObject:@"Contents/Resources/nonlocalized.nib"];
    [projectFiles addObject:@"Contents/MacOS/MyApp"];
    [projectFiles addObject:@"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/English.lproj/GCTWAINSourceWindow.nib"];
    [projectFiles addObject:@"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/en.lproj/GCTWAINMainMenu.nib"];
    
    // Prepare the target file on the disk
    NSError *error;
    NSString *targetRootPath = @"/private/tmp/ilocalize/";
    XCTAssertTrue([[NSFileManager defaultManager] createDirectoryAtPath:targetRootPath withIntermediateDirectories:YES attributes:Nil error:&error], @"Prepare path for copy failed because %@", error);
    
    NSString *target = [targetRootPath stringByAppendingPathComponent:@"fileopmanager.app"];
    [target movePathToTrash];
    
    XCTAssertTrue([[NSFileManager defaultManager] copyItemAtPath:[self pathForResource:@"Contents/FileOperationManagerModified.app"] toPath:target error:&error], @"Copy FileOperationManager.app to temp because %@", error);
    
    // Assert the list of mergeable files
    XCTAssertTrue([m discoverMergeableFiles:mergeableFiles inTarget:target usingProjectFiles:projectFiles projectSource:source errorHandler:nil], @"Enumerate directory");
    XCTAssertEqualObjects(mergeableFiles, ([NSArray arrayWithObjects:
                                           @"Contents/Resources/en.lproj/InfoPlist.strings",
                                           @"Contents/Resources/fr.lproj/anotherone.nib",
                                           @"Contents/Resources/nonlocalized.nib",
                                           @"Contents/PlugIns/GCTWAIN_PPC.app/Contents/Resources/en.lproj/GCTWAINMainMenu.nib",
                                           nil]), @"Mergeable content");
    
    XCTAssertTrue([targetRootPath removePathFromDisk:&error], @"Target wasn't removed because %@", error);
}

#pragma mark Misc

- (void)testExtensions
{
    NSAssert([@"/toto/tutu" isEqualToPath:@"/toto/tutu/"], @"Failed test path 1");
    NSAssert([@"/toto/tutu/" isEqualToPath:@"/toto/tutu"], @"Failed test path 2");
    NSAssert([@"/toto/tutu/" isEqualToPath:@"/toto/tutu/"], @"Failed test path 3");
    NSAssert(![@"/toto/tutu/tete" isEqualToPath:@"/toto/tutu/"], @"Failed test path 4");
}

- (void)testLanguages
{
    NSAssert([LanguageTool isLanguage:@"French" equalsToLanguage:@"French"], @"Language test 1");
    NSAssert([LanguageTool isLanguage:@"French" equalsToLanguage:@"fr"], @"Language test 2");
    NSAssert([LanguageTool isLanguage:@"fr" equalsToLanguage:@"French"], @"Language test 3");
    NSAssert([LanguageTool isLanguage:@"English" equalsToLanguage:@"en"], @"Language test 4");
    NSAssert(![LanguageTool isLanguage:@"English" equalsToLanguage:@"ja"], @"Language test 5");
    
    NSAssert([LanguageTool isLanguage:@"en_GB" equalsToLanguage:@"en-GB"], @"Language test");
    
    NSAssert([LanguageTool isLanguageCode:@"English" equivalentToLanguageCode:@"en"], @"Language test 6");
    NSAssert([LanguageTool isLanguageCode:@"English" equivalentToLanguageCode:@"English"], @"Language test 7");
    NSAssert(![LanguageTool isLanguageCode:@"English" equivalentToLanguageCode:@"French"], @"Language test 8");
    NSAssert([LanguageTool isLanguageCode:@"fr_CH" equivalentToLanguageCode:@"French"], @"Language test 9");
    NSAssert([LanguageTool isLanguageCode:@"fr_CH" equivalentToLanguageCode:@"fr"], @"Language test 10");
    NSAssert(![LanguageTool isLanguageCode:@"fr_CH" equivalentToLanguageCode:@"English"], @"Language test 11");
    NSAssert(![LanguageTool isLanguageCode:@"" equivalentToLanguageCode:@"English"], @"Language test 12");
    
    NSAssert([[LanguageTool displayNameForLanguage:@"English"] isEqualToString:@"English"], @"English");
    NSAssert([[LanguageTool displayNameForLanguage:@"en"] isEqualToString:@"English"], @"en");
    NSAssert([[LanguageTool displayNameForLanguage:@"French"] isEqualToString:@"French"], @"French");
    NSAssert([[LanguageTool displayNameForLanguage:@"fr"] isEqualToString:@"French"], @"fr");
    NSAssert([[LanguageTool displayNameForLanguage:@"fr_CH"] isEqualToString:@"French (Switzerland)"], @"fr_CH");
    NSAssert([[LanguageTool displayNameForLanguage:@"foobad"] isEqualToString:@"foobad"], @"foobad");
}

- (void)testEscapeComparaison
{
    NSAssert([StringTool isString:@"tutu" equalToString:@"tutu" ignoreEscapeDifferences:YES ignoreCase:YES], @"Failed test EscapeComparaison extension 1");
    NSAssert(![StringTool isString:@"tutu" equalToString:@"tuto" ignoreEscapeDifferences:YES ignoreCase:YES], @"Failed test EscapeComparaison extension 2");
    NSAssert([StringTool isString:@"tutu\ntoto" equalToString:@"tutu\ntoto" ignoreEscapeDifferences:YES ignoreCase:YES], @"Failed test EscapeComparaison extension 3");
    NSAssert([StringTool isString:@"tutu\ntoto" equalToString:@"tutu\\ntoto" ignoreEscapeDifferences:YES ignoreCase:YES], @"Failed test EscapeComparaison extension 4");
    NSAssert(![StringTool isString:@"tutu\ntoto" equalToString:@"tutu\\ntoto" ignoreEscapeDifferences:NO ignoreCase:YES], @"Failed test EscapeComparaison extension 5");
}

- (void)testControlChar
{
    NSAssert([StringTool isString:@"hello\\nworld" equalToString:@"hello\nworld" ignoreEscapeDifferences:YES ignoreCase:YES], @"<1>");
    NSAssert([StringTool isString:@"hello\nworld" equalToString:@"hello\\nworld" ignoreEscapeDifferences:YES ignoreCase:YES], @"<2>");
    NSAssert([StringTool isString:@"hello\nworld" equalToString:@"hello\nworLD" ignoreEscapeDifferences:YES ignoreCase:YES], @"<3>");
    NSAssert([StringTool isString:@"hello\\nworld" equalToString:@"hello\\nworLD" ignoreEscapeDifferences:YES ignoreCase:YES], @"<4>");
    
    NSAssert(![StringTool isString:@"hello\\tworld" equalToString:@"hello\\nworld" ignoreEscapeDifferences:YES ignoreCase:YES], @"<5>");
    NSAssert([StringTool isString:@"hello\nworld\n" equalToString:@"hello\\nworld\n" ignoreEscapeDifferences:YES ignoreCase:YES], @"<6>");
    NSAssert([StringTool isString:@"hello\nworld\\n" equalToString:@"hello\\nworld\n" ignoreEscapeDifferences:YES ignoreCase:YES], @"<7>");
    NSAssert([StringTool isString:@"hello\\nworld\\n" equalToString:@"hello\nworld\n" ignoreEscapeDifferences:YES ignoreCase:YES], @"<8>");
    NSAssert(![StringTool isString:@"hello\\nworld\\t" equalToString:@"hello\nworld\n" ignoreEscapeDifferences:YES ignoreCase:YES], @"<9>");
    
    NSAssert(![StringTool isString:@"hello\\nworld1" equalToString:@"hello\nworld" ignoreEscapeDifferences:YES ignoreCase:YES], @"<10>");
    NSAssert(![StringTool isString:@"hello\\nworld1" equalToString:@"hello\nworld12" ignoreEscapeDifferences:YES ignoreCase:YES], @"<11>");
    
    NSAssert(![StringTool isString:@"hello\\nworld1\\" equalToString:@"hello\nworld1" ignoreEscapeDifferences:YES ignoreCase:YES], @"<12>");
    NSAssert([StringTool isString:@"hello\\nworld1\\" equalToString:@"hello\nworld1\\" ignoreEscapeDifferences:YES ignoreCase:YES], @"<13>");
}

- (void)testEscapeString
{
    // The rule is:
    
    // - add \ before " if it is not already escaped
    // [TextView string] => [Encoding string suitable for writing to a .strings file]
    // 1. Hello World => "Hello World"
    // 2. Hello\nWorld => "Hello\nWorld"
    // 3. Hello"World => "Hello\"World" (special case because the double quote is used as delimiter)
    // 4. Hello\"World => "Hello\"World"
    // 5. Hello\World => "Hello\World"
    // 6. Hello\\World => "Hello\\World"
    // 7. Hello\\\World => "Hello\\\World"
    
    XCTAssertEqualObjects([StringTool escapeDoubleQuoteInString:@"Hello World"], @"Hello World", @"");
    XCTAssertEqualObjects([StringTool escapeDoubleQuoteInString:@"Hello\nWorld"], @"Hello\nWorld", @"");
    XCTAssertEqualObjects([StringTool escapeDoubleQuoteInString:@"Hello\"World"], @"Hello\\\"World", @"");
    XCTAssertEqualObjects([StringTool escapeDoubleQuoteInString:@"Hello\\\"World"], @"Hello\\\"World", @"");
    XCTAssertEqualObjects([StringTool escapeDoubleQuoteInString:@"Hello\\World"], @"Hello\\World", @"");
    XCTAssertEqualObjects([StringTool escapeDoubleQuoteInString:@"Hello\\\\World"], @"Hello\\\\World", @"");
    XCTAssertEqualObjects([StringTool escapeDoubleQuoteInString:@"Hello\\\\\\World"], @"Hello\\\\\\World", @"");
}

- (void)testUnescapeString
{
    XCTAssertEqualObjects([StringTool unescapeDoubleQuoteInString:@"Hello World"], @"Hello World", @"");
    XCTAssertEqualObjects([StringTool unescapeDoubleQuoteInString:@"Hello\nWorld"], @"Hello\nWorld", @"");
    XCTAssertEqualObjects([StringTool unescapeDoubleQuoteInString:@"Hello\"World"], @"Hello\"World", @"");
    XCTAssertEqualObjects([StringTool unescapeDoubleQuoteInString:@"Hello\\\"World"], @"Hello\"World", @"");
    XCTAssertEqualObjects([StringTool unescapeDoubleQuoteInString:@"Hello\\World"], @"Hello\\World", @"");
    XCTAssertEqualObjects([StringTool unescapeDoubleQuoteInString:@"Hello\\\\World"], @"Hello\\\\World", @"");
    XCTAssertEqualObjects([StringTool unescapeDoubleQuoteInString:@"Hello\\\\\\World"], @"Hello\\\\\\World", @"");
}

- (void)testRemoveDoubleQuoteString
{
    XCTAssertEqualObjects([StringTool removeDoubleQuoteInString:@"Hello World"], @"Hello World", @"");
    XCTAssertEqualObjects([StringTool removeDoubleQuoteInString:@"Hello\nWorld"], @"Hello\nWorld", @"");
    XCTAssertEqualObjects([StringTool removeDoubleQuoteInString:@"Hello\"World"], @"Hello World", @"");
    XCTAssertEqualObjects([StringTool removeDoubleQuoteInString:@"Hello\\\"World"], @"Hello World", @"");
    XCTAssertEqualObjects([StringTool removeDoubleQuoteInString:@"Hello\\World"], @"Hello\\World", @"");
    XCTAssertEqualObjects([StringTool removeDoubleQuoteInString:@"Hello\\\\World"], @"Hello\\\\World", @"");
    XCTAssertEqualObjects([StringTool removeDoubleQuoteInString:@"Hello\\\\\\World"], @"Hello\\\\\\World", @"");
}

- (void)testXMLCharacters
{
    XCTAssertTrue(![([NSString stringWithFormat:@"%C", (unichar)0x11]) containsValidXMLCharacters:nil], @"Invalid characters");
    XCTAssertTrue([([NSString stringWithFormat:@"Hello, world"]) containsValidXMLCharacters:nil], @"Valid characters");
    XCTAssertTrue([([NSString stringWithFormat:@"HELLO_WORLD"]) containsValidXMLCharacters:nil], @"Valid characters");
    XCTAssertTrue([([NSString stringWithFormat:@"<Your ﬁle E-Mail Address here>"]) containsValidXMLCharacters:nil], @"Valid characters");
}

- (void)testCompiledNib
{
    NSAssert([[self pathForResource:@"CompiledNib/compiled-flat-v3.nib"] isPathNibCompiledForIbtool], @"compiled-flat-v3.nib");
    NSAssert([[self pathForResource:@"CompiledNib/compiled-v3.nib"] isPathNibCompiledForIbtool], @"compiled-v3.nib");
    NSAssert([[self pathForResource:@"CompiledNib/compiled-v2.nib"] isPathNibCompiledForNibtool], @"compiled-v2.nib");
    NSAssert(![[self pathForResource:@"CompiledNib/non-compiled-v3.nib"] isPathNibCompiledForIbtool], @"non-compiled-v3.nib");
    NSAssert(![[self pathForResource:@"CompiledNib/non-compiled-v2.nib"] isPathNibCompiledForNibtool], @"non-compiled-v2.nib");
}

- (void)testPropagation
{
    PropagationEngine *pe = [PropagationEngine engine];
    
    // ================= first propagation ===========================
    
    SimpleStringController *source = [SimpleStringController stringWithBase:@"House" translation:@"Maison"];
    
    NSMutableArray *scs = [NSMutableArray array];
    [scs addObject:source];
    [scs addObject:[SimpleStringController stringWithBase:@"House" translation:@""]];
    [scs addObject:[SimpleStringController stringWithBase:@"House:" translation:@""]];
    [scs addObject:[SimpleStringController stringWithBase:@"House..." translation:@""]];
    [scs addObject:[SimpleStringController stringWithBase:@"House…" translation:@""]];
    [scs addObject:[SimpleStringController stringWithBase:@"House…" translation:@""]];
    [scs addObject:[SimpleStringController stringWithBase:@"House …" translation:@""]];
    [scs addObject:[SimpleStringController stringWithBase:@"House." translation:@""]];
    
    [pe propagateString:source toStrings:scs ignoreCase:NO block:nil];
    
    NSMutableArray *expected = [NSMutableArray array];
    [expected addObject:[SimpleStringController stringWithBase:@"House" translation:@"Maison"]];
    [expected addObject:[SimpleStringController stringWithBase:@"House" translation:@"Maison"]];
    [expected addObject:[SimpleStringController stringWithBase:@"House:" translation:@"Maison:"]];
    [expected addObject:[SimpleStringController stringWithBase:@"House..." translation:@"Maison..."]];
    [expected addObject:[SimpleStringController stringWithBase:@"House…" translation:@"Maison…"]];
    [expected addObject:[SimpleStringController stringWithBase:@"House…" translation:@"Maison…"]];
    // not translated because the root doesn't match (white space)
    [expected addObject:[SimpleStringController stringWithBase:@"House …" translation:@""]];
    // not translated because the root doesn't match (dot)
    [expected addObject:[SimpleStringController stringWithBase:@"House." translation:@""]];
    
    XCTAssertEqualObjects(scs, expected, @"First propagation");
    
    
    // ================= second propagation ===========================
    
    source.base = @"House…";
    source.translation = @"Immeuble…";
    
    [pe propagateString:source toStrings:scs ignoreCase:NO block:nil];
    
    [expected removeAllObjects];
    [expected addObject:[SimpleStringController stringWithBase:@"House…" translation:@"Immeuble…"]];
    [expected addObject:[SimpleStringController stringWithBase:@"House" translation:@"Immeuble"]];
    [expected addObject:[SimpleStringController stringWithBase:@"House:" translation:@"Immeuble:"]];
    [expected addObject:[SimpleStringController stringWithBase:@"House..." translation:@"Immeuble..."]];
    [expected addObject:[SimpleStringController stringWithBase:@"House…" translation:@"Immeuble…"]];
    [expected addObject:[SimpleStringController stringWithBase:@"House…" translation:@"Immeuble…"]];
    // not translated because the root doesn't match (white space)
    [expected addObject:[SimpleStringController stringWithBase:@"House …" translation:@""]];
    // not translated because the root doesn't match (dot)
    [expected addObject:[SimpleStringController stringWithBase:@"House." translation:@""]];
    
    XCTAssertEqualObjects(scs, expected, @"Second propagation");
    
    // ================= third propagation ===========================
    
    source.base = @"House…";
    source.translation = @"Immeuble …";
    
    [pe propagateString:source toStrings:scs ignoreCase:NO block:nil];
    
    [expected removeAllObjects];
    [expected addObject:[SimpleStringController stringWithBase:@"House…" translation:@"Immeuble …"]];
    [expected addObject:[SimpleStringController stringWithBase:@"House" translation:@"Immeuble"]];
    [expected addObject:[SimpleStringController stringWithBase:@"House:" translation:@"Immeuble:"]];
    [expected addObject:[SimpleStringController stringWithBase:@"House..." translation:@"Immeuble..."]];
    [expected addObject:[SimpleStringController stringWithBase:@"House…" translation:@"Immeuble …"]];
    [expected addObject:[SimpleStringController stringWithBase:@"House…" translation:@"Immeuble …"]];
    // not translated because the root doesn't match (white space)
    [expected addObject:[SimpleStringController stringWithBase:@"House …" translation:@""]];
    // not translated because the root doesn't match (dot)
    [expected addObject:[SimpleStringController stringWithBase:@"House." translation:@""]];
    
    XCTAssertEqualObjects(scs, expected, @"Third propagation");
    
    // ================= fourth propagation ===========================
    
    source.base = @"Decrypting… Estimated time remaining: %@";
    source.translation = @"Décryptage en cours… Temps restant: %@";
    
    [scs removeAllObjects];
    [scs addObject:source];
    [scs addObject:[SimpleStringController stringWithBase:@"Decrypting… Estimated time remaining: %@" translation:@""]];
    [scs addObject:[SimpleStringController stringWithBase:@"Decrypting. Estimated time remaining: %@" translation:@""]];
    [scs addObject:[SimpleStringController stringWithBase:@"Decrypting: Estimated time remaining: %@" translation:@""]];
    [scs addObject:[SimpleStringController stringWithBase:@"Decrypting... Estimated time remaining: %@" translation:@""]];
    [scs addObject:[SimpleStringController stringWithBase:@"Decrypting. Estimated time remaining: %@" translation:@""]];
    
    [pe propagateString:source toStrings:scs ignoreCase:NO block:nil];
    
    [expected removeAllObjects];
    [expected addObject:[SimpleStringController stringWithBase:@"Decrypting… Estimated time remaining: %@" translation:@"Décryptage en cours… Temps restant: %@"]];
    [expected addObject:[SimpleStringController stringWithBase:@"Decrypting… Estimated time remaining: %@" translation:@"Décryptage en cours… Temps restant: %@"]];
    [expected addObject:[SimpleStringController stringWithBase:@"Decrypting. Estimated time remaining: %@" translation:@""]];
    [expected addObject:[SimpleStringController stringWithBase:@"Decrypting: Estimated time remaining: %@" translation:@""]];
    [expected addObject:[SimpleStringController stringWithBase:@"Decrypting... Estimated time remaining: %@" translation:@""]];
    [expected addObject:[SimpleStringController stringWithBase:@"Decrypting. Estimated time remaining: %@" translation:@""]];
    
    XCTAssertEqualObjects(scs, expected, @"Fourth propagation");    
}

- (void)testFindReplace {
    NSValue *r1 = [NSValue valueWithRange:NSMakeRange(5, 3)];
    NSValue *r2 = [NSValue valueWithRange:NSMakeRange(16, 3)];
    NSValue *r3 = [NSValue valueWithRange:NSMakeRange(29, 3)];
    
    FindContentMatching *fcm = [[FindContentMatching alloc] init];
    [fcm addRanges:@[r1, r3, r2] item:0];
    
    NSArray *sortedRanges = [fcm rangesForItem:0];
    NSArray *expected = @[r3, r2, r1];
    XCTAssertEqualObjects(expected, sortedRanges, @"Reverse sorted range");
}

@end
