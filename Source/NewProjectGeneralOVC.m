//
//  NewProjectGeneralOVC.m
//  iLocalize
//
//  Created by Jean Bovet on 2/13/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "NewProjectGeneralOVC.h"
#import "PreferencesWC.h"
#import "BundleSelectorDialog.h"
#import "LanguageTool.h"
#import "NewProjectSettings.h"
#import "BundleSource.h"

@implementation NewProjectGeneralOVC

@synthesize settings;

- (id)init
{
    if((self = [super initWithNibName:@"NewProjectGeneral"])) {
        presetsManager = [[PresetsManager alloc] init];
        presetsManager.delegate = self;
    }
    return self;
}


#pragma mark Settings

- (NSString*)projectName
{
    return [[projectNameField stringValue] lastPathComponent];
}

- (void)setProjectFolder:(NSString *)path
{
    NSString *absolutePath = path?[path stringByStandardizingPath]:@"";
    [projectFolderPathControl setURL:[NSURL fileURLWithPath:absolutePath]];    
}

- (NSString*)projectFolder
{
    return [[projectFolderPathControl URL] path];
}

- (void)setSourcePath:(NSString *)path
{
    NSString *absolutePath = path?[path stringByStandardizingPath]:@"";
    [projectSourcePathControl setURL:[NSURL fileURLWithPath:absolutePath]];        
}

- (NSString*)sourcePath
{
    return [[projectSourcePathControl URL] path];
}

#pragma mark Preferences

- (void)savePreferences
{
    [[NSUserDefaults standardUserDefaults] setObject:[projectNameField stringValue] forKey:@"AssistantProjectName"];
    [[NSUserDefaults standardUserDefaults] setObject:[self projectFolder] forKey:@"AssistantProjectFolder"];
    [[NSUserDefaults standardUserDefaults] setObject:[self sourcePath] forKey:@"AssistantProjectApplication"];
}

- (void)applyPreferences
{
    [projectNameField setStringValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"AssistantProjectName"]?:@""];    
    [self setProjectFolder:[[NSUserDefaults standardUserDefaults] objectForKey:@"AssistantProjectFolder"]];    
    [self setSourcePath:[[NSUserDefaults standardUserDefaults] objectForKey:@"AssistantProjectApplication"]];
}

#pragma mark Operation View Controller

- (void)updateInfoField
{
    NSString *projectFolderPath = [[[self projectFolder] stringByAppendingPathComponent:[self projectName]] stringByAbbreviatingWithTildeInPath];
    [projectInfoField setStringValue:[NSString stringWithFormat:NSLocalizedString(@"The project directory “%@” will be created if necessary", nil), projectFolderPath]];
}

- (void)willShow
{
    presetsManager.parentWindow = [self window];
    presetsManager.popUpButton = mPresetPopUp;
    [presetsManager buildPreset];

    [self applyPreferences];    
    [self updateInfoField];
    
    [[self window] setInitialFirstResponder:projectNameField];    
}

- (void)willCancel
{
    [self savePreferences];
}

- (void)validateContinue:(ValidateContinueCallback)callback
{
    NSString *projectSourcePath = [self sourcePath];
    if(![projectSourcePath isPathExisting]) {
        NSBeginAlertSheet(NSLocalizedString(@"Source Application Missing", nil),
                          NSLocalizedString(@"OK", NULL),
                          NULL, NULL, [self window], self, nil,
                          NULL,
                          nil, NSLocalizedString(@"The source application “%@” doesn't exist. Select a source application to correct the problem.", nil), projectSourcePath);                    
        callback(NO);
    } else if([[LanguageTool languagesInPath:projectSourcePath] count] == 0) {
        NSBeginAlertSheet(NSLocalizedString(@"No Language Detected", nil), NSLocalizedString(@"OK", NULL),
                          NULL, NULL, [self window], self, nil,
                          NULL,
                          nil, NSLocalizedString(@"The source application “%@” doesn't contains any language. At least one language must exist.", nil), projectSourcePath);
        callback(NO);
    } else {
        callback(YES);
    }    
}

- (void)willContinue
{
    [self savePreferences];    
    
    settings.name = [self projectName];
    settings.source = [BundleSource sourceWithPath:[self sourcePath]];
    settings.projectFolder = [self projectFolder];
}

#pragma mark Actions

- (IBAction)chooseProjectFolder:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];
    if ([self projectFolder]) {
        [panel setDirectoryURL:[NSURL fileURLWithPath:[self projectFolder]]];        
    }
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if(result == NSFileHandlingPanelOKButton) {
            [self setProjectFolder:[[panel URL] path]];
            [self updateInfoField];
        }        
    }];
}

- (IBAction)chooseSourceBundle:(id)sender
{    
    BundleSelectorDialog *dialog = [[BundleSelectorDialog alloc] init];
    dialog.defaultPath = [self sourcePath];
    [dialog promptForBundleForWindow:[self window] callback:^(NSString *path) {
        if(path) {
            [self setSourcePath:path];
        }
    }];
}

- (IBAction)sourceBundlePathChanged:(id)sender
{
    // update the project name when the source bundle path is changed by the user
    [projectNameField setStringValue:[[[self sourcePath] lastPathComponent] stringByDeletingPathExtension]]; 
}

- (IBAction)projectFolderPathChanged:(id)sender
{
    [self updateInfoField];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    [self updateInfoField];
}

#pragma mark Presets Delegate

#define PRESET_NAME            @"PRESET_NAME"
#define PRESET_PROJECT_NAME    @"PRESET_PROJECT_NAME"
#define PRESET_FOLDER_NAME    @"PRESET_FOLDER_NAME"
#define PRESET_APPLICATION    @"PRESET_APPLICATION"

- (NSArray*)presets
{
    return [[PreferencesWC shared] projectPresets];
}

- (void)setPresets:(NSArray*)presets
{
    [[PreferencesWC shared] setProjectPresets:presets];
}

- (NSString*)presetName:(id)preset
{
    return preset[PRESET_NAME];    
}

- (id)createPresetWithName:(NSString*)name
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[PRESET_NAME] = name;
    dic[PRESET_PROJECT_NAME] = [projectNameField stringValue];
    dic[PRESET_FOLDER_NAME] = [self projectFolder];
    dic[PRESET_APPLICATION] = [self sourcePath];    
    return dic;    
}

- (void)applyPreset:(id)preset
{
    [projectNameField setStringValue:preset[PRESET_PROJECT_NAME]];
    [self setProjectFolder:preset[PRESET_FOLDER_NAME]];
    [self setSourcePath:preset[PRESET_APPLICATION]];        
    [self updateInfoField];
}

@end
