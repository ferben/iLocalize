//
//  Application.m
//  iLocalize3
//
//  Created by Jean on 31.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "ApplicationDelegate.h"
#import "ILDocumentController.h"

#import "PreferencesWC.h"
#import "PreferencesGeneral.h"
#import "Preferences.h"

#import "ProjectBrowserWC.h"
#import "NewProjectSettings.h"
#import "ProjectDocument.h"

#import "BackgroundUpdater.h"
#import "FileTool.h"
#import "StringEncodingTool.h"

#import "ToolLaunchApp.h"

#import "NibEngine.h"

#import "ExplorerFilterManager.h"

#import "GlossaryFolder.h"
#import "GlossaryManager.h"
#import "GlossaryManagerWC.h"
#import "GlossaryDocument.h"

#import "Constants.h"
#import "Constants.h"

#import "ImmutableToMutableArrayOfObjectsTransformer.h"

#import "RecentDocuments.h"

#import "ProjectWC.h"
#import "NewProjectOperationDriver.h"
#import "SEIManager.h"

#import <ExceptionHandling/NSExceptionHandler.h>

#import "ASProject.h"
#import "AboutWindow.h"

@interface ApplicationDelegate ()

@property (nonatomic, strong) ILDocumentController *sharedDocumentController;

@end

@implementation ApplicationDelegate

+ (void)initialize
{
	NSValueTransformer *transformer = [[ImmutableToMutableArrayOfObjectsTransformer alloc] init];
	[NSValueTransformer setValueTransformer:transformer forName:@"ImmutableToMutableArrayOfObjectsTransformer"];
}

- (void)awakeFromNib
{    			
	// To activate:
	// $ defaults write ch.arizona-software.iLocalize ch.arizona-software.ilocalize.debug YES
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ch.arizona-software.ilocalize.debug"])
    {
		NSMenu *mainMenuBar = [NSApp mainMenu];
		NSMenuItem *debugMenuItem = [[NSMenuItem alloc] initWithTitle:@"Debug" action:nil keyEquivalent:@""];
		NSMenu *submenu = [[NSMenu alloc] initWithTitle:@"Debug"];

        [submenu addItemWithTitle:@"Detect Encoding of Selected File" action:@selector(detectEncoding:) keyEquivalent:@""];
		[submenu addItemWithTitle:@"Check Selected File" action:@selector(checkSelectedFile:) keyEquivalent:@""];
		[submenu addItemWithTitle:@"Convert nibs to xibs" action:@selector(convertNibsToXibs:) keyEquivalent:@""];
		[submenu addItemWithTitle:@"TMX Performance Test" action:@selector(tmxPerformanceTest:) keyEquivalent:@""];

        [debugMenuItem setSubmenu:submenu];
		[mainMenuBar addItem:debugMenuItem];
	}
	
	mSymbolWindowController = [[NSWindowController alloc] init];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    [bundle loadNibNamed:@"Symbols" owner:mSymbolWindowController topLevelObjects:nil];
	
	[[RecentDocuments createInstanceForDocumentExtensions:@[@"ilocalize"] identifier:@"projects"] setMenu:mOpenRecentProjectMenu];
	[[RecentDocuments createInstanceForDocumentExtensions:[[SEIManager sharedInstance] allImportableExtensions] identifier:@"glossaries"] setMenu:mOpenRecentGlossaryMenu];
	
	[RecentDocuments loadAll];
}


#pragma mark -

- (NSString*)bundleVersion
{
	return [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];	
}

#pragma mark -

static NSDictionary *customHelpMenuDic = nil;

