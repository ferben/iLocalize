//
//  ProjectExport.m
//  iLocalize
//
//  Created by Jean on 12/16/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "ExportProjectOVC.h"
#import "ProjectController.h"
#import "LanguageController.h"
#import "ExportProjectSettings.h"
#import "ExportProjectOptionsOVC.h"
#import "ProjectStructureViewController.h"
#import "AZPathNode.h"
#import "ProjectPrefs.h"

#define LANGUAGE_NAME        @"name"
#define LANGUAGE_DISPLAY    @"display"
#define LANGUAGE_PROGRESS    @"progress"
#define LANGUAGE_WARNING    @"warning"

@implementation ExportProjectOVC

@synthesize rootPath;

@synthesize settings;

- (id)init
{
    if ((self = [super initWithNibName:@"ExportProject"]))
    {
        pathNodeSelectionView = [[AZPathNodeSelectionView alloc] init];
        languagesSelectionView = [[AZListSelectionView alloc] init];
        presetsManager = [[PresetsManager alloc] init];
        presetsManager.delegate = self;
    }
    
    return self;
}


- (void)updateTargetFolder
{
    // If the path is not defined or does not exist, use the current directory
    if (!self.settings.destFolder || ![self.settings.destFolder isPathExisting])
    {
        // self.settings.destFolder = NSHomeDirectory();
        
        // fd:20170321: we're now using the user's Desktop by default
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES );
        NSString *theDesktopPath = [paths objectAtIndex:0];

        self.settings.destFolder = theDesktopPath;
    }
    
    [targetPathControl setURL:[NSURL fileURLWithPath:self.settings.destFolder]];
    [self stateChanged];
}

- (void)updatePaths
{
    self.rootPath = [ProjectStructureViewController pathTreeForProjectProvider:[self projectProvider]];
    pathNodeSelectionView.outlineView = outlineView;
    pathNodeSelectionView.rootPath = self.rootPath;
    [pathNodeSelectionView refresh];    

    if (self.settings.paths == nil)
    {
        // if paths is nil, it means everything needs to be exported
        [pathNodeSelectionView selectAll];
    }
    else
    {
        [pathNodeSelectionView selectRelativePaths:self.settings.paths];
    }
}

- (void)updateLanguages
{
    NSMutableArray *languages = [NSMutableArray array];
    
    for (LanguageController *languageController in [[[self projectProvider] projectController] languageControllers])
    {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[LANGUAGE_NAME] = [languageController language];
        dic[LANGUAGE_DISPLAY] = [languageController displayLanguage];
        dic[[AZListSelectionView selectedKey]] = @([self.settings.languages containsObject:[languageController language]]);            
        
        if (![languageController isBaseLanguage])
        {
            NSString *s = [languageController percentCompletedString];
            dic[LANGUAGE_PROGRESS] = [s length] == 0 ? NSLocalizedString(@"Done", nil) : s;            
        }
        
        NSImage *image = [languageController allWarningsImage];
        
        if (image)
        {
            dic[LANGUAGE_WARNING] = image;                        
        }
        
        [languages addObject:dic];
    }
    
    languagesSelectionView.outlineView = languagesOutlineView;
    languagesSelectionView.elements = languages;
    [languagesSelectionView reloadData];
}

- (void)applySettings
{
    [self updateTargetFolder];
    [self updatePaths];
    [self updateLanguages];
}

- (void)willShow
{        
    presetsManager.parentWindow = [self window];
    presetsManager.popUpButton = presetPopUpButton;
    
    if (!self.bypass)
    {
        // Only build the preset menu when not bypassing
        // the view controller (which means it is executing
        // an Export As Preset and building the preset
        // popup will overwrite any settings that the user
        // selected preset has carried so far.
        [presetsManager buildPreset];
    }
    
    [self applySettings];
}

// Returns an array of selected path by the user.
- (NSArray *)selectedPaths
{
    if ([pathNodeSelectionView isAllSelected])
    {
        return nil; // everything
    }
    else
    {
        return [pathNodeSelectionView selectedRelativePaths];
    }
}

