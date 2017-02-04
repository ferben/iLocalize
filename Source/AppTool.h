//
//  AppTool.h
//  iLocalize3
//
//  Created by Jean on 06.09.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@interface AppTool : NSObject
{
}

+ (BOOL)launchApplication:(NSString *)app language:(NSString *)language bringToFront:(BOOL)bringToFront;

@end