- (void)prepareCustomHelpMenuItems
{
	NSString *customMenuInfo = [[NSBundle mainBundle] pathForResource:@"HelpMenu" ofType:@"plist"];
	if(customMenuInfo == nil) return;
	
	@try {
		customHelpMenuDic = [NSDictionary dictionaryWithContentsOfFile:customMenuInfo];
		NSArray *items = customHelpMenuDic[@"ILMenuHelpItems"];
		if([items count]) {
			[mHelpMenu addItem:[NSMenuItem separatorItem]];
			
			NSDictionary *d;
			for(d in items) {
				NSString *name = d[@"ILMenuHelpName"];
				NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:name action:@selector(handleCustomHelpMenuItem:) keyEquivalent:@""];
				[item setRepresentedObject:d];
				[item setTarget:self];
				[mHelpMenu addItem:item];
			}					
		}
	}
	@catch(NSException  *e) {
		[e printStackTrace];
		NSLog(@"CustomHelpMenuItems %@", e);
	}
}

- (void)handleCustomHelpMenuItem:(id)sender
{
	NSDictionary *d = [sender representedObject];
	NSString *url = d[@"ILMenuHelpTypeURL"];
	if(url) {
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
		return;
	}
	NSString *localized = d[@"ILMenuHelpTypeLocalizedFile"];
	if(localized) {
		NSString *path = [[NSBundle mainBundle] pathForResource:[localized stringByDeletingPathExtension] ofType:[localized pathExtension]];
		if(path) {
			[[NSWorkspace sharedWorkspace] openFile:path];
			return;
		} else {
			NSLog(@"%@ cannot be found in the localized resource", localized);
		}
		return;
	}
	NSLog(@"No action executed");
}

- (void)removeOpenRecentMenuItem
{
	// fileMenu is an outlet you create to the File menu in your application
    int openDocumentMenuItemIndex = [mFileMenu indexOfItemWithTarget:nil
														   andAction:@selector(openDocument:)];
	
    if (    (openDocumentMenuItemIndex >= 0)
         && ([[mFileMenu itemAtIndex:openDocumentMenuItemIndex + 1] hasSubmenu])
       )
    {
		// We'll presume it's the Open Recent menu item, because this is
		// the heuristic that NSDocumentController uses to add it to the
		// File menu
		[mFileMenu removeItemAtIndex:openDocumentMenuItemIndex + 1];
    }	
}

- (void)prepareApplication
{		
	[[PreferencesWC shared] load];		
	
	// Call this method to establish the "main thread"
	[Utils isMainThread];
	
	// Build the encoding menu
	NSMenu *menu = [[StringEncodingTool shared] availableEncodingsMenuWithTarget:nil action:@selector(fileEncodingMenuAction:)];
	[mEncodingMenuItem setSubmenu:menu];

	// Build the Open Previous Version menu
	menu = [[NSMenu alloc] initWithTitle:@"Open Previous Version"];
	[menu setDelegate:self];
	[mOpenPreviousVersionMenuItem setSubmenu:menu];
	
	menu = [[NSMenu alloc] initWithTitle:@"Language"];
	[menu setDelegate:self];
	[mViewLanguageMenuItem setSubmenu:menu];
			
	// Add custom items in the Help menu
	[self prepareCustomHelpMenuItems];
}

- (void)prepareSmartFilters
{
	[[ExplorerFilterManager shared] loadGlobalFilters];
}

- (void)prepareGlossaries
{
	GlossaryManager *m = [GlossaryManager sharedInstance];
	if([m globalFolders].count == 0) {
		GlossaryFolder *folder = [GlossaryFolder folderForPath:[[FileTool systemApplicationSupportFolder] stringByAppendingPathComponent:@"/Glossaries"] name:NSLocalizedString(@"Global", @"Glossary Global Path Name")];
		folder.deletable = NO;
		[m addFolder:folder];
	}
}

- (void)checkForNibTool
{	
	BOOL ibToolOK = [NibEngine ensureTool];
    
	if (!ibToolOK)
    {
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Required Tool Missing", nil)
										 defaultButton:NSLocalizedString(@"OK", nil)
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:NSLocalizedString(@"iLocalize did not find the command-line tool “ibtool” which is required to perform localization. Make sure that Xcode 3 or above is installed on your machine. The path to “ibtool” can be manually specified in Preferences > Advanced > Tools.", nil)];	
		[alert runModal];
	}	
}

