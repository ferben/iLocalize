//
//  GlossaryNotification.h
//  iLocalize
//
//  Created by Jean Bovet on 4/28/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

// Notification used when a glossary has changed on the disk or a folder has been modified
#define GlossaryDidChange  @"GlossaryDidChange"

// Notification used when the background indexing starts and stops
#define GlossaryProcessingDidChange  @"GlossaryProcessingDidChange"

@class GlossaryFolder;

enum NOTIFICATION_ACTION
{
    INDEX_CHANGED,
    GLOSSARY_SAVED,
    GLOSSARY_DELETED,
    FOLDER_ADDED,
    FOLDER_DELETED,
    PROCESSING_STARTED,
    PROCESSING_STOPPED,
    PROCESSING_UPDATED
};

/**
 Notification object that is being posted for any glossary notification.
 */
@interface GlossaryNotification : NSObject
{
    // Array of new files detected in one of the glossary folder
    NSArray         *listOfNewFiles;
    
    // Array of modified files (changes on the disk)
    NSArray         *modifiedFiles;
    
    // Array of files removed from one of the glossary folder
    NSArray         *deletedFiles;

    // The folder
    GlossaryFolder  *folder;
    
    // Source of the notification to avoid recursive notification
    id               source;
    
    // Percentage of processing
    double           processingPercentage;
    
    // Type of action
    int              action;
}

@property (strong) NSArray *listOfNewFiles;
@property (strong) NSArray *modifiedFiles;
@property (strong) NSArray *deletedFiles;
@property (strong) GlossaryFolder *folder;
@property double processingPercentage;
@property (strong) id source;
@property int action;

+ (GlossaryNotification *)notificationWithAction:(int)action;

@end
