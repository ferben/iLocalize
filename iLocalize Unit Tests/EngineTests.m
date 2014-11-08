//
//  EngineTests.m
//  iLocalize
//
//  Created by Jean Bovet on 11/24/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FileTool.h"
#import "StringTool.h"
#import "LanguageTool.h"
#import "NibEngine.h"
#import "StringsEngine.h"
#import "CheckEngine.h"
#import "FileModel.h"
#import "StringsContentModel.h"
#import "FMEngineNib.h"
#import "StringEncodingTool.h"
#import "HTMLEncodingTool.h"
#import "Glossary.h"
#import "Constants.h"
#import "Utils.h"
#import "StringEncoding.h"
#import "CmdLineProjectProvider.h"
#import "ConsoleItem.h"
#import "StringModel.h"
#import "AbstractTests.h"

@interface EngineTests : AbstractTests

@property (nonatomic, strong) id<ProjectProvider> projectProvider;

@end

@implementation EngineTests

- (void)setUp
{
    self.projectProvider = [[CmdLineProjectProvider alloc] init];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"consoleDisplayUsingNSLog"];
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"outputnibcommand"];
	[[NSUserDefaults standardUserDefaults] setObject:[self ibtoolPath] forKey:@"ibtoolPath"];
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (NSString*)resourcePathWithName:(NSString*)path {
    return [[self pathForResource:@"NibEngine"] stringByAppendingPathComponent:path];
}

/**
 Test the error output parsing if NibEngine with ibtool.
 */
- (void)testErrorOuput
{
	Console *c = [self.projectProvider console];
	NibEngine *engine = [NibEngine engineWithConsole:c];
	
	{
		[c mark];
		NSString *badFile = [self resourcePathWithName:@"NibFiles/BadFile.nib"];
		NSString *strings = [engine stringsOfNibFile:badFile];
		XCTAssertNil(strings, @"No strings");
		XCTAssertEqual((int)[[c allItemsSinceMark] count], 1, @"One error reported");
		ConsoleItem *item = [[c allItemsSinceMark] firstObject];
		XCTAssertTrue([[item description] hasPrefix:@"description: The document \"BadFile.nib\" could not be opened. Interface Builder cannot open compiled nibs.\nrecovery-suggestion: Try opening the source document instead of the compiled nib.\nStatus: 1\nArguments:"], @"Error message");
	}
	
	{
		[c mark];
		NSString *normalFile = [self resourcePathWithName:@"NibFiles/ProjectBrowser.nib"];
		NSString *strings = [engine stringsOfNibFile:normalFile];
		XCTAssertNotNil(strings, @"Strings");
		XCTAssertEqual((int)[[c allItemsSinceMark] count], 0, @"No error reported");
	}
}

- (void)testStringsOfNibFile
{
	NibEngine *engine = [NibEngine engineWithConsole:[self.projectProvider console]];
	
	NSString *englishStrings = [self resourcePathWithName:@"TranslateOnly/english.strings"];
	NSString *frenchStrings = [self resourcePathWithName:@"TranslateOnly/french.strings"];
	NSString *englishNibFile = [self resourcePathWithName:@"TranslateOnly/English.nib"];
	NSString *frenchNibFile = [self resourcePathWithName:@"TranslateOnly/French.nib"];
	
	StringsContentModel *expected = [engine parseStringModelsFromText:[NSString stringWithContentsOfFile:englishStrings usedEncoding:nil error:nil]];
	StringsContentModel *actual = [engine parseStringModelsOfNibFile:englishNibFile];
	
	XCTAssertEqualObjects(actual, expected, @"testStringsOfNibFile 1");
	
	expected = [engine parseStringModelsFromText:[NSString stringWithContentsOfFile:englishStrings usedEncoding:nil error:nil]];
	actual = [engine parseStringModelsOfNibFile:frenchNibFile];
	XCTAssertFalse([actual isEqual:expected], @"testStringsOfNibFile 2");
	
	expected = [engine parseStringModelsFromText:[NSString stringWithContentsOfFile:frenchStrings usedEncoding:nil error:nil]];
	actual = [engine parseStringModelsOfNibFile:frenchNibFile];
	XCTAssertEqualObjects(actual, expected, @"testStringsOfNibFile 3");
}

