//
//  FMEditor.h
//  iLocalize3
//
//  Created by Jean on 25.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"

@class FMEngine;
@class LanguageController;
@class FileController;
@class Console;
@class Stack;

@interface FMEditor : NSObject {
    IBOutlet NSView    *mBaseView;
    IBOutlet NSView    *mLocalizedView;

    FMEngine        *mEngine;
    
    NSWindow        *mWindow;
    
    Stack            *mStackState;
    
    LanguageController    *mLanguageController;
    NSMutableArray            *mFileControllers;
}

@property (nonatomic, weak) id<ProjectProvider> projectProvider;

+ (id)editor;

- (void)awake;
- (void)close;

- (ProjectPrefs*)projectPrefs;
- (NSUndoManager*)undoManager;
- (Console*)console;

- (void)setEngine:(FMEngine*)engine;
- (FMEngine*)engine;

- (NSWindow*)window;
- (Stack*)stackState;

- (NSView*)view;
- (NSArray*)keyViews;
- (BOOL)allowsMultipleSelection;

- (BOOL)canExportToStrings;
- (BOOL)canTranslateUsingStrings;

- (void)makeVisibleInBox:(NSView*)box;
- (void)makeInvisible;

- (NSString*)baseLanguage;
- (NSString*)baseLanguageDisplay;

- (NSString*)localizedLanguage;
- (NSString*)localizedLanguageDisplay;

- (BOOL)isBaseLanguage;

- (void)setLanguageController:(LanguageController*)lc;
- (LanguageController*)languageController;

- (NSArray*)allFilesOfSelectedLanguage;

- (void)setFileControllers:(NSArray*)fcs;
- (FileController*)fileController;

- (void)exportFile:(NSString*)sourcePath toStringsFile:(NSString*)targetPath;
- (void)translateUsingStringsFile:(NSString*)file;

- (void)selectContentItem:(id)item;
- (NSArray*)selectedContentItems;

- (void)selectNextItem;

- (void)pushState;
- (void)popState;

- (NSString*)windowToolTipRequestedAtPosition:(NSPoint)pos;

- (IBAction)performDebugAction:(id)sender;

@end
