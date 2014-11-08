//
//  LanguageModel.m
//  iLocalize3
//
//  Created by Jean on 30.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "LanguageModel.h"
#import "FileModel.h"

#import "FileTool.h"
#import "LanguageTool.h"

static NSString const *kTranslateUsingGlossariesSelectedStates = @"kTranslateUsingGlossariesSelectedStates";
static NSString const *kUpdateOrAddInGlossariesSelectedStates = @"kUpdateOrAddInGlossariesSelectedStates";

@implementation LanguageModel

+ (void)initialize
{
	if(self == [LanguageModel class]) {
		[self setVersion:3];
	}
}

+ (LanguageModel*)model
{
	return [[LanguageModel alloc] init];
}

- (id)init
{
	if(self = [super init]) {
		mLanguage = NULL;
		mFileModelArray = [[NSMutableArray alloc] init];
        self.translateUsingGlossariesSelectedStates = [NSArray array];
        self.updateOrAddInGlossariesSelectedStates = [NSArray array];
		
		// Map from relative file path to FileModel to speed up
		// the lookup. Make sure to clear this cache when there
		// is a modification in the file relative path.
		mPath2Model = [[NSMutableDictionary alloc] init];
	}
	return self;
}


- (id)initWithCoder:(NSCoder*)coder
{
	if(self = [super init]) {
		mLanguage = [coder decodeObject];
		mFileModelArray = [coder decodeObject];
        NSInteger version = [coder versionForClassName:[self className]];
        switch (version) {
            case 1: {
                NSArray* mLocalFileModelArray = [coder decodeObject];
                // Make sure to update the list of local files after loading it here. Some of them might become global again if they exist in the base language
                // Version 4 note: no more separate array for local files. They are integrated in the main array and will be sorted using predicates.
                [mFileModelArray addObjectsFromArray:mLocalFileModelArray];
            }
                break;
             
            case 3: {
                NSDictionary *data = [self decodeObjectOrNil:[coder decodeObject]];
                self.translateUsingGlossariesSelectedStates = data[kTranslateUsingGlossariesSelectedStates];
                self.updateOrAddInGlossariesSelectedStates = data[kUpdateOrAddInGlossariesSelectedStates];
            }
                break;
        }
		mPath2Model = [[NSMutableDictionary alloc] init];
		[self updateCache];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeObject:mLanguage];
	[coder encodeObject:mFileModelArray];

    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    if (self.translateUsingGlossariesSelectedStates.count > 0) {
        data[kTranslateUsingGlossariesSelectedStates] = self.translateUsingGlossariesSelectedStates;
    }
    if (self.updateOrAddInGlossariesSelectedStates.count > 0) {
        data[kUpdateOrAddInGlossariesSelectedStates] = self.updateOrAddInGlossariesSelectedStates;
    }
    
    [coder encodeObject:[self encodeObjectOrNil:data]];
    
	// Version 4: no more local files array, everything in the main array
	//[coder encodeObject:mLocalFileModelArray];
}

- (id)encodeObjectOrNil:(id)objectOrNil {
    return objectOrNil?:[NSNull null];
}

- (id)decodeObjectOrNil:(id)value {
    if ([value isEqual:[NSNull null]]) {
        return nil;
    } else {
        return value;
    }
}

- (void)setLanguage:(NSString*)language
{
	mLanguage = language;
}

- (NSString*)language
{
	return mLanguage;
}

- (void)addFileModel:(FileModel*)fileModel
{
	[mFileModelArray addObject:fileModel];
	[fileModel setLanguageModel:self];
	[self addToCache:fileModel];
}

- (void)deleteFileModel:(FileModel*)fileModel
{
	[mFileModelArray removeObject:fileModel];
	[fileModel setLanguageModel:nil];
	[self removeFromCache:fileModel];
}

- (NSMutableArray*)fileModels
{
	return mFileModelArray;
}

- (FileModel*)findFileModelForBaseFileModel:(FileModel*)baseFileModel language:(NSString*)language translatedPaths:(NSArray*)translatedPaths
{
	FileModel *fileModel;
	for(fileModel in mFileModelArray) {
		for(id loopItem in translatedPaths) {
			if([[fileModel relativeFilePath] isEqualCaseInsensitiveToString:loopItem])
				return fileModel;        			
		}
	}		
	return nil;
}

// Return the file model matching the equivalent base file model
- (FileModel*)fileModelForBaseFileModel:(FileModel*)baseFileModel language:(NSString*)language
{
	NSArray *translatedPaths = [FileTool equivalentLanguagePaths:[FileTool translatePath:[baseFileModel relativeFilePath] toLanguage:language]];
	
	BOOL optimized = YES;
	if(optimized) {
		for(id loopItem in translatedPaths) {
			FileModel *fm = mPath2Model[[loopItem lowercaseString]];
			if(fm) return fm;
		}
		
		// Nothing found. Add to cache.
		FileModel *fm = [self findFileModelForBaseFileModel:baseFileModel language:language translatedPaths:translatedPaths];
		if(fm) {
			[self addToCache:fm];
		}
	} else {
		return [self findFileModelForBaseFileModel:baseFileModel language:language translatedPaths:translatedPaths];
	}
	return nil;
}

- (FileModel*)fileModelForBaseFileModel:(FileModel*)baseFileModel
{
    return [self fileModelForBaseFileModel:baseFileModel language:mLanguage];
}

- (void)updateCache
{
	[mPath2Model removeAllObjects];
	int index;
	for(index = 0; index < [mFileModelArray count]; index++) {
		FileModel *fm = mFileModelArray[index];
		[fm setLanguageModel:self];
		
		NSArray *equivalentPaths = [FileTool equivalentLanguagePaths:[fm relativeFilePath]];
		int j;
		for(j = 0; j < [equivalentPaths count]; j++) {
			if(mPath2Model[[equivalentPaths[j] lowercaseString]]) {
				// IL-138:
				// File is already in the cache which means it is duplicated in the list.
				// This apparently happens with some old iLocalize project.
				LOG(@"Removing duplicate file %@", [fm relativeFilePath]);
				[mFileModelArray removeObjectAtIndex:index];
				index--;
				goto removed;
			}			
		}
		[self addToCache:fm];
		
	removed:
		continue;
	}
}

- (void)addToCache:(FileModel*)fm
{
	mPath2Model[[[fm relativeFilePath] lowercaseString]] = fm;
}

- (void)removeFromCache:(FileModel*)fm
{
	[mPath2Model removeObjectForKey:[[fm relativeFilePath] lowercaseString]];
}

- (NSString*)description
{
	NSMutableString *s = [NSMutableString string];
	[s appendFormat:@"Name = %@\n", mLanguage];
	[s appendFormat:@"Files = %@\n", mFileModelArray];
	return s;
}

@end
