//
//  ProjectExportSettings.h
//  iLocalize
//
//  Created by Jean on 12/16/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"

@interface ExportProjectSettings : NSObject
{
    // Which paths to export
    NSArray   *paths;
    
    // Which languages to export
    NSArray   *languages;
    
    // Options
    BOOL       exportLanguageFoldersOnly;
    BOOL       exportAsFolder;
    BOOL       compactNib;
    BOOL       upgradeNib;
    BOOL       compress;
    BOOL       nameIncludesBuildNumber;
    BOOL       nameIncludesLanguages;
    BOOL       email;
    NSString  *emailProgram;
    NSString  *emailMessage;
    
    // Destination folder
    NSString  *destFolder;
    
    // Files to copy (not persisted)
    BOOL       mergeFiles;
    NSArray   *filesToCopy;
}

@property (strong) NSArray *paths;
@property (strong) NSArray *languages;
@property BOOL exportLanguageFoldersOnly;
@property BOOL exportAsFolder;
@property BOOL compactNib;
@property BOOL upgradeNib;
@property BOOL compress;
@property BOOL nameIncludesBuildNumber;
@property BOOL nameIncludesLanguages;
@property BOOL email;
@property (strong) NSString *emailToAddress;
@property (strong) NSString *emailProgram;
@property (strong, readonly) NSString *emailSubject;
@property (strong) NSString *emailMessage;
@property (strong) NSString *destFolder;

@property BOOL mergeFiles;
@property (strong) NSArray *filesToCopy;

@property (weak) id<ProjectProvider> provider;

/**
 Returns the name of the exported target (before any compression).
 */
- (NSString *)targetName;

/**
 Returns the path of the exported target (before any compression).
 */
- (NSString *)targetBundle;

/**
 Returns the path of the exported target, including any compression.
 */
- (NSString *)compressedTargetBundle;

// used for persistence
- (void)setData:(NSDictionary *)data;
- (NSDictionary *)data;

@end