- (NSArray *)openProjectURLs
{
	return [[RecentDocuments findInstanceWithID:@"projects"] urls];
	/*
	 NSMutableArray *projects = [NSMutableArray array];
	NSEnumerator *enumerator = [[[NSDocumentController sharedDocumentController] recentDocumentURLs] objectEnumerator];
	NSURL *url;
	while(url = [enumerator nextObject]) {
		NSString *extension = [[url path] pathExtension];
		if([extension isEqualToString:@"ilocalize"] && [[url path] isPathExisting]) {
			[projects addObject:url];
		}
	}
	 return projects;
	 */	
}

- (void)openLastOpenedDocuments
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"reopenLastProjects"])
    {
        // remove duplicates if any
        NSOrderedSet *documentPaths = [NSOrderedSet orderedSetWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"lastOpenedDocumentPaths"]];
        
        if (documentPaths.count > 0)
        {
            for (NSString *path in documentPaths)
            {
                if ([path isPathExisting])
                {
                    NSError *error = nil;
                    
                    if (![[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:path] display:YES error:&error] && error)
                    {
                        ERROR(@"Unable to open recent document %@: %@", path, error);
                    }
                }
            }
        }
        else
        {
            [self performSelector:@selector(newProject:) withObject:self afterDelay:0];
        }
    }
}

- (void)closeApplication
{
	// Set the preferences to the proper action to do at startup:
	// - open the last projects if any windows were open
	// - open the Project Browser is no window were open
	NSMutableArray *openDocumentPaths = [NSMutableArray array];
    
	for (NSDocument *doc in [[NSDocumentController sharedDocumentController] documents])
    {
		[openDocumentPaths addObject:[[doc fileURL] path]];
	}

    // remove duplicates if any
    NSArray *documentPaths = [[NSSet setWithArray:openDocumentPaths] allObjects];
    
    if (documentPaths.count > 0)
    {
		[[NSUserDefaults standardUserDefaults] setInteger:STARTUP_OPEN_LAST_USED forKey:@"actionAtStartup"];
		[[NSUserDefaults standardUserDefaults] setObject:documentPaths forKey:@"lastOpenedDocumentPaths"];
	}
    else
    {
		[[NSUserDefaults standardUserDefaults] setInteger:STARTUP_PROJECT_BROWSER forKey:@"actionAtStartup"];
	}
	
	// Save all the projects automatically when the application closes
	for (NSDocument *doc in [[NSDocumentController sharedDocumentController] documents])
    {
		if ([doc isKindOfClass:[ProjectDocument class]])
        {
			// Need this little hack so saveDocument really saves the document
			// because the document isDocumentEdited flag can be NO
			// while there are still data to save (internal data).
			// The isDocumentEdited flag is YES when a file of the project
			// needs to be saved to the disk.
			[doc updateChangeCount:NSChangeDone];
			[doc saveDocument:self];			
		}
	}
	
	[[BackgroundUpdater shared] stopAndWaitForCompletion];
	[[PreferencesWC shared] save];
	[RecentDocuments saveAll];
}

#pragma mark -

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return NO;
}

- (void)applicationWillFinishLaunching:(NSNotification *)notif
{
    if (IsTestRunning())
    {
        return;
    }
    
/*	[[ILCrashReporter defaultReporter]
	 launchReporterForCompany:@"Arizona Software"
	 reportAddr:@"ilocalize@arizona-software.ch"];
	
		NSLog(@"%d", 0/0);
*/	
	// Count the number of time it started (used by the RegistrationAndUpdate class)	
	int startCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"startCount"];
	[[NSUserDefaults standardUserDefaults] setInteger:startCount + 1 forKey:@"startCount"];
	
	// Create the document controller here: it will then be used as the shared document controller
	// See http://developer.apple.com/documentation/Cocoa/Conceptual/Documents/Tasks/SubclassController.html
	self.sharedDocumentController = [[ILDocumentController alloc] init];
	
	[self prepareApplication];
	[self prepareSmartFilters];
	[self prepareGlossaries];
    [self checkForNibTool];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notif
{
    if (IsTestRunning())
    {
        return;
    }
    
	[self removeOpenRecentMenuItem];
		
	if ([[NSApp orderedDocuments] count])
		return;
	
	BOOL firstStartup;
    
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"firstStartup"] == nil)
    {
		firstStartup = YES;
	}
    else
    {
		firstStartup = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstStartup"];
	}
    
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstStartup"];
	
	if (firstStartup)
    {
		[self performSelector:@selector(newProject:) withObject:self afterDelay:0];		
	}
    else
    {
        switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"actionAtStartup"])
        {
            case STARTUP_OPEN_LAST_USED:
				[self openLastOpenedDocuments];
				break;
			case STARTUP_NEW_PROJET:
				[self performSelector:@selector(newProject:) withObject:self afterDelay:0];
				break;
				// FIX CASE 57: project browser at startup
			case STARTUP_PROJECT_BROWSER:
				[self performSelector:@selector(browseProjects:) withObject:self afterDelay:0];
				break;
        }
	}
}

