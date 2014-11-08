
@class ProjectModel;
@class ProjectPrefs;
@class Structure;
@class Explorer;
@class Console;
@class ProjectDocument;
@class ProjectController;
@class LanguageController;
@class ProjectWC;
@class OperationWC;
@class OperationDispatcher;
@class EngineProvider;
@class FMEditor;
@class FMEngine;
@class HistoryManager;

@protocol ProjectProvider

- (void)setUndoManagerEnabled:(BOOL)flag;
- (BOOL)undoManagerEnabled;
- (NSUndoManager*)projectUndoManager;

- (ProjectModel*)projectModel;
- (ProjectPrefs*)projectPrefs;
- (Structure*)structure;
- (Explorer*)explorer;
- (Console*)console;
- (HistoryManager*)historyManager;

- (ProjectDocument*)projectDocument;
- (ProjectController*)projectController;
- (LanguageController*)selectedLanguageController;
- (NSArray*)selectedFileControllers;
- (NSArray*)selectedStringControllers;

- (ProjectWC*)projectWC;
- (OperationWC*)operation;

- (OperationDispatcher*)operationDispatcher;
- (EngineProvider*)engineProvider;

- (FMEditor*)currentFileModuleEditor;

- (FMEditor*)fileModuleEditorForFile:(NSString*)file;
- (FMEngine*)fileModuleEngineForFile:(NSString*)file;

- (NSString*)sourceApplicationPath;

- (NSString*)projectAppVersionString;
- (NSString*)applicationExecutableName;

- (void)beginOperation;
- (void)endOperation;

- (void)rearrangeFilesController;

- (void)resetConflictingFilesDecision;
- (void)setConflictingFilesDecision:(NSArray*)decision;
- (int)decisionForConflictingRelativeFile:(NSString*)file;

- (void)setDirty;

- (void)openFileWithExternalEditor:(NSString*)file;

@end