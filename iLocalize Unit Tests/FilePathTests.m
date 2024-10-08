//
//  FilePathTests.m
//  iLocalize
//
//  Created by Jean Bovet on 11/24/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AZPathNode.h"
#import "ScanBundleOp.h"
#import "AbstractTests.h"

@interface FilePathTests : AbstractTests

@end

@implementation FilePathTests

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

- (void)assertNode:(AZPathNode*)root
          location:(NSString*)location
              name:(NSString*)name
     childrenCount:(NSUInteger)count
 containsLanguages:(BOOL)containsLanguages
          language:(NSString*)language
       displayable:(BOOL)displayable
{
    AZPathNode *node;
    if(displayable) {
        node = [root displayableChildAtLocation:location];
    } else {
        node = [root childAtLocation:location];
    }
    XCTAssertEqualObjects(node.name, name, @"");
    if(displayable) {
        XCTAssertEqual([node displayableChildren].count, count, @"");
    } else {
        XCTAssertEqual([node children].count, count, @"");
    }
    XCTAssertEqual(node.containsLanguages, containsLanguages, @"");
    XCTAssertEqualObjects(node.language, language, @"");
}

- (void)assertNode:(AZPathNode*)node
          location:(NSString*)location
              name:(NSString*)name
     childrenCount:(NSInteger)count
 containsLanguages:(BOOL)containsLanguages
          language:(NSString*)language
{
    [self assertNode:node location:location name:name childrenCount:count containsLanguages:containsLanguages language:language displayable:NO];
    [self assertNode:node location:location name:name childrenCount:count containsLanguages:containsLanguages language:language displayable:YES];
}

- (void)assertNode:(AZPathNode*)node
          location:(NSString*)location
              name:(NSString*)name
     childrenCount:(NSInteger)count
       displayable:(BOOL)displayable
{
    [self assertNode:node location:location name:name childrenCount:count containsLanguages:NO language:nil displayable:displayable];
}

- (void)assertNode:(AZPathNode*)node
          location:(NSString*)location
              name:(NSString*)name
     childrenCount:(NSInteger)count
{
    [self assertNode:node location:location name:name childrenCount:count containsLanguages:NO language:nil displayable:NO];
    [self assertNode:node location:location name:name childrenCount:count containsLanguages:NO language:nil displayable:YES];
}

- (void)testPathNode
{
    AZPathNode *root = [AZPathNode rootNodeWithPath:@"/Users/bovet/Test.app/"];
    XCTAssertEqualObjects(root.rootPath, @"/Users/bovet/Test.app/", @"Root path");
    [self assertNode:root location:nil name:@"Test.app" childrenCount:0];
    
    [root addRelativePath:@"/Contents/Resources/French.lproj/MainMenu.nib"];
    
    [self assertNode:root location:nil name:@"Test.app" childrenCount:1];
    
    [self assertNode:root location:@"0" name:@"Contents" childrenCount:1];
    [self assertNode:root location:@"0,0" name:@"Resources" childrenCount:1];
    [self assertNode:root location:@"0,0,0" name:@"French.lproj" childrenCount:1];
    [self assertNode:root location:@"0,0,0,0" name:@"MainMenu.nib" childrenCount:0];
    
    [root addRelativePath:@"/Contents/Resources/English.lproj/MainMenu.nib"];
    [root addRelativePath:@"/Contents/Resources/English.lproj/Localizable.strings"];
    
    [self assertNode:root location:@"0" name:@"Contents" childrenCount:1];
    [self assertNode:root location:@"0,0" name:@"Resources" childrenCount:2];
    [self assertNode:root location:@"0,0,0" name:@"English.lproj" childrenCount:2];
    [self assertNode:root location:@"0,0,0,0" name:@"Localizable.strings" childrenCount:0];
    [self assertNode:root location:@"0,0,0,1" name:@"MainMenu.nib" childrenCount:0];
    [self assertNode:root location:@"0,0,1" name:@"French.lproj" childrenCount:1];
    [self assertNode:root location:@"0,0,1,0" name:@"MainMenu.nib" childrenCount:0];
}

