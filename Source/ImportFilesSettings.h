//
//  ImportFilesSettings.h
//  iLocalize
//
//  Created by Jean Bovet on 2/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

/**
 This class contains all the settings needed to update the project
 with files.
 */
@interface ImportFilesSettings : NSObject
{
    // The list of files to use for the update
    NSArray   *files;
    
    // Array of files with their matching file controller
    NSArray   *matchItems;

    // Update base language settings
    BOOL       updateBaseLanguage;
    BOOL       resetLayout;

    // Update localized language settings
    NSString  *localizedLanguage;
    BOOL       updateNibLayouts;
}

@property (strong) NSArray *files;
@property (strong) NSArray *matchItems;
@property BOOL updateBaseLanguage;
@property BOOL resetLayout;
@property BOOL updateNibLayouts;
@property (strong) NSString *localizedLanguage;

@end
