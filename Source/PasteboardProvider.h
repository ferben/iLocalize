//
//  PasteboardProvider.h
//  iLocalize3
//
//  Created by Jean on 24.07.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@interface PasteboardProvider : NSObject {
	NSMutableDictionary *mTypes;
}

+ (PasteboardProvider*)shared;

- (void)declareTypes:(NSArray*)types owner:(id)owner pasteboard:(NSPasteboard*)pb;
- (void)removeOwner:(id)owner;

@end
