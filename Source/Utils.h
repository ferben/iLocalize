//
//  Utils.h
//  iLocalize3
//
//  Created by Jean on 6/25/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

@interface Utils : NSObject {

}
+ (BOOL)isMainThread;
+ (NSPoint)posInCellAtMouseLocation:(NSPoint)pos row:(int*)row column:(int*)column tableView:(NSTableView*)tv;
+ (SInt32)getOSVersion;
+ (BOOL)isOSVersionTigerAndBelow:(SInt32)version;
+ (BOOL)isOSTigerAndBelow;
@end
