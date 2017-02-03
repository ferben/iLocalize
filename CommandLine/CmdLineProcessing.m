//
//  CommandLineProcessing.m
//  iLocalize
//
//  Created by Jean Bovet on 1/19/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "CmdLineProcessing.h"
#import "CmdLineProjectProvider.h"
#import "NibEngine.h"

#import "NewProjectOperation.h"
#import "NewProjectSettings.h"

#import "ImportBundlePreviewOp.h"
#import "ImportRebaseBundleOp.h"
#import "ImportDiff.h"
#import "ImportLanguagesOp.h"
#import "ProjectDiskOperations.h"
#import "ImportFilesConflict.h"
#import "FileOperationManager.h"
#import "ScanBundleOp.h"
#import "BundleSource.h"

@implementation CmdLineProcessing

- (id) init
{
    self = [super init];
    if (self != nil) {
        provider = [[CmdLineProjectProvider alloc] init];
        [ImportFilesConflict setOverrideValue:RESOLVE_USE_IMPORTED_FILE];
    }
    return self;
}

- (void)dealloc
{
    [provider release];
    [super dealloc];
}

- (void)saveProjectToFile:(NSString*)file
{
    if(file) {
        NSData *data = [ProjectDiskOperations dataForModel:[provider projectModel] prefs:[provider projectPrefs]];    
        [data writeToURL:[NSURL fileURLWithPath:file] atomically:NO];            
    }
}

/**
 Command-line format:
 -cmd createproject -name "test" -folder "/tmp/ilocalize" -source "..." -base "en" -languages "fr,de"
 */
- (void)createProjectWithName:(NSString*)name folder:(NSString*)folder source:(NSString*)source baseLanguage:(NSString*)baseLanguage languages:(NSString*)languages
{
    NSLog(@"Create project with:");
    NSLog(@"  name = %@", name);
    NSLog(@"  folder = %@", folder);
    NSLog(@"  source = %@", source);
    NSLog(@"  base lang = %@", baseLanguage);
    NSLog(@"  languages = %@", languages);

    BundleSource *bundleSource = [BundleSource sourceWithPath:source];

    NewProjectSettings *settings = [[NewProjectSettings alloc] init];
    [settings setName:@"test"];
    [settings setSource:bundleSource];
    [settings setProjectFolder:folder];
    [settings setBaseLanguage:baseLanguage];
    [settings setLocalizedLanguages:[languages componentsSeparatedByString:@","]];
    [settings setCopySourceOnlyIfExists:YES];
    
    ScanBundleOp *scanBundleOp = [ScanBundleOp operation];
    scanBundleOp.path = settings.source.sourcePath;
    [scanBundleOp execute];
    settings.source.sourceNode = scanBundleOp.node; 

    NewProjectOperation *op = [NewProjectOperation operation];
    op.projectProvider = provider;    
    op.settings = settings;
    [op prepareProjectModel:[op.projectProvider projectModel]];
    [op createProject];
}

/**
 Command-line format:
 -cmd rebaseproject -project "/tmp/ilocalize/test.ilocalize" -source "..."
 */
- (void)rebaseProjectFromPath:(NSString*)projectPath withSource:(NSString*)source
{
    NSLog(@"Rebase project with:");
    NSLog(@"  project = %@", projectPath);
    NSLog(@"  source = %@", source);
    
    // Read project
    [provider setProjectModel:[ProjectDiskOperations readModelFromPath:projectPath]];

    ImportDiff *importDiff = [[ImportDiff alloc] init];
    BundleSource *bundleSource = [BundleSource sourceWithPath:source];

    ScanBundleOp *scanBundleOp = [ScanBundleOp operation];
    scanBundleOp.path = bundleSource.sourcePath;
    [scanBundleOp execute];
    bundleSource.sourceNode = scanBundleOp.node; 

    ImportBundlePreviewOp *previewOp = [ImportBundlePreviewOp operation];
    previewOp.projectProvider = provider;
    previewOp.importDiff = importDiff;
    [previewOp setSourcePath:bundleSource];
    [previewOp execute];
    
    ImportRebaseBundleOp *rebaseOp = [ImportRebaseBundleOp operation];
    rebaseOp.projectProvider = provider;
    [rebaseOp setUsePreviousLayout:YES];
    [rebaseOp setImportDiff:importDiff];
    [rebaseOp execute];
}

/**
 Command-line format:
 -cmd updateproject -project "/tmp/ilocalize/test.ilocalize" -source "..." -languages "fr" 
 */
- (void)updateProjectFromPath:(NSString*)projectPath usingSource:(NSString*)source languages:(NSString*)languages
{
    NSLog(@"Update project with:");
    NSLog(@"  project = %@", projectPath);
    NSLog(@"  source = %@", source);
    NSLog(@"  languages = %@", languages);
    
    // Read project
    [provider setProjectModel:[ProjectDiskOperations readModelFromPath:projectPath]];

    ImportLanguagesOp *importOp = [ImportLanguagesOp operation];
    importOp.projectProvider = provider;
    importOp.languages = [languages componentsSeparatedByString:@","];
    importOp.identical = NO;
    importOp.layouts = YES;
    importOp.copyOnlyIfExists = YES;
    importOp.sourcePath = source;
    [importOp execute];
}