- (void)disabled_testTranslateNibFileUsingStringFile
{
	// ibtool --strings-file french.strings English.nib --write Output.nib
	
	NibEngine *engine = [NibEngine engineWithConsole:[self.projectProvider console]];
	
	NSString *frenchStrings = [self resourcePathWithName:@"TranslateOnly/french.strings"];
	NSString *englishNibFile = [self resourcePathWithName:@"TranslateOnly/English.nib"];
	//	NSString *frenchNibFile = [self resourcePathWithName:@"TranslateOnly/French.nib"];
	NSString *translatedNibFile = [self resourcePathWithName:@"TranslateOnly/Output.nib"];
	
	NSString *tempFile = [FileTool generateTemporaryFileNameWithExtension:@"nib"];
	NSAssert([[NSFileManager defaultManager] copyItemAtPath:englishNibFile toPath:tempFile error:nil], @"testTranslateNibFileUsingStringFile 1");
	
	[engine translateNibFile:tempFile usingStringFile:frenchStrings];
	
	NSAssert([self contentOfFile:translatedNibFile equalsFile:tempFile], @"testTranslateNibFileUsingStringFile 2");
}

- (void)disabled_testTranslateNibFileUsingStringFileAndLayout
{
	// nibtool TranslatedLayout.nib -O -r -I French.nib -d french.strings
	// ibtool --previous-file English.nib --incremental-file French.nib --localize-incremental --strings-file french.strings --write Output.nib	English.nib
	
	NibEngine *engine = [NibEngine engineWithConsole:[self.projectProvider console]];
	
	NSString *englishNibFile = [self resourcePathWithName:@"TranslateAndLayout/English.nib"];
	NSString *frenchNibFile = [self resourcePathWithName:@"TranslateAndLayout/French.nib"];
	NSString *frenchStringsFile = [self resourcePathWithName:@"TranslateAndLayout/french.strings"];
	NSString *outputNibFile = [self resourcePathWithName:@"TranslateAndLayout/Output.nib"];
	
	NSString *tempFile = [FileTool generateTemporaryFileNameWithExtension:@"nib"];
	NSAssert([[NSFileManager defaultManager] copyItemAtPath:englishNibFile toPath:tempFile error:nil], @"testTranslateNibFileUsingStringFileAndLayout 1");
	
	[engine translateNibFile:tempFile usingLayoutFromNibFile:frenchNibFile usingStringFile:frenchStringsFile];
    
	NSAssert([self contentOfFile:outputNibFile equalsFile:tempFile], @"testTranslateNibFileUsingStringFileAndLayout 2");
	
	[tempFile removePathFromDisk];
}

#pragma mark StringsEngine

- (void)assertStringModels:(StringsContentModel*)sms withVerifyFile:(NSString*)verify
{
    NSMutableString *answer = [NSMutableString string];
    NSEnumerator *enumerator = [sms stringsEnumerator];
    StringModel *sm;
    while((sm = [enumerator nextObject])) {
        [answer appendFormat:@"\"%@\" = \"%@\" = \"%@\"\n", [sm key], [sm value], [sm comment]];
    }
	
    NSData *data = [NSData dataWithContentsOfFile:verify];
	NSAssert(data != nil, @"Verify data is null");
	
    NSString *target = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if([answer isEqualToString:target])
        return;
	
    unsigned index;
    for(index = 0; index < MIN([answer length], [target length]); index++) {
        unichar a = [answer characterAtIndex:index];
        unichar t = [target characterAtIndex:index];
        if(a != t) {
			NSLog(@"--------------- Actual:\n%@", answer);
			NSLog(@"--------------- Verify:\n%@", target);
            NSLog(@"Answer = {%@}", [answer substringWithRange:NSMakeRange(index-20, 40)]);
            NSLog(@"Target = {%@}", [target substringWithRange:NSMakeRange(index-20, 40)]);
        }
        NSAssert(a == t, @"%@", [NSString stringWithFormat:@"Strings test failed! At index = %d, answer = '%C' (%d) and target = '%C' (%d)", index, a, a, t, t]);
    }
}

