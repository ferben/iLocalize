//
//  PreferencesGeneral.m
//  iLocalize3
//
//  Created by Jean on 02.01.06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "PreferencesGeneral.h"
#import "PreferencesWC.h"

#import "Constants.h"

@interface PreferencesGeneral (PrivateMethods)
- (void)applyEditorFont;
@end

@implementation PreferencesGeneral

static id _shared = nil;

+ (id)shared
{
    @synchronized(self) {
        if(_shared == nil)
            _shared = [[self alloc] init];        
    }
    return _shared;
}

- (id)init
{
	if (self = [super init])
    {
        // 2016-01-23 fd: There is no PreferencesGeneral.xib any longer.
        // We're using PreferencesLocalization.xib instead.
        
        /* 
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        if (![bundle loadNibNamed:@"PreferencesGeneral" owner:self topLevelObjects:nil])
        {
            // throw exception
            @throw [NSException exceptionWithName:@"View initialization failed"
                                           reason:@"PreferencesGeneral: Could not load resources!"
                                         userInfo:nil];
        }
        */
	}

    return self;
}

#pragma mark -

- (void)setInspectors:(NSArray*)array
{
	[[NSUserDefaults standardUserDefaults] setObject:array forKey:@"Inspectors"];
}

- (NSArray*)inspectors
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"Inspectors"];
}

- (BOOL)automaticallySaveModifiedFiles
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"automaticallySaveModifiedFiles"];
}

- (BOOL)automaticallyReloadFiles
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"automaticallyReloadFiles"];
}

- (BOOL)automaticallySaveProject
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"autoSaveProject"];
}

- (NSInteger)automaticallySaveProjectDelay
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"autoSaveProjectDelay"];
}

- (BOOL)autoUpdateSmartFilters
{
	//return [[NSUserDefaults standardUserDefaults] integerForKey:@"autoUpdateSmartFilters"];	
	// Version 4: always NO
	return NO;
}

- (BOOL)recentDocumentsOnlyProject
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"recentDocumentsOnlyProject"];
}

@end
