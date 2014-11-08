//
//  ImportFilesOperationDriver.m
//  iLocalize
//
//  Created by Jean Bovet on 2/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ImportFilesOperationDriver.h"
#import "ImportFilesSelectionOVC.h"
#import "ImportFilesOVC.h"
#import "ImportFilesBaseLanguageOp.h"
#import "ImportFilesLocalizedOp.h"

#import "ImportFilesSettings.h"
#import "ImportFilesMultiMatchOVC.h"

#import "ImportLocalizedDetectConflictsOp.h"
#import "ImportLocalizedResolveConflictsOVC.h"

#import "AnalyzeBundleOp.h"
#import "AnalyzeBundleOVC.h"

#import "ProjectController.h"

#import "FileMatchItem.h"
#import "FileConflictItem.h"
#import "FileController.h"

@implementation ImportFilesOperationDriver

@synthesize settings;
@synthesize analyzeOp;
@synthesize detectConflictsOp;

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.settings = [[ImportFilesSettings alloc] init];
	}
	return self;
}


#define STATE_CHOOSE_FILES_OVC 1
#define STATE_ANALYZE_OP 2
#define STATE_ANALYZE_PREVIEW_OVC 3
#define STATE_SETTINGS_OVC 4
#define STATE_MULTI_MATCH_OVC 5
#define STATE_UPDATE_BASE 6
#define STATE_UPDATE_LOCALIZED 7

#define STATE_LOCALIZED_DETECT_CONFLICTS_OP 8
#define STATE_LOCALIZED_RESOLVE_CONFLICTS_OVC 9

- (id)operationForState:(int)state
{
	id op = nil;
	switch (state) {
		case STATE_CHOOSE_FILES_OVC: {
			ImportFilesSelectionOVC *ovc = [ImportFilesSelectionOVC createInstance];
			ovc.settings = self.settings;
			op = ovc;
			break;			
		}
			
		case STATE_ANALYZE_OP: {
			self.analyzeOp = [AnalyzeBundleOp operation];
			analyzeOp.files = self.settings.files;
			op = analyzeOp;
			break;			
		}
			
		case STATE_ANALYZE_PREVIEW_OVC: {
			AnalyzeBundleOVC *operation = [AnalyzeBundleOVC createInstance];
			operation.problems = self.analyzeOp.problems;
			op = operation;
			break;			
		}		
			
		case STATE_SETTINGS_OVC: {
			ImportFilesOVC *ovc = [ImportFilesOVC createInstance];
			ovc.settings = self.settings;
			op = ovc;
			break;			
		}	
			
		case STATE_MULTI_MATCH_OVC: {
			ImportFilesMultiMatchOVC *ovc = [ImportFilesMultiMatchOVC createInstance];
			ovc.matchItems = self.settings.matchItems;
			op = ovc;
			break;			
		}			
			
		case STATE_UPDATE_BASE: {
			ImportFilesBaseLanguageOp *operation = [ImportFilesBaseLanguageOp operation];
			operation.settings = self.settings;
			op = operation;
			break;			
		}			
			
		case STATE_UPDATE_LOCALIZED: {
			ImportFilesLocalizedOp *operation = [ImportFilesLocalizedOp operation];
			operation.settings = self.settings;
			op = operation;
			break;			
		}	
			
		case STATE_LOCALIZED_DETECT_CONFLICTS_OP: {
			self.detectConflictsOp = [ImportLocalizedDetectConflictsOp operation];
			NSMutableArray *fileItems = [NSMutableArray array];
			for(FileMatchItem *item in self.settings.matchItems) {
				FileConflictItem *ci = [[FileConflictItem alloc] init];
				ci.source = [item file];
				ci.project = [[item matchingFileController] absoluteFilePath];
				[fileItems addObject:ci];
			}
			detectConflictsOp.fileConflictItems = fileItems;
			op = detectConflictsOp;
			break;			
		}
			
		case STATE_LOCALIZED_RESOLVE_CONFLICTS_OVC: {
			ImportLocalizedResolveConflictsOVC *ovc = [ImportLocalizedResolveConflictsOVC createInstance];
			ovc.fileConflictItems = [self.detectConflictsOp conflictingFileItems];
			op = ovc;
			break;			
		}			
	}
	return op;
}

- (int)previousState:(int)state
{
	int previousState = STATE_ERROR;
	switch (state) {
		case STATE_CHOOSE_FILES_OVC:
			previousState = STATE_END;
			break;
		case STATE_MULTI_MATCH_OVC:
			previousState = STATE_SETTINGS_OVC;
			break;
		default:
			previousState = STATE_CHOOSE_FILES_OVC;
			break;
	}
	return previousState;
}

- (int)nextState:(int)state
{
	int nextState = STATE_ERROR;
	switch (state) {
		case STATE_INITIAL:
			nextState = STATE_CHOOSE_FILES_OVC;
			break;
			
		case STATE_CHOOSE_FILES_OVC:
			nextState = STATE_ANALYZE_OP;
			break;
			
		case STATE_ANALYZE_OP:
			if([self.analyzeOp hasProblems]) {
				nextState = STATE_ANALYZE_PREVIEW_OVC;				
			} else {
				nextState = STATE_SETTINGS_OVC;
			}
			break;
			
		case STATE_ANALYZE_PREVIEW_OVC:
			nextState = STATE_SETTINGS_OVC;
			break;
			
		case STATE_SETTINGS_OVC: {
			// First let's see if there are any multiple file matches.
			LanguageController *lc;
			if(self.settings.updateBaseLanguage) {
				lc = [self.provider.projectController baseLanguageController];
			} else {
				lc = [self.provider.projectController languageControllerForLanguage:self.settings.localizedLanguage];
			}
			BOOL multipleMatch = NO;
			self.settings.matchItems = [ImportFilesMultiMatchOVC matchesFiles:self.settings.files languageController:lc multipleMatch:&multipleMatch];
			if(multipleMatch) {
				// Display the multi-match view before continuing.
				nextState = STATE_MULTI_MATCH_OVC;
			} else {
				// No, so let's update the files right away
				if(self.settings.updateBaseLanguage) {
					nextState = STATE_UPDATE_BASE;				
				} else {
					nextState = STATE_LOCALIZED_DETECT_CONFLICTS_OP;
				}				
			}
			break;			
		}
			
		case STATE_MULTI_MATCH_OVC:
			if(self.settings.updateBaseLanguage) {
				nextState = STATE_UPDATE_BASE;				
			} else {
				nextState = STATE_LOCALIZED_DETECT_CONFLICTS_OP;
			}				
			break;
						
		case STATE_LOCALIZED_DETECT_CONFLICTS_OP:
			if([[self.detectConflictsOp conflictingFileItems] count] > 0) {
				nextState = STATE_LOCALIZED_RESOLVE_CONFLICTS_OVC;
			} else {
				nextState = STATE_UPDATE_LOCALIZED;
			}
			break;
			
		case STATE_LOCALIZED_RESOLVE_CONFLICTS_OVC:
			nextState = STATE_UPDATE_LOCALIZED;
			break;
			
		case STATE_UPDATE_BASE:
			nextState = STATE_END;
			break;
			
		case STATE_UPDATE_LOCALIZED:
			nextState = STATE_END;
			break;			
	}
	return nextState;
}

@end
