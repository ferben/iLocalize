//
//  AppTool.m
//  iLocalize3
//
//  Created by Jean on 06.09.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AppTool.h"
#import "FileTool.h"

@implementation AppTool

// Used to search for a particular value in the Preferences
/*
+ (void)search:(id)container forValue:(id)value found:(NSMutableArray*)found path:(NSArray*)path
{
	if([container isKindOfClass:[NSDictionary class]]) {
		for(id key in [container allKeys]) {			
			[AppTool search:[container objectForKey:key] forValue:value found:found path:[path arrayByAddingObject:key]];			
		}		
	} else if([container isKindOfClass:[NSArray class]]) {
		for(id v in container) {
			[AppTool search:v forValue:value found:found path:path];			
		}
	} else {
		if([container isEqual:value]) {
			[found addObject:[NSString stringWithFormat:@"%@: %@", path, value]];
		}
	}
}

+ (void)searchDomains
{
	NSMutableArray *found = [NSMutableArray array];
	
	for(NSString *domain in [[NSUserDefaults standardUserDefaults] persistentDomainNames]) {
		NSDictionary *d = [[NSUserDefaults standardUserDefaults] persistentDomainForName:domain];
		[AppTool search:d forValue:[NSNumber numberWithInt:20] found:found path:[NSArray arrayWithObject:domain]];
	}
	NSLog(@"%@", found);	
}
*/

+ (BOOL)launchApplication:(NSString*)app language:(NSString*)language bringToFront:(BOOL)bringToFront
{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain];
    NSMutableDictionary *ndic = [NSMutableDictionary dictionaryWithDictionary:dic];
    NSMutableArray *array = [NSMutableArray arrayWithArray:ndic[@"AppleLanguages"]];
    [array removeObject:language];
    [array insertObject:language atIndex:0];
    ndic[@"AppleLanguages"] = array;
    
    // Don't set the AppleLocale with the language only. It has to have
    // also a region (eg en_US) because otherwise some app, like iCalamus,
    // won't load correctly. To avoid any issue, we don't change it.
    // Implement that ability to choose which locale to use for the current language
//    [ndic setObject:language forKey:@"AppleLocale"];
    
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:ndic forName:NSGlobalDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    BOOL success = NO;
    @try {
        NSError *error = nil;
        NSRunningApplication *ra = [[NSWorkspace sharedWorkspace] launchApplicationAtURL:[NSURL fileURLWithPath:app]
                                                                                 options:NSWorkspaceLaunchWithoutAddingToRecents|NSWorkspaceLaunchNewInstance
                                                                           configuration:nil
                                                                                   error:&error];
        if (nil == ra) {
            NSLog(@"Failed to launch the application: %@", [error localizedDescription]);
        } else {
            if (bringToFront) {
                [ra activateWithOptions:NSApplicationActivateAllWindows];
            }
            success = YES;
        }
    }
    @finally {
        [[NSUserDefaults standardUserDefaults] setPersistentDomain:dic forName:NSGlobalDomain];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return success;
}

@end
