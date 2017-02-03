//
//  NewProjectAnalyzeBundle.m
//  iLocalize
//
//  Created by Jean on 6/11/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "AnalyzeBundleOVC.h"
#import "LanguageTool.h"
#import "SmartPathParser.h"
#import "FileTool.h"
#import "NewProjectSettings.h"
#import "NibEngine.h"
#import "AZPathNode.h"

@implementation AnalyzeBundleOVC

@synthesize rootPath;
@synthesize problems;

- (id)init
{
	if((self = [super initWithNibName:@"AnalyzeBundle" bundle:nil])) {
        rootNode = [[AZPathNode alloc] init];
	}
	return self;
}


- (void)updateButtons
{
	AZPathNode *item = [outlineView selectedItem];
	[copyToClipboardButton setEnabled:item != nil];
	[revealButton setEnabled:item.payload != nil];	
}

- (void)awakeFromNib
{
    NSString *rootPathSolved = rootPath?rootPath:@"/";
    for(NSDictionary *problem in self.problems) {
        AZPathNode *problemNode = [AZPathNode rootNodeWithPath:rootPathSolved];
        problemNode.payload = problem;

        for(NSDictionary *fileInfo in problem[@"files"]) {
            NSString *file = fileInfo[@"file"];
            AZPathNode *childNode = [problemNode addRelativePath:[file stringByRemovingPrefix:rootPathSolved]];
            childNode.payload = file;
        }
                
        [rootNode addNode:problemNode];
    }

	for(int r=0; r<[outlineView numberOfRows]; r++) {
		AZPathNode *node = [outlineView itemAtRow:r];
		if([[node children] count] < 10) {
			[outlineView expandItem:node];			
		}
	}
    
	[self updateButtons];
}

#pragma mark Actions

- (IBAction)copyToClipboard:(id)sender
{
	NSMutableString *s = [NSMutableString string];
    for (AZPathNode *node in [outlineView selectedItems]) {
        [node visitLeaves:^(AZPathNode *n) {
            [s appendString:n.payload];
            [s appendString:@"\n"];        
        }];        
    }

    if (s.length > 0) {
        NSPasteboard *pb = [NSPasteboard generalPasteboard];
        [pb declareTypes:@[NSStringPboardType] owner:nil];
        [pb setString:s forType:NSStringPboardType];		        
    }
}

- (IBAction)revealInFinder:(id)sender
{
    for (AZPathNode *node in [outlineView selectedItems]) {
        NSString *file = node.payload;
        if(file) {
            [FileTool revealFile:file];		
        }
    }
}

#pragma mark Delegate

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	[self updateButtons];
}

- (NSString *)outlineView:(NSOutlineView *)outlineView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tc item:(id)item mouseLocation:(NSPoint)mouseLocation
{
    AZPathNode *node = item;
    if([node.payload isKindOfClass:[NSDictionary class]]) {
        return (node.payload)[@"tooltip"];        
    } else {
        return nil;
    }
}

#pragma mark Source

- (NSUInteger)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item
{
	if (item == NULL)
    {
        return [[rootNode children] count];
	}
    else
    {
        return [[item children] count];
	}
}

- (id)outlineView:(NSOutlineView *)ov child:(int)index ofItem:(id)item
{
	if(item == NULL) {
        return [rootNode children][index];
	} else {
        return [item children][index];
	}
}

- (BOOL)outlineView:(NSOutlineView *)ov isItemExpandable:(id)item
{
    return [[item children] count] > 0;
}

- (id)outlineView:(NSOutlineView *)ov objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    NSString *value = nil;
    
    AZPathNode *node = item;
    if([node.payload isKindOfClass:[NSDictionary class]]) {
        value = (node.payload)[@"typeDisplay"];
    }
    
    if(value == nil) {
        return [item name];        
    } else {
        return value;
    }
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item 
{	
    AZPathNode *node = item;
    if([node.payload isKindOfClass:[NSDictionary class]]) {
        [cell setImage:nil];
    } else {
        NSString *file = [node absolutePath];
        if(file) {
            [cell setImage:[[NSWorkspace sharedWorkspace] iconForFile:file]];
        } else {
            [cell setImage:nil];
        }        
    }
}

@end
