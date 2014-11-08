//
//  ProjectMenuTranslate.m
//  iLocalize
//
//  Created by Jean on 12/29/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectMenuTranslate.h"
#import "ProjectWC.h"
#import "PreferencesGeneral.h"
#import "ProjectFilesController.h"
#import "ProjectDetailsController.h"
#import "FMEditorStrings.h"
#import "GlossaryTranslateWC.h"
#import "GlossaryScope.h"
#import "ProjectDocument.h"
#import "GlossaryTranslator.h"
#import "LanguageController.h"
#import "LanguageModel.h"
#import "XLIFFImportOperationDriver.h"

@implementation ProjectMenuTranslate

- (id) init
{
	self = [super init];
	if (self != nil) {
		wc = [[GlossaryTranslateWC alloc] init];
		scope = [[GlossaryScope alloc] init];
		translator = [[GlossaryTranslator alloc] init];
	}
	return self;
}


- (void)awake
{
	scope.projectProvider = self.projectDocument;	
}

- (IBAction)translateUsingGlossaries:(id)sender
{
    // Restore the selected state
    LanguageController *lc = [scope.projectProvider selectedLanguageController];
    scope.selectedStates = lc.languageModel.translateUsingGlossariesSelectedStates;

	[wc setDidCloseSelector:@selector(translationWindowDidClose) target:self];
	[wc setParentWindow:[[self projectWC] window]];
	[wc setProjectProvider:[self projectDocument]];
	[wc setScope:scope];
	[wc showAsSheet];
}

- (IBAction)translateUsingSelectedGlossaryEntry:(id)sender {
    [[self.projectWC projectDetailsController] executeCommand:_cmd];
}

- (void)translationWindowDidClose
{
	id<ProjectProvider> provider = [[self projectWC] projectDocument];
    
    // Store the selected state for the current language
    LanguageController *lc = [scope.projectProvider selectedLanguageController];
    lc.languageModel.translateUsingGlossariesSelectedStates = scope.selectedStates;
    
	[translator setIgnoreCase:[[NSUserDefaults standardUserDefaults] boolForKey:@"translateIgnoreCase"]];
    [translator setLanguageController:[provider selectedLanguageController]];

	NSArray *glossaries = [scope selectedGlossaries];
	
	switch ([wc hideCode]) {
		case 0:
			// cancel
			break;
		case 1: // all files
			[translator translateFileControllers:[[provider selectedLanguageController] fileControllers]
								  withGlossaries:glossaries];
			break;
		case 2: // selected files
			[translator translateFileControllers:[provider selectedFileControllers]
								  withGlossaries:glossaries];
			break;
	}
}

- (IBAction)translateUsingExternalStringsFile:(id)sender
{
    NSArray *fcs = [[self projectDocument] selectedFileControllers];
	NSDictionary *args = @{@"fcs": fcs};
	[[XLIFFImportOperationDriver driverWithProjectProvider:[self projectDocument]] executeWithArguments:args];
//	[[self projectFiles] translateUsingStringsFile];
}

- (IBAction)clearUpdatedFileSymbols:(id)sender
{
	[[self.projectWC selectedFileControllers] makeObjectsPerformSelector:@selector(clearUpdatedStatus)];
}

- (void)performActionOnEditor:(BOOL(^)(FMEditor *editor))block {
    FMEditor *currentEditor = [self.projectWC currentFileEditor];
    if (block(currentEditor)) {
        if([[PreferencesGeneral shared] autoUpdateSmartFilters]) {
			[self.projectWC refreshListOfFiles];
		}
    }
}

- (IBAction)approveString:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(approveString:)]) {
            [editor approveString:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (IBAction)approveFile:(id)sender
{
	[[self.projectWC selectedFileControllers] makeObjectsPerformSelector:@selector(approve)];
	if([[PreferencesGeneral shared] autoUpdateSmartFilters])
		[self.projectWC refreshListOfFiles];
}

- (IBAction)approveIdenticalStringsInSelectedFiles:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(approveIdenticalStringsInSelectedFiles:)]) {
            [editor approveIdenticalStringsInSelectedFiles:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (IBAction)approveIdenticalStringsInAllFiles:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(approveIdenticalStringsInAllFiles:)]) {
            [editor approveIdenticalStringsInAllFiles:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (IBAction)approveAutoTranslatedStringsInSelectedFiles:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(approveAutoTranslatedStringsInSelectedFiles:)]) {
            [editor approveAutoTranslatedStringsInSelectedFiles:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (IBAction)approveAutoTranslatedStringsInAllFiles:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(approveAutoTranslatedStringsInAllFiles:)]) {
            [editor approveAutoTranslatedStringsInAllFiles:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (IBAction)approveAutoInvariantStringsInSelectedFiles:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(approveAutoInvariantStringsInSelectedFiles:)]) {
            [editor approveAutoInvariantStringsInSelectedFiles:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (IBAction)approveAutoInvariantStringsInAllFiles:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(approveAutoInvariantStringsInAllFiles:)]) {
            [editor approveAutoInvariantStringsInAllFiles:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (IBAction)approveAutoHandledStringsInSelectedFiles:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(approveAutoHandledStringsInSelectedFiles:)]) {
            [editor approveAutoHandledStringsInSelectedFiles:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (IBAction)approveAutoHandledStringsInAllFiles:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(approveAutoHandledStringsInAllFiles:)]) {
            [editor approveAutoHandledStringsInAllFiles:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (IBAction)propagateTranslationToIdenticalStringsInSelectedFiles:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(propagateTranslationToIdenticalStringsInSelectedFiles:)]) {
            [editor propagateTranslationToIdenticalStringsInSelectedFiles:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (IBAction)propagateTranslationToIdenticalStringsInAllFiles:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(propagateTranslationToIdenticalStringsInAllFiles:)]) {
            [editor propagateTranslationToIdenticalStringsInAllFiles:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (IBAction)markStringsAsTranslated:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(markStringsAsTranslated:)]) {
            [editor markStringsAsTranslated:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (IBAction)unmarkStringsAsTranslated:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(unmarkStringsAsTranslated:)]) {
            [editor unmarkStringsAsTranslated:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (IBAction)copyBaseStringsToTranslation:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(copyBaseStringsToTranslation:)]) {
            [editor copyBaseStringsToTranslation:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (IBAction)swapBaseStringsToTranslation:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(swapBaseStringsToTranslation:)]) {
            [editor swapBaseStringsToTranslation:self];
            return YES;
        } else {
            return NO;
        }
    }];
}


