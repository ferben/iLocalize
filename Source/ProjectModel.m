//
//  ProjectModel.m
//  iLocalize3
//
//  Created by Jean on 30.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "ProjectModel.h"
#import "LanguageModel.h"
#import "FileModel.h"

#import "ProjectPrefs.h"

#import "Console.h"

@implementation ProjectModel

+ (void)initialize
{
	if(self == [ProjectModel class]) {
		[self setVersion:0];
	}
}

+ (ProjectModel*)model
{
	return [[ProjectModel alloc] init];
}

- (id)init
{
	if((self = [super init])) {
		mName = NULL;
		mSourceName = NULL;
		mProjectPath = NULL;
		mBaseLanguage = NULL;
		mLanguageModelArray = [[NSMutableArray alloc] init];
	}
	return self;
}


- (id)initWithCoder:(NSCoder*)coder
{
	if((self = [super init])) {
		mName = [coder decodeObject];
		mSourceName = [coder decodeObject];
		mProjectPath = [coder decodeObject];
		mBaseLanguage = [coder decodeObject];
		mLanguageModelArray = [coder decodeObject];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeObject:mName];
	[coder encodeObject:mSourceName];
	[coder encodeObject:mProjectPath];
	[coder encodeObject:mBaseLanguage];
	[coder encodeObject:mLanguageModelArray];
}

#pragma mark -

- (void)setName:(NSString*)name
{
	mName = name;
}

- (NSString*)name
{
	return mName;
}

- (void)addLanguageModelForLanguage:(NSString*)language
{
	LanguageModel *model = [LanguageModel model];
	[model setLanguage:language];
	[self addLanguageModel:model];
}

- (LanguageModel*)languageModelForLanguage:(NSString*)language
{
	LanguageModel *model;
    @synchronized(self) {
        for(model in mLanguageModelArray) {
            if([[model language] isEquivalentToLanguage:language]) {
                return model;
            }
        }        
    }
	return NULL;
}

- (void)addFileModel:(FileModel*)fileModel toLanguage:(NSString*)language
{
    @synchronized(self) {
        LanguageModel *languageModel = [self languageModelForLanguage:language];
        if(languageModel == NULL) {
            [self addLanguageModelForLanguage:language];
            languageModel = [self languageModelForLanguage:language];
        }
        [languageModel addFileModel:fileModel];        
    }
}

- (void)setBaseLanguage:(NSString*)language
{
	mBaseLanguage = language;

	[self addLanguageModelForLanguage:language];
}

- (NSString*)baseLanguage
{
	return mBaseLanguage;
}

- (void)addLanguages:(NSArray*)languages
{
	NSString *language;
	for(language in languages) {
		if([self languageModelForLanguage:language])
			continue;
		
		[self addLanguageModelForLanguage:language];
	}
}

- (void)addLanguageModel:(LanguageModel*)model
{
    @synchronized(self) {
        [mLanguageModelArray addObject:model];        
    }
}

- (void)removeLanguageModel:(LanguageModel*)model
{
    @synchronized(self) {
        [mLanguageModelArray removeObject:model];        
    }
}

- (LanguageModel*)baseLanguageModel
{
	return [self languageModelForLanguage:mBaseLanguage];
}

- (NSMutableArray*)languageModels
{
	return mLanguageModelArray;
}

#pragma mark -

- (void)setSourceName:(NSString*)name
{
	mSourceName = name;
}

- (NSString*)sourceName
{
	return mSourceName;
}

- (void)setProjectPath:(NSString*)path
{
	mProjectPath = path;
}

- (NSString*)projectPath
{
	return mProjectPath;
}

+ (NSString*)projectSourceFolderPathForProjectPath:(NSString*)pp
{
	return [pp stringByAppendingPathComponent:@"Source"];	
}

- (NSString*)projectSourceFolderPath
{
	return [ProjectModel projectSourceFolderPathForProjectPath:[self projectPath]];
}

- (NSString*)projectSourceFilePath
{
	return [[self projectSourceFolderPath] stringByAppendingPathComponent:[self sourceName]];
}

- (NSString*)projectGlossaryFolderPath
{
	return [[self projectPath] stringByAppendingPathComponent:@"Glossaries"];
}

- (NSString*)projectHistoryFolderPath
{
	return [[self projectSourceFolderPath] stringByAppendingPathComponent:@"History"];
}

- (NSString*)relativePathFromAbsoluteProjectPath:(NSString*)absPath
{
	NSString *projectPath = [self projectSourceFilePath];
	NSString *relativePath = [absPath stringByRemovingPrefix:projectPath];
	
	if(relativePath == NULL) {
		NSLog(@"Cannot relativize absolute project path \"%@\" (project file path \"%@\")", absPath, projectPath);
	}
	return relativePath;
}

- (NSString*)absoluteProjectPathFromRelativePath:(NSString*)relPath
{
	return [[self projectSourceFilePath] stringByAppendingPathComponent:relPath];
}

- (NSString*)description
{
	NSMutableString *s = [NSMutableString string];
	[s appendFormat:@"Name = %@\n", mName];
	[s appendFormat:@"Source = %@\n", mSourceName];
	[s appendFormat:@"Project = %@\n", mProjectPath];
	[s appendFormat:@"Base = %@\n", mBaseLanguage];
	[s appendFormat:@"Languages = %@\n", mLanguageModelArray];
	return s;
}

@end
