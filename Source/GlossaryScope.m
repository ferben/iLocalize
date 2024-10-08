//
//  GlossaryScope.m
//  iLocalize
//
//  Created by Jean Bovet on 1/29/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "GlossaryScope.h"
#import "GlossaryScopeItem.h"
#import "GlossaryManager.h"
#import "GlossaryFolder.h"
#import "Glossary.h"
#import "GlossaryNotification.h"
#import "LanguageController.h"
#import "ProjectModel.h"
#import "TreeNode.h"
#import "ProjectController.h"

@implementation GlossaryScope

@synthesize projectProvider;

- (id) init
{
    self = [super init];
    if (self != nil) {
        nodesForLanguage = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(glossaryDidChange:)
                                                     name:GlossaryDidChange
                                                   object:nil];                
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)glossaryDidChange:(NSNotification*)notif
{
    [self refresh];
}

- (NSString*)language
{
    return [[self.projectProvider selectedLanguageController] language];
}

/**
 Rebuilds the tree hierarchy of scopes, eventually deselecting the glossaries that are
 specified in parameter. The hierarchy follows this structure (and all the glossary are by default selected):
 - rootNode
    - localPath (if exists)
        - glossary 1
        - ...
    - globalPath1
        - glossary 1
        - glossary 2
        - ...
    - globalPath2
        - glossary 1
        - ...
    - ...
 */
- (TreeNode*)buildRootNodeForLanguage:(NSString*)language deselectedGlossaryPaths:(NSSet*)oldUnselectedGlossaryPaths
{
    TreeNode *rootNode = [TreeNode rootNode];
            
    NSString *baseLanguage = [[self.projectProvider projectController] baseLanguage];
                              
    GlossaryManager *gm = [GlossaryManager sharedInstance];
    NSArray *allFolders = [gm globalFoldersAndLocalFoldersForProject:self.projectProvider];
    NSMutableArray *glossaries = [NSMutableArray array];
    for(GlossaryFolder *folder in allFolders) {
        for(Glossary *g in [folder sortedGlossaries]) {
            if([g.sourceLanguage isEquivalentToLanguage:baseLanguage] && [g.targetLanguage isEquivalentToLanguage:language]) {
                [glossaries addObject:g];
            }
        }
    }
        
    GlossaryFolder *localPath = [[gm foldersForProject:self.projectProvider] firstObject];
    
    // Add the project local path
    if([[localPath path] isPathExisting]) {
        TreeNode *localPathNode = [TreeNode nodeWithTitle:[self.projectProvider applicationExecutableName]];
        localPathNode.payload = [GlossaryScopeItem itemWithFolder:localPath
                                                            state:NSControlStateValueOn
                                                             icon:[[NSWorkspace sharedWorkspace] iconForFile:[self.projectProvider sourceApplicationPath]]];
        
        [glossaries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Glossary *g = obj;
            if([g.folder isEqualTo:localPath]) {
                TreeNode *node = [TreeNode leafNode];
                [node setTitle:g.name];
                int state = NSControlStateValueOn;
                if([oldUnselectedGlossaryPaths containsObject:g.file]) {
                    state = NSControlStateValueOff;
                }
                node.payload = [GlossaryScopeItem itemWithGlossary:g 
                                                             state:state
                                                              icon:[[NSWorkspace sharedWorkspace] iconForFile:g.file]];
                [localPathNode addNode:node];
            }
        }];        
        
        if([localPathNode numberOfNodes] > 0) {
            [rootNode addNode:localPathNode];            
        }
    }
    
    // Add all the global paths
    [[gm globalFolders] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GlossaryFolder *p = obj;
        if([p.path isPathExisting]) {
            TreeNode *globalPathNode = [TreeNode nodeWithTitle:[p nameAndPath]];
            globalPathNode.payload = [GlossaryScopeItem itemWithFolder:p
                                                                 state:NSControlStateValueOn
                                                                  icon:[[NSWorkspace sharedWorkspace] iconForFile:p.path]];
            
            [glossaries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Glossary *g = obj;
                if([g.folder isEqualTo:p]) {
                    TreeNode *node = [TreeNode leafNode];
                    [node setTitle:g.name];
                    int state = NSControlStateValueOn;
                    if([oldUnselectedGlossaryPaths containsObject:g.file]) {
                        state = NSControlStateValueOff;
                    }
                    node.payload = [GlossaryScopeItem itemWithGlossary:g state:state
                                                                  icon:[[NSWorkspace sharedWorkspace] iconForFile:g.file]];
                    [globalPathNode addNode:node];
                }
            }];                    

            if([globalPathNode numberOfNodes] > 0) {
                [rootNode addNode:globalPathNode];
            }
        }
    }];    
    return rootNode;
}

