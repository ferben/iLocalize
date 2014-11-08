//
//  IGroup.h
//  iLocalize
//
//  Created by Jean Bovet on 10/16/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"
#import "IGroupEngineManager.h"

@class IGroupView;
@class IGroupElement;

@interface IGroup : NSObject <IGroupEngineManagerDelegate> {
	IGroupEngineManager *manager;
	NSString *name;
	NSArray *elements;
}

@property (weak) IGroupView *view;
@property (strong) NSString *name;
@property (strong) NSArray *elements;
@property (nonatomic, weak) id<ProjectProvider> projectProvider;

+ (IGroup*)groupWithProjectProvider:(id<ProjectProvider>)provider engine:(IGroupEngine*)engine;

- (void)setEngine:(IGroupEngine*)engine;

- (void)assignToView:(IGroupView*)view;

- (void)clickOnElement:(IGroupElement*)element;

@end
