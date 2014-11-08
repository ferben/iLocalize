//
//  GlossaryScope.h
//  iLocalize
//
//  Created by Jean Bovet on 1/29/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"

@class TreeNode;

/**
 Class that handles a scope of glossaries, that is, among a set of glossary,
 which ones are selected for processing.
 */
@interface GlossaryScope : NSObject {
	/**
	 Map of root node for each language. A root node contains the tree of scopes.
	 */
	NSMutableDictionary *nodesForLanguage;
}

/**
 The project provider.
 */
@property (weak) id<ProjectProvider> projectProvider;

/**
 Property that contains the states that identify which
 glossary are selected. This state can be saved and
 re-used later to restore the selection.
 */
@property (nonatomic, copy) NSArray *selectedStates;

/**
 Refreshes the list of glossaries for the current language.
 */
- (void)refresh;

/**
 Returns the root node of the tree representing all the available scopes.
 */
- (TreeNode*)rootNode;

/**
 Deselect all the glossaries
 */
- (void)deselectAll;

/**
 Returns an array of glossaries that are selected.
 */
- (NSArray*)selectedGlossaries;

@end