/**
 Command-line format:
 -cmd extract -language "fr" -source "..." -target "..."
 */
- (void)extractLanguage:(NSString*)language source:(NSString*)source target:(NSString*)target
{
    FileOperationManager *m = [FileOperationManager manager];
    NSMutableArray *files = [NSMutableArray array];
    BOOL success = [m enumerateDirectory:source files:files errorHandler:^(NSURL *url, NSError *error) {
        NSLog(@"Problem listing content directory at \"%@\": %@", url, error);
        return NO;
    }];
    if(success) {
        [m excludeNonLocalizedFiles:files];
        [m normalizeLanguages:[NSArray arrayWithObject:language] files:files];
        [m includeLocalizedFilesFromLanguages:[NSArray arrayWithObject:language] files:files];
        [m copyFiles:files source:source target:target errorHandler:^(NSError *error) {
            NSLog(@"Problem copying the files: %@", error);
            return NO;
        }];
    }
}

- (BOOL)processCommand:(NSString*)cmd args:(NSDictionary*)args {
    BOOL processed = NO;
    NSString *projectFile = nil;

    if([cmd isEqualToString:@"createproject"]) {
        [self createProjectWithName:[args objectForKey:@"name"]
                             folder:[args objectForKey:@"folder"]
                             source:[args objectForKey:@"source"]
                       baseLanguage:[args objectForKey:@"base"]
                          languages:[args objectForKey:@"languages"]];
        NSString *name = [args objectForKey:@"name"];
        projectFile = [[args objectForKey:@"folder"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.ilocalize", name, name]];
        processed = YES;
    }    
    
    if([cmd isEqualToString:@"rebaseproject"]) {
        [self rebaseProjectFromPath:[args objectForKey:@"project"]
                         withSource:[args objectForKey:@"source"]];
        projectFile = [args objectForKey:@"project"];
        processed = YES;
    }    
    
    if([cmd isEqualToString:@"updateproject"]) {
        [self updateProjectFromPath:[args objectForKey:@"project"]
                        usingSource:[args objectForKey:@"source"]
                          languages:[args objectForKey:@"languages"]];
        projectFile = [args objectForKey:@"project"];
        processed = YES;
    }    
    
    if([cmd isEqualToString:@"extract"]) {
        [self extractLanguage:[args objectForKey:@"language"]
                       source:[args objectForKey:@"source"]
                       target:[args objectForKey:@"target"]];
        processed = YES;
    }    
    
    if(processed && projectFile) {
        [self saveProjectToFile:projectFile];
    }
    return processed;    
}

- (BOOL)processCommands
{
    NSUserDefaults *sd = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"consoleDisplayUsingNSLog"];

    NSString *cmd = [sd stringForKey:@"cmd"];
    if ([cmd isEqualToString:@"__exec_test"]) {
        // Special cmd set by the Scheme Tool when running from within Xcode. This allows to debug the tool process.
        NSMutableArray *cmds = [NSMutableArray arrayWithCapacity:10];
        
        NSMutableDictionary *args = [NSMutableDictionary dictionary];
        [args setObject:@"createproject" forKey:@"cmd"];
        [args setObject:@"test" forKey:@"name"];
        [args setObject:@"/tmp/ilocalize" forKey:@"folder"];
        [args setObject:@"/Users/bovet/Development/ArizonaSoftware/software/iLocalize/main/UnitTests/Resources/Rebase_ibtool/MyApp_iso/MyApp 1.0.app" forKey:@"source"];
        [args setObject:@"en" forKey:@"base"];
        [args setObject:@"fr" forKey:@"languages"];
        [cmds addObject:args];

        args = [NSMutableDictionary dictionary];
        [args setObject:@"rebaseproject" forKey:@"cmd"];
        [args setObject:@"/tmp/ilocalize/test/test.ilocalize" forKey:@"project"];
        [args setObject:@"/Users/bovet/Development/ArizonaSoftware/software/iLocalize/main/UnitTests/Resources/Rebase_ibtool/MyApp_iso/MyApp 2.0.app" forKey:@"source"];
        [cmds addObject:args];
        
        args = [NSMutableDictionary dictionary];
        [args setObject:@"rebaseproject" forKey:@"cmd"];
        [args setObject:@"/tmp/ilocalize/test/test.ilocalize" forKey:@"project"];
        [args setObject:@"/Users/bovet/Development/ArizonaSoftware/software/iLocalize/main/UnitTests/Resources/Rebase_ibtool/MyApp_legacy/MyApp 1.0.app" forKey:@"source"];
        [cmds addObject:args];
        
        for (NSDictionary *_cmdArgs in cmds) {
            if (![self processCommand:[_cmdArgs objectForKey:@"cmd"] args:_cmdArgs]) {
                return NO;
            }
        }
        return YES;
    } else {
        return [self processCommand:cmd args:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
    }
}

+ (BOOL)process
{
    CmdLineProcessing *clp = [[CmdLineProcessing alloc] init];
    BOOL processed = [clp processCommands];
    return processed;
}

@end
