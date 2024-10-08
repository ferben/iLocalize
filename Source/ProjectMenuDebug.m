//
//  ProjectMenuDebug.m
//  iLocalize
//
//  Created by Jean on 1/8/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "ProjectMenuDebug.h"
#import "ProjectDocument.h"

#import "StringEncodingTool.h"
#import "StringEncoding.h"

#import "FileController.h"
#import "FMEngine.h"
#import "CheckProjectOperation.h"
#import "SaveAllOperation.h"
#import "NibEngine.h"
#import "NibEngineResult.h"
#import "OperationWC.h"
#import "LanguageController.h"
#import "ProjectWC.h"

#import "TMXImporter.h"

@implementation ProjectMenuDebug

- (IBAction)checkSelectedFile:(id)sender
{
    [[CheckProjectOperation operationWithProjectProvider:[self projectDocument]] checkSelectedFile];
}

- (IBAction)detectEncoding:(id)sender
{
    FileController *fc = [[self.projectWC selectedFileControllers] firstObject];
    
    if (fc)
    {
        FMEngine *e = [[self projectDocument] fileModuleEngineForFile:[fc filename]];
        StringEncoding *encoding = [e encodingOfFile:[fc filename] language:[[self.projectWC selectedLanguageController] language]];
        
        if ([fc encoding] != encoding)
        {
            // compose alert
            NSAlert *alert = [NSAlert new];
            [alert setAlertStyle:NSAlertStyleWarning];
            [alert setMessageText:NSLocalizedStringFromTable(@"DebugMismatchEncodingTitle",@"Alerts",nil)];
            [alert setInformativeText:[NSString stringWithFormat:NSLocalizedStringFromTable(@"DebugMismatchEncodingDescr", @"Alerts", nil), [[fc encoding] encodingName], encoding.encodingName]];
            [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextReload",@"Alerts",nil)];      // 1st button
            [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextCancel",@"Alerts",nil)];      // 2nd button
            
            // show alert
            [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse alertReturnCode)
            {
                [[alert window] orderOut:self];
                
                if (alertReturnCode == NSAlertFirstButtonReturn)
                {
                    // old stuff from -beginSheetModalForWindow:modalDelegate:didEndSelector:contextInfo:
                    // FileController *fc = (__bridge FileController *)(contextInfo);
                    [fc setEncoding:[self encodingOfFileController:fc]];
                    [[SaveAllOperation operationWithProjectProvider:[self projectDocument]] reloadAll:@[fc]];
                }
            }];
        }
    }
}

- (StringEncoding *)encodingOfFileController:(FileController *)fc
{
    BOOL hasEncoding;

    return [StringEncodingTool encodingOfFile:[fc absoluteFilePath] defaultEncoding:[fc encoding] hasEncodingInformation:&hasEncoding];
}

- (OperationWC *)operation
{
    return [[self projectDocument] operation];
}

- (NibEngineResult *)convertNib:(NSString *)nib toXib:(NSString *)xib
{    
    NibEngine *engine = [NibEngine engineWithConsole:[[self projectDocument] console]]; 
    NibEngineResult *result = [engine convertNibFile:nib toXibFile:xib];
    
    return result;
}

- (NibEngineResult *)convertNibsToXibsFromPath:(NSString *)source toPath:(NSString *)target
{
    [[self operation] setTitle:NSLocalizedString(@"Converting…", nil)];
    [[self operation] setCancellable:YES];
    [[self operation] setIndeterminate:YES];
    [[self operation] show];    
    
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:source error:nil];
    
    [[self operation] setMaxSteps:[files count]];
    
    for (NSString *sourceFile in files)
    {
        if ([[self operation] shouldCancel])
            break;
        
        if ([[sourceFile pathExtension] isEqualToString:@"nib"])
        {
            NibEngineResult *r = [self convertNib:[source stringByAppendingPathComponent:sourceFile] 
                                            toXib:[target stringByAppendingPathComponent:[[sourceFile stringByDeletingPathExtension] stringByAppendingString:@".xib"]]];
            if (!r.success)
            {
                [[self operation] hide];
                return r;
            }
            
            [[self operation] increment];
        }
    }

    [[self operation] hide];
    return nil;
}

- (IBAction)convertNibsToXibs:(id)sender
{
//    NSString *sourcePath = nil;
//    NSString *targetPath = nil;
//    
//    NSOpenPanel *panel = [NSOpenPanel openPanel];
//    [panel setCanChooseFiles:NO];
//    [panel setCanChooseDirectories:YES];
//    [panel setAllowsMultipleSelection:NO];
//    [panel setMessage:@"Choose the directory where the nib files to convert are located"];
//    if([panel runModalForTypes:nil] == NSOKButton) {
//        sourcePath = [[panel filenames] firstObject];
//        [panel setMessage:@"Choose the directory where the converted xib files will be written"];
//        [panel setCanCreateDirectories:YES];
//        if([panel runModalForTypes:nil] == NSOKButton) {
//            targetPath = [[panel filenames] firstObject];
//            NibEngineResult *result = [self convertNibsToXibsFromPath:sourcePath toPath:targetPath];
//            if(result && !result.success) {
//                NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Error while converting", nil) 
//                                                 defaultButton:NSLocalizedString(@"OK", nil)
//                                               alternateButton:nil
//                                                   otherButton:nil
//                                     informativeTextWithFormat:result.output];        
//                [alert runModal];
//            }
//        }
//    }
}

- (IBAction)tmxPerformanceTest:(id)sender
{
    for (NSUInteger index = 0; index < 20; index++)
    {
        TMXImporter *importer = [[TMXImporter alloc] init];
        importer.useFastXMLParser = YES;
    
        if (![importer importDocument:[NSURL fileURLWithPath:@"/Users/bovet/Development/ArizonaSoftware/software/iLocalize/support/Glossaries/Skype_Italian_07_06_09-test.tmx"] error:nil])
        {
            NSLog(@"Error!");
            break;
        }
    }
}

@end
