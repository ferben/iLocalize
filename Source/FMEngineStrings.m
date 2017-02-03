//
//  FMEngineStrings.m
//  iLocalize3
//
//  Created by Jean on 25.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEngineStrings.h"
#import "FMStringsExtensions.h"

#import "EngineProvider.h"
#import "SynchronizeEngine.h"
#import "StringsEngine.h"

#import "FileModel.h"
#import "StringModel.h"
#import "StringsContentModel.h"

#import "FileController.h"
#import "StringController.h"

#import "Console.h"
#import "Constants.h"

#import "StringEncodingTool.h"
#import "PreferencesLanguages.h"

@implementation FMEngineStrings

- (id)init
{
    if ((self = [super init]))
    {
    }
    
    return self;
}


// Overridden by FMEngineNib
- (AbstractStringsEngine *)stringModelsOfFile:(NSString *)file encodingUsed:(StringEncoding **)encoding defaultEncoding:(StringEncoding *)defaultEncoding
{
    StringsEngine *engine = [self stringsEngine];
    [engine parseStringModelsOfStringsFile:file encodingUsed:encoding defaultEncoding:defaultEncoding];    
    
    return engine;
}

// Overridden by FMEngineNib
- (AbstractStringsEngine *)stringModelsOfFile:(NSString *)file defaultEncoding:(StringEncoding *)defaultEncoding
{
    return [self stringModelsOfFile:file encodingUsed:nil defaultEncoding:defaultEncoding];    
}

// Overridden by FMEngineNib
- (AbstractStringsEngine *)stringModelsOfFile:(NSString *)file usingEncoding:(StringEncoding *)encoding
{
    StringsEngine *engine = [self stringsEngine];
    [engine parseStringModelsOfStringsFile:file encoding:encoding];    
    
    return engine;
}

#pragma mark -

- (BOOL)supportsStringEncoding
{
    return YES;
}

- (BOOL)supportsContentTranslation
{
    return YES;
}

- (FileModelContent *)fmDuplicateFileModelContent:(FileModelContent *)content emptyValue:(BOOL)emptyValue
{
    FileModelContent *newContent = [content copy];
    [newContent setContent:[NSMutableArray array]];
    
    NSEnumerator *enumerator = [[content stringsContent] stringsEnumerator];
    StringModel* stringModel;
    
    while ((stringModel = [enumerator nextObject]))
    {
        StringModel *nsm = [stringModel copy];

        // Status needs to be computed again (i.e. when creating a new language)
        // HACK
        [nsm setStatus:(1 << STRING_STATUS_NONE)];
        
        if (emptyValue)
            [nsm setValue:@""];
        
        [[newContent content] addObject:nsm];
    }
    
    return newContent;
}

- (void)fmLoadFile:(NSString *)file intoFileModel:(FileModel *)fileModel
{
    AbstractStringsEngine *engine = [self stringModelsOfFile:file defaultEncoding:[self encodingForLanguage:[fileModel language]]];
    
    [[fileModel fileModelContent] setContent:[engine content]];
    [fileModel setEOLType:[engine eolType]];
    [fileModel setFormat:[engine format]];
}

- (void)fmTranslateFileModel:(FileModel *)fileModel usingLocalizedFile:(NSString *)localizedFile
{
    AbstractStringsEngine *engine = [self stringModelsOfFile:localizedFile defaultEncoding:[self encodingForLanguage:[fileModel language]]];
    StringsContentModel *localizedStringModels = [engine content];
    
    if ([localizedStringModels numberOfStrings] == 0)
        return;
    
    NSEnumerator *enumerator = [[[fileModel fileModelContent] stringsContent] stringsEnumerator];
    StringModel *stringModel;
    
    while ((stringModel = [enumerator nextObject]))
    {
        StringModel *localizedModel = [localizedStringModels stringModelForKey:[stringModel key]];
        
        if (localizedModel)
            [stringModel setValue:[localizedModel value]];
    }
    
    // Because we are not sure if the localized file is identical to the memory file (and the localized file can also
    // be outside of the project)
    [fileModel setModificationDate:[NSDate date]];
}

#pragma mark -

