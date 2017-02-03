//
//  PathNode.m
//  iLocalize
//
//  Created by Jean Bovet on 1/26/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "AZPathNode.h"
#import "LanguageTool.h"

@interface AZPathNode (PrivateMethods)
- (AZPathNode*)addPathComponents:(NSMutableArray*)components;
@end

@implementation AZPathNode

@synthesize parent;
@synthesize name;
@synthesize rootPath;
@synthesize language;
@synthesize containsLanguages;
@synthesize state;
@synthesize payload;

+ (AZPathNode *)rootNodeWithPath:(NSString*)path
{
    AZPathNode *node = [[AZPathNode alloc] init];
    node.rootPath = path;
    node.name = [path lastPathComponent];
    return node;
}

- (id) init
{
    self = [super init];
    
    if (self != nil)
    {
        _children = [[NSMutableArray alloc] init];
        filteredChildren = nil;
        displayableChildren = nil;
        self.containsLanguages = NO;
        hideLanguageFolders = NO;
        useLocalizedPathsOnly = NO;
        useLanguagePlaceholder = NO;
        languagePlaceholderNode = NO;
        languagePlaceholderNodes = nil;
        childrenSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    }
    
    return self;
}


- (void)applyState:(NSInteger)inState
{
    self.state = inState;

    if ([self children].count > 0)
    {
        // This node has children. Propagate the state to all the children.
        [self visitChildren:^BOOL(AZPathNode *child)
        {
            child.state = state;
            return YES;
        }];
    }
    
    // Update the state of the parent of the node
    [self visitParent:^(AZPathNode *pnode)
    {
        // Set the state of the parent depending on the states of its direct children.
        
        NSInteger parentState = NSMixedState;
        
        for (AZPathNode *child in [pnode children])
        {
            if (parentState == NSMixedState)
            {
                parentState = child.state;
            }
            else if (parentState != child.state)
            {
                parentState = NSMixedState;
                break;
            }            
        }
        
        pnode.state = parentState;
    }];    
}

- (void)setState:(NSInteger)inState
{
    // In the case of a placeholder, set all the represented nodes state
    if(languagePlaceholderNode) {
        for(AZPathNode *node in languagePlaceholderNodes) {
            [node visitAll:^BOOL(AZPathNode *node) {
                node.state = inState;
                return YES;
            }];
        }        
    }    
    
    state = inState;    
}

- (NSInteger)state
{
    // In the case of a placeholder, returns the union of all the nodes state it represents
    if(languagePlaceholderNode) {
        state = [[languagePlaceholderNodes firstObject] state];
        for(AZPathNode *node in languagePlaceholderNodes) {
            if(state != node.state) {
                state = NSMixedState;
                break;
            }
        }
    }
    return state;        
}

// Internal method: fill the components array with the name 
// of this node and all its parent.
- (void)pathComponents:(NSMutableArray*)components
{
    [parent pathComponents:components];
    if(self.name) {
        [components addObject:self.name];        
    }
}

- (NSString*)relativePath
{
    NSMutableArray *components = [NSMutableArray array];
    [self pathComponents:components];
    return [NSString pathWithComponents:components];
}

- (NSString*)absolutePath
{
    if(self.parent && !self.rootPath) {
        // Ask the parent for the rootpath if it is not set already in this node:
        // A situation can happen when this node is a root node for the path structure
        // but it is nevertheless added to a parent node (e.g. the preview when rebasing
        // a project where the root nodes are the operation and under each operation there is
        // the tree structure).
        return [[parent absolutePath] stringByAppendingPathComponent:name];
    } else {
        return self.rootPath;
    }
}

// Invalidate all the filters
- (void)invalidateFilters
{
    filteredChildren = nil;
    
    displayableChildren = nil;
}

- (void)addNode:(AZPathNode*)node
{
    node.parent = self;
    [_children addObject:node];        
    [_children sortUsingDescriptors:@[childrenSortDescriptor]];
    [self invalidateFilters];
}

