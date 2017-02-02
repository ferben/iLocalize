//
//  ImportPreviewWC.m
//  iLocalize3
//
//  Created by Jean on 25.12.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ImportPreviewOVC.h"
#import "ImportDiff.h"
#import "ImportBundlePreviewOp.h"
#import "AZPathNode.h"
#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"
#import "ProjectModel.h"
#import "FileTool.h"
#import "BundleSource.h"

@implementation ImportPreviewOVC

@synthesize baseBundleSource;
@synthesize items;

- (id)init
{
	if((self = [super initWithNibName:@"ImportPreview"])) {
		mDescription = [[NSMutableString alloc] init];
		root = [[AZPathNode alloc] init];
	}
	return self;
}


- (NSString*)nextButtonTitle
{
	return NSLocalizedString(@"Update", nil);
}

- (void)willShow
{
	[mDescription setString:[[NSDate date] description]];
		
	NSMutableDictionary *opDic = [NSMutableDictionary dictionary];
    for(ImportDiffItem *item in items) {
		if(item.operation == OPERATION_IDENTICAL) {
			continue;
		}
        
		NSNumber *key = [NSNumber numberWithUnsignedInt:item.operation];
		NSMutableArray *opItems = opDic[key];
		if(!opItems) {
			opItems = [NSMutableArray array];
			opDic[key] = opItems;
		}
		[opItems addObject:item];
		
        
		[mDescription appendFormat:@"\n[%@] %@", item.operationName, item.file];
    }
    
	// Build the tree
    [root removeAllChildren];
	NSArray *sortedKeys = [[opDic allKeys] sortedArrayUsingComparator:(NSComparator)^(id obj1, id obj2){
		return [obj1 compare:obj2]; 
    }];

	for(NSNumber *op in sortedKeys) {
        // Build the operation node
        AZPathNode *opNode = [AZPathNode rootNodeWithPath:@""];
        opNode.payload = op;
        		
        // Build the children for that particular operation
		for(ImportDiffItem *item in opDic[op]) {
            AZPathNode *itemNode = [opNode addRelativePath:item.file];
            itemNode.payload = item;
		}
        
        [root addNode:opNode];
	}

    [root applyState:NSOnState];

	[outlineView reloadData];
	[outlineView expandItem:nil expandChildren:YES];
}

- (IBAction)export:(id)sender
{
	NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes:@[@"txt"]];
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if(result == NSFileHandlingPanelOKButton) {
            [mDescription writeToFile:[[panel URL] path] atomically:YES encoding:[mDescription smallestEncoding] error:nil];
        }                
    }];
}

#pragma mark Source

- (int)outlineView:(NSOutlineView *)ov numberOfChildrenOfItem:(id)item
{
	if(item == NULL) {
		return [[root children] count];
	} else {
		return [[item children] count];
	}
}

- (id)outlineView:(NSOutlineView *)ov child:(int)index ofItem:(id)item
{
	if(item == NULL) {
		return [root children][index];
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
	BOOL statusColumn = [[tableColumn identifier] isEqualToString:@"Status"];
		
    AZPathNode *pn = item;
    
    if (statusColumn)
    {
        if ([pn.payload isKindOfClass:[NSNumber class]])
        {
            return nil;
        }
        else
        {
            return [pn.payload image];
        }
    }
    else
    {
        return [NSNumber numberWithInteger:pn.state];
    }
}

- (void)outlineView:(NSOutlineView *)ov setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	int state = [object intValue];
	if(state == NSMixedState) {
		state = NSOnState;
	}
	
	AZPathNode *tn = item;
    [tn applyState:state];
	[ov reloadData];
}

- (void)outlineView:(NSOutlineView *)olv willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item 
{	
    AZPathNode *node = item;
	BOOL statusColumn = [[tableColumn identifier] isEqualToString:@"Status"];
	if(!statusColumn) {
		id payload = node.payload;
		NSString *title = nil;
		NSImage *icon = nil;
		if([payload isKindOfClass:[NSNumber class]]) {
			__block int enabledCount = 0;
            [node visitLeaves:^(AZPathNode *n) {
                if(n.state == NSOnState) {
					enabledCount++;
				}
            }];
            
			NSString *ls = @"";
			switch ([payload intValue]) {
				case OPERATION_ADD:
					if(enabledCount == 0) {
						ls = NSLocalizedString(@"No file will be added", nil);
					} else if(enabledCount == 1) {
						ls = NSLocalizedString(@"One file will be added", nil);
					} else {
						ls = NSLocalizedString(@"%d files will be added", nil);	
					}
					break;
				case OPERATION_DELETE:
					if(enabledCount == 0) {
						ls = NSLocalizedString(@"No file will be removed", nil);
					} else if(enabledCount == 1) {
						ls = NSLocalizedString(@"One file will be removed", nil);
					} else {
						ls = NSLocalizedString(@"%d files will be removed", nil);	
					}
					break;
				case OPERATION_UPDATE:
					if(enabledCount == 0) {
						ls = NSLocalizedString(@"No file will be updated", nil);
					} else if(enabledCount == 1) {
						ls = NSLocalizedString(@"One file will be updated", nil);
					} else {
						ls = NSLocalizedString(@"%d files will be updated", nil);	
					}					
					break;
			}
			title = [NSString stringWithFormat:ls, enabledCount];
		} else {
			NSString *relativeFile = [node relativePath];
			NSString *absoluteFile = [FileTool resolveEquivalentFile:[[self.projectProvider projectController] absoluteProjectPathFromRelativePath:relativeFile]];
			if(![absoluteFile isPathExisting]) {
				// If the path doesn't exist, it means it is a new file to add. We need to use the source path for that.
				absoluteFile = [FileTool resolveEquivalentFile:[self.baseBundleSource.sourcePath stringByAppendingPathComponent:relativeFile]];
			}

            title = [node name];
			icon = [[NSWorkspace sharedWorkspace] iconForFile:absoluteFile];                        
		}

		[cell setTitle:title];
		[cell setImage:icon];		
	}
}

@end