- (id)fmRebaseBaseFileController:(FileController *)baseFileController usingFile:(NSString *)file eolType:(NSUInteger *)eolType
{
    AbstractStringsEngine *engine = [self stringModelsOfFile:file defaultEncoding:[self encodingForLanguage:[baseFileController language]]];
    StringsContentModel *stringModels = [engine content];    
    *eolType = [engine eolType];
    
    if ([stringModels numberOfStrings] == 0)
        return stringModels;
        
    // First detect and mark string models were the base value has changed (base modified)
    
    NSEnumerator *enumerator = [stringModels stringsEnumerator];
    StringModel *stringModel;
    
    while ((stringModel = [enumerator nextObject]))
    {
        StringController *baseStringController = [baseFileController stringControllerForKey:[stringModel key]];
//        StringController *baseStringController = [[baseFileController stringControllers] stringControllerForKey:[stringModel key]];

        if (!baseStringController)
            continue;
        
        if ([[baseStringController base] isEqualToString:[stringModel value]])
            continue;
        
        // Tricks to set the correct status!
        // HACK
        [stringModel setStatus:(1 << STRING_STATUS_BASE_MODIFIED) | (1 << STRING_STATUS_TOCHECK)];
        
        [[self console] addLog:[NSString stringWithFormat:@"Base string modified { key = \"%@\", value = \"%@\" } with key { key = \"%@\", value = \"%@\" }",
            [baseStringController key],
            [baseStringController translation],
            [stringModel key],
            [stringModel value]] class:[self class]];
    }    
    
    return stringModels;
}

- (void)fmRebaseFileContentWithContent:(StringsContentModel *)content fileController:(FileController *)fileController
{
    FileModel *fileModel = [fileController fileModel];
        
    // Display which key will be removed
    
    NSEnumerator *enumerator = [[[fileModel fileModelContent] stringsContent] stringsEnumerator];
    StringModel *model;
    
    while ((model = [enumerator nextObject]))
    {
        if ([content stringModelForKey:[model key]] == NULL)
        {
            [[self console] addLog:[NSString stringWithFormat:@"Remove key { key = \"%@\", value = \"%@\", comment = \"%@\" }",
                [model key], [model value], [model comment]] class:[self class]];
        }
    }
    
    // Display which key will be added
    
    NSMutableArray *newModels = [NSMutableArray array];
    
    enumerator = [content stringsEnumerator];
    
    while ((model = [enumerator nextObject]))
    {
        if ([[[fileModel fileModelContent] stringsContent] stringModelForKey:[model key]] == NULL)
        {
            // Add the new models to an array for further actions
            [newModels addObject:model];
            
            // Mark each added string
            // HACK
            [model setStatus:(1 << STRING_STATUS_TOCHECK)];
            
            [[self console] addLog:[NSString stringWithFormat:@"Add key { key = \"%@\", value = \"%@\", comment = \"%@\" }",
                [model key], [model value], [model comment]] class:[self class]];
        }
    }
    
    // Do the rebase of the string models
    
    [[[fileModel fileModelContent] stringsContent] removeAllStrings];
    
    BOOL isBase = [fileController isBaseFileController];
    
    enumerator = [content stringsEnumerator];
    
    while ((model = [enumerator nextObject]))
    {
        StringModel *newModel = [model copy];
        
        if (!isBase && [newModels containsObject:model])
        {
            // If file controller is not a base file, remove the translation
            // because it is in fact not translated ;-)
            [newModel setValue:@""];
            // HACK
            [newModel setStatus:(1 << STRING_STATUS_TOTRANSLATE)];
        }
        
        [[[fileModel fileModelContent] stringsContent] addStringModel:newModel];
    }
    
    [fileController rebuildFromModel];
    [fileController stringControllersDidChange];
    
    // Synchronize the date. If the file is not a base file, it will be synchronized anyway by the caller method (see below)    
    [fileController setModificationDate:[[fileController absoluteFilePath] pathModificationDate]];
}

