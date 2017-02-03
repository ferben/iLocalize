//
//  GMGlossaryNode.m
//  iLocalize
//
//  Created by Jean on 4/2/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "GMGlossaryNode.h"
#import "Glossary.h"
#import "GlossaryFolder.h"

@implementation GMGlossaryNode

@synthesize glossary=_glossary;
@synthesize path=_path;
@synthesize searchString;

+ (GMGlossaryNode*)nodeWithPath:(NSString*)path
{
    GMGlossaryNode *node = [[GMGlossaryNode alloc] init];
    node.path = path;
    return node;
}

+ (GMGlossaryNode*)nodeWithGlossary:(Glossary*)glossary
{
    GMGlossaryNode *node = [[GMGlossaryNode alloc] init];
    node.glossary = glossary;
    return node;
}

- (id)init
{
    if((self = [super init])) {
        children = [[NSMutableArray alloc] init];
    }
    return self;
}


- (BOOL)insert:(Glossary*)glossary components:(NSArray*)components index:(int)index
{
    if(self.path == nil) {        
        if(self.glossary) {
            // cannot insert because it is a glossary node (leaf)
            return NO;
        } else {
            // root node, continue
        }
    } else if(![[self.path lastPathComponent] isEqual:components[index]]) {
        // node title doesn't correspond
        return NO;
    } else {
        index++;
    }
    
    if(index == [components count]-1) {
        [children addObject:[GMGlossaryNode nodeWithGlossary:glossary]];
        return YES;
    } else {
        for(GMGlossaryNode *child in self.children) {
            if([child insert:glossary components:components index:index]) {
                return YES;
            }
        }
        
        NSString *basePath = glossary.folder.path;
        GMGlossaryNode *node = [GMGlossaryNode nodeWithPath:[basePath stringByAppendingPathComponent:[NSString pathWithComponents:[components subarrayWithRange:NSMakeRange(0, index+1)]]]];
        [children addObject:node];
        [node insert:glossary components:components index:index];
        return YES;
    }
}

- (void)insert:(Glossary*)glossary
{
    NSArray *components = [[glossary relativeFile] pathComponents];
    [self insert:glossary components:components index:0];
}

- (void)applySearchString:(NSString*)string
{
    self.searchString = string;
    for(GMGlossaryNode *c in children) {
        [c applySearchString:string];
    }
}

- (NSArray*)children
{
    if([self.searchString length] == 0) return children;
    
    NSMutableArray *filtered = [NSMutableArray array];
    for(GMGlossaryNode *c in children) {
        if(c->_glossary) {
            // glossary node, filter it
            if([[c->_glossary name] rangeOfString:self.searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [filtered addObject:c];                
            } else if([[c sourceLanguage] rangeOfString:self.searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [filtered addObject:c];                                
            } else if([[c targetLanguage] rangeOfString:self.searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [filtered addObject:c];                                
            }
        } else {
            [filtered addObject:c];            
        }
    }
    return filtered;
}

- (NSString*)name
{
    if(self.path) {
        return [self.path lastPathComponent];
    } else if(self.glossary) {
        return [self.glossary name];
    } else {
        return nil;
    }
}

- (NSString*)file
{
    if(self.glossary) {
        return [self.glossary file];
    } else {
        return self.path;
    }
}

- (NSString*)sourceLanguage
{
    return [self.glossary.sourceLanguage displayLanguageName];
}

- (NSString*)targetLanguage
{
    return [self.glossary.targetLanguage displayLanguageName];
}

- (NSInteger)items
{
    if (_glossary)
    {
        return [self.glossary entryCount];        
    }
    else
    {
        return [self.children count];
    }
}

- (BOOL)isEqual:(id)anObject
{
    if(![anObject isKindOfClass:[GMGlossaryNode class]]) {
        return NO;
    }
    
    if(self.path) {
        return [self.path isEqual:[anObject path]];
    } else {
        return [self.glossary isEqual:[anObject glossary]];
    }
}

- (NSUInteger)hash
{
    if(self.path) {
        return [self.path hash];
    } else {
        return [self.glossary hash];
    }    
}

@end
