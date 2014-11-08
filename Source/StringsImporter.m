//
//  StringsImporter.m
//  iLocalize
//
//  Created by Jean Bovet on 4/29/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "StringsImporter.h"
#import "StringsEngine.h"
#import "StringsContentModel.h"
#import "StringModel.h"

@implementation StringsImporter

- (NSArray*)readableExtensions
{
	return @[@"strings"];
}

- (BOOL)importDocument:(NSURL*)url error:(NSError**)error
{
	StringsEngine *engine = [StringsEngine engineWithConsole:nil];
	StringsContentModel *model = [engine parseStringModelsOfStringsFile:[url path]];
	for(StringModel *sm in [model strings]) {
		[self addStringWithKey:nil base:[sm key] translation:[sm value] file:nil];
	}
	self.sourceLanguage = nil;
	self.targetLanguage = nil;
		
	return YES;
}

@end
