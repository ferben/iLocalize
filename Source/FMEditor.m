//
//  FMEditor.m
//  iLocalize3
//
//  Created by Jean on 25.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEditor.h"
#import "FMEngine.h"

#import "FileController.h"

#import "PreferencesWC.h"

#import "LanguageController.h"
#import "LanguageTool.h"

#import "Stack.h"
#import "Constants.h"

@implementation FMEditor

+ (id)editor
{
	return [[self alloc] init];
}

- (id)init
{
	if ((self = [super init]))
    {
		mEngine = NULL;
		
		mWindow = NULL;
		mStackState = [[Stack alloc] init];
				
		mFileControllers = [[NSMutableArray alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(engineDidReload:)
													 name:ILNotificationEngineDidReload
												   object:nil];
		
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];

        if (![bundle loadNibNamed:[self nibname] owner:self topLevelObjects:nil])
        {
            // throw exception
            @throw [NSException exceptionWithName:@"View initialization failed"
                                           reason:@"FMEditor: Could not load resources!"
                                         userInfo:nil];
        }
        
        [self registerToPreferences];
	}
    
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self unregisterFromPreferences];

}

#pragma mark -

- (void)engineDidReload:(NSNotification*)notif
{
	if([notif object] == mEngine) {
        // Be sure to execute the updateContent on the main thread, otherwise the HTML view
        // doesn't get correctly updated.
        [self performSelectorOnMainThread:@selector(updateContent) withObject:nil waitUntilDone:YES];        
    }
}

#pragma mark -

- (ProjectPrefs*)projectPrefs
{
	return [[self projectProvider] projectPrefs];
}

- (NSUndoManager*)undoManager
{
	return [[self projectProvider] projectUndoManager];
}

- (Console*)console
{
	return [[self projectProvider] console];
}

- (void)setEngine:(FMEngine*)engine
{
	mEngine = engine;
}

- (FMEngine*)engine
{
	return mEngine;
}

- (void)setWindow:(NSWindow*)window
{
	mWindow = window;
}

- (NSWindow*)window
{
	return mWindow;
}

- (Stack*)stackState
{
	return mStackState;
}

- (NSString*)nibname
{
	return NULL;
}

- (NSView*)view
{
	if([self isBaseLanguage]) {
		return mBaseView;
	} else {
		return mLocalizedView;
	}
}

- (NSArray*)keyViews
{
    return nil;
}

- (BOOL)allowsMultipleSelection
{
	return NO;
}

- (BOOL)canExportToStrings
{
	return NO;
}

- (BOOL)canTranslateUsingStrings
{
	return NO;
}

- (NSString*)baseLanguage
{
	return [[self languageController] baseLanguage];
}

- (NSString*)baseLanguageDisplay
{
	return [[self baseLanguage] displayLanguageName];
}

- (NSString*)localizedLanguage
{
	return [[self languageController] language];
}

- (NSString*)localizedLanguageDisplay
{
	return [[self localizedLanguage] displayLanguageName];
}

- (BOOL)isBaseLanguage
{
	return [[self languageController] isBaseLanguage];
}

- (void)setLanguageController:(LanguageController*)lc
{
	mLanguageController = lc;
}

- (LanguageController*)languageController
{
	return mLanguageController;
}

- (NSArray*)allFilesOfSelectedLanguage
{
	return [[self languageController] fileControllers];
}

#pragma mark -

- (void)awake
{
	
}

- (void)close {
    
}

- (void)makeVisibleInBox:(NSView*)box
{
	[self ensureContent];
	[self updateContent];
	[box setContentView:[self view]];
	// Invoke willShow after setting the view into the box
	// because the box will resize the view so any layout computation
	// in willShow need to have happen with the view having the proper size.
	[self willShow];
	[self setWindow:[box window]];
}

- (void)makeInvisible
{
	[self willHide];
	
	mLanguageController = nil;
	
	[mFileControllers removeAllObjects];
}

- (void)willShow
{
	
}

- (void)willHide
{
	
}

- (void)setFileControllers:(NSArray*)fcs
{
    [mFileControllers removeAllObjects];
    for(FileController *fc in fcs) {
        if(![fc ignore]) {
            [mFileControllers addObject:fc];
        }
    }
}

- (FileController*)fileController
{
	return [mFileControllers firstObject];
}

- (void)exportFile:(NSString*)sourcePath toStringsFile:(NSString*)targetPath
{
	
}

- (void)translateUsingStringsFile:(NSString*)file
{
	
}

- (void)selectContentItem:(id)item
{
	
}

- (NSArray*)selectedContentItems
{
	return NULL;
}

- (void)selectNextItem
{
	
}

- (void)ensureContent
{
	// Ensure that all file content has been loaded (because it will be displayed)
	
	FileController *fc;
	for(fc in mFileControllers) {
		if(![fc hasBaseModelContent])
			[[self engine] loadFile:[fc absoluteBaseFilePath] intoFileModel:[fc baseFileModel]];
		
		if(![fc hasModelContent])
			[[self engine] loadFile:[fc absoluteFilePath] intoFileModel:[fc fileModel]];
	}	
}

- (void)updateContent
{
	
}

#pragma mark -

- (void)registerToPreferences
{
	
}

- (void)unregisterFromPreferences
{
	[[PreferencesWC shared] removeObserver:self];
}

#pragma mark -

- (void)pushState
{
	
}

- (void)popState
{
	
}

- (NSString*)windowToolTipRequestedAtPosition:(NSPoint)pos
{
	return nil;
}

- (IBAction)performDebugAction:(id)sender
{
	
}

@end
