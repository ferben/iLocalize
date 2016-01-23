//
//  PreferencesAdvanced.m
//  iLocalize3
//
//  Created by Jean on 02.01.06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "PreferencesAdvanced.h"
#import "Preferences.h"

@implementation PreferencesAdvanced

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
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        if (![bundle loadNibNamed:@"PreferencesAdvanced" owner:self topLevelObjects:nil])
        {
            // throw exception
            @throw [NSException exceptionWithName:@"View initialization failed"
                                           reason:@"PreferencesAdvanced: Could not load resources!"
                                         userInfo:nil];
        }
	}

    return self;
}


- (void)awakeFromNib
{
}

#pragma mark -

- (BOOL)autoSnapshotEnabled
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"enableAutoSnapshot"];
}

- (int)maximumNumberOfSnapshots
{
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"maxSnapshots"];
}

#pragma mark -

- (IBAction)selectProjectDefaultFolder:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
    [panel beginSheetModalForWindow:mWindow
                  completionHandler:^(NSInteger result) {
                      if(result == NSFileHandlingPanelOKButton) {
                          [[NSUserDefaults standardUserDefaults] setObject:[[[panel URL] path] stringByAbbreviatingWithTildeInPath] forKey:@"newProjectDefaultFolder"];
                      }                      
                  }];
}

#pragma mark -

- (NSString*)interfaceBuilder3Path
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:@"ib3path"];
}

- (void)browseInterfaceBuilderPath:(NSString*)key
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setDirectoryURL:[NSURL fileURLWithPath:@"/Applications"]];
    [panel beginSheetModalForWindow:mWindow
                  completionHandler:^(NSInteger result) {
                      if(result == NSFileHandlingPanelOKButton) {
                          [[NSUserDefaults standardUserDefaults] setObject:[[panel URL] path] forKey:key];
                      }                      
                  }];
}

- (IBAction)browseIB3Path:(id)sender
{
	[self browseInterfaceBuilderPath:@"ib3path"];
}

#pragma mark ibtool

- (IBAction)addIbtoolPlugin:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setCanChooseFiles:YES];
	[panel setCanChooseDirectories:NO];
	[panel setAllowsMultipleSelection:YES];
    [panel beginSheetModalForWindow:mWindow
                  completionHandler:^(NSInteger result) {
                      if(result == NSFileHandlingPanelOKButton) {
                          for (NSURL *url in [panel URLs]) {
                              NSString *file = [url path];
                              if([[file pathExtension] isEqualToString:@"ibplugin"]) {
                                  NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                                  dic[@"path"] = file;
                                  [mIbtoolPlugins addObject:dic];		
                              }                              
                          }
                          [[Preferences shared] clearIbtoolPlugins];
                      }
                  }];    
}

@end