- (void)testFilterBundleOperation
{
    ScanBundleOp *op = [[ScanBundleOp alloc] init];
    op.path = [self pathForResource:@"Contents/FilterBundle.app"];
    [op execute];
    
    [op.node setUseLanguagePlaceholder:NO]; // Because ScanBundleOp set it to YES
    
    /*
     Expected hierarchy:
     FilterBundle.app
     +- Contents
     ...+- Info.plist
     ...+- MacOS
     ......+- MyApp
     ...+- PkgInfo
     ...+- Resources
     ......+- en.lproj (9 files)
     ......+- fr.lproj (4 files)
     ......+- French.lproj (2 files)
     ......+- Helper (2 files)
     .........+- English.lproj
     ............+- InfoPlist.strings
     ............+- Localizable.strings
     .........+- Helper.strings
     */
    
    AZPathNode *root = op.node;
    [self assertNode:root location:nil name:@"FilterBundle.app" childrenCount:1 containsLanguages:YES language:nil];
    [self assertNode:root location:@"0" name:@"Contents" childrenCount:4 containsLanguages:YES language:nil];
    
    [self assertNode:root location:@"0,0" name:@"Info.plist" childrenCount:0];
    [self assertNode:root location:@"0,1" name:@"MacOS" childrenCount:1];
    [self assertNode:root location:@"0,1,0" name:@"MyApp" childrenCount:0];
    [self assertNode:root location:@"0,2" name:@"PkgInfo" childrenCount:0];
    
    [self assertNode:root location:@"0,3" name:@"Resources" childrenCount:4 containsLanguages:YES language:nil];
    [self assertNode:root location:@"0,3,0" name:@"en.lproj" childrenCount:9 containsLanguages:NO language:@"en"];
    [self assertNode:root location:@"0,3,0,3" name:@"InfoPlist.strings" childrenCount:0 containsLanguages:NO language:@"en"];
    [self assertNode:root location:@"0,3,1" name:@"fr.lproj" childrenCount:4 containsLanguages:NO language:@"fr"];
    [self assertNode:root location:@"0,3,1,1" name:@"special.xml" childrenCount:0 containsLanguages:NO language:@"fr"];
    [self assertNode:root location:@"0,3,2" name:@"French.lproj" childrenCount:2 containsLanguages:NO language:@"French"];
    [self assertNode:root location:@"0,3,3" name:@"Helper" childrenCount:2 containsLanguages:YES language:nil];
    [self assertNode:root location:@"0,3,3,0" name:@"English.lproj" childrenCount:2 containsLanguages:NO language:@"English"];
    [self assertNode:root location:@"0,3,3,0,0" name:@"InfoPlist.strings" childrenCount:0 containsLanguages:NO language:@"English"];
    [self assertNode:root location:@"0,3,3,0,1" name:@"Localizable.strings" childrenCount:0 containsLanguages:NO language:@"English"];
    
    [root setUseLocalizedOnly:YES];
    
    [self assertNode:root location:nil name:@"FilterBundle.app" childrenCount:1 containsLanguages:YES language:nil];
    [self assertNode:root location:@"0" name:@"Contents" childrenCount:1 containsLanguages:YES language:nil];
    
    [self assertNode:root location:@"0,0" name:@"Resources" childrenCount:4 containsLanguages:YES language:nil];
    [self assertNode:root location:@"0,0,0" name:@"en.lproj" childrenCount:9 containsLanguages:NO language:@"en"];
    [self assertNode:root location:@"0,0,1" name:@"fr.lproj" childrenCount:4 containsLanguages:NO language:@"fr"];
    [self assertNode:root location:@"0,0,2" name:@"French.lproj" childrenCount:2 containsLanguages:NO language:@"French"];
    [self assertNode:root location:@"0,0,3" name:@"Helper" childrenCount:1 containsLanguages:YES language:nil];
    [self assertNode:root location:@"0,0,3,0" name:@"English.lproj" childrenCount:2 containsLanguages:NO language:@"English"];
    [self assertNode:root location:@"0,0,3,0,0" name:@"InfoPlist.strings" childrenCount:0 containsLanguages:NO language:@"English"];
    [self assertNode:root location:@"0,0,3,0,1" name:@"Localizable.strings" childrenCount:0 containsLanguages:NO language:@"English"];
    
    [root setUseLanguagePlaceholder:YES];
    
    [self assertNode:root location:nil name:@"FilterBundle.app" childrenCount:1 containsLanguages:YES language:nil];
    [self assertNode:root location:@"0" name:@"Contents" childrenCount:1 containsLanguages:YES language:nil];
    
    [self assertNode:root location:@"0,0" name:@"Resources" childrenCount:4 containsLanguages:YES language:nil displayable:NO];
    [self assertNode:root location:@"0,0" name:@"Resources" childrenCount:2 containsLanguages:YES language:nil displayable:YES];
    [self assertNode:root location:@"0,0,0" name:@"English, French" childrenCount:0 displayable:YES];
    [self assertNode:root location:@"0,0,1" name:@"Helper" childrenCount:1 containsLanguages:YES language:nil displayable:YES];
    [self assertNode:root location:@"0,0,1,0" name:@"English" childrenCount:0 displayable:YES];
    
    [root setUseLanguagePlaceholder:NO];
    
    [self assertNode:root location:@"0,0" name:@"Resources" childrenCount:4 containsLanguages:YES language:nil];
    
    // ****************************************
    // Testing the selection of a placeholder: it should propagate to its represented nodes
    
    [root setUseLanguagePlaceholder:YES];
    
    AZPathNode *placeholder = [root displayableChildAtLocation:@"0,0,0"]; // placeholder for the languages in Contents/Resources/
    [self assertNode:placeholder location:nil name:@"English, French" childrenCount:0];
    
    [placeholder applyState:NSControlStateValueOn];
    XCTAssertEqual([[root childAtLocation:@"0,0,0"] state], (NSInteger)NSControlStateValueOn, @"On State");
    XCTAssertEqual([[root childAtLocation:@"0,0,1"] state], (NSInteger)NSControlStateValueOn, @"On State");
    XCTAssertEqual([[root childAtLocation:@"0,0,2"] state], (NSInteger)NSControlStateValueOn, @"On State");
    
    [placeholder applyState:NSControlStateValueOff];
    XCTAssertEqual([[root childAtLocation:@"0,0,0"] state], (NSInteger)NSControlStateValueOff, @"Off State");
    XCTAssertEqual([[root childAtLocation:@"0,0,1"] state], (NSInteger)NSControlStateValueOff, @"Off State");
    XCTAssertEqual([[root childAtLocation:@"0,0,2"] state], (NSInteger)NSControlStateValueOff, @"Off State");
    
    [[root childAtLocation:@"0,0,0"] setState:NSControlStateValueOn];
    [[root childAtLocation:@"0,0,1"] setState:NSControlStateValueOn];
    [[root childAtLocation:@"0,0,2"] setState:NSControlStateValueOn];
    
    XCTAssertEqual([placeholder state], (NSInteger)NSControlStateValueOn, @"Placeholder On State");
    
    [root applyState:NSControlStateValueOn];
    XCTAssertEqual([[root childAtLocation:@"0,0,0"] state], (NSInteger)NSControlStateValueOn, @"On State");
    XCTAssertEqual([[root childAtLocation:@"0,0,1"] state], (NSInteger)NSControlStateValueOn, @"On State");
    XCTAssertEqual([[root childAtLocation:@"0,0,2"] state], (NSInteger)NSControlStateValueOn, @"On State");
    XCTAssertEqual([[root childAtLocation:@"0,0,3"] state], (NSInteger)NSControlStateValueOn, @"On State");
    
    [placeholder applyState:NSControlStateValueOff];
    XCTAssertEqual([[root childAtLocation:@"0,0,0"] state], (NSInteger)NSControlStateValueOff, @"Off State");
    XCTAssertEqual([[root childAtLocation:@"0,0,1"] state], (NSInteger)NSControlStateValueOff, @"Off State");
    XCTAssertEqual([[root childAtLocation:@"0,0,2"] state], (NSInteger)NSControlStateValueOff, @"Off State");
    
    // ***************************************
    // Testing the selected paths
    
    NSArray *selectedPaths = [root selectedRelativePaths];
    NSArray *expected = [NSArray arrayWithObjects:
                         @"FilterBundle.app/Contents/Resources/Helper/English.lproj/InfoPlist.strings",
                         @"FilterBundle.app/Contents/Resources/Helper/English.lproj/Localizable.strings",
                         nil];
    XCTAssertEqualObjects(selectedPaths, expected, @"Expected paths 1");
    
    // Select the placeholder
    [placeholder applyState:NSControlStateValueOn];
    expected = [NSArray arrayWithObjects:
                @"FilterBundle.app/Contents/Resources/en.lproj/Complex.rtfd",
                @"FilterBundle.app/Contents/Resources/en.lproj/Credits.html",
                @"FilterBundle.app/Contents/Resources/en.lproj/image.tiff",
                @"FilterBundle.app/Contents/Resources/en.lproj/InfoPlist.strings",
                @"FilterBundle.app/Contents/Resources/en.lproj/Localizable.strings",
                @"FilterBundle.app/Contents/Resources/en.lproj/MainMenu.nib",
                @"FilterBundle.app/Contents/Resources/en.lproj/special.xml",
                @"FilterBundle.app/Contents/Resources/en.lproj/Unchanged.strings",
                @"FilterBundle.app/Contents/Resources/en.lproj/version1.rtf",
                @"FilterBundle.app/Contents/Resources/fr.lproj/MainMenu.nib",
                @"FilterBundle.app/Contents/Resources/fr.lproj/special.xml",
                @"FilterBundle.app/Contents/Resources/fr.lproj/Unchanged.strings",
                @"FilterBundle.app/Contents/Resources/fr.lproj/version1.rtf",
                @"FilterBundle.app/Contents/Resources/French.lproj/Others.strings",
                @"FilterBundle.app/Contents/Resources/French.lproj/Panel.nib",
                @"FilterBundle.app/Contents/Resources/Helper/English.lproj/InfoPlist.strings",
                @"FilterBundle.app/Contents/Resources/Helper/English.lproj/Localizable.strings",
                nil];
    XCTAssertEqualObjects([root selectedRelativePaths], expected, @"Expected paths 2");
    
    // Select nothing
    [root applyState:NSControlStateValueOff];
    XCTAssertEqualObjects([root selectedRelativePaths], [NSArray array], @"Empty paths");
}

@end
