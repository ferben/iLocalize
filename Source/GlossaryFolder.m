//
//  ILGlossaryFolder.m
//  iLocalize
//
//  Created by Jean Bovet on 4/25/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "GlossaryFolder.h"
#import "Glossary.h"
#import "ProjectDocument.h"
#import "ProjectModel.h"
#import "AZOrderedDictionary.h"

@implementation GlossaryFolder

@synthesize name;
@synthesize path;
@synthesize glossaryMap;
@synthesize boundToProject;
@synthesize deletable;

+ (GlossaryFolder*)folderForProject:(id<ProjectProvider>)provider name:(NSString*)name
{
	GlossaryFolder *folder = [[GlossaryFolder alloc] init];	
	folder.name = name;
	folder.path = [[provider projectModel] projectGlossaryFolderPath];
	folder.deletable = NO;
	folder.boundToProject = YES;
	return folder;
}

+ (GlossaryFolder*)folderForPath:(NSString*)path name:(NSString*)name
{
	GlossaryFolder *folder = [[GlossaryFolder alloc] init];	
	folder.name = name;
	folder.path = path;
	folder.deletable = YES;
	folder.boundToProject = NO;
	return folder;
}


- (NSString*)nameAndPath
{
	NSString *title = [NSString stringWithFormat:@"%@ — %@", self.name, [self.path stringByAbbreviatingWithTildeInPath]];
	return title;
}

- (NSArray*)glossaries
{
	return [self.glossaryMap allValues];
}

- (NSArray*)sortedGlossaries
{
    return [[self glossaries] sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2){
		return [[obj1 name] caseInsensitiveCompare:[obj2 name]]; 
    }];
}

- (BOOL)isBoundToProject:(id<ProjectProvider>)provider
{
	if(provider) {
		return [self.path isEqualToString:[[provider projectModel] projectGlossaryFolderPath]];		
	} else {
		return NO;
	}
}

- (NSString*)name
{
	if(name == nil) {
		self.name = [self.path lastPathComponent];
	}
	return name;
}

- (void)setName:(NSString*)n
{
    name = [n copy]; 
}

- (BOOL)isEqual:(id)anObject
{	
	if(![anObject isKindOfClass:[GlossaryFolder class]]) {
		return NO;
	}
	
	return [self.path isEqualToPath:[anObject path]];
}

- (NSUInteger)hash
{
	return [self.path hash];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"{ Path = \"%@\", glossaries = %ld }", self.path, self.glossaryMap.count];
}

#pragma mark Persistent Data

- (void)setPersistentData:(NSDictionary*)data
{
	self.path = data[@"path"];
	self.name = data[@"name"];
	self.deletable = [data booleanForKey:@"deletable"];		
	self.boundToProject = [data booleanForKey:@"boundToProject"];
	self.glossaryMap = [[AZOrderedDictionary alloc] init];
	for(NSDictionary *gdata in data[@"glossaryData"]) {
		Glossary *g = [[Glossary alloc] init];
		if([g setPersistentData:gdata]) {
			g.folder = self;
			[self.glossaryMap setObject:g forKey:g.targetFile];
		} else {
			ERROR(@"Unable to restore cached data for glossary %@", g);
		}
	}
}

- (NSDictionary*)persistentData
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	[dic setObjectOrNil:self.path forKey:@"path"];
	[dic setObjectOrNil:self.name forKey:@"name"];
	dic[@"boundToProject"] = @(self.boundToProject);
	dic[@"deletable"] = @(self.deletable);
	NSMutableArray *glossaryData = [NSMutableArray array];
	for(Glossary *glossary in [self glossaries]) {
		[glossaryData addObject:[glossary persistentData]];
	}
	dic[@"glossaryData"] = glossaryData;
	return dic;
}

@end
