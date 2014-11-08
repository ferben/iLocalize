//
//  PresetsManager.m
//  iLocalize
//
//  Created by Jean Bovet on 4/2/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "PresetsManager.h"

typedef void(^PresetAlertCallbackBlock)(NSString *name);

@implementation PresetsManager

#define TAG_SAVE 10000
#define TAG_SAVE_AS 10001
#define TAG_RENAME 10002
#define TAG_DELETE 10003
#define TAG_DEFAULT 10004

- (id) init
{
	self = [super init];
	if (self != nil) {
		nameField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 22, 250, 22)];
		infoAlertLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 250, 14)];
		okButton = nil;
		originalName = nil;
	}
	return self;
}


- (void)buildPresetAndSelect:(int)select
{
	NSMenu *menu = [self.popUpButton menu];
	[menu removeAllItems];
	
	int tag = 0;
	
	for(id p in [self.delegate presets]) {
		[[menu addItemWithTitle:[self.delegate presetName:p] action:nil keyEquivalent:@""] setTag:tag++];
	}
	
	if(tag == 0) {
		// No presets. Add the default preset.
		[[menu addItemWithTitle:NSLocalizedString(@"Default", @"Default Preset Title") action:nil keyEquivalent:@""] setTag:TAG_DEFAULT];
		currentPresetTag = TAG_DEFAULT;
	} else {
		currentPresetTag = 0;
	}
	
	if(select >= 0) {
		currentPresetTag = select;
	}
	
	[menu addItem:[NSMenuItem separatorItem]];
	
	NSMenuItem *saveMenuItem = [menu addItemWithTitle:NSLocalizedString(@"Save", @"Preset Save") action:nil keyEquivalent:@""];
//	[saveMenuItem setAction:@selector(saveMenuItem:)];
//	[saveMenuItem setTarget:self];
	[saveMenuItem setTag:TAG_SAVE];
	[[menu addItemWithTitle:NSLocalizedString(@"Save As…", @"Preset Save As") action:nil keyEquivalent:@""] setTag:TAG_SAVE_AS];
	[[menu addItemWithTitle:NSLocalizedString(@"Rename…", @"Preset Rename") action:nil keyEquivalent:@""] setTag:TAG_RENAME];
	[[menu addItemWithTitle:NSLocalizedString(@"Delete", @"Preset Delete") action:nil keyEquivalent:@""] setTag:TAG_DELETE];
	
	[self.popUpButton setEnabled:YES];
	[self.popUpButton selectItemWithTag:currentPresetTag];
	[self.popUpButton setTarget:self];
	[self.popUpButton setAction:@selector(presetPopUp:)];
	
	// Trigger the selection if one is present so the UI gets updated with the data of this preset
	if(tag > 0 && currentPresetTag >= 0) {
		[self presetPopUp:self.popUpButton];
	}
}

//- (void)saveMenuItem:(id)sender
//{	
//	[popUpButton selectItemWithTag:currentPresetTag];
////	NSLog(@"Save!");
//}

- (void)buildPreset
{
	[self buildPresetAndSelect:-1];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	BOOL defaultPreset = currentPresetTag == TAG_DEFAULT;
	
	switch ([menuItem tag]) {
		case TAG_SAVE:
		case TAG_RENAME:
		case TAG_DELETE:
			return !defaultPreset;
	}
	return YES;
}

/**
 Returns true if the alert can validate the name.
 The name must not exists already.
 */
- (BOOL)alertCanOK
{
	[infoAlertLabel setStringValue:@""];

	BOOL ok = NO;
	NSString *name = [nameField stringValue];
	if(name.length > 0 && ![name isEqual:originalName]) {
		BOOL exists = NO;
		for(id p in [self.delegate presets]) {
			if([[self.delegate presetName:p] isEqualToString:[nameField stringValue]]) {
				exists = YES;
				break;
			}
		}
		if(exists) {
			[infoAlertLabel setStringValue:NSLocalizedString(@"Preset already exists", @"Preset Already Exists Info")];
		} else {
			ok = YES;
		}

	}
	return ok;
}

