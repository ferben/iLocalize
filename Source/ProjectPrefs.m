//
//  ProjectPrefs.m
//  iLocalize3
//
//  Created by Jean on 04.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ProjectPrefs.h"
#import "ProjectLabels.h"
#import "ProjectProvider.h"

@implementation ProjectPrefs

@synthesize selectedLanguage;
@synthesize selectedFile;
@synthesize labels;
@synthesize windowPosition;
@synthesize interfacePrefs;
@synthesize filesColumnInfo;
@synthesize updateBundlePrefs;
@synthesize exportSettings;
@synthesize exportSettingsPresets;
@synthesize exportXLIFFSettings;
@synthesize importXLIFFSettings;
@synthesize filterFiles;
@synthesize showTextZone;
@synthesize showKeyColumn;
@synthesize showInvisibleCharacters;
@synthesize showLocalFiles;
@synthesize showStatusBar;
@synthesize showStructureView;

+ (void)initialize
{
	if (self == [ProjectPrefs class])
    {
		[self setVersion:1];		
	}
}

- (id)init
{
	if (self = [super init])
    {
		self.labels = [ProjectLabels defaultLabels];
		[self addObserver:self forKeyPath:@"prefChanged" options:NSKeyValueObservingOptionNew context:nil];
	}
	
    return self;
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"prefChanged"];
	self.projectProvider = nil;
}

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
    {
		[self addObserver:self forKeyPath:@"prefChanged" options:NSKeyValueObservingOptionNew context:nil];

		NSInteger version = [coder versionForClassName:NSStringFromClass([ProjectPrefs class])];
        
		if (version >= 1)
        {
			self.selectedLanguage = [coder decodeObjectForKey:@"selectedLanguage"];
			self.selectedFile = [coder decodeObjectForKey:@"selectedFile"];
			self.labels = [coder decodeObjectForKey:@"labels"];
			self.windowPosition = [coder decodeRectForKey:@"windowPosition"];
			self.interfacePrefs = [coder decodeObjectForKey:@"interfacePrefs"];
			self.filesColumnInfo = [coder decodeObjectForKey:@"filesColumnInfo"];
			self.updateBundlePrefs = [coder decodeObjectForKey:@"updateBundlePrefs"];
			self.exportSettings = [coder decodeObjectForKey:@"exportSettings"];
			self.exportSettingsPresets = [coder decodeObjectForKey:@"exportSettingsPresets"];
			self.exportXLIFFSettings = [coder decodeObjectForKey:@"exportXLIFFSettings"];
			self.importXLIFFSettings = [coder decodeObjectForKey:@"importXLIFFSettings"];
			self.filterFiles = [coder decodeObjectForKey:@"filterFiles"];
			self.showTextZone = [coder decodeBoolForKey:@"showTextZone"];
			self.showKeyColumn = [coder decodeBoolForKey:@"showKeyColumn"];
			self.showInvisibleCharacters = [coder decodeBoolForKey:@"showInvisibleCharacters"];
			self.showLocalFiles = [coder decodeBoolForKey:@"showLocalFiles"];
			self.showStatusBar = [coder decodeBoolForKey:@"showStatusBar"];
			self.showStructureView = [coder decodeBoolForKey:@"showStructureView"];
		}
        else
        {
			// forget about version 0
			[coder decodeObject];
		}
		
		if (self.labels == nil)
        {
			self.labels = [ProjectLabels defaultLabels];
		}
	}
    
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.selectedLanguage forKey:@"selectedLanguage"];
	[coder encodeObject:self.selectedFile forKey:@"selectedFile"];
	[coder encodeObject:self.labels forKey:@"labels"];
	[coder encodeRect:self.windowPosition forKey:@"windowPosition"];
	[coder encodeObject:self.interfacePrefs forKey:@"interfacePrefs"];
	[coder encodeObject:self.filesColumnInfo forKey:@"filesColumnInfo"];
	[coder encodeObject:self.updateBundlePrefs forKey:@"updateBundlePrefs"];
	[coder encodeObject:self.exportSettings forKey:@"exportSettings"];
	[coder encodeObject:self.exportSettingsPresets forKey:@"exportSettingsPresets"];
	[coder encodeObject:self.exportXLIFFSettings forKey:@"exportXLIFFSettings"];
	[coder encodeObject:self.importXLIFFSettings forKey:@"importXLIFFSettings"];
	[coder encodeObject:self.filterFiles forKey:@"filterFiles"];
	[coder encodeBool:self.showTextZone forKey:@"showTextZone"];
	[coder encodeBool:self.showKeyColumn forKey:@"showKeyColumn"];
	[coder encodeBool:self.showInvisibleCharacters forKey:@"showInvisibleCharacters"];
	[coder encodeBool:self.showLocalFiles forKey:@"showLocalFiles"];
	[coder encodeBool:self.showStatusBar forKey:@"showStatusBar"];
	[coder encodeBool:self.showStructureView forKey:@"showStructureView"];
}

+ (NSSet *)keyPathsForValuesAffectingPrefChanged
{
	return [NSSet setWithObjects:
            @"selectedLanguage",
            @"selectedFile",
            @"labels",
            @"windowPosition",
			@"interfacePrefs",
            @"filesColumnInfo",
            @"updateBundlePrefs",
            @"exportSettings",
            @"exportSettingsPresets",
			@"exportXLIFFSettings",
            @"importXLIFFSettings",
            @"showTextZone",
			@"showKeyColumn",
            @"showInvisibleCharacters",
            @"showLocalFiles",
            @"showStatusBar",
            @"showStructureView",
            @"filterFiles",
            nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"prefChanged"])
    {
		[self.projectProvider setDirty];			
	}
}

- (id)prefChanged
{
	return nil;
}

- (void)setPrefChanged:(id)sender
{
}

@end
