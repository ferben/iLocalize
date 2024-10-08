//
//  ProjectDocument.m
//  iLocalize3
//
//  Created by Jean on 29.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "ProjectDocument.h"
#import "Utils.h"

#import "ProjectModel.h"
#import "LanguageModel.h"
#import "FileModel.h"
#import "FileModelContent.h"
#import "StringsContentModel.h"
#import "StringModel.h"

#import "ProjectPrefs.h"
#import "Console.h"

#import "Explorer.h"
#import "ExplorerItem.h"
#import "ExplorerFilter.h"
#import "ExplorerFilterManager.h"

#import "ProjectController.h"

#import "ProjectWC.h"
#import "NewProjectSettings.h"

#import "ConsoleWC.h"

#import "OperationDispatcher.h"
#import "OperationWC.h"
#import "OperationReportWC.h"

#import "EngineProvider.h"

#import "FMManager.h"
#import "FMEngine.h"
#import "FMEditor.h"

#import "SaveAllOperation.h"

#import "Constants.h"
#import "Constants.h"

#import "NibEngine.h"
#import "FileTool.h"
#import "ASProject.h"
#import "ASManager.h"
#import "CheckProjectOperation.h"
#import "PreferencesAdvanced.h"
#import "FileConflictDecision.h"

#import "ProjectDiskOperations.h"

@interface ProjectDocument ()

@property (nonatomic) BOOL documentBecameDirty;

@end

@implementation ProjectDocument

@synthesize operationRunning;

- (id)init
{
    if((self = [super init])) {
        mProjectModel = [[ProjectModel alloc] init];
        
        mProjectPrefs = [[ProjectPrefs alloc] init];
        mProjectPrefs.projectProvider = self;
        
        mConsole = [[Console alloc] init];
        
        mExplorer = [[Explorer alloc] init];
        mExplorer.projectProvider = self;

        mProjectController = [[ProjectController alloc] init];
        mProjectController.projectProvider = self;
        
        mConsoleWindowController = NULL;
        
        mOperationDispatcher = [[OperationDispatcher alloc] init];
        [mOperationDispatcher setProjectProvider:self];
        
        mOperationWC = [[OperationWC alloc] init];
        
        mEngineProvider = [[EngineProvider alloc] init];
        [mEngineProvider setProjectProvider:self];
                        
        mFMEditors = [[NSMutableDictionary alloc] init];
        mFMEngines = [[NSMutableDictionary alloc] init];
        
        mConflictingFilesDecision = [[NSMutableArray alloc] init];
        
        mOSVersion = [Utils getOSVersion];
                
        mUndoManagerEnabled = YES;

        self.operationRunning = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(projectControllerDidBecomeDirty:)
                                                     name:ILNotificationProjectControllerDidBecomeDirty 
                                                   object:NULL];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [mConsoleWindowController close];
}

#pragma mark -

- (void)reportRepairWithTitle:(NSString*)title message:(NSString*)message
{
    ERROR(@"Repair: [%@] %@", title, message);
    [[self console] addError:title description:message class:[self class]];
}

