//
//  ImportLocalFilesOperationDriver.m
//  iLocalize
//
//  Created by Jean Bovet on 2/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ImportLocalFilesOperationDriver.h"
#import "ImportFilesSettings.h"
#import "ImportFilesSelectionOVC.h"
#import "ImportLocalFilesOperation.h"

#import "AnalyzeBundleOp.h"
#import "AnalyzeBundleOVC.h"

#import "ImportFilesMultiMatchOVC.h"
#import "FileMatchItem.h"
#import "LanguageController.h"
#import "FileController.h"

@implementation ImportLocalFilesOperationDriver

@synthesize settings;
@synthesize analyzeOp;

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.settings = [[ImportFilesSettings alloc] init];
	}
	return self;
}


- (BOOL)matchesFiles:(NSArray*)files languageController:(LanguageController*)languageController
{
	NSMutableArray *fileMatchItems = [NSMutableArray array];
	BOOL multipleMatches = NO;
	
	for(NSString *file in files) {
		NSMutableArray *localFiles = [[NSMutableArray alloc] init];
		[[languageController fileControllersMatchingName:[file lastPathComponent]] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			FileController *fc = obj;
			if(fc.isLocal) {
				[localFiles addObject:fc];
			}
		}];
		if([localFiles count] == 0)
			continue;
		if([localFiles count] > 1)
			multipleMatches = YES;
		[fileMatchItems addObject:[FileMatchItem itemWithFile:file matchingFileControllers:localFiles]];
	}
	
	self.settings.matchItems = fileMatchItems;
	
	return multipleMatches;
}

#pragma mark State Machine

#define STATE_CHOOSE_FILES_OVC 1
#define STATE_ANALYZE_OP 2
#define STATE_ANALYZE_PREVIEW_OVC 3
#define STATE_DETECT_MULTI_MATCH 4
#define STATE_MULTI_MATCH_OVC 5
#define STATE_UPDATE_LOCAL_FILES 6

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
            self.analyzeOp.files = self.settings.files;
			op = analyzeOp;
			break;			
		}
			
		case STATE_ANALYZE_PREVIEW_OVC: {
			AnalyzeBundleOVC *operation = [AnalyzeBundleOVC createInstance];
			operation.problems = self.analyzeOp.problems;
			op = operation;
			break;			
		}		
						
		case STATE_MULTI_MATCH_OVC: {
			ImportFilesMultiMatchOVC *ovc = [ImportFilesMultiMatchOVC createInstance];
			ovc.matchItems = self.settings.matchItems;
			op = ovc;
			break;			
		}			
			
		case STATE_UPDATE_LOCAL_FILES: {
			ImportLocalFilesOperation *operation = [ImportLocalFilesOperation operation];
			operation.settings = self.settings;
			op = operation;
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
				nextState = STATE_DETECT_MULTI_MATCH;
			}
			break;
			
		case STATE_ANALYZE_PREVIEW_OVC:
			nextState = STATE_DETECT_MULTI_MATCH;
			break;
			
		case STATE_DETECT_MULTI_MATCH: {
			// First let's see if there are any multiple file matches.
			if([self matchesFiles:self.settings.files languageController:[self.provider selectedLanguageController]]) {
				// Display the multi-match view before continuing.
				nextState = STATE_MULTI_MATCH_OVC;
			} else {
				// No, so let's update the files right away
				nextState = STATE_UPDATE_LOCAL_FILES;				
			}
			break;			
		}
			
		case STATE_MULTI_MATCH_OVC:
			nextState = STATE_UPDATE_LOCAL_FILES;				
			break;
									
		case STATE_UPDATE_LOCAL_FILES:
			nextState = STATE_END;
			break;			
	}
	return nextState;
}

@end