- (IBAction)clearBaseComments:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(clearBaseComments:)]) {
            [editor clearBaseComments:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (IBAction)clearTranslationComments:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(clearTranslationComments:)]) {
            [editor clearTranslationComments:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (IBAction)clearComments:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(clearComments:)]) {
            [editor clearComments:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (IBAction)clearTranslations:(id)sender
{
    [self performActionOnEditor:^BOOL(id editor) {
        if ([editor respondsToSelector:@selector(clearTranslations:)]) {
            [editor clearTranslations:self];
            return YES;
        } else {
            return NO;
        }
    }];
}

- (BOOL)validateMenuItem:(NSMenuItem*)anItem
{
    SEL action = [anItem action];
	BOOL isFilesSelected = [[self.projectWC selectedFileControllers] count] > 0;
	BOOL isStringsSelected = isFilesSelected && [[self.projectWC selectedStringControllers] count] > 0;
//	BOOL isMultipleFilesSelected = [[self.projectWC selectedFileControllers] count] > 1;
	BOOL isBaseLanguage = [[[self projectDocument] selectedLanguageController] isBaseLanguage];
	if(isBaseLanguage) {
		return action == @selector(clearUpdatedFileSymbols:);
	}
	
//	if(action == @selector(translateUsingExternalStringsFile:)) {
//		return !isMultipleFilesSelected && [[self.projectWC currentFileEditor] canTranslateUsingStrings];
//	}
		
    if(action == @selector(translateUsingSelectedGlossaryEntry:)) {
        return [[self.projectWC projectDetailsController] canExecuteCommand:action];
    }
    
	if(action == @selector(approveFile:)) {
		return isFilesSelected;
	}

	if(action == @selector(approveString:)) {
		return isStringsSelected;
	}

	if(action == @selector(approveIdenticalStringsInSelectedFiles:)) {
		return isStringsSelected;
	}
	if(action == @selector(approveIdenticalStringsInAllFiles:)) {
		return isStringsSelected;
	}

	if(action == @selector(approveAutoTranslatedStringsInSelectedFiles:)) {
		return isFilesSelected;
	}
	if(action == @selector(approveAutoTranslatedStringsInAllFiles:)) {
		return YES;
	}

	if(action == @selector(approveAutoInvariantStringsInSelectedFiles:)) {
		return isFilesSelected;
	}
	if(action == @selector(approveAutoInvariantStringsInAllFiles:)) {
		return YES;
	}

	if(action == @selector(approveAutoHandledStringsInSelectedFiles:)) {
		return isFilesSelected;
	}
	if(action == @selector(approveAutoHandledStringsInAllFiles:)) {
		return YES;
	}

	if(action == @selector(propagateTranslationToIdenticalStringsInSelectedFiles:)) {
		return isStringsSelected;
	}
	if(action == @selector(propagateTranslationToIdenticalStringsInAllFiles:)) {
		return isStringsSelected;
	}

	if(action == @selector(markStringsAsTranslated:)) {
		return isStringsSelected;
	}
	if(action == @selector(unmarkStringsAsTranslated:)) {
		return isStringsSelected;
	}

	if(action == @selector(copyBaseStringsToTranslation:)) {
		return isStringsSelected;
	}
	if(action == @selector(swapBaseStringsToTranslation:)) {
		return isStringsSelected;
	}

	if(action == @selector(clearBaseComments:)) {
		return isStringsSelected;
	}
	if(action == @selector(clearTranslationComments:)) {
		return isStringsSelected;
	}
	if(action == @selector(clearComments:)) {
		return isStringsSelected;
	}
	if(action == @selector(clearTranslations:)) {
		return isStringsSelected;
	}
		
	return YES;		
}

@end