- (void)repairProjectModel:(ProjectModel*)projectModel
{
    // Execute the repair only if the following settings is YES.
    if(!REPAIR_DOCUMENT) return;
            
    [[self console] mark];
    
    // Detect duplicate files
    for(LanguageModel *lm in [projectModel languageModels]) {
        NSMutableSet *files = [NSMutableSet set];        
        NSMutableArray *fms = [lm fileModels];
        int index = 0;
        while(index < [fms count]) {
            NSString *path = [fms[index] relativeFilePath];
            if([files containsObject:path]) {
                [self reportRepairWithTitle:[NSString stringWithFormat:@"Duplicate file \"%@\" in \"%@\" removed", [path lastPathComponent], [lm language]]
                                    message:[NSString stringWithFormat:@"File \"%@\" is a duplicate and has been removed", path]];
                [fms removeObjectAtIndex:index];
            } else {
                [files addObject:path];
                index++;
            }            
        }
    }
    
    // Detect localized files without any content

    LanguageModel *baseLanguageModel = [projectModel baseLanguageModel];
    for(LanguageModel *lm in [projectModel languageModels]) {
        if(lm == baseLanguageModel) continue;
        
        for(FileModel *baseFileModel in [baseLanguageModel fileModels]) {
            FileModel *fileModel = [lm fileModelForBaseFileModel:baseFileModel];
            if([[baseFileModel fileModelContent] hasContent]) {
                NSMutableString *message = [NSMutableString string];
                NSString *path = [fileModel relativeFilePath];
                
                // Check only file which have a content and which content is a string based content
                StringsContentModel *baseStringsContentModel = [[baseFileModel fileModelContent] stringsContent];
                StringsContentModel *stringsContentModel = [[fileModel fileModelContent] stringsContent];
                if([[stringsContentModel strings] count] == 0 && [[baseStringsContentModel strings] count] > 0) {            
                    [stringsContentModel setStringModels:[baseStringsContentModel strings]];
                    [message appendString:@"The file has no content while its corresponding base file has some content."];
                }                        

                BOOL modelMissing = NO;
                for(StringModel *baseStringModel in [[[baseFileModel fileModelContent] stringsContent] strings]) {
                    StringModel *stringModel = [[[fileModel fileModelContent] stringsContent] stringModelForKey:[baseStringModel key]];
                    if(!stringModel) {
                        // Localized model is missing a key model
                        [[[fileModel fileModelContent] stringsContent] addStringModel:[baseStringModel copy]];
                        modelMissing = YES;
                    }
                }                        
                
                if(modelMissing) {
                    if([message length] > 0) {
                        [message appendString:@" "];
                    }
                    [message appendString:@"One or more strings are missing."];                    
                }
                
                if([message length] > 0) {
                    [message appendString:@" You should manually review this file."];
                    
                    [self reportRepairWithTitle:[NSString stringWithFormat:@"The file \"%@\" in \"%@\" was damaged and has been repaired", [path lastPathComponent], [lm language]]
                                        message:message];
                }
            }
        }
    }
    
    [OperationReportWC showConsoleIfWarningsOrErrorsSinceLastMarkWithDelay:[self console]];
}

- (void)rebuildExplorer
{        
    [mExplorer rebuild];
}

- (BOOL)allowedToSave
{
    return YES;
}

#pragma mark -

- (void)makeWindowControllers
{        
    id mwc = [[ProjectWC alloc] init];
    [mExplorer setDelegate:[mwc projectExplorer]];
    [self addWindowController:mwc];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ILNotificationProjectProviderDidOpen object:self];
}

#pragma mark -

- (void)setUndoManagerEnabled:(BOOL)flag
{
    mUndoManagerEnabled = flag;
}

- (BOOL)undoManagerEnabled
{
    return mUndoManagerEnabled;
}

- (NSUndoManager*)projectUndoManager
{
    if(mUndoManagerEnabled) {
        return [self undoManager];
    } else {
        return nil;
    }
}

- (ProjectModel*)projectModel
{
    return mProjectModel;
}

- (ProjectPrefs*)projectPrefs
{
    return mProjectPrefs;
}

- (Structure*)structure
{
    return mStructure;
}

- (Explorer*)explorer
{
    return mExplorer;
}

- (Console*)console
{
    return mConsole;
}

- (HistoryManager*)historyManager
{
    return [[self projectWC] historyManager];
}

- (ProjectDocument*)projectDocument
{
    return self;
}

- (ProjectController*)projectController
{
    return mProjectController;
}

- (LanguageController*)selectedLanguageController
{
    return [[self projectWC] selectedLanguageController];
}

- (NSArray*)selectedFileControllers
{
    return [[self projectWC] selectedFileControllers];
}