- (void)assertEncodeStringModels:(StringsContentModel*)sms format:(NSUInteger)format verify:(NSString*)verify
{
    StringsEngine *engine = [StringsEngine engineWithConsole:nil];
	NSString *encoded = [engine encodeStringModels:sms baseStringModels:sms skipEmpty:NO format:format encoding:ENCODING_UTF8];
	NSString *verifyString = [NSString stringWithContentsOfFile:verify encoding:NSUTF8StringEncoding error:nil];
	if([encoded isEqualToString:verifyString]) return;
	
    unsigned index;
    for(index = 0; index < MIN([encoded length], [verifyString length]); index++) {
        unichar a = [encoded characterAtIndex:index];
        unichar t = [verifyString characterAtIndex:index];
        if(a != t) {
			NSLog(@"--------------- Encoded:\n%@", encoded);
			NSLog(@"--------------- Verify:\n%@", verifyString);
            NSLog(@"Mismatch around {{%@}}", [encoded substringWithRange:NSMakeRange(index-10, 15)]);
        }
        NSAssert(a == t, @"%@", ([NSString stringWithFormat:@"Strings test failed! At index = %d, answer = '%C' (%d) and target = '%C' (%d)", index, a, a, t, t]));
    }
}

- (void)assertSource:(NSString*)source verify:(NSString*)verify encoded:(NSString*)encoded format:(NSUInteger)format
{
    StringsEngine *engine = [StringsEngine engineWithConsole:nil];
	StringsContentModel *sms = [engine parseStringModelsOfStringsFile:[self pathForResource:source]];
	NSAssert(sms != nil, @"StringModels are null");
	
	NSAssert([engine format] == format, @"Format does not match (expecting %lu but got %lu)", format, (unsigned long)[engine format]);
	
	[self assertStringModels:sms
			  withVerifyFile:[self pathForResource:verify]];
	
	[self assertEncodeStringModels:sms
							format:format
							verify:[self pathForResource:encoded]];
}

- (void)testStringsFormat
{
	[self assertSource:@"StringsFormat/apple.strings"
				verify:@"StringsFormat/apple-verify.strings"
			   encoded:@"StringsFormat/apple-encoded.strings"
				format:STRINGS_FORMAT_APPLE_STRINGS];
	
	[self assertSource:@"StringsFormat/apple-xml.strings"
				verify:@"StringsFormat/apple-xml-verify.strings"
			   encoded:@"StringsFormat/apple-xml.strings"
				format:STRINGS_FORMAT_APPLE_XML];
	
	[self assertSource:@"StringsFormat/abvent-xml.strings"
				verify:@"StringsFormat/abvent-xml-verify.strings"
			   encoded:@"StringsFormat/abvent-xml.strings"
				format:STRINGS_FORMAT_ABVENT_XML];
}