- (void)fmRebaseTranslateContentWithContent:(StringsContentModel *)content fileController:(FileController *)fileController
{    
    // Translate all string models that are already existing in the localized language
    NSEnumerator *enumerator = [content stringsEnumerator];
    StringModel *stringModel;
    
    while ((stringModel = [enumerator nextObject]))
    {
        //StringController *localizedStringController = [[fileController stringControllers] stringControllerForKey:[stringModel key]];
        StringController *localizedStringController = [fileController stringControllerForKey:[stringModel key]];
        
        if (localizedStringController)
        {
            [[self console] addLog:[NSString stringWithFormat:@"Translate key { key = \"%@\", value = \"%@\" } with key { key = \"%@\", value = \"%@\" }",
                [stringModel key],
                [stringModel value],
                [localizedStringController key],
                [localizedStringController translation]] class:[self class]];
            
            [stringModel setValue:[localizedStringController translation]];
            [stringModel setComment:[localizedStringController translationComment]];
        }
    }            
}

- (void)fmRebaseAndTranslateContentWithContent:(StringsContentModel *)content fileController:(FileController *)fileController usingPreviousLayout:(BOOL)previousLayout
{    
    // Translate first all string models that are already existing in the localized language
    [self fmRebaseTranslateContentWithContent:content fileController:fileController];
    
    // And then replace the string models    
    [self fmRebaseFileContentWithContent:content fileController:fileController];
    
    // Update file to disk    
    [[self synchronizeEngine] synchronizeToDisk:fileController];
}

#pragma mark -

- (void)fmReloadFileController:(FileController *)fileController usingFile:(NSString *)file
{
    AbstractStringsEngine *engine;
    StringsContentModel *stringModels;
    
    if ([fileController supportsEncoding])
    {
        // Read the strings from the proposed file by detecting its encoding (it can be different
        // than the file represented by the file controller).
        StringEncoding *encoding;
        
        engine = [self stringModelsOfFile:file 
                             encodingUsed:&encoding
                          defaultEncoding:[self encodingForLanguage:[fileController language]]];
        
        // Needs to update the encoding because it can change on the disk after the file is created.
        [fileController setEncoding:encoding];        
        [fileController setHasEncoding:YES];        
    }
    else
    {
        // The only case for that is if the file is a nib file. This method is not overrided
        // by FMEngineNib, that's why we have to test that.
        engine = [self stringModelsOfFile:file usingEncoding:0];
    }
    
    stringModels = [engine content];

    for (StringController *stringController in [fileController stringControllers])
    {
        StringModel *localizedModel = [stringModels stringModelForKey:[stringController key]];
    
        if (!localizedModel)
            continue;
        
        // Update also the comment if it is non-null
        if ([localizedModel comment])
        {
            [stringController setTranslationComment:[localizedModel comment]];            
        }
        
        // Force automatic translation because the translation comes from the file and cannot
        // be not translated. The problem first appears with the option "Auto translation: turned on only for
        // to translate strings": strings already translated were not updated which is wrong here
        // because these translation comes from the file itself.
        [stringController setAutomaticTranslation:[localizedModel value] force:YES];
        
        if (![[stringController translation] isEqualToString:[localizedModel value]])
        {
            // If the string cannot be modified, then the source file used to update the string
            // is not anymore up-to-date and needs to be saved (only if the source file is the localized file!)
            if ([file isEqualToString:[fileController absoluteFilePath]])
                [stringController setModified:MODIFY_ALL];
        }
    }
    
    [fileController stringControllersDidChange];    
}

- (void)fmSaveFileController:(FileController *)fileController usingEncoding:(StringEncoding *)encoding
{
    NSString *file = [fileController absoluteFilePath];
    StringsContentModel *baseStringModels = [[[fileController baseFileModel] fileModelContent] stringsContent];
    StringsContentModel *stringModels = [[[fileController fileModel] fileModelContent] stringsContent];
    StringsEngine *engine = [self stringsEngine];
    [engine setEolType:[[fileController baseFileModel] eolType]];
    
    NSData *data = [StringEncodingTool encodeString:[engine encodeStringModels:stringModels baseStringModels:baseStringModels 
                                                                     skipEmpty:NO format:[[fileController fileModel] format]
                                                                      encoding:encoding]
                                toDataUsingEncoding:encoding];        
    
    if ([data writeToFile:file atomically:YES] == NO)
    {
        [[self console] addError:[NSString stringWithFormat:@"Failed to write %@", [file lastPathComponent]]
                     description:[NSString stringWithFormat:@"Cannot write to file \"%@\"", file]
                           class:[self class]];
    }
}

@end