- (NSArray*)selectedStringControllers
{
    return [[self projectWC] selectedStringControllers];
}

- (ProjectWC*)projectWC
{
    return [[self windowControllers] firstObject];
}

- (OperationWC*)operation
{
    return mOperationWC;
}

- (OperationDispatcher*)operationDispatcher
{
    return mOperationDispatcher;
}

- (EngineProvider*)engineProvider
{
    return mEngineProvider;
}

- (FMEditor*)currentFileModuleEditor
{
    return [[self projectWC] currentFileEditor];
}

- (FMEditor*)fileModuleEditorForFile:(NSString*)file
{
    NSString *ext = [file pathExtension];
    if([file isPathNib])
        ext = @"strings";    // same editor for strings/nib/xib file
    
    FMEditor *editor = mFMEditors[ext];
    if(editor == NULL) {
        editor = [[FMManager shared] editorForFile:file];
        if(editor) {
            mFMEditors[ext] = editor;
            [editor setProjectProvider:self];
            [editor awake];
        }
    }
    return editor;
}

- (FMEngine*)fileModuleEngineForFile:(NSString*)file
{
    FMEngine *engine = nil;
    @synchronized(self) {
        engine = mFMEngines[[file pathExtension]];
        if(engine == NULL) {
            engine = [[FMManager shared] engineForFile:file];
            if(!engine)
                engine = [FMEngine engine];
            mFMEngines[[file pathExtension]] = engine;
        }
        [engine setProjectProvider:self];        
    }
    return engine;
}

- (NSString*)sourceApplicationPath
{
    return [[self projectModel] projectSourceFilePath];    
}

- (NSString*)projectAppVersionString
{
    NSString *language = [[self projectModel] baseLanguage];
    NSString *path = [[self projectModel] projectSourceFilePath];
    NSString *shortVersionString = [FileTool shortVersionOfBundle:path language:language];    
    NSString *versionString = [FileTool versionOfBundle:path language:language];
    
    if(shortVersionString && versionString)
        return [NSString stringWithFormat:@"%@ build %@", shortVersionString, versionString];
    else if(shortVersionString)
        return shortVersionString;
    else if(versionString)
        return versionString;
    else
        return @"";
}

- (NSString*)applicationExecutableName
{
    // First look at the Info.plist file to get the name of the executable (because the Finder name can be different)
    
    NSDictionary *infoDic = [[NSBundle bundleWithPath:[self sourceApplicationPath]] infoDictionary];
    if(infoDic) {
        if(infoDic[@"CFBundleExecutable"])
            return infoDic[@"CFBundleExecutable"];
    }
    
    return [[[self sourceApplicationPath] lastPathComponent] stringByDeletingPathExtension];
}

- (void)rearrangeFilesController
{
    [[[self projectWC] filesController] rearrangeObjects];
}

- (void)beginOperation
{
    self.operationRunning = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:ILNotificationBeginOperation object:self];
    [mProjectController beginOperation];
}

- (void)endOperation
{
    self.operationRunning = NO;
    [mProjectController endOperation];
    [[NSNotificationCenter defaultCenter] postNotificationName:ILNotificationEndOperation object:self];
    [self updateDirty];
}

- (void)openFileWithExternalEditor:(NSString*)file
{
    NSString *suggestedApp = nil;
    if([file isPathNib]) {
        suggestedApp = [[PreferencesAdvanced shared] interfaceBuilder3Path];
//        if([Utils isOSTigerAndBelow]) {
//            // no suggestion, it will be IB 2.x anyway
//        } else {
//            // here, let's see if the nib is IB 2 or IB 3
//            if([file isPathNib2]) {
//                suggestedApp = [[PreferencesAdvanced shared] interfaceBuilder2Path];                
//            } else if([file isPathNib3]) {                
//                suggestedApp = [[PreferencesAdvanced shared] interfaceBuilder3Path];
//            } else {
//                // unable to determine the version, use the project setting
//                switch([self  nibEngineType]) {
//                    case TYPE_NIBTOOL:
//                        suggestedApp = [[PreferencesAdvanced shared] interfaceBuilder2Path];
//                        break;
//                    case TYPE_IBTOOL:
//                        suggestedApp = [[PreferencesAdvanced shared] interfaceBuilder3Path];
//                        break;
//                }
//            }
//        }
    }
    [FileTool openFile:file suggestedApp:suggestedApp];    
}

