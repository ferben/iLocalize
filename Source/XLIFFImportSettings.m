//
//  XLIFFImportSettings.m
//  iLocalize
//
//  Created by Jean Bovet on 3/24/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XLIFFImportSettings.h"


@implementation XLIFFImportSettings

@synthesize file;
@synthesize targetFiles;
@synthesize fileElements;
@synthesize useResnameInsteadOfSource;

// used for persistence
- (void)setData:(NSDictionary*)data
{
	if(data == nil) return;
	
	self.file = data[@"file"];
    self.useResnameInsteadOfSource = [data[@"useResnameInsteadOfSource"] boolValue];
}

- (NSDictionary*)data
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	[dic setObjectOrNil:self.file forKey:@"file"];
	dic[@"useResnameInsteadOfSource"] = @(self.useResnameInsteadOfSource);
	return dic;
}

@end
