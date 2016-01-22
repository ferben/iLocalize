//
//  Preferences.m
//  iLocalize
//
//  Created by Jean Bovet on 1/21/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "Preferences.h"
#import "StringEncoding.h"

@implementation Preferences

static id _shared = nil;

+ (id)shared
{
    @synchronized(self) {
        if(_shared == nil)
            _shared = [[self alloc] init];        
    }
    return _shared;
}

+ (void)initialize
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    			
	// General
	
	dic[@"actionAtStartup"] = @STARTUP_OPEN_LAST_USED;
    
	dic[@"newProjectRememberFields"] = @YES;
	
    dic[@"automaticallySaveModifiedFiles"] = @YES;
	dic[@"automaticallyReloadFiles"] = @YES;    
	dic[@"autoSaveProjectDelay"] = @10;		
	
	dic[@"recentDocumentsOnlyProject"] = @YES;

    dic[@"reopenLastProjects"] = @NO;

	// Localization
    dic[@"behaviorMode"] = @0;		
	dic[@"translateIgnoreControlCharacters"] = @NO;		
	dic[@"autoFillTranslationWithBaseForNewLanguage"] = @NO;
	dic[@"baseLanguageReadOnly"] = @NO;		    
	dic[@"autoPropagateTranslationMode"] = @AUTO_PROPAGATE_TRANSLATION_SELECTED;
	
	// Advanced
	dic[@"newProjectDefaultFolder"] = @"~/Documents/iLocalize";

	dic[@"enableAutoSnapshot"] = @NO;
	dic[@"maxSnapshots"] = @5;
	dic[@"maxHistoryFolderFiles"] = @3;        
	dic[@"consoleDisplayUsingNSLog"] = @NO;
	
	dic[@"nibcompare"] = @YES;
	dic[@"outputnibcommand"] = @NO;
				
	dic[@"ibtoolPath"] = @"/usr/bin/ibtool";
	dic[@"nibtoolPath"] = @"/usr/bin/nibtool";
	dic[@"zipPath"] = @"/usr/bin/zip";
	dic[@"diffPath"] = @"/usr/bin/opendiff";

	dic[@"ib3path"] = @"/Developer/Applications/Interface Builder.app";
	dic[@"ib2path"] = @"/Xcode2.5/Applications/Interface Builder.app";	
			
	//
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:dic];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		mCachedIbtoolPlugins = nil;
	}
	return self;
}


- (int)maximumNumberOfHistoryFiles
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"maxHistoryFolderFiles"];
}

- (BOOL)consoleDisplayUsingNSLog
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"consoleDisplayUsingNSLog"];
}

- (BOOL)baseLanguageReadOnly
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"baseLanguageReadOnly"];	
}

- (BOOL)developerMode
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"behaviorMode"] == 0;
}

- (BOOL)ignoreCase
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"translateIgnoreCase"];
}

- (StringEncoding*)defaultEncoding
{
	NSInteger identifier = [[NSUserDefaults standardUserDefaults] integerForKey:DEFAULT_ENCODING];	
	return [StringEncoding stringEncodingForIdentifier:identifier];
}

- (void)clearIbtoolPlugins
{
	mCachedIbtoolPlugins = nil;
}

- (NSArray*)ibtoolPlugins
{
	if(mCachedIbtoolPlugins == nil) {
		mCachedIbtoolPlugins = [[NSMutableArray alloc] init];
		[[[NSUserDefaults standardUserDefaults] arrayForKey:@"ibtoolPlugins"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSDictionary *dic = obj;
			[mCachedIbtoolPlugins addObject:dic[@"path"]];			
		}];
	}
	return mCachedIbtoolPlugins;
}


@end