#pragma mark -

- (void)resetConflictingFilesDecision
{
    [mConflictingFilesDecision removeAllObjects];
}

- (void)setConflictingFilesDecision:(NSArray*)decision
{
    [mConflictingFilesDecision addObjectsFromArray:decision];
}

- (int)decisionForConflictingRelativeFile:(NSString*)file
{
    for(FileConflictDecision *decision in mConflictingFilesDecision) {
        if([decision.file isEqualToString:file]) {
            return decision.decision;            
        }
    }
    return RESOLVE_USE_NONE;
}

#pragma mark -

- (NSString*)consoleFile
{
    return [[[[self fileURL] path] stringByDeletingPathExtension] stringByAppendingPathExtension:@"console"];
}

- (BOOL)keepBackupFile
{
    return YES;
}

/**
 Overrides this method to ensure the dirty indicator never gets displayed. This is because
 iLocalize automatically saves the document when the window is closed.
 */
- (void)updateChangeCount:(NSDocumentChangeType)change
{
    //NSLog(@"%@", [NSThread callStackSymbols]);
    [super updateChangeCount:NSChangeCleared];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    if(![self allowedToSave]) {
        return nil;        
    }
    
    [[SaveAllOperation operationWithProjectProvider:self] saveFilesWithoutConfirmation];

    [[self projectWC] documentWillSave];
        
    // Save the console data in another file
    
    [[NSKeyedArchiver archivedDataWithRootObject:mConsole] writeToFile:[self consoleFile] atomically:YES];
        
    // Save the project data    
    return [ProjectDiskOperations dataForModel:mProjectModel prefs:mProjectPrefs];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    if ([data length])
    {
        NSDictionary *dic = [ProjectDiskOperations readProjectUsingData:data];

        if (dic == nil)
        {
            // compose alert
            NSAlert *alert = [NSAlert new];
            
            [alert setAlertStyle:NSAlertStyleWarning];
            [alert setMessageText:NSLocalizedStringFromTable(@"ProjectDocumentInvalidTitle",@"Alerts",nil)];
            [alert setInformativeText:NSLocalizedStringFromTable(@"ProjectDocumentRecentDescr",@"Alerts",nil)];
            [alert addButtonWithTitle:NSLocalizedStringFromTable(@"ProjectDocumentInvalidOK",@"Alerts",nil)];   // 1st button
            
            // show alert
            [alert runModal];

            return NO;
        }
        
        BOOL upgrade = NO;
        mOSVersion = [dic[PROJECT_OS_VERSION] longValue];        

        // 1 = nibtool
        // 2 = ibtool
        NSUInteger nibEngineType = 2;
        
        if (dic[PROJECT_NIBENGINE_TYPE])
        {
            // NibEngine type is specified, use it.
            nibEngineType = [dic[PROJECT_NIBENGINE_TYPE] longValue];
        }
        
        // Leopard and above
        if (nibEngineType != 2)
        {
            // Cannot open Tiger project on Leopard OS if nibtool is not installed

            // compose alert
            NSAlert *alert = [NSAlert new];
            
            [alert setAlertStyle:NSAlertStyleWarning];
            [alert setMessageText:NSLocalizedStringFromTable(@"ProjectDocumentTigerTitle",@"Alerts",nil)];
            [alert setInformativeText:NSLocalizedStringFromTable(@"ProjectDocumentTigerDescr",@"Alerts",nil)];
            [alert addButtonWithTitle:NSLocalizedStringFromTable(@"ProjectDocumentInvalidOK",@"Alerts",nil)];   // 1st button
            
            // show alert
            [alert runModal];

            return NO;
        }            
        
        int documentVersion = [dic[PROJECT_VERSION_KEY] intValue];

        if (documentVersion > CURRENT_DOCUMENT_VERSION)
        {
            // compose alert
            NSAlert *alert = [NSAlert new];
            
            [alert setAlertStyle:NSAlertStyleWarning];
            [alert setMessageText:NSLocalizedStringFromTable(@"ProjectDocumentRecentTitle",@"Alerts",nil)];
            [alert setInformativeText:NSLocalizedStringFromTable(@"ProjectDocumentRecentDescr",@"Alerts",nil)];
            [alert addButtonWithTitle:NSLocalizedStringFromTable(@"ProjectDocumentInvalidOK",@"Alerts",nil)];   // 1st button
            
            // show alert
            [alert runModal];
            
            return NO;
        }
        else if(documentVersion < CURRENT_DOCUMENT_VERSION)
        {
            // compose alert
            NSAlert *alert = [NSAlert new];
            
            [alert setAlertStyle:NSAlertStyleWarning];
            [alert setMessageText:NSLocalizedStringFromTable(@"ProjectDocumentUpgradeTitle",@"Alerts",nil)];
            [alert setInformativeText:[NSString stringWithFormat:NSLocalizedStringFromTable(@"ProjectDocumentUpgradeDescr",@"Alerts",nil), [[[self fileURL] path] lastPathComponent]]];
            [alert addButtonWithTitle:NSLocalizedStringFromTable(@"ProjectDocumentInvalidOK",@"Alerts",nil)];   // 1st button
            
            // show and evaluate alert
            if ([alert runModal] == NSAlertFirstButtonReturn)
                upgrade = YES;
            else
                return NO;            
        }

        if ([[self consoleFile] isPathExisting])
        {
            id console = [NSKeyedUnarchiver unarchiveObjectWithFile:[self consoleFile]];
            
            if (console)
            {
                mConsole = console;
            }
        }
        
        if (dic[PROJECT_MODEL_KEY])
        {
            mProjectModel = dic[PROJECT_MODEL_KEY];
            [mProjectModel setProjectPath:[[[self fileURL] path] parentPath]];
            [self repairProjectModel:mProjectModel];
            
            @try
            {
                [mProjectController rebuildFromModel];            
            }
            @catch (NSException * e)
            {
                if (outError)
                {
                    EXCEPTION(e);
                    NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to open the project", nil)};
                    *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:errorInfo];
                }
                
                return NO;
            }
        }
        
        if (dic[PROJECT_PREFS_KEY])
        {
            mProjectPrefs = dic[PROJECT_PREFS_KEY];    
            [mProjectPrefs setProjectProvider:self];
        }
                
        if (upgrade)
        {
            // Backup the old file. The new project will be saved anyway at some point later
            // or when the user closes it.
            NSString *filename = [[self fileURL] path];
            NSString *copy = [NSString stringWithFormat:@"%@.old-%@", [filename stringByDeletingPathExtension], [filename pathExtension]];
            [[NSFileManager defaultManager] copyItemAtPath:filename toPath:copy error:nil];
        }
        
        [self rebuildExplorer];
        [[self undoManager] removeAllActions];
    }
    
    return YES;
}