// Internal method
- (AZPathNode*)addNewChild:(NSMutableArray*)components
{
    if([components count] > 0) {
        // Try to add the component to one of its children if matching
        NSString *childComponent = [components firstObject];
        for(AZPathNode *child in _children) {
            if([child.name isEqualToString:childComponent]) {
                return [child addPathComponents:components];
            }
        }

        // No children matching, add it as a child
        AZPathNode *child = [[AZPathNode alloc] init];
        child.name = childComponent;
        
        [self addNode:child];
        AZPathNode *leafChild = [child addPathComponents:components];
        if(leafChild == nil) {
            leafChild = child;
        }
        return leafChild;
    } else {
        return nil;
    }
}

- (AZPathNode*)addPathComponents:(NSMutableArray*)components
{
    NSString *c = [components firstObject];
    if(c == nil) return nil;

    if(self.name == nil) {
        [components removeObjectAtIndex:0];
        self.name = c;
        return [self addPathComponents:components];
    } else if([c isEqualToString:name]) {
        [components removeObjectAtIndex:0];
        return [self addNewChild:components];
    } else {
        return [self addNewChild:components];
    }
}

- (AZPathNode*)addRelativePath:(NSString *)relativePath
{
    if(self.parent != nil) {
        [Logger throwExceptionWithReason:@"Cannot add a path to a non-root node"];
    }
    
    NSMutableArray *components = [NSMutableArray arrayWithArray:[relativePath pathComponents]];
    if([[components firstObject] isEqualToString:@"/"]) {
        [components removeFirstObject];
    }
    if([[components lastObject] isEqualToString:@"/"] && components.count > 1) {
        [components removeObjectAtIndex:components.count-1];
    }
    return [self addPathComponents:components];
}

- (void)beginModifications
{
    // nothing to do
}

- (void)endModifications
{
    // Scan all the nodes to assign the proper language and related flags
    [self visitAll:^BOOL(AZPathNode *n) {
        if([[n relativePath] isPathLanguageProject]) {
            n.language = [[[n relativePath] stringByDeletingPathExtension] lastPathComponent];
            if(n.parent.language) {
                // already in a language folder... what to do?
            } else {
                // indicate to the parents that it contains a language
                AZPathNode *p = n;
                while((p = p.parent) != nil) {
                    p.containsLanguages = YES;
                }
            }
        } else if(n.parent.language) {
            n.language = n.parent.language;
        }
        return YES;
    }];
}

- (NSString*)title
{
    return self.name;
}

- (NSImage*)image
{
    if(languagePlaceholderNode) {
        return [[NSImage imageNamed:@"ToolbarLanguages"] imageWithSize:NSMakeSize(16, 16)];
    } else {
        return [[NSWorkspace sharedWorkspace] iconForFile:[self absolutePath]];        
    }
}

- (AZPathNode*)childAtLocation:(NSString*)location block:(NSArray*(^)(AZPathNode *child))block
{
    AZPathNode *node = self;
    NSArray *locs = [location componentsSeparatedByString:@","];
    for(NSString *index in locs) {
        NSArray *nodes = block(node);
        node = nodes[[index intValue]];
    }
    return node;    
}

- (AZPathNode*)childAtLocation:(NSString*)location
{
    return [self childAtLocation:location block:^NSArray *(AZPathNode *child) {
        return [child children];
    }];
}

- (AZPathNode*)displayableChildAtLocation:(NSString*)location
{
    return [self childAtLocation:location block:^NSArray *(AZPathNode *child) {
        return [child displayableChildren];
    }];
}

- (NSArray*)children
{
    if(!filteredChildren) {
        NSMutableArray *children = [NSMutableArray array];        
        // Filter the localized nodes
        for(AZPathNode *c in _children) {
            if(useLocalizedPathsOnly) {
                if(c.containsLanguages || c.language.length > 0) {
                    [children addObject:c];
                }
            } else {
                [children addObject:c];
            }
        }
        filteredChildren = children;
    }
    return filteredChildren;
}

