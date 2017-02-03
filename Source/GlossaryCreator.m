//
//  GlossaryCreator.m
//  iLocalize3
//
//  Created by Jean on 09.04.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "GlossaryCreator.h"
#import "Glossary.h"

#import "ProjectWC.h"

#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"
#import "StringController.h"

@implementation GlossaryCreator

+ (GlossaryCreator *)creator
{
	return [[self alloc] init];
}

- (id)init
{
	if (self = [super init])
    {
		glossary = [[Glossary alloc] init];
	}
	
    return self;
}


- (void)setProvider:(id<ProjectProvider>)provider
{
	mProvider = provider;
}

- (void)setSource:(NSInteger)source
{
	mSource = source;
}

- (void)setSourceLanguage:(NSString *)language
{
	mSourceLanguage = [[mProvider projectController] languageControllerForLanguage:language];
}

- (void)setTargetLanguage:(NSString*)language
{
	mTargetLanguage = [[mProvider projectController] languageControllerForLanguage:language];
}

- (void)setIncludeTranslatedStrings:(BOOL)flag
{
	mIncludeTranslated = flag;
}

- (void)setIncludeNonTranslatedStrings:(BOOL)flag
{
	mIncludeNonTranslated = flag;
}

- (void)setExcludeLockedStrings:(BOOL)flag
{
	mExcludeLocked = flag;
}

- (void)setRemoveDuplicateEntries:(BOOL)flag
{
	mRemoveDuplicateEntries = flag;
}

- (void)addStringControllerSource:(StringController*)source target:(StringController*)target
{
	if(!mIncludeTranslated && ![target statusToTranslate])
		return;

	if(!mIncludeNonTranslated && [target statusToTranslate])
		return;

	if(mExcludeLocked && [target lock])
		return;
	
	if([target translation] == nil)
		return;
	
	[glossary addEntryWithSource:[source translation] translation:[target translation]];
}

- (void)addStringControllersSource:(NSArray*)source target:(NSArray*)target
{
	int i;
	for(i = 0; i < [source count]; i++) {
		[self addStringControllerSource:source[i]
								 target:target[i]];
	}
}

- (void)addFileControllerSource:(FileController*)source target:(FileController*)target
{
	[self addStringControllersSource:[source stringControllers]
							  target:[target stringControllers]];
}

- (void)addFileControllersSource:(NSArray*)source target:(NSArray*)target
{
	int i;
	for(i = 0; i < [source count]; i++) {
		[self addFileControllerSource:source[i]
							   target:target[i]];
	}
}

#pragma mark -

- (void)createFromLanguage
{
	[self addFileControllersSource:[mSourceLanguage fileControllers]
							target:[mTargetLanguage fileControllers]];
}

- (void)createFromFiles
{
	NSMutableArray *source = [NSMutableArray array];
	NSMutableArray *target = [NSMutableArray array];
	
	NSEnumerator *enumerator = [[mProvider selectedFileControllers] objectEnumerator];
	FileController *fc;
	while(fc = [enumerator nextObject]) {
		FileController *basefc = [fc baseFileController];
		
		[source addObject:[mSourceLanguage fileControllerMatchingBaseFileController:basefc]];
		[target addObject:[mTargetLanguage fileControllerMatchingBaseFileController:basefc]];
	}	
	
	[self addFileControllersSource:source
							target:target];
}

- (void)createFromStrings
{
	NSMutableArray *source = [NSMutableArray array];
	NSMutableArray *target = [NSMutableArray array];
	
	NSEnumerator *enumerator = [[[mProvider projectWC] selectedStringControllers] objectEnumerator];
	StringController *sc;
	while(sc = [enumerator nextObject]) {
		// File controller of the string controller
		FileController *fc = [sc parent];
		// Base string controller
		StringController *bsc = [fc baseStringController:sc];

		// Source language file controller
		FileController *sfc = [mSourceLanguage fileControllerMatchingBaseFileController:[fc baseFileController]];
		// Source language string controller
		StringController *ssc = [sfc stringControllerMatchingBaseStringController:bsc];
		
		// Target language file controller
		FileController *tfc = [mTargetLanguage fileControllerMatchingBaseFileController:[fc baseFileController]];
		// Target language string controller
		StringController *tsc = [tfc stringControllerMatchingBaseStringController:bsc];
		
		[source addObject:ssc];
		[target addObject:tsc];
	}

	[self addStringControllersSource:source target:target];
}

- (Glossary*)create
{
	glossary.sourceLanguage = [mSourceLanguage language];
	glossary.targetLanguage = [mTargetLanguage language];
			
	switch(mSource) {
		case SOURCE_LANGUAGE:
			[self createFromLanguage];
			break;
		case SOURCE_FILES:
			[self createFromFiles];
			break;
		case SOURCE_STRINGS:
			[self createFromStrings];
			break;
	}

	if(mRemoveDuplicateEntries) {
		[glossary removeDuplicateEntries];
	}
	return glossary;
}

@end
