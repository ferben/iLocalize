//
//  PresetsManager.h
//  iLocalize
//
//  Created by Jean Bovet on 4/2/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@protocol PresetsManagerDelegate
- (NSArray*)presets;
- (void)setPresets:(NSArray*)presets;
- (NSString*)presetName:(id)preset;
- (id)createPresetWithName:(NSString*)name;
- (void)applyPreset:(id)preset;
@end

@interface PresetsManager : NSObject<NSTextFieldDelegate> {
	NSTextField *nameField;
	NSTextField *infoAlertLabel;
	NSButton *okButton;
	NSString *originalName;
	BOOL alertIsRenaming;
	int currentPresetTag;
}
@property (assign) NSWindow *parentWindow;
@property (weak) id<PresetsManagerDelegate> delegate;
@property (weak) NSPopUpButton *popUpButton;

- (void)buildPreset;

- (IBAction)presetPopUp:(id)sender;

@end
