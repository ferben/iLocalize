//
//  ILGlossary.h
//  iLocalize
//
//  Created by Jean Bovet on 4/25/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "SEIConstants.h"

@class GlossaryFolder;

/**
 In memory representation of a glossary on the disk.
 */
@interface Glossary : NSObject
{
    // The folder containing the glossary
    GlossaryFolder       *folder;
    
    // The file representing the glossary
    NSString             *file;
    
    // The target file. It is the same as the file unless the file is an alias.
    // In this case, the target file contains the target of the alias.
    NSString             *targetFile;
    
    // Date of the last modification
    NSDate               *modificationDate;
    
    // The format of the glossary
    SEI_FORMAT            format;
    
    // The languages of the glossary
    NSString             *sourceLanguage;
    NSString             *targetLanguage;
    
    // Array of ILGlossaryEntry
    NSMutableArray       *entries;
    
    // Number of entries. This field is used to keep track
    // of the number of entries without having to keep all the entries in memory.
    NSInteger             entryCount;
    
    // Cached structure only
    NSMutableDictionary  *mappedEntries;
    NSMutableDictionary  *mappedCaseInsensitiveEntries;
}

@property (strong) GlossaryFolder *folder;
@property (strong) NSString *file;
@property (strong) NSString *targetFile;
@property (strong) NSDate *modificationDate;
@property SEI_FORMAT format;
@property (strong) NSString *sourceLanguage;
@property (strong) NSString *targetLanguage;
@property NSInteger entryCount;

/**
 Returns the name of the glossary which is the last path component.
 */
- (NSString *)name;

/**
 Returns the relative file of the glossary which is the portion of the path
 relative to the glossary folder.
 */
- (NSString *)relativeFile;

/**
 Returns true if the entries are loaded in memory.
 */
- (BOOL)entriesLoaded;

/**
 Adds an entry to the glossary.
 */
- (void)addEntryWithSource:(NSString *)source translation:(NSString *)translation;

/**
 Adds an array of entries to the glossary.
 */
- (void)addEntries:(NSArray *)otherEntries;

/**
 Replaces all matching entries in this glossary with the specified entries.
 Entries are matching using their source string.
 */
- (void)replaceEntries:(NSArray *)otherEntries;

/**
 Replaces (or adds if the entry doesn't exist) the entries in this glossary
 */
- (void)updateEntries:(NSArray *)otherEntries;

/**
 Removes all the entries of this glossary.
 */
- (void)removeAllEntries;

/**
 Removes all duplicated entries.
 @return true if at least one entry was removed
 */
- (BOOL)removeDuplicateEntries;

/**
 Returns an array of ILGlossaryEntry. If the entries are not in memory, they are loaded.
 */
- (NSArray *)entries;

/**
 Returns a dictionary of the entries such as <source> => <translation>. The source is converted
 to lower case.
 */
- (NSDictionary *)mappedCaseInsensitiveEntries;

/**
 Returns a dictionary of the entries such as <source> => <translation>.
 */
- (NSDictionary *)mappedEntries;

/**
 Loads the properties of the glossary, such as languages and number of entries.
 */
- (void)loadProperties;

/**
 Loads the content of the glossary which includes:
 - the properties
 - the entries
 */
- (BOOL)loadContent;

/**
 Reloads the content from the disk because the in memory is content is out of date.
 */
- (void)markContentToReload;

/**
 Returns YES if the glossary is read-only.
 */
- (BOOL)readOnly;

/**
 Writes the glossary to the file.
 */
- (BOOL)writeToFile:(NSError **)error;

/**
 Writes the glossary content to another file, leaving the original file intact (export).
 @param inFile The file to write the content to
 @param referenceFile The file that actually identifies this glossary. It can be different than inFile if inFile is a temporary file for example before being
 moved to referenceFile.
 */
- (BOOL)exportToFile:(NSString *)inFile referenceFile:(NSString *)referenceFile format:(SEI_FORMAT)inFormat error:(NSError **)error;

/**
 Sets the persistent data of this glossary.
 @return true if the persistent data were successfully applied.
 */
- (BOOL)setPersistentData:(NSDictionary *)data;

/**
 Returns the persistent data of this glossary.
 */
- (NSDictionary *)persistentData;

@end