#pragma mark -

- (void)updateDirty
{
    if (self.documentBecameDirty)
    {
        self.documentBecameDirty = NO;
        [self setDirty];
    }
}

- (void)setDirty
{
    // Note: we have to delay the update change count if the window is not visible. Otherwise, the dirty "mark" is not correctly
    // displayed and will not be updated later (even if another set dirty call is made)
    if ([[self projectWC] isWindowLoaded])
    {
        // Since version 4.0, the flag dirty is set only when files need to be saved on the disk.
        if (self.operationRunning)
        {
            // Delay this action until the current operation finishes because it might cause a crash if one of the file controller
            // gets deleted while enumerating it to find if it needs to be saved to the disk.
            self.documentBecameDirty = YES;
        }
        else
        {
            if ([[[self projectController] needsToBeSavedFileControllers] count] > 0)
            {
                [self updateChangeCount:NSChangeDone];                    
            }
            else
            {
                [self updateChangeCount:NSChangeCleared];                                
            }            
        }
    }
    else
    {
        // The window controller will call `updateDirty` when the window is loaded
        self.documentBecameDirty = YES;
    }
}

- (void)projectControllerDidBecomeDirty:(NSNotification*)notif
{
    if ([notif object] == mProjectController)
    {
        [self performSelectorOnMainThread:@selector(setDirty)
                               withObject:NULL
                            waitUntilDone:NO];        
    }
}