- (NSArray*)filteredChildrenWithPlaceholder:(NSArray*)children
{
    if(useLanguagePlaceholder) {
        NSMutableArray *filtered = [NSMutableArray array];
        NSMutableArray *languageNodes = [NSMutableArray array];
        for(AZPathNode *c in children) {
            if(c.language.length > 0) {
                [languageNodes addObject:c];
            } else {
                [filtered addObject:c];
            }
        }
        if(languageNodes.count > 0) {
            // There is at least one language node. Create the placeholder
            AZPathNode *placeholder = [[AZPathNode alloc] init];
            NSMutableString *s = [NSMutableString string];
            NSMutableSet *languages = [NSMutableSet set];
            for(AZPathNode *ln in languageNodes) {
                NSString *l = [ln.language displayLanguageName];
                if(![languages containsObject:l]) {
                    [languages addObject:l];
                    if(s.length > 0) {
                        [s appendString:@", "];
                    }
                    [s appendString:l];
                }
            }
            placeholder.name = s;
            placeholder->languagePlaceholderNode = YES;
            placeholder->languagePlaceholderNodes = languageNodes;
            placeholder.parent = self;
            [filtered insertObject:placeholder atIndex:0];
        }
        return filtered;
    } else {
        return children;
    }
}

- (NSArray*)filteredChildrenWithLanguageFolder:(NSArray*)children
{
    if(hideLanguageFolders) {
        NSMutableArray *filtered = [NSMutableArray array];
        for(AZPathNode *c in children) {
            if(!c.language) {
                [filtered addObject:c];
            }
        }
        return filtered;
    } else {
        return children;
    }
}

- (NSArray*)displayableChildren
{
    if(!displayableChildren) {
        NSArray *children = [self filteredChildrenWithPlaceholder:[self children]];
        children = [self filteredChildrenWithLanguageFolder:children];
        displayableChildren = children;
    }
    return displayableChildren;
}

- (void)removeAllChildren
{
    [_children removeAllObjects];
    [self invalidateFilters];
}

- (NSArray*)selectedPaths:(BOOL)relative
{
    NSMutableArray *paths = [NSMutableArray array];
    [self visitLeaves:^(AZPathNode *node) {
        if(node.state == NSOnState) {
            if(relative) {
                [paths addObject:[node relativePath]];                
            } else {
                [paths addObject:[node absolutePath]];                                
            }
        }
    }];    
    return paths;    
}

- (NSArray*)selectedRelativePaths
{
    return [self selectedPaths:YES];
}

- (NSArray*)selectedAbsolutePaths
{
    return [self selectedPaths:NO];    
}

- (void)setHideLanguageFolders:(BOOL)flag
{
    [self visitAll:^BOOL(AZPathNode *node) {
        node->hideLanguageFolders = flag;
        [node invalidateFilters];
        return YES;
    }];
}

- (void)setUseLocalizedOnly:(BOOL)localized
{
    [self visitAll:^BOOL(AZPathNode *node) {
        node->useLocalizedPathsOnly = localized;
        [node invalidateFilters];
        return YES;
    }];
}

- (void)setUseLanguagePlaceholder:(BOOL)placeholder
{
    [self visitAll:^BOOL(AZPathNode *node) {
        node->useLanguagePlaceholder = placeholder;
        [node invalidateFilters];
        return YES;
    }];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ - %ld children", self.name, _children.count];
}

- (BOOL)isEqual:(id)object
{
    return [[self absolutePath] isEqualToPath:[object absolutePath]];
}

- (void)visitAll:(BOOL(^)(AZPathNode *node))block
{
    if(block(self)) {
        for(AZPathNode *c in [self children]) {
            if(block(c)) {
                [c visitChildren:block];            
            }
        }        
    }
}

- (void)visitChildren:(BOOL(^)(AZPathNode *node))block
{
    for(AZPathNode *c in [self children]) {
        if(block(c)) {
            [c visitChildren:block];            
        }
    }
}

- (void)visitParent:(void(^)(AZPathNode *node))block
{
    AZPathNode *p = self.parent;
    if(p) {
        block(p);
        [p visitParent:block];
    }
}

- (void)visitLeaves:(void(^)(AZPathNode *node))block
{
    if([self children].count == 0) {
        block(self);
    } else {
        for(AZPathNode *c in [self children]) {
            [c visitLeaves:block];
        }        
    }

}

@end