- (void)presentPresetAlertWithName:(NSString*)name callback:(PresetAlertCallbackBlock)callback rename:(BOOL)rename
{
	originalName = name;
	alertIsRenaming = rename;
	
	// Prepare the accessory view
	NSView *accessoryView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 250, nameField.frame.size.height+infoAlertLabel.frame.size.height+10)];

	[nameField setStringValue:name];
	[nameField setEditable:YES];
	[nameField setDelegate:self];	
	[accessoryView addSubview:nameField];
	
	[infoAlertLabel setStringValue:@""];
	[infoAlertLabel setEditable:NO];
	[infoAlertLabel setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];		
	[infoAlertLabel setTextColor:[NSColor redColor]];
	[infoAlertLabel setBordered:NO];
	[infoAlertLabel setDrawsBackground:NO];
	[accessoryView addSubview:infoAlertLabel];
	
	NSAlert *alert = [[NSAlert alloc] init];
	okButton = [alert addButtonWithTitle:rename?NSLocalizedString(@"Rename", @"Preset Alert Rename Button"):NSLocalizedString(@"OK", @"Preset Alert OK Button")];
	[alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Preset Alert Cancel Button")];
	[alert setMessageText:rename?NSLocalizedString(@"Rename Preset", @"Preset Alert Message"):NSLocalizedString(@"Save New Preset", @"Preset Alert Message")];
	[alert setInformativeText:NSLocalizedString(@"Enter the name of the preset:", @"Preset Alert Message")];
	[alert setAlertStyle:NSInformationalAlertStyle];
	[alert setAccessoryView:accessoryView];
	[alert layout];
	[[alert window] makeFirstResponder:nameField];
	[okButton setEnabled:[self alertCanOK]];
	
	[alert beginSheetModalForWindow:self.parentWindow
                      modalDelegate:self
                     didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo:(__bridge_retained void*)[callback copy]];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[[alert window] orderOut:self];
	okButton = nil;
	
	NSString *name = [nameField stringValue];
	PresetAlertCallbackBlock callback = (__bridge_transfer PresetAlertCallbackBlock)contextInfo;
	if(returnCode == NSAlertSecondButtonReturn || [name length] == 0) {
		[self.popUpButton selectItemWithTag:currentPresetTag];
		return;
	}
	
	callback(name);
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	[okButton setEnabled:[self alertCanOK]];
}

- (NSMutableArray*)mutablePresets
{
	NSMutableArray *array = [NSMutableArray array];
	if([[self.delegate presets] count] > 0) {
		[array addObjectsFromArray:[self.delegate presets]];
	}
	return array;
}

/**
 Saves the current preset under a preset name.
 */
- (void)presetSaveAs
{
	[self presentPresetAlertWithName:@"" callback:^(NSString *name) {
		NSMutableArray *array = [self mutablePresets];
		[array addObject:[self.delegate createPresetWithName:name]];
		[self.delegate setPresets:array];
		[self buildPresetAndSelect:[array count] - 1];
	} rename:NO];
}


/**
 Replaces the settings of the current selected preset with the current settings.
 */
- (void)presetSave
{
	if(currentPresetTag == TAG_DEFAULT) {
		[self presetSaveAs];
	} else {
		NSMutableArray *array = [self mutablePresets];
		array[currentPresetTag] = [self.delegate createPresetWithName:[self.delegate presetName:array[currentPresetTag]]];
		[self.delegate setPresets:array];
		[self.popUpButton selectItemWithTag:currentPresetTag];
	}
}

/**
 Renames the current preset.
 */
- (void)presetRename
{
	[self presentPresetAlertWithName:[self.delegate presetName:[self.delegate presets][currentPresetTag]] callback:^(NSString *name) {
		NSMutableArray *array = [self mutablePresets];
		array[currentPresetTag] = [self.delegate createPresetWithName:name];
		[self.delegate setPresets:array];
		[self buildPresetAndSelect:currentPresetTag];
	} rename:YES];
}

/**
 Removes the current preset.
 */
- (void)presetRemove
{
	if(currentPresetTag < TAG_DEFAULT) {
		NSMutableArray *array = [self mutablePresets];
		[array removeObjectAtIndex:currentPresetTag];
		[self.delegate setPresets:array];
		[self buildPreset];
	}
}

/**
 Actions from the preset popup.
 */
- (IBAction)presetPopUp:(id)sender
{
	int tag = [[sender selectedItem] tag];
	switch (tag) {
		case TAG_SAVE:
			[self presetSave];
			break;
		case TAG_SAVE_AS:
			[self presetSaveAs];
			break;
		case TAG_RENAME:
			[self presetRename];
			break;
		case TAG_DELETE:
			[self presetRemove];
			break;
		default:
			currentPresetTag = tag;
			if(currentPresetTag < TAG_DEFAULT) {
				[self.delegate applyPreset:[self mutablePresets][currentPresetTag]];
			}
			break;
	}
}

@end
