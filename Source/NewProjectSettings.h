//
//  NewProjectSettings.h
//  iLocalize
//
//  Created by Jean on 12/16/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

@class BundleSource;

@interface NewProjectSettings : NSObject {
    NSString *name;
    BundleSource *source;
    NSString *projectFolder;
    NSString *baseLanguage;
    NSArray *localizedLanguages;
    BOOL copySourceOnlyIfExists;
}

/**
 Name of the project
 */
@property (strong) NSString *name;

/**
 The source of the project
 */
@property (strong) BundleSource *source;

/**
 The folder where the project will be created
 */
@property (strong) NSString *projectFolder;

@property (strong) NSString *baseLanguage;
@property (strong) NSArray *localizedLanguages;
@property BOOL copySourceOnlyIfExists;

/**
 Returns the path to the folder containing the project.
 It is <projectFolder>/<name>.
 */
- (NSString*)projectFolderPath;

/**
 Returns the path to the project file.
 It is <projectFolder>/<name>/<name.ilocalize>
 */
- (NSString*)projectFilePath;

@end
