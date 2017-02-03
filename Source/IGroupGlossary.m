//
//  IGroupGlossary.m
//  iLocalize
//
//  Created by Jean Bovet on 10/16/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroupGlossary.h"
#import "IGroupElementGlossary.h"
#import "IGroupEngineGlossary.h"
#import "IGroupView.h"

#import "ProjectProvider.h"
#import "GlossaryTranslator.h"
#import "FMEditor.h"

@implementation IGroupGlossary

- (id) init
{
    self = [super init];
    if (self != nil) {
        self.name = @"Glossary";
        
        sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO]];
    }
    return self;
}


- (void)newResults:(NSArray*)results forEngineManaged:(IGroupEngineManager*)manager
{
    // use a set so the results are unique
    NSMutableSet *mutableSet = [NSMutableSet setWithArray:elements];
    
    // add the new results to the set
    for(NSDictionary *r in results) {
        IGroupElement *element = [IGroupElementGlossary elementWithDictionary:r];
        // don't add elements that have identical source and target
        if([element.source isEqualToString:element.target]) continue;
        [mutableSet addObject:element];            
    }

    // get back a sorted array
    self.elements = [mutableSet sortedArrayUsingDescriptors:sortDescriptors];
    
    // ask to update the view
    [self.view setNeedsDisplay:YES];
}

- (void)clearResultsForEngineManaged:(IGroupEngineManager*)manager
{
    self.elements = nil;
    [self.view setNeedsDisplay:YES];
}

- (void)clickOnElement:(IGroupElement*)element
{
    GlossaryTranslator *translator = [GlossaryTranslator translator];
    [translator setLanguageController:[self.projectProvider selectedLanguageController]];
    
    NSArray *selectedStrings = [self.projectProvider selectedStringControllers];
    if([selectedStrings count] == 1) {
        [translator translateStringControllers:selectedStrings withString:element.target base:nil];
        
        FMEditor *editor = [self.projectProvider currentFileModuleEditor];
        if([editor respondsToSelector:@selector(performAutoPropagation)]) {
            [editor performSelector:@selector(performAutoPropagation)];            
        }
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"glossaryTranslateSelectNextString"]) {
            [editor selectNextItem];
        }
    } else {
        [translator translateStringControllers:selectedStrings withString:element.target base:element.source];
    }    
}

@end
