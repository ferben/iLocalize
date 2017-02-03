//
//  ImageTool.h
//  iLocalize3
//
//  Created by Jean on 12.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//


@interface ImageTool : NSObject {
    NSMutableDictionary        *mImages;
}
+ (id)shared;
- (NSImage*)imageNamed:(NSString*)name;
- (NSImage*)imageNamed:(NSString*)name selected:(BOOL)selected;
@end
