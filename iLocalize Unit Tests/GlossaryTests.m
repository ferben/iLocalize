//
//  iLocalize_Unit_Tests.m
//  iLocalize Unit Tests
//
//  Created by Jean Bovet on 11/16/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Glossary.h"
#import "GlossaryFolder.h"
#import "GlossaryManager.h"
#import "GlossaryEntry.h"

#import "AZOrderedDictionary.h"

#import "AbstractTests.h"

@interface GlossaryTests : AbstractTests

@end

@implementation GlossaryTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (NSString*)seiResourceDirectory
{
    return [self pathForResource:@"SEI"];
}

- (NSSet*)remainingPathsFromArray:(NSArray*)a minusSet:(NSSet*)b {
    NSMutableSet *remaining = [NSMutableSet set];
    for (NSString *path in b) {
        [remaining removeObject:path];
        [remaining removeObject:[[NSURL fileURLWithPath:path] absoluteString]];
    }
    return remaining;
}

- (void)testIsRunning
{
    XCTAssertTrue(IsTestRunning(), @"Running test should be marked as such");
}

static BOOL IsPathEqualsTo(NSString *a, NSString *b) {
    NSURL *urlA = [[NSURL fileURLWithPath:a] URLByResolvingSymlinksInPath];
    NSURL *urlB = [[NSURL fileURLWithPath:b] URLByResolvingSymlinksInPath];
    return [[urlA path] isEqualToString:[urlB path]];
}

