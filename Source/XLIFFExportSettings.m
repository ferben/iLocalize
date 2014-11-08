//
//  XLIFFExportSettings.m
//  iLocalize
//
//  Created by Jean Bovet on 3/23/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XLIFFExportSettings.h"
#import "SEIConstants.h"


@implementation XLIFFExportSettings

@synthesize files;
@synthesize format;
@synthesize sourceLanguage;
@synthesize targetLanguage;
@synthesize targetFile;
- (id) init
{
	self = [super init];
	if (self != nil) {
		self.format = XLIFF;
	}
	return self;
}

// used for persistence
- (void)setData:(NSDictionary*)data
{
	if(data == nil) return;
	
	self.format = [data[@"format"] intValue];
	self.sourceLanguage = data[@"sourceLanguage"];
	self.targetLanguage = data[@"targetLanguage"];
	self.targetFile = data[@"targetFile"];
}

- (NSDictionary*)data
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"format"] = [NSNumber numberWithInt:self.format];
	[dic setObjectOrNil:self.sourceLanguage forKey:@"sourceLanguage"];
	[dic setObjectOrNil:self.targetLanguage forKey:@"targetLanguage"];
	[dic setObjectOrNil:self.targetFile forKey:@"targetFile"];	
	return dic;
}

@end