- (NSArray*)glossariesForLanguage:(NSString*)language state:(int)state
{
    NSMutableArray *selected = [NSMutableArray array];
    @synchronized(self) {
        for(TreeNode *pathNode in [nodesForLanguage[language] nodes]) {
            for(TreeNode *glossaryNode in [pathNode nodes]) {
                GlossaryScopeItem *item = glossaryNode.payload;
                if(item.state == state) {
                    [selected addObject:item.glossary];
                }
            }
        }
    }
    return selected;
}

- (void)refresh
{
    for(NSString *language in [nodesForLanguage allKeys]) {
        // Build a set of path for all the glossaries that are selected.
        NSArray *unselectedGlossaries = [self glossariesForLanguage:language state:NSControlStateValueOff];
        NSMutableSet *unselectedGlossaryPaths = [NSMutableSet set];
        [unselectedGlossaries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Glossary *g = obj;
            [unselectedGlossaryPaths addObject:g.file];
        }];

        TreeNode *newRootNode = [self buildRootNodeForLanguage:language deselectedGlossaryPaths:unselectedGlossaryPaths];
        nodesForLanguage[language] = newRootNode;
    }
}

- (TreeNode*)rootNode
{
    TreeNode *rootNode = nil;
    @synchronized(self) {
        NSString *language = [self language];
        if(language) {
            rootNode = nodesForLanguage[language];
            if(rootNode == nil) {
                rootNode = [self buildRootNodeForLanguage:language deselectedGlossaryPaths:nil];
                nodesForLanguage[language] = rootNode;
            }                    
        }
    }
    return rootNode;
}

- (void)deselectAll
{
    [self rootNode]; // trigger the creation of the root node if it is not created already
    @synchronized(self) {
        for(TreeNode *pathNode in [nodesForLanguage[[self language]] nodes]) {
            for(TreeNode *glossaryNode in [pathNode nodes]) {
                GlossaryScopeItem *item = glossaryNode.payload;
                item.state = NSControlStateValueOff;
            }
        }
    }    
}

- (NSArray*)selectedGlossaries
{
    [self rootNode]; // trigger the creation of the root node if it is not created already
    return [self glossariesForLanguage:[self language] state:NSControlStateValueOn];
}

- (NSArray*)selectedStates {
    NSMutableArray *states = [NSMutableArray array];
    for (Glossary *g in [self selectedGlossaries]) {
        [states addObjectSafe:g.targetFile];
    }
    return states;
}

- (void)setSelectedStates:(NSArray *)selectedStates {
    [self rootNode]; // trigger the creation of the root node if it is not created already
    @synchronized(self) {
        for(TreeNode *pathNode in [nodesForLanguage[[self language]] nodes]) {
            for(TreeNode *glossaryNode in [pathNode nodes]) {
                GlossaryScopeItem *item = glossaryNode.payload;
                if([selectedStates containsObject:item.glossary.targetFile]) {
                    item.state = NSControlStateValueOn;
                } else {
                    item.state = NSControlStateValueOff;
                }
            }
        }
    }
}

@end