- (void)testGlossaryManager
{
	GlossaryFolder *folder = [[GlossaryFolder alloc] init];
	folder.path = [self seiResourceDirectory];
    
    // Remove the "new-file.xml" if it exists already on the disk
    NSString *newFile = [folder.path stringByAppendingPathComponent:@"new-file.xml"];
    [newFile removePathFromDisk];
    
	GlossaryManager *m = [GlossaryManager sharedInstance];
	[m addFolder:folder immediately:YES];
	[m reload:YES];
    
	NSMutableSet *expectedSet = [NSMutableSet set];
	NSString *badPath = [folder.path stringByAppendingPathComponent:@"XLIFF/sample-bad.xml"];
	NSString *goodPath = [folder.path stringByAppendingPathComponent:@"XLIFF/sample.xml"];
	[expectedSet addObject:[folder.path stringByAppendingPathComponent:@"TMX/sample-glossary-empty.xml"]];
	[expectedSet addObject:[folder.path stringByAppendingPathComponent:@"TMX/sample-glossary.xml"]];
	[expectedSet addObject:[folder.path stringByAppendingPathComponent:@"TMX/sample.xml"]];
	[expectedSet addObject:[folder.path stringByAppendingPathComponent:@"TXML/sample.xml"]];
	[expectedSet addObject:[folder.path stringByAppendingPathComponent:@"TXML/linebreak-escape.xml"]];
	[expectedSet addObject:[folder.path stringByAppendingPathComponent:@"TXML/linebreak-sample.txt"]];
	[expectedSet addObject:[folder.path stringByAppendingPathComponent:@"strings/sample.strings"]];
	[expectedSet addObject:[folder.path stringByAppendingPathComponent:@"ilg/sample.ilg"]];
	[expectedSet addObject:[folder.path stringByAppendingPathComponent:@"AppleGlot/sample.ad"]];
	[expectedSet addObject:badPath];
	[expectedSet addObject:goodPath];
	
    {
        NSSet *remaining = [self remainingPathsFromArray:[folder.glossaryMap allKeys] minusSet:expectedSet];
        XCTAssertEqual(remaining.count, (NSUInteger)0, @"Unexpected remaining glossaries: %@", remaining);
    }
	
	// Load all the entries
	for(Glossary *g in [folder glossaries]) {
		XCTAssertFalse([g entriesLoaded], @"Entries not loaded 1");
		[g entries];
		XCTAssertTrue([g entriesLoaded], @"Entries loaded 1");
	}
	
	// Reload and check that nothing has changed
	[m reload:YES];
    
    {
        NSSet *remaining = [self remainingPathsFromArray:[folder.glossaryMap allKeys] minusSet:expectedSet];
        XCTAssertEqual(remaining.count, (NSUInteger)0, @"Unexpected remaining glossaries: %@", remaining);
    }

	for(Glossary *g in [folder glossaries]) {
		XCTAssertTrue([g entriesLoaded], @"Entries loaded 2: %@", g.file);
	}
	
	// Remove and add a new file
	[badPath removePathFromDisk];
    
	NSStringEncoding encoding;
	NSString *content = [NSString stringWithContentsOfFile:goodPath usedEncoding:&encoding error:nil];
	XCTAssertTrue([content writeToFile:newFile atomically:NO encoding:encoding error:nil], @"Write new content");
    
	[expectedSet removeObject:badPath];
	[expectedSet addObject:newFile];
    
	[m reload:YES];
    
    {
        NSSet *remaining = [self remainingPathsFromArray:[folder.glossaryMap allKeys] minusSet:expectedSet];
        XCTAssertEqual(remaining.count, (NSUInteger)0, @"Unexpected remaining glossaries: %@", remaining);
    }

	for(Glossary *g in [folder glossaries]) {
		if(IsPathEqualsTo(g.file, newFile)) {
			XCTAssertFalse([g entriesLoaded], @"Entries not loaded 3");
			[g entries];
			XCTAssertTrue([g entriesLoaded], @"Entries loaded 3");
		} else {
			XCTAssertTrue([g entriesLoaded], @"Entries not loaded 3b: %@", g.file);
		}
	}
    
	// Modify a new file and see if it is detected
    
	// wait one second so the date modification will be different
	[NSThread sleepForTimeInterval:1];
	content = [NSString stringWithContentsOfFile:newFile usedEncoding:&encoding error:nil];
	[newFile removePathFromDisk];
	XCTAssertTrue(([content writeToFile:newFile atomically:NO encoding:encoding error:nil]), @"Write new content");
	
	[m reload:YES];
    {
        NSSet *remaining = [self remainingPathsFromArray:[folder.glossaryMap allKeys] minusSet:expectedSet];
        XCTAssertEqual(remaining.count, (NSUInteger)0, @"Unexpected remaining glossaries: %@", remaining);
    }
	for(Glossary *g in [folder glossaries]) {
		if(IsPathEqualsTo(g.file, newFile)) {
			// this new file needs to be reloaded because its content has changed on the disk
			XCTAssertFalse([g entriesLoaded], @"Entries not loaded 4");
			[g entries];
			XCTAssertTrue([g entriesLoaded], @"Entries loaded 4");
		} else {
			XCTAssertTrue([g entriesLoaded], @"Entries loaded 4b: %@", g.file);
		}
	}
	
	// Reload again to check that nothing has changed
	[m reload:YES];
    {
        NSSet *remaining = [self remainingPathsFromArray:[folder.glossaryMap allKeys] minusSet:expectedSet];
        XCTAssertEqual(remaining.count, (NSUInteger)0, @"Unexpected remaining glossaries: %@", remaining);
    }
	for(Glossary *g in [folder glossaries]) {
		XCTAssertTrue([g entriesLoaded], @"Entries loaded 5: %@", g.file);
	}
	
	// Now check for some entries
	BOOL tested = NO;
	for(Glossary *g in [folder glossaries]) {
		if([g.file hasSuffix:@"XLIFF/sample.xml"]) {
			tested = YES;
			XCTAssertEqual((NSUInteger)3, g.entries.count, @"Number of entries");
			
			GlossaryEntry *e1 = [g.entries objectAtIndex:0];
			XCTAssertEqualObjects(e1.source, @"Main Window", @"First entry source");
			XCTAssertEqualObjects(e1.translation, @"Fenetre \"principale\"", @"First entry translation");
            
			GlossaryEntry *e2 = [g.entries objectAtIndex:1];
			XCTAssertEqualObjects(e2.source, @"Choose", @"Second entry source");
			XCTAssertEqualObjects(e2.translation, @"Choisir", @"Second entry translation");
		}
	}
	XCTAssertTrue(tested, @"Tested entries");
}

@end
