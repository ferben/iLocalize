//
//  LanguageInfoModel.m
//  iLocalize
//
//  Created by Jean on 3/28/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "LanguageInfoModel.h"
#import "LanguageTool.h"

@implementation LanguageInfoModel

@synthesize identifier=_identifier;

+ (LanguageInfoModel*)infoWithIdentifier:(NSString*)identifier
{
    LanguageInfoModel *info = [[LanguageInfoModel alloc] init];
    info.identifier = identifier;
    return info;
}

- (id)init
{
    if(self = [super init]) {
        _identifier = nil;
    }
    return self;
}


/*
- (BOOL)isEqual:(id)object
{
    NSLog(@">%@", [object class]);
    return [super isEqual:object];
}
*/

- (NSComparisonResult)compareDisplayName:(LanguageInfoModel*)other
{
    return [[self displayName] caseInsensitiveCompare:[other displayName]];
}

- (NSString*)displayName
{
    return [self.identifier displayLanguageName];
}

- (NSString*)languageIdentifier
{
    return [LanguageTool languageIdentifierForLanguage:self.identifier];
}

- (NSString*)description
{
    return [self languageIdentifier];
}

@end
