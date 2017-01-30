//
//  NewProjectSettings.m
//  iLocalize
//
//  Created by Jean on 12/16/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "NewProjectSettings.h"
#import "Constants.h"

@implementation NewProjectSettings

@synthesize name;
@synthesize source;
@synthesize projectFolder;
@synthesize baseLanguage;
@synthesize localizedLanguages;
@synthesize copySourceOnlyIfExists;

- (id)init
{
	if((self = [super init])) {
		
	}
	return self;
}


- (NSString *)projectFolderPath
{
	return [self.projectFolder stringByAppendingPathComponent:self.name];
}

- (NSString *)projectFilePath
{
	return [[self projectFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", self.name, PROJET_EXT]];
}

@end
