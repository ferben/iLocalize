//
//  GlossaryTranslator.m
//  iLocalize3
//
//  Created by Jean on 27.05.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "GlossaryTranslator.h"
#import "Glossary.h"

#import "FileController.h"
#import "StringController.h"
#import "LanguageController.h"

#import "OperationWC.h"
#import "PreferencesLocalization.h"
#import "StringTool.h"

#import "ProjectWC.h"

#import "Constants.h"

@implementation GlossaryTranslator

+ (GlossaryTranslator*)translator
{
	return [[GlossaryTranslator alloc] init];
}

- (id)init
{
	if(self = [super init]) {
        mOperation = [[OperationWC alloc] init];
        mLanguageController = nil;
		mCachedRootString = [[NSMutableDictionary alloc] init];
		mCachedRemainingString = [[NSMutableDictionary alloc] init];
		mIgnoreCase = NO;
	}
	return self;
}


- (void)setIgnoreCase:(BOOL)flag
{
	mIgnoreCase = flag;
}

- (void)setLanguageController:(LanguageController*)lc
{
    mLanguageController = lc;
}

- (void)progress
{
    [mOperation setProgress:mCurrentCount];
}

- (void)beginOperation
{
    [mLanguageController beginOperation];
}

- (void)endOperation
{
    [mLanguageController endOperation];
}

#pragma mark -

- (void)translateStringControllers:(NSArray*)scs withString:(NSString*)string base:(NSString*)base
{
	if(base) {
		StringController *sc;
		for(sc in scs) {
			if([[sc base] isEqualToValue:base options:ILStringIgnoreCase])
				[sc setTranslation:string];
		}
	} else {
		[scs makeObjectsPerformSelector:@selector(setTranslation:) withObject:string];		
	}
}

- (void)translateFileControllers:(NSArray*)fcs withString:(NSString*)string base:(NSString*)base
{
	FileController *fc;
	for(fc in fcs) {
		[self translateStringControllers:[fc stringControllers] withString:string base:base];
	}
}

#pragma mark -

- (void)translateStringController:(StringController*)sc withGlossary:(Glossary*)glossary
{
	NSString *translation = (mIgnoreCase?[glossary mappedCaseInsensitiveEntries]:[glossary mappedEntries])[(mIgnoreCase?[[sc base] lowercaseString]:[sc base])];
	if(translation.length > 0) {
		if(![[sc translation] isEqualToString:translation])
			[sc setAutomaticTranslation:translation];            
	}                
	
	@synchronized(self) {
		mCurrentCount++;
		if(mCurrentCount % 50 == 0) {
			[self progress];					
		}
	}
}

- (void)translateStringController:(StringController*)sc withGlossaries:(NSArray*)glossaries
{
	[glossaries enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		Glossary *glossary = obj;		
		[self translateStringController:sc withGlossary:glossary];
	}];	
}

- (void)translateStringControllers:(NSArray*)scs withGlossaries:(NSArray*)glossaries
{
	for(StringController *sc in scs) {
		@autoreleasepool {
			[self translateStringController:sc withGlossaries:glossaries];
		}
		if([mOperation shouldCancel]) break;
	}
}

- (void)_translateFileControllers:(NSArray*)fcs withGlossaries:(NSArray*)glossaries
{
	for(FileController *fc in fcs) {
		[self translateStringControllers:[fc filteredStringControllers] withGlossaries:glossaries];
		if([mOperation shouldCancel]) break;
	}
}

- (void)_translateFileControllersWithGlossaries:(NSDictionary*)dic
{
    [self _translateFileControllers:dic[@"fcs"] withGlossaries:dic[@"glossaries"]];
    [self performSelectorOnMainThread:@selector(threadStopped) withObject:nil waitUntilDone:NO];
}

- (void)threadStopped
{
    [mOperation hide];
    [self endOperation];
}

- (void)translateFileControllers:(NSArray*)fcs withGlossaries:(NSArray*)glossaries
{
	int scCount = 0;
    
	FileController *fc;
	for(fc in fcs) {
        scCount += [[fc filteredStringControllers] count];
    }
    
    mMaxCount = [glossaries count] * scCount;
    mCurrentCount = 0;    
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"fcs"] = fcs;
    dic[@"glossaries"] = glossaries;
	
	[mOperation setParentWindow:[[[mLanguageController projectProvider] projectWC] window]];
	[mOperation setMaxSteps:mMaxCount];
	[mOperation setTitle:NSLocalizedString(@"Translating…", nil)];

    [self beginOperation];
    [NSApplication detachDrawingThread:@selector(_translateFileControllersWithGlossaries:) toTarget:self withObject:dic];	    
    
    if(mMaxCount > 200) {
		[mOperation showAsSheet];
    }	
}

@end
