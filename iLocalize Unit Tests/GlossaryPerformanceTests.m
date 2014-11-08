//
//  GlossaryPerformanceTests.m
//  iLocalize
//
//  Created by Jean Bovet on 11/27/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import "AbstractTests.h"
#import "AppleGlotImporter.h"
#import "TMXImporter.h"

@interface GlossaryPerformanceTests : AbstractTests

@end

@implementation GlossaryPerformanceTests

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

// Timing: 32s, 31s
- (void)disabled_testPerformance
{
    NSString *directory = @"/Users/bovet/Downloads/iLocalize Testing/Glossaries/FU-French-fr/";
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
    XCTAssertNotNil(files, @"Error retrieving files: %@", error);

    for (NSUInteger index=0; index<2; index++) {
        for (NSString *file in files) {
            AppleGlotImporter *importer = [[AppleGlotImporter alloc] init];
            NSString *path = [directory stringByAppendingPathComponent:file];
            XCTAssertTrue([importer importDocument:[NSURL fileURLWithPath:path] error:nil], @"Import AppleGlot");
        }
    }
}

- (void)testTMXCanImportDocument {
    NSString *tmxFile = [self pathForResource:@"AZXMLParser/glossary/tmx.xml"];
    
    NSTimeInterval regularTime = [self measureExecutionTime:^{
        TMXImporter *importer = [[TMXImporter alloc] init];
        XCTAssertTrue([importer canImportDocument:[NSURL fileURLWithPath:tmxFile] error:nil], @"Import failed");
    }];

    NSTimeInterval fastTime = [self measureExecutionTime:^{
        TMXImporter *importer = [[TMXImporter alloc] init];
        importer.useFastXMLParser = YES;
        XCTAssertTrue([importer canImportDocument:[NSURL fileURLWithPath:tmxFile] error:nil], @"Import failed");
    }];

    NSLog(@"** CanImportDocument: f=%f, s=%f, gain is %f", fastTime, regularTime, regularTime/fastTime);
}

- (void)testTMXImportDocument {
    NSString *tmxFile = [self pathForResource:@"AZXMLParser/glossary/tmx.xml"];
    
    NSTimeInterval regularTime = [self measureExecutionTime:^{
        TMXImporter *importer = [[TMXImporter alloc] init];
        XCTAssertTrue([importer importDocument:[NSURL fileURLWithPath:tmxFile] error:nil], @"Import failed");
    }];
    
    NSTimeInterval fastTime = [self measureExecutionTime:^{
        TMXImporter *importer = [[TMXImporter alloc] init];
        importer.useFastXMLParser = YES;
        XCTAssertTrue([importer importDocument:[NSURL fileURLWithPath:tmxFile] error:nil], @"Import failed");
    }];
    
    NSLog(@"** ImportDocument: f=%f, s=%f, gain is %f", fastTime, regularTime, regularTime/fastTime);
}

@end
