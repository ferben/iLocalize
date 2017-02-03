//
//  ResourceFileEngine.h
//  iLocalize3
//
//  Created by Jean on 21.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "AbstractEngine.h"

@interface ResourceFileEngine : AbstractEngine {
    NSMutableArray    *mFiles;
}

+ (ResourceFileEngine*)engine;

/**
 Parses the specified array of absolute file path
 */
- (void)parseFiles:(NSArray*)files;

- (void)parseFilesInPath:(NSString*)path;

- (NSArray*)files;
- (NSArray*)filesOfLanguage:(NSString*)language;

- (void)removeFilesOfLanguages:(NSArray*)languages inPath:(NSString*)path;

@end
