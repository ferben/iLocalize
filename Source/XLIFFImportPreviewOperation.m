//
//  XLIFFImportPreviewOperation.m
//  iLocalize
//
//  Created by Jean Bovet on 3/24/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XLIFFImportPreviewOperation.h"
#import "XLIFFImportSettings.h"
#import "XLIFFImportFileElement.h"
#import "XLIFFImportStringElement.h"

#import "SEIManager.h"
#import "XMLImporter.h"
#import "XMLImporterElement.h"
#import "XLIFFImportFileElement.h"

#import "LanguageController.h"
#import "FileController.h"
#import "StringController.h"
#import "AZOrderedDictionary.h"

@implementation XLIFFImportPreviewOperation

@synthesize settings;


- (XMLImporter*)parse:(NSError**)error
{
	NSURL *url = [NSURL fileURLWithPath:self.settings.file];
	XMLImporter *importer = [[SEIManager sharedInstance] importerForFile:url error:error];
	[importer importDocument:url error:error];
	return importer;
}

- (void)matchFileElements:(NSMutableArray*)fileElements forFileController:(FileController*)fc withElements:(NSArray*)elements
{
	NSMutableArray *stringElements = [NSMutableArray array];
	
	XLIFFImportFileElement *fileElement = [[XLIFFImportFileElement alloc] init];		
	fileElement.stringElements = stringElements;
	
	BOOL matchAtLeastOneFile = NO;

	for(XMLImporterElement *element in elements) {
		BOOL hasMatch = NO;
		for(StringController *sc in [fc stringControllers]) {
            BOOL matching = NO;
            if (settings.useResnameInsteadOfSource) {
                matching = [element.key isEqualToString:[sc key]];
            } else {
                matching = [element.source isEqualToString:[sc base]];
            }
			if(matching && ![element.translation isEqualToString:[sc translation]]) {
				XLIFFImportStringElement *stringElement = [[XLIFFImportStringElement alloc] init];
				stringElement.sc = sc;
				stringElement.translation = element.translation;
				[stringElements addObject:stringElement];
				hasMatch = YES;
				break;
			}					
		}				
		if(hasMatch) {				
			fileElement.fc = fc;
			matchAtLeastOneFile = YES;
		}			
	}	

	if(matchAtLeastOneFile) {
		[fileElements addObject:fileElement];		
	}
}

- (void)execute
{
	[self setOperationName:NSLocalizedString(@"Preparing…", nil)];

	NSError *error = nil;
	XMLImporter *importer = [self parse:&error];
	if(!importer || error) {
		[self notifyError:error];
		return;
	}

	LanguageController *lc = [[self projectProvider] selectedLanguageController];
	if ([importer.sourceLanguage length] > 0 && ![importer.sourceLanguage isEquivalentToLanguage:[lc baseLanguage]]) {
		NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%@ contains the base language “%@” which does not match the base language “%@” of the project.", @"XLIFF Import"), 
							 [self.settings.file lastPathComponent], importer.sourceLanguage, [lc baseLanguage]];
		[self notifyError:[Logger errorWithMessage:message]];
		return;
	}
	if ([importer.targetLanguage length] > 0 && ![importer.targetLanguage isEquivalentToLanguage:[lc language]]) {
		NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%@ contains the target language “%@” which does not match the current language “%@” of the project.", @"XLIFF Import"), 
							 [self.settings.file lastPathComponent], importer.targetLanguage, [lc language]];
		[self notifyError:[Logger errorWithMessage:message]];
		return;
	}
	
	NSMutableArray *fileElements = [NSMutableArray array];
	
	// Match the strings scoped by files
	for(NSString *path in [importer.elementsPerFile allKeys]) {
		FileController *fc = [lc fileControllerWithRelativePath:path translate:YES];		
		if(!fc) {				
			ERROR(@"No file found for path %@", path);
		}
		if(![settings.targetFiles containsObject:fc]) {
			// skip files that are not targeted
			continue;
		}

		[self matchFileElements:fileElements forFileController:fc withElements:[importer.elementsPerFile objectForKey:path]];
	}	
	
	// Match the strings that are not scoped by files
	for(FileController *fc in settings.targetFiles) {
		[self matchFileElements:fileElements forFileController:fc withElements:importer.elementsWithoutFile];		
	}
	
	if(fileElements.count == 0) {
		[self notifyError:[Logger errorWithMessage:NSLocalizedString(@"There are no strings to translate.", @"XLIFF Import")]];
	}
	settings.fileElements = fileElements;		
}

@end
