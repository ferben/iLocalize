//
//  IGroup.m
//  iLocalize
//
//  Created by Jean Bovet on 10/16/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroup.h"
#import "IGroupView.h"
#import "IGroupEngineManager.h"

@implementation IGroup

@synthesize name;
@synthesize elements;

+ (IGroup*)groupWithProjectProvider:(id<ProjectProvider>)provider engine:(IGroupEngine*)engine
{
    IGroup *group = [[self alloc] init];
    [group setEngine:engine];
    [group setProjectProvider:provider];
    return group;
}

- (id) init
{
    self = [super init];
    if (self != nil) {
        manager = nil;
        elements = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [manager stop];
    

}

- (void)setEngine:(IGroupEngine*)engine
{
    manager = [IGroupEngineManager managerForEngine:engine];
    [manager setDelegate:self];    
}

- (void)setProjectProvider:(id<ProjectProvider>)provider
{
    [self willChangeValueForKey:@"projectProvider"];
    _projectProvider = provider;
    [self didChangeValueForKey:@"projectProvider"];
    manager.state.projectProvider = provider;
    [manager start];    
}

- (void)assignToView:(IGroupView*)groupView
{
    self.view = groupView;
    self.view.group = self;
}

#pragma mark For subclasses

- (void)newResults:(NSArray*)results forEngineManaged:(IGroupEngineManager*)manager
{
    // for subclass
}

- (void)clearResultsForEngineManaged:(IGroupEngineManager*)manager
{
    // for subclass
}

- (void)clickOnElement:(IGroupElement*)element
{
    // for subclass
}

- (void)notifyProcessing:(BOOL)processing
{
    // for subclass
}

@end