#pragma mark -

- (void)checkProjectAfterCreation
{
    CheckProjectOperation *op = [CheckProjectOperation operationWithProjectProvider:[self projectDocument]];
    [op setDelegate:self];
    [op checkAllProjectNoAlertIfSuccess];
}

- (void)checkProjectCompleted
{
    [self saveDocument:self];
    
    // Assume that at this point only the NewProject AppleEvent is in progres:
    // end the event and return the newly created project
    [[ASManager shared] endAsyncCommandWithResult:[ASProject projectWithDocument:self]];        
}

- (void)createProjectDidCancel
{
    // Remove project because the next time iLocalize is launched, it will be opened (because it
    // is in the Recent Files menu)
    [[[self projectModel] projectPath] removePathFromDisk];
    [[self operation] hide];
    // FIX CASE 51
    [[self windowControllers] makeObjectsPerformSelector:@selector(close)];
    [self close];
    
    [[ASManager shared] endAsyncCommand];    
}

- (void)createProjectDidEnd
{
    // Display now the project window (see comment in Application)

    // Make sure the window controllers are created (when creating a new project, they are not).
    if ([self projectWC] == nil)
    {
        [self makeWindowControllers];        
    }
    
    [self rebuildExplorer];
    [[[self projectWC] window] makeKeyAndOrderFront:self];        
    [[self projectWC] reloadAll];
    
    // Check the project
    [self performSelector:@selector(checkProjectAfterCreation) withObject:nil afterDelay:0];
}

#pragma mark -

- (void)canCloseDocumentWithDelegate:(id)inDelegate shouldCloseSelector:(SEL)inShouldCloseSelector contextInfo:(void *)inContextInfo
{
    // don't present an alert, save all the files immediately
    [self saveDocumentWithDelegate:inDelegate 
                   didSaveSelector:inShouldCloseSelector 
                       contextInfo:inContextInfo];
}

- (void)close
{
    for (FMEditor *editor in [mFMEditors allValues])
    {
        [editor close];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ILNotificationProjectProviderWillClose object:self];
    [super close];
    [[NSNotificationCenter defaultCenter] postNotificationName:ILNotificationProjectProviderDidClose object:self];    
}

- (IBAction)showConsoleWindow:(id)sender
{
    if (mConsoleWindowController == NULL)
    {
        mConsoleWindowController = [[ConsoleWC alloc] initWithProjectProvider:self];        
    }
    
    [mConsoleWindowController show];
}

- (BOOL)validateMenuItem:(NSMenuItem*)anItem
{
    SEL action = [anItem action];
    
    if (action == @selector(saveDocumentAs:))
    {
        return NO;
    }
    
    if (action == @selector(saveDocumentTo:))
    {
        return NO;
    }
    
    if (action == @selector(revertDocumentToSaved:))
    {
        return NO;
    }
    
    return YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ - %@", [super description], [self fileURL]];
}

@end
