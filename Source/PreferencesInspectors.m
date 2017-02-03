//
//  PreferencesInspectors.m
//  iLocalize3
//
//  Created by Jean on 02.01.06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "PreferencesInspectors.h"


@implementation PreferencesInspectors

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
    
    dic[@"alternateTranslationLimitEnable"] = @YES;
    dic[@"alternateTranslationLimit"] = @10;
    
    dic[@"glossaryMatchLimitEnable"] = @YES;
    dic[@"glossaryMatchLimit"] = @10;
    
    dic[@"alternateTranslationThreshold"] = @1;
    dic[@"glossaryMatchThreshold"] = @1;
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:dic];
}

- (id)init
{
    if (self = [super init])
    {
        // 2016-01-23 fd: There is no PreferencesInspectors.xib at all?!?
        
        // [NSBundle loadNibNamed:@"PreferencesInspectors" owner:self];
    }
    
    return self;
}

#pragma mark -

- (BOOL)alternateTranslationLimitEnable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"alternateTranslationLimitEnable"];
}

- (NSInteger)alternateTranslationLimit
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"alternateTranslationLimit"];
}

- (NSInteger)alternateTranslationThreshold
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"alternateTranslationThreshold"];
}

#pragma mark -

- (BOOL)glossaryMatchLimitEnable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"glossaryMatchLimitEnable"];
}

- (NSInteger)glossaryMatchLimit
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"glossaryMatchLimit"];
}

- (NSInteger)glossaryMatchThreshold
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"glossaryMatchThreshold"];
}

@end
