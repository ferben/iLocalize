//
//  ViewCustom.m
//  iLocalize3
//
//  Created by Jean on 03.02.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ViewCustom.h"


@implementation ViewCustom

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

// Note from WWDC: call this method when moving a view into a nsbox with setContentView
- (void)registerDraggedTypes
{
	[self registerForDraggedTypes:@[NSFilenamesPboardType,NSFilesPromisePboardType]];		
}

#pragma mark -

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender 
{
	NSDragOperation op = [super draggingEntered:sender];
	if(op == NSDragOperationNone) {
		op = NSDragOperationCopy;		
	}
	return op;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	NSDragOperation op = [super draggingEntered:sender];
	if(op == NSDragOperationNone) {
		op = NSDragOperationCopy;		
	}
	return op;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender 
{
	BOOL result = [super draggingEntered:sender];
	if(!result) {
		NSPasteboard *pboard = [sender draggingPasteboard];
		NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
		[delegate performSelector:@selector(viewFileDidDrag:) withObject:[filenames firstObject]];
		return YES;		
	}
	return result;
}

@end
