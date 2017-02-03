//
//  StringsExporter.m
//  iLocalize
//
//  Created by Jean Bovet on 4/29/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "StringsExporter.h"
#import "StringsEngine.h"
#import "StringEncoding.h"
#import "StringsContentModel.h"
#import "StringModel.h"

@implementation StringsExporter

+ (NSString*)writableExtension
{
	return @"strings";
}
- (id) init
{
	self = [super init];
	
    if (self != nil)
    {
		stringsContentModel = nil;
	}
	
    return self;
}


- (void)buildHeader
{
	stringsContentModel = [[StringsContentModel alloc] init];
	row = 0;
}

- (void)buildFooter
{
	StringsEngine *engine = [StringsEngine engineWithConsole:nil];
	NSString *encodedStrings = [engine encodeStringModels:stringsContentModel baseStringModels:nil
												skipEmpty:NO format:STRINGS_FORMAT_APPLE_STRINGS
												 encoding:ENCODING_UNICODE];
	[self.content appendString:encodedStrings];
	stringsContentModel = nil;
}

- (void)buildFileHeader:(id<FileControllerProtocol>)fc
{	
	// there is no nothing of file segment in strings
}

- (void)buildFileFooter:(id<FileControllerProtocol>)fc
{
	// there is no nothing of file segment in strings
}

- (void)buildStringWithString:(id<StringControllerProtocol>)sc index:(NSUInteger)index globalIndex:(NSUInteger)globalIndex file:(id<FileControllerProtocol>)fc
{
	StringModel *sm = [StringModel model];
	[sm setKey:sc.base as:STRING_QUOTED atRow:row];
	[sm setValue:sc.translation as:STRING_QUOTED atRow:row];
    [sm setComment:sc.baseComment as:STRING_QUOTED atRow:row];
	[stringsContentModel addStringModel:sm];
    
	if (row == 0)
    {
		row = 1;
	}
}


@end
