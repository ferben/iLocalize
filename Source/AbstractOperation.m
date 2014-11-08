//
//  AbstractOperation.m
//  iLocalize3
//
//  Created by Jean on 08.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractOperation.h"
#import "AbstractWC.h"
#import "ProjectWC.h"
#import "LanguageController.h"

@interface AbstractOperation (PrivateMethods)
- (id)initWithProjectProvider:(id<ProjectProvider>)provider;
- (void)awake;
@end

@implementation AbstractOperation

@synthesize didCloseCallback;

+ (id)operationWithProjectProvider:(id<ProjectProvider>)provider
{
	AbstractOperation *op = [[self alloc] initWithProjectProvider:provider];
	return op;
}

- (id)initWithProjectProvider:(id<ProjectProvider>)provider
{
	if(self = [super init]) {
		mProjectProvider = provider;
		mAbstractWCInstances = [[NSMutableDictionary alloc] init];
		[self awake];
	}
	return self;
}


- (void)awake
{
	
}

- (id<ProjectProvider>)projectProvider
{
	return mProjectProvider;
}

- (ProjectController*)projectController
{
	return [[self projectProvider] projectController];
}

- (ProjectWC*)projectWC
{
	return [[self projectProvider] projectWC];
}

- (ProjectFilesController*)projectFiles
{
	return [[self projectWC] projectFiles];
}

- (ProjectExplorerController*)projectExplorer
{
	return [[self projectWC] projectExplorer];
}

- (NSWindow*)projectWindow
{
	return [[self projectWC] window];
}

- (NSPopUpButton*)languagesPopUp
{
	return [[self projectWC] languagesPopUp];
}

- (NSArrayController*)languagesController
{
	return [[self projectWC] languagesController];
}

- (NSArrayController*)filesController
{
	return [[self projectWC] filesController];
}

- (LanguageController*)selectedLanguageController
{
	return [[self projectWC] selectedLanguageController];
}

- (AbstractWC*)instanceOfAbstractWC:(Class)c
{
	AbstractWC *wc = [[c alloc] init];
	[wc setParentWindow:[self projectWindow]];
	[wc setProjectProvider:[self projectProvider]];			
	return wc;
}

- (AbstractWC*)instanceOfAbstractWCName:(NSString*)className
{
	id instance = mAbstractWCInstances[className];
	if(instance == NULL) {
		instance = [self instanceOfAbstractWC:NSClassFromString(className)];
		mAbstractWCInstances[className] = instance;
	}
	return instance;
}

- (OperationWC*)operation
{
	return [[self projectProvider] operation];
}

- (OperationDispatcher*)operationDispatcher
{
	return [[self projectProvider] operationDispatcher];
}

- (EngineProvider*)engineProvider
{
	return [[self projectProvider] engineProvider];
}

- (Console*)console
{
	return [[self projectProvider] console];
}

- (void)refreshListOfFiles
{
	[[[self projectWC] selectedLanguageController] filteredFileControllersDidChange];	
}

- (void)close
{
	if(self.didCloseCallback) {
		self.didCloseCallback();
	}
}

@end