- (NSArray *)selectedLanguages
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *dic in [languagesSelectionView selectedElements])
    {
        if ([dic[[AZListSelectionView selectedKey]] boolValue])
        {
            [array addObject:dic[LANGUAGE_NAME]];                    
        }
    }
    
    return array;
}

- (void)saveSettings
{
    self.settings.paths = [self selectedPaths];
    self.settings.languages = [self selectedLanguages];    
    self.settings.destFolder = [[targetPathControl URL] path];
}

- (NSString *)nextButtonTitle
{
    return NSLocalizedString(@"Export", nil);
}

- (void)willCancel
{
    [self saveSettings];
}

- (void)willContinue
{
    [self saveSettings];
}

- (BOOL)canContinue
{
    return self.settings.destFolder.length > 0;
}

- (void)validateContinue:(ValidateContinueCallback)callback
{
    [self saveSettings];

    if ([self.settings.compressedTargetBundle isPathExisting])
    {
        // compose alert
        NSAlert *alert = [NSAlert new];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert setMessageText:[NSString stringWithFormat:NSLocalizedStringFromTable(@"ExportProjectFileExistsTitle",@"Alerts",nil), [self.settings.compressedTargetBundle lastPathComponent]]];
        [alert setInformativeText:NSLocalizedStringFromTable(@"ExportProjectFileExistsDescr",@"Alerts",nil)];
        [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextMerge",@"Alerts",nil)];           // 1st button
        [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextOverwrite",@"Alerts",nil)];       // 2nd button
        [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextCancel",@"Alerts",nil)];          // 3rd button
        
        // show alert
        [alert beginSheetModalForWindow:[self visibleWindow] completionHandler:^(NSModalResponse alertReturnCode)
        {
            [[alert window] orderOut:self];

            // old stuff from -beginSheetModalForWindow:modalDelegate:didEndSelector:contextInfo:
            // contextInfo:(__bridge_retained void*)[callback copy]];
            // ValidateContinueCallback callback = (__bridge_transfer ValidateContinueCallback)(contextInfo);

            switch (alertReturnCode)
            {
                case NSAlertFirstButtonReturn:
                case NSAlertSecondButtonReturn:
                    self.settings.mergeFiles = (alertReturnCode == NSAlertFirstButtonReturn);
                    callback(YES);
            }
        }];
    }
    else
    {
        callback(YES);    
    }    
}

#pragma mark Actions

- (IBAction)options:(id)sender
{
    [self saveSettings];

    ExportProjectOptionsOVC *ovc = [ExportProjectOptionsOVC createInstance];
    ovc.projectProvider = self.projectProvider;
    ovc.settings = self.settings;
    
    [self runModalOperationViewController:ovc];
}

- (IBAction)chooseTargetDirectory:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setCanCreateDirectories:YES];
    [panel setDirectoryURL:[NSURL fileURLWithPath:self.settings.destFolder]];
    [panel setTitle:NSLocalizedString(@"Choose Destination Folder", nil)];
    [panel setPrompt:NSLocalizedString(@"Choose", nil)];

    if ([panel runModal] == NSModalResponseOK)
    {
        self.settings.destFolder = [[panel URL] path];        
        [self updateTargetFolder];
    }
}

#pragma mark Presets Delegate

- (NSArray *)presets
{
    return [[self.projectProvider projectPrefs] exportSettingsPresets];
}

- (void)setPresets:(NSArray *)presets
{
    [[self.projectProvider projectPrefs] setExportSettingsPresets:presets];
}

- (NSString *)presetName:(id)preset
{
    return preset[EXPORT_PRESET_NAME];    
}

- (id)createPresetWithName:(NSString *)name
{
    [self saveSettings];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    dic[EXPORT_PRESET_NAME] = name;
    dic[EXPORT_PRESET_SETTINGS] = [self.settings data];
    
    return dic;    
}

- (void)applyPreset:(id)preset
{
    [self.settings setData:preset[EXPORT_PRESET_SETTINGS]];
    [self applySettings];
}

@end
