//
//  Utils.m
//  iLocalize3
//
//  Created by Jean on 6/25/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "Utils.h"
#include <Availability.h>


@implementation Utils

static NSThread *mainThread = nil;

+ (BOOL)isMainThread
{
	if(mainThread == nil) {
		mainThread = [NSThread currentThread];
	}
	return [NSThread currentThread] == mainThread;
}

+ (NSPoint)posInCellAtMouseLocation:(NSPoint)pos row:(NSInteger *)row column:(NSInteger *)column tableView:(NSTableView *)tv
{
	NSPoint posInTableView = [tv convertPoint:pos fromView:nil];
	*row = [tv rowAtPoint:posInTableView];
	*column = [tv columnAtPoint:posInTableView];
	NSPoint posInCell;
	if(*row >= 0 && *column >= 0) {
		NSRect cellFrame = [tv frameOfCellAtColumn:*column row:*row];
		posInCell = NSMakePoint(posInTableView.x-cellFrame.origin.x, posInTableView.y-cellFrame.origin.y);
	} else {
		posInCell = NSMakePoint(-1, -1);
	}
	return posInCell;
}

+ (SInt32)getOSVersion
{
    static SInt32 exactVersion = 0x00;
    
    if (0x00 == exactVersion)
    {
        @synchronized(self)
        {
            if (0x00 == exactVersion)
            {
                if ([NSProcessInfo instancesRespondToSelector:@selector(operatingSystemVersion)])
                {
                    NSOperatingSystemVersion sysVersion = [[NSProcessInfo processInfo] operatingSystemVersion];

                    switch (sysVersion.majorVersion)
                    {
                        case 11:
                            exactVersion = 0x01100;
                            break;
                            
                        case 10:
                            exactVersion = 0x01000;
                            break;
                            
                        case  9:
                            exactVersion = 0x0900;
                            break;
                            
                        case  8:
                            exactVersion = 0x0800;
                            break;
                            
                        case  7:
                            exactVersion = 0x0700;
                    }
                    
                    exactVersion = exactVersion | ((sysVersion.minorVersion & 0x0F) << 4) | (sysVersion.patchVersion & 0x0F);
                }
            }
        }
    }
    
    return exactVersion;
}


/* fd:2015-01-07 replaced by new version (see above) after a hint from Thorsten Lemke
+ (SInt32)getOSVersion
{
	SInt32 MacVersion;
	if (Gestalt(gestaltSystemVersion, &MacVersion) == noErr) {
		return MacVersion;
	} else {
		return 0;
	}
}
*/

+ (BOOL)isOSVersionTigerAndBelow:(SInt32)version
{
	return version <= 0x1049;
}

+ (BOOL)isOSTigerAndBelow
{
	return [Utils isOSVersionTigerAndBelow:[Utils getOSVersion]];
}

@end
