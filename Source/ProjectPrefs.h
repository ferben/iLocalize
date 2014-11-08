//
//  ProjectPrefs.h
//  iLocalize3
//
//  Created by Jean on 04.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@protocol ProjectProvider;

@interface ProjectPrefs : NSObject <NSCoding> {
	NSString *selectedLanguage;
	NSString *selectedFile;
	NSArray *labels;
	NSRect windowPosition;
	NSDictionary *interfacePrefs;
	NSArray *filesColumnInfo;
	NSDictionary *updateBundlePrefs;
	NSDictionary *exportSettings;
	NSArray *exportSettingsPresets;
	NSDictionary *exportXLIFFSettings;
	NSDictionary *importXLIFFSettings;
	
	// array of files identifying each filter. This array is used to keep track of the ordering of the filters per project
	NSArray *filterFiles;
	
	BOOL showTextZone;
	BOOL showKeyColumn;
	BOOL showInvisibleCharacters;
	BOOL showLocalFiles;
	BOOL showStatusBar;
	BOOL showStructureView;
}

@property (weak) id<ProjectProvider> projectProvider;
@property (copy) NSString *selectedLanguage;
@property (copy) NSString *selectedFile;
@property (copy) NSArray *labels;
@property NSRect windowPosition;
@property (copy) NSDictionary *interfacePrefs;
@property (copy) NSArray *filesColumnInfo;
@property (copy) NSDictionary *updateBundlePrefs;
@property (copy) NSDictionary *exportSettings;
@property (copy) NSArray *exportSettingsPresets;
@property (copy) NSDictionary *exportXLIFFSettings;
@property (copy) NSDictionary *importXLIFFSettings;
@property (copy) NSArray *filterFiles;
@property BOOL showTextZone;
@property BOOL showKeyColumn;
@property BOOL showInvisibleCharacters;
@property BOOL showLocalFiles;
@property BOOL showStatusBar;
@property BOOL showStructureView;

@end
