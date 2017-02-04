//
//  LanguageInfoModel.h
//  iLocalize
//
// This class is used when displaying a menu of languages. For example:
// - AddLanguage
// - Languages Preferences
//
//  Created by Jean on 3/28/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

@interface LanguageInfoModel : NSObject
{
    NSString  *_identifier;
}

@property (strong) NSString *identifier;
@property (weak, readonly) NSString *displayName;
@property (weak, readonly) NSString *languageIdentifier;

+ (LanguageInfoModel *)infoWithIdentifier:(NSString *)identifier;

@end
