//
//  ProjectSource.m
//  iLocalize
//
//  Created by Jean Bovet on 5/26/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "BundleSource.h"
#import "AZPathNode.h"

@implementation BundleSource

@synthesize sourcePath;
@synthesize sourceNode;

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}


+ (BundleSource*)sourceWithPath:(NSString*)sourcePath
{
    BundleSource *ps = [[BundleSource alloc] init];
    ps.sourcePath = sourcePath;
    return ps;
}

- (NSString*)sourceName
{
    return [self.sourcePath lastPathComponent];
}

- (NSArray*)sourceFiles
{
    return [self.sourceNode selectedAbsolutePaths];
}

- (NSArray*)relativeSourceFiles
{
    // The returned paths have the root name included which we don't want
    // since we want file relative to the root name.
    // Example: it returns "MyApp.app/Contents/Resources/English.lproj/Localizable.strings"
    // But the root app is "MyApp.app" so we want "Contents/Resources/English.lproj/Localizable.strings"
    NSMutableArray *files = [NSMutableArray array];
    for(NSString *file in [self sourceFiles]) {
        [files addObject:[file stringByRemovingPrefix:self.sourcePath]];
    }
    return files;
}

@end