- (void)testCheckEngine
{
	CheckEngine *engine = [[CheckEngine alloc] init];
	/*NSLog(@"%@", [engine parseFormattingCharacters:@"This is a %@ with %3.2f and %i."]);
	 NSLog(@"%@", [engine parseFormattingCharacters:@"This is a %3.2f with %@ and %i."]);
	 NSLog(@"%@", [engine parseFormattingCharacters:@"This is a %2$3.2f with %1$@ and %3$i."]);
	 NSLog(@"%@", [engine parseFormattingCharacters:@"This is a %@ with %i and %3.2f."]);
	 NSLog(@"%@", [engine parseFormattingCharacters:@"This is a %@ with %1 and %2."]);
	 NSLog(@"%@", [engine parseFormattingCharacters:@"This is a %@ with %1 and %2, %3."]);
	 NSLog(@"%@", [engine parseFormattingCharacters:@"Released %1 %2, %3"]);
	 NSLog(@"%@", [engine parseFormattingCharacters:@"Développé %2 %1, %3"]);
	 NSLog(@"%@", [engine parseFormattingCharacters:@"This is a %@ with %1 and %2.3f and %4.2d"]);*/
	
	//	NSLog(@"%@", [engine parseFormattingCharacters:@"%0A%0AIf%20you%20report%20a%20crash%2C%20please%20attach%20the%20crash%20log%20found%20in%20%3CHome%3E/Library/Logs/CrashReporter/SubEthaEdit.crash.log.%0A%0A"]);
	
    XCTAssertFalse([engine checkFormattingCharactersOfBaseString:@"%1$@"
                                                 localizedString:@"%@"], @"<test a>");
    
    XCTAssertTrue([engine checkFormattingCharactersOfBaseString:@"%1$@"
                                                localizedString:@"%1$@"], @"<test a>");
    
    XCTAssertFalse([engine checkFormattingCharactersOfBaseString:@"%2$l %1$@"
                                                 localizedString:@"%@ %l"], @"<test b>");
    
    XCTAssertTrue([engine checkFormattingCharactersOfBaseString:@"%2$l %1$@"
                                                localizedString:@"%1$@ %2$l"], @"<test b>");
    
    
    XCTAssertFalse([engine checkFormattingCharactersOfBaseString:@"%l"
                                                 localizedString:@""], @"<test c>");
    
	XCTAssertFalse([engine checkFormattingCharactersOfBaseString:@"This is a %@ with %3.2f and %i."
                                                 localizedString:@"This is a %2$3.2f with %1$@ and %3$i."], @"<test 1>");

    XCTAssertTrue([engine checkFormattingCharactersOfBaseString:@"This is a %1$@ with %2$3.2f and %3$i."
                                                localizedString:@"This is a %2$3.2f with %1$@ and %3$i."], @"<test 1>");

    XCTAssertFalse([engine checkFormattingCharactersOfBaseString:@"This is a %2$@ with %1$3.2f and %3$i."
                                                 localizedString:@"This is a %2$3.2f with %1$@ and %3$i."], @"<test 1>");

	XCTAssertTrue([engine checkFormattingCharactersOfBaseString:@"Released %1$%@ %2$%@, %3$%2f"
                                                localizedString:@"Developpe %2$%@ %1$%@, %3$%2f."], @"<test 2>");
	
	XCTAssertTrue([engine checkFormattingCharactersOfBaseString:@"Released %1$%@ %2$%@, %3$%@"
                                                localizedString:@"Developpe %2$%@ %1$%@, %3$%@"], @"<test 2'>");
	
	XCTAssertFalse([engine checkFormattingCharactersOfBaseString:@"This is a %@ with %i and %3.2f."
                                                 localizedString:@"This is a %2$3.2f with %1$@ and %3$i."], @"<test 3>");
	
	XCTAssertFalse([engine checkFormattingCharactersOfBaseString:@"This is a %@ with %3.2f and %d."
                                                 localizedString:@"This is a %2$3.2f with %1$@ and %3$i."], @"<test 4>");
	
	XCTAssertFalse([engine checkFormattingCharactersOfBaseString:@"Released %1$%@ %2$%@, %3$%2f"
                                                 localizedString:@"Developpe %2$%2f %1$%@, %3$%@."], @"<test 5>");
	
	XCTAssertTrue([engine checkFormattingCharactersOfBaseString:@"Are you sure you want to delete the \"%1$@\" %2$@%3$@?"
                                                localizedString:@"Sind Sie sicher, dass Sie den %2$@ \"%1$@\" %3$@ loeschen wollen?"], @"<test 6>");
	
	XCTAssertTrue([engine checkFormattingCharactersOfBaseString:@"Are you sure you want to delete the \"%1$@\" %2$@ %3$@?"
                                                localizedString:@"Sind Sie sicher, dass Sie den %2$@ \"%1$@\" %3$@ loeschen wollen?"], @"<test 7>");
	
	NSString *localizedString = [NSString stringWithContentsOfFile:[self pathForResource:@"Contents/HistoryBulgarian.txt"] encoding:NSUTF8StringEncoding error:nil];
	XCTAssertTrue([engine checkFormattingCharactersOfBaseString:@"History"
                                                localizedString:localizedString], @"<test 8>");
}


@end
