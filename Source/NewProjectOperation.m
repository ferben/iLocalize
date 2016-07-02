//
//  NewProjectEngine.m
//  iLocalize3
//
//  Created by Jean on 30.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "NewProjectOperation.h"
#import "ModelEngine.h"
#import "LanguageEngine.h"
#import "ResourceFileEngine.h"

#import "ProjectController.h"
#import "ProjectDocument.h"

#import "ProjectModel.h"
#import "LanguageModel.h"
#import "FileModel.h"

#import "LanguageTool.h"
#import "FileTool.h"

#import "Console.h"
#import "OperationWC.h"

#import "NewProjectSettings.h"
#import "BundleSource.h"
#import "FileOperationManager.h"

@implementation NewProjectOperation

@synthesize settings;

- (id)init
{
	if (self = [super init])
    {
	}
	
    return self;
}


#pragma mark -

- (void)copyMoveSourceToProjectPath
{
    NSArray *baseLanguages = [LanguageTool equivalentLanguagesWithLanguage:[self.settings baseLanguage]];
    
    NSMutableArray *files = [NSMutableArray arrayWithArray:[self.settings.source relativeSourceFiles]];
    
    FileOperationManager *m = [FileOperationManager manager];
    [m includeLocalizedFilesFromLanguages:baseLanguages files:files];

    NSString *targetPath = [[ProjectModel projectSourceFolderPathForProjectPath:self.settings.projectFolderPath] stringByAppendingPathComponent:[self.settings.source.sourcePath lastPathComponent]];
    
    [m copyFiles:files source:self.settings.source.sourcePath target:targetPath errorHandler:^BOOL(NSError *error)
    {
        [self notifyError:error];
        return YES;
    }];
}

#pragma mark -

- (void)createBaseFileModels
{
	if ([self cancel])
		return;

	[[self console] beginOperation:@"Creating base file models" class:[self class]];
	
    // NSLog(@"baseLanguage: %@", [self.settings baseLanguage]);
    // NSLog(@"# of localizedLanguages: %ld", [self.settings.localizedLanguages count]);
    
	NSArray *baseFiles = [[[self engineProvider] resourceFileEngine] filesOfLanguage:[self.settings baseLanguage]];
    
	[self setProgressMax:[baseFiles count] * ([self.settings.localizedLanguages count] + 1)];
		
    [baseFiles enumerateObjectsWithOptions:CONCURRENT_OP_OPTIONS usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        NSString *baseFile = obj;
        [[self console] addLog:[NSString stringWithFormat:@"From file \"%@\"", baseFile] class:[self class]];
        [self progressIncrement];		
        
        FileModel *baseFileModel = [[[self engineProvider] modelEngine] createFileModelFromProjectFile:baseFile];
        
        [[self projectModel] addFileModel:baseFileModel toLanguage:[self.settings baseLanguage]];
        
        *stop = [self cancel];
    }];        
	
	[[self console] endOperation];
}

- (void)createLocalizedFileModels
{
	if([self cancel])
		return;
	
	[[self console] beginOperation:@"Creating localized languages" class:[self class]];
	
	[[[self engineProvider] languageEngine] addLanguages:self.settings.localizedLanguages
											   identical:YES
												  layout:YES
										copyOnlyIfExists:self.settings.copySourceOnlyIfExists
                                                  source:self.settings.source];
			
	[[self console] endOperation];
}

- (void)prepareProjectModel:(ProjectModel *)model
{
	[model setSourceName:[self.settings.source sourceName]];
	[model setName:self.settings.name];
	[model setProjectPath:self.settings.projectFolderPath];
	[model setBaseLanguage:self.settings.baseLanguage];	
}

- (void)createProjectDocument
{
	// Do not display the window yet - it will be displayed after the project creation (otherwise, we are having problem
	// with the binding (structure table doesn't work - in fact, LanguageController will/didChangeKey doesn't seem to work but
	// work as soon as we deselect and select the language again)
	
	// Create an empty file  and open it (at the end of the New Project process, the document will be automatically saved)
	NSString * file = [self.settings projectFilePath];
    
	if ([file isPathExisting])
		[file removePathFromDisk];
	else
		[[FileTool shared] preparePath:file atomic:YES skipLastComponent:YES];
    
	[[NSFileManager defaultManager] createFileAtPath:file contents:NULL attributes:NULL];
    
    // NSDocument *document;
	
    NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
    NSURL *url = [NSURL fileURLWithPath:file];
    
    NSDocument *document = [documentController openDocumentWithContentsOfURL:url display:NO error:nil];


/* fd:2016-07-02: somehow the new method always returns nil for document. :-(
 
 [documentController openDocumentWithContentsOfURL:[NSURL fileURLWithPath:file] display:NO completionHandler:
    ^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error)
    {
        if (error)
        {
            [documentController presentError:error];
        }
    }];
*/
    // Safety first - don't keep empty project files!
    if (document == nil)
    {
        if ([file isPathExisting])
            [file removePathFromDisk];
    }
    else
    {
        ProjectDocument *myDocument = (ProjectDocument *)document;
        
        [self prepareProjectModel:[myDocument projectModel]];
        [self notifyNewProjectProvider:myDocument];
    }
}

- (BOOL)cancellable
{
	return YES;
}

- (void)createProject
{
    NSDate *beginDate = [NSDate date];
    
	[self copyMoveSourceToProjectPath];	
	
	[[[self engineProvider] resourceFileEngine] parseFilesInPath:[[self projectModel] projectSourceFilePath]];
	
	[self createBaseFileModels];
    
	if ([self cancel])
        return;
	
	[self createLocalizedFileModels];
    
	if ([self cancel])
        return;

	[[self projectController] rebuildFromModel];	
    
    [[self console] addLog:[NSString stringWithFormat:@"Created project in %.2f seconds", [[NSDate date] timeIntervalSinceDate:beginDate]] class:[self class]];
}

- (void)didExecute
{
	// Notify the project document that the project has been created
	ProjectDocument *doc = (ProjectDocument *)self.projectProvider;
	
    if ([self cancel])
    {
		[doc performSelectorOnMainThread:@selector(createProjectDidCancel) withObject:nil waitUntilDone:YES];
	}
    else
    {
		[doc performSelectorOnMainThread:@selector(createProjectDidEnd) withObject:nil waitUntilDone:YES];
	}	
}

- (void)execute
{
	[[self console] beginOperation:@"Create New Project" class:[self class]];
	[self setOperationName:NSLocalizedString(@"Creating Project…", nil)];
    
	// This is the first step to do: it creates the document and assign the project provider
	// to this operation. Must execute on the main thread otherwise we have problems with the timer
	// that cannot be deallocated later on (it must be allocated/deallocated from the same thread).
    
    [self performSelectorOnMainThread:@selector(createProjectDocument) withObject:nil waitUntilDone:YES];
    
	[self createProject];
	
	[[self console] endOperation];	
}

@end
