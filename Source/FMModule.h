//
//  FMModule.h
//  iLocalize3
//
//  Created by Jean on 26.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@class FMManager;

@interface FMModule : NSObject {
	FMManager	*mManager;
}

+ (FMModule*)moduleWithManager:(FMManager*)manager;

- (Class)editorClass;
- (Class)engineClass;
- (Class)controllerClass;

- (FMManager*)manager;

- (NSString*)name;
- (NSString*)path;

- (NSImage*)fileImage;
- (BOOL)supportsFlagLayout;

- (BOOL)builtIn;

- (void)load;
- (void)unload;

@end
