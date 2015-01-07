//
//  ImageTool.m
//  iLocalize3
//
//  Created by Jean on 12.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ImageTool.h"


@implementation ImageTool

static ImageTool *shared = nil;

+ (id)shared
{
    @synchronized(self) {
        if(shared == nil)
            shared = [[ImageTool alloc] init];        
    }
	return shared;
}

- (id)init
{
	if(self = [super init]) {
		mImages = [[NSMutableDictionary alloc] init];
	}
	return self;
}


- (NSImage *)imageSelectedUsingImage:(NSImage *)source
{
	NSSize imageSize = [source size];
	NSRect r = NSMakeRect(0, 0, imageSize.width, imageSize.height);
	
	NSImage *selectedLayer = [[NSImage alloc] initWithSize:imageSize];
	[selectedLayer lockFocus];
	[[NSColor colorWithDeviceRed:0.2 green:0.2 blue:0.2 alpha:0.5] set];
	[NSBezierPath fillRect:r];	
	[selectedLayer unlockFocus];
	
	NSImage *target = [[NSImage alloc] initWithSize:imageSize];
	[target lockFocus];
    // [source setFlipped:YES];
	[source drawInRect:r operation:NSCompositeSourceOver fraction:1];
	[selectedLayer drawInRect:r operation:NSCompositeSourceAtop fraction:1];
	[target unlockFocus];	
	
	return target;
}

- (NSImage*)imageNamed:(NSString*)name
{
	return mImages[name];
}

- (NSImage*)imageNamed:(NSString*)name selected:(BOOL)selected
{
	NSString *internalName = selected?[name stringByAppendingString:@"_selected"]:name;
	
	NSImage *image = [self imageNamed:internalName];
	if(!image) {
		image = [NSImage imageNamed:name];
		if(selected)
			image = [self imageSelectedUsingImage:image];
		mImages[internalName] = image;
	}
	return image;
}

@end