- (void)applicationWillTerminate:(NSNotification *)notif
{
	[self closeApplication];
}

- (void)applicationDidBecomeActive:(NSNotification *)notif
{
	[NSApplication detachDrawingThread:@selector(performUpdate) toTarget:[BackgroundUpdater shared] withObject:nil];	
}

- (void)applicationDidChangeScreenParameters:(NSNotification *)aNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:ILNotificationScreenDidChange
														object:nil];
}

- (ProjectWC *)findFirstProjectWC
{
	NSEnumerator *enumerator = [[NSApp orderedWindows] objectEnumerator];
	NSWindow *window;
	while(window = [enumerator nextObject]) {
		if([window isVisible] && [[window windowController] isKindOfClass:[ProjectWC class]]) {
			return [window windowController];
		}
	}        
	return nil;
}

- (void)menuNeedsUpdate:(NSMenu *)menu
{
	if([mOpenPreviousVersionMenuItem submenu] == menu) {
		[[self findFirstProjectWC] performSelector:@selector(openPreviousVersionMenuNeedsUpdate:) withObject:menu];					
	}
	if([mViewLanguageMenuItem submenu] == menu) {
		[[self findFirstProjectWC] performSelector:@selector(viewLanguageMenuNeedsUpdate:) withObject:menu];
	}
}

#pragma mark Actions

- (IBAction)aboutWindow:(id)sender
{
	[AboutWindow show];
}

- (IBAction)browseProjects:(id)sender
{
    [ProjectBrowserWC browse];
}

- (IBAction)newProject:(id)sender
{
	OperationDriver *driver = [NewProjectOperationDriver driverWithProjectProvider:nil];
	[driver execute];
}

- (IBAction)manageGlossary:(id)sender
{
	[[GlossaryManagerWC shared] show];
}

- (IBAction)openAndRepair:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"repair"];
	[NSApp sendAction:@selector(openDocument:) to:nil from:sender];
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"repair"];
}

- (IBAction)showPreferences:(id)sender
{
	[[PreferencesWC shared] show];
}

- (IBAction)showSymbols:(id)sender
{
	[[mSymbolWindowController window] makeKeyAndOrderFront:self];
}

- (IBAction)localizationOnMacOSX:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://developer.apple.com/intl/localization/"]];
}

- (IBAction)appleGlossariesFTP:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://developer.apple.com/internationalization/download/"]];
}

- (IBAction)makeDonation:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4L937JJJQHDLA"]];    
}

#pragma mark AppleScriptSupport

- (NSArray *)projects
{	
	NSMutableArray *projects = [NSMutableArray array];
	NSEnumerator *enumerator = [[[NSDocumentController sharedDocumentController] documents] objectEnumerator];
	NSDocument *doc;
    
	while (doc = [enumerator nextObject])
    {
		if ([doc isKindOfClass:[ProjectDocument class]])
        {
			[projects addObject:[ASProject projectWithDocument:(ProjectDocument*)doc]];
		}
	}
    
	return projects;
}

- (BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key
{
    if ([key isEqualToString:@"projects"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
