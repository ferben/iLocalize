//
//  ILGlossaryFolder.h
//  iLocalize
//
//  Created by Jean Bovet on 4/25/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@class AZOrderedDictionary;

/**
 Manages a folder containing glossaries.
 */
@interface GlossaryFolder : NSObject
{
    // The name of the folder used for display purpose only
    NSString             *name;
    
    // The path representing the folder
    NSString             *path;
    
    // Dictionary of <file>=><Glossary>.
    AZOrderedDictionary  *glossaryMap;
    
    // Flag that indicates if this folder is local to a project
    BOOL                  boundToProject;
    
    // Flag that indicates if this folder can be removed. The following folders cannot be removed:
    // - the default global folder (../Library/Application Support/iLocalize/Glossaries)
    // - each project's local folder
    BOOL                  deletable;
}

@property (strong) NSString *name;
@property (strong) NSString *path;
@property (strong) AZOrderedDictionary *glossaryMap;
@property BOOL boundToProject;
@property BOOL deletable;

/**
 Returns a new instance of a folder local to a project.
 */
+ (GlossaryFolder *)folderForProject:(id<ProjectProvider>)provider name:(NSString *)name;

/**
 Returns a new instance of a global folder.
 */
+ (GlossaryFolder *)folderForPath:(NSString *)path name:(NSString *)name;

/**
 Returns the name of the folder followed by its path with a "-" separating the two.
 Useful to use in display to dis-ambiguate multiple folders with the same name.
 */
- (NSString *)nameAndPath;

/**
 Returns an array of Glossary taken from the glossaryMap.
 */
- (NSArray *)glossaries;

/**
 Returns an array of Glossary sorted by name.
 */
- (NSArray *)sortedGlossaries;

/**
 Returns true if this folder is bound to the specified project.
 */
- (BOOL)isBoundToProject:(id<ProjectProvider>)provider;

// Persistent data
- (void)setPersistentData:(NSDictionary *)data;
- (NSDictionary *)persistentData;

@end
