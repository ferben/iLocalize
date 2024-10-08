//
//  PathNode.h
//  iLocalize
//
//  Created by Jean Bovet on 1/26/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

/**
 Node representing a path.
 */
@interface AZPathNode : NSObject
{
    @private
    /**
     The parent node or nil if root.
     */
    AZPathNode        *parent;
    
    /**
     The children nodes. This array contains all the nodes.
     */
    NSMutableArray    *_children;
    
    /**
     Array of children after filtering (e.g. localized only)
     */
    NSArray           *filteredChildren;
    
    /**
     Array of children suitable for display (e.g. with language placeholder)
     */
    NSArray           *displayableChildren;
    
    /**
     Name of this node.
     */
    NSString          *name;
    
    /**
     This property is set to the root node only and contains
     the path of the root node.
     */
    NSString          *rootPath;
    
    // Language of this path (or nil if this path is not localized)
    NSString          *language;
    
    // True if this node contains at least one language in its children
    BOOL               containsLanguages;
    
    // State of the node. Usually NSControlStateValueOn, NSControlStateValueMixed or NSControlStateValueOff
    NSInteger          state;
    
    // Flag indicating to hide the language folders (*.lproj)
    BOOL               hideLanguageFolders;
    
    // Flag indicating to return only children that contains at least one language
    BOOL               useLocalizedPathsOnly;
    
    // Flag indicating to return placeholder nodes instead of the language children
    BOOL               useLanguagePlaceholder;
    
    // Flag indicating this node is the language placeholder node. This is used so the user can choose to
    // select the languages of this node but not other children of this node
    BOOL               languagePlaceholderNode;
    
    // Nodes that the language placeholder represents.
    NSArray           *languagePlaceholderNodes;
    
    // Internal sort descriptor used to keep the children sorted
    NSSortDescriptor  *childrenSortDescriptor;
    
    // The optional payload of this node
    id                 payload;
}

@property (strong) AZPathNode *parent;
@property (copy) NSString *name;
@property (copy) NSString *rootPath;
@property (strong) NSString *language;
@property BOOL containsLanguages;
@property (nonatomic) NSInteger state;
@property (strong) id payload;

/**
 Creates a root node with the specified path.
 */
+ (AZPathNode *)rootNodeWithPath:(NSString *)path;

/**
 Sets the state of this node and propagate to its children and parents.
 The behavior is that all its children is going to take this state
 and its parent will be updated according to their children states.
 */
- (void)applyState:(NSInteger)inState;

/**
 Returns the path of this node relative to the root node path.
 */
- (NSString *)relativePath;

/**
 Returns the absolute path of this node.
 */
- (NSString *)absolutePath;

/**
 Add a node. When building a tree of path, you should use addRelativePath instead.
 */
- (void)addNode:(AZPathNode *)node;

/**
 Add a relative path to this root node.
 
 Note: The node must be the root node, otherwise an exception is throwed.
 
 @return The node that represent the last element of the path (the leaf node)
 */
- (AZPathNode *)addRelativePath:(NSString *)relativePath;

/**
 Invoke this method before starting to modify this node using addRelativePath.
 */
- (void)beginModifications;

/**
 Invoke this method when all the modification to the node has been done.
 This method will decorate the tree with the appropriate attributes, such as languages.
 */
- (void)endModifications;

/**
 Returns the title of this node tailored for display.
 */
- (NSString *)title;

/**
 Returns the image associated with this node.
 */
- (NSImage *)image;

/**
 Returns the node at the specified tree location. The location specified the branch
 to follow, such as:
 @"0,0,1" : child(0).child(0).child(1)
 */
- (AZPathNode *)childAtLocation:(NSString *)location;

// The same but with the displayable children
- (AZPathNode *)displayableChildAtLocation:(NSString *)location;

/**
 Returns the children of this node. The array returned by this method
 is filtered by the flag mentioned above.
 */
- (NSArray *)children;

/**
 Returns the children of this node that can be dispalyed.
 */
- (NSArray *)displayableChildren;

/**
 Removes all the children of this node.
 */
- (void)removeAllChildren;

/**
 Returns an array of all the selected paths (relative)
 */
- (NSArray *)selectedRelativePaths;
- (NSArray *)selectedAbsolutePaths;

/**
 Hide language folders from the displayed children.
 */
- (void)setHideLanguageFolders:(BOOL)flag;

/**
 Use only localized nodes, that is nodes that have at least one language.
 */
- (void)setUseLocalizedOnly:(BOOL)localized;

/**
 Invoke this method to use language placeholder nodes instead of showing the language folders.
 */
- (void)setUseLanguagePlaceholder:(BOOL)placeholder;

// Visitors
- (void)visitAll:(BOOL(^)(AZPathNode *node))block;
- (void)visitChildren:(BOOL(^)(AZPathNode *node))block;
- (void)visitParent:(void(^)(AZPathNode *node))block;
- (void)visitLeaves:(void(^)(AZPathNode *node))block;
                       
@end
