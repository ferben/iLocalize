//
//  Preferences.h
//  iLocalize
//
//  Created by Jean Bovet on 1/21/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#define DEFAULT_ENCODING @"defaultEncodingIdentifier"

#define AUTO_PROPAGATE_TRANSLATION_NONE      0
#define AUTO_PROPAGATE_TRANSLATION_SELECTED  1
#define AUTO_PROPAGATE_TRANSLATION_ALL       2

#define STARTUP_DO_NOTHING       0
#define STARTUP_OPEN_LAST_USED   1
#define STARTUP_NEW_PROJET       2
#define STARTUP_PROJECT_BROWSER  3

static NSString *const kAlwaysOverwriteGlossaryPrefs = @"always.overwrite.glossary";
static NSString *const kAlwaysViewGlossaryPrefs = @"always.view.glossary";

@class StringEncoding;

@interface Preferences : NSObject
{
    NSMutableArray  *mCachedIbtoolPlugins;
}

+ (id)shared;

- (NSInteger)maximumNumberOfHistoryFiles;
- (BOOL)consoleDisplayUsingNSLog;

- (BOOL)baseLanguageReadOnly;
- (BOOL)developerMode;
- (BOOL)ignoreCase;

- (StringEncoding *)defaultEncoding;

- (void)clearIbtoolPlugins;
- (NSArray *)ibtoolPlugins;

@end
