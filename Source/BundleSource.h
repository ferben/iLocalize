//
//  ProjectSource.h
//  iLocalize
//
//  Created by Jean Bovet on 5/26/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@class AZPathNode;

/**
 This class contains the information about a bundle and its files.
 This class is used to keep track of which files inside that bundle are
 considered for the various operations, such as creating a new project or
 rebasing a project.
 */
@interface BundleSource : NSObject
{
    @private
    /**
     The path of the source. This path is always the root directory of the source.
     */
    NSString    *sourcePath;
    
    /**
     A node representing the content of the source path as a tree.
     */
    AZPathNode  *sourceNode;
}

@property (strong) NSString *sourcePath;
@property (strong) AZPathNode *sourceNode;

/**
 Creates a source with a single path.
 */
+ (BundleSource *)sourceWithPath:(NSString *)sourcePath;

/**
 Returns the name of the source.
 */
- (NSString *)sourceName;

/**
 Returns an array of absolute files to use (that are selected in the tree).
 */
- (NSArray *)sourceFiles;

/**
 Returns an array of relative files to use. This array is derived from the source node.
 */
- (NSArray *)relativeSourceFiles;

@end
