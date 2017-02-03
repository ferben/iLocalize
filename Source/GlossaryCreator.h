//
//  GlossaryCreator.h
//  iLocalize3
//
//  Created by Jean on 09.04.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"

#define SOURCE_LANGUAGE 0
#define SOURCE_FILES	1
#define SOURCE_STRINGS	2

@class LanguageController;
@class Glossary;

@interface GlossaryCreator : NSObject
{
	Glossary              *glossary;
	NSInteger              mSource;
	LanguageController    *mSourceLanguage;
	LanguageController    *mTargetLanguage;
	BOOL                   mIncludeTranslated;
	BOOL                   mIncludeNonTranslated;
	BOOL                   mExcludeLocked;
	BOOL                   mRemoveDuplicateEntries;
	
	id <ProjectProvider>   mProvider;
}

+ (GlossaryCreator *)creator;

- (void)setProvider:(id<ProjectProvider>)provider;
- (void)setSource:(NSInteger)source;
- (void)setSourceLanguage:(NSString *)language;
- (void)setTargetLanguage:(NSString *)language;
- (void)setIncludeTranslatedStrings:(BOOL)flag;
- (void)setIncludeNonTranslatedStrings:(BOOL)flag;
- (void)setExcludeLockedStrings:(BOOL)flag;
- (void)setRemoveDuplicateEntries:(BOOL)flag;

- (Glossary *)create;

@end
