//
//  FMModule.m
//  iLocalize3
//
//  Created by Jean on 26.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMModule.h"


@implementation FMModule

- (id)initWithManager:(FMManager*)manager
{
    if(self = [super init]) {
        mManager = manager;        
    }
    return self;
}

+ (FMModule*)moduleWithManager:(FMManager*)manager
{
    return [[self alloc] initWithManager:manager];
}

- (Class)editorClass
{
    return NULL;
}

- (Class)engineClass
{
    return NULL;
}

- (Class)controllerClass
{
    return NULL;
}

- (FMManager*)manager
{
    return mManager;
}

- (NSString*)name
{
    return NSStringFromClass([self class]);
}

- (NSString*)path
{
    return [self builtIn]?NSLocalizedString(@"Built-in", @"File Editor Built-in"):@"";
}

- (NSImage*)fileImage
{
    return [NSImage imageNamed:@"FileIconGeneric"];
}

- (BOOL)supportsFlagLayout
{
    return NO;
}

- (BOOL)builtIn
{
    return NO;
}

- (void)load
{
    
}

- (void)unload
{
    
}

@end
