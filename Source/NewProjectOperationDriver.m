//
//  NewProjectOperationDriver.m
//  iLocalize
//
//  Created by Jean Bovet on 2/13/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "NewProjectOperationDriver.h"
#import "NewProjectGeneralOVC.h"
#import "NewProjectLanguagesOVC.h"
#import "ScanBundleOp.h"
#import "ScanBundleOVC.h"
#import "AnalyzeBundleOp.h"
#import "AnalyzeBundleOVC.h"
#import "NewProjectOperation.h"
#import "NewProjectSettings.h"
#import "BundleSource.h"

@implementation NewProjectOperationDriver

@synthesize settings;
@synthesize generalOVC;
@synthesize languagesOVC;
@synthesize filterBundleOp;
@synthesize filterBundleOVC;
@synthesize analyzeOp;

enum STATES {
	STATE_GENERAL_OVC,
	STATE_FILTER_BUNDLE_OP,
	STATE_FILTER_BUNDLE_OVC,
	STATE_ANALYZE_OP,
	STATE_ANALYZE_PREVIEW_OVC,
	STATE_LANGUAGES_OVC,
	STATE_CREATE_PROJET
};

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.settings = [[NewProjectSettings alloc] init];
	}
	return self;
}


- (NSString*)windowTitle
{
	return NSLocalizedString(@"Create New Project", nil);
}

- (BOOL)isAssistant
{
	return YES;
}

- (id)operationForState:(int)state
{
	id op = nil;
	switch (state) {
		case STATE_GENERAL_OVC:
			self.generalOVC = [NewProjectGeneralOVC createInstance];
			self.generalOVC.settings = settings;
			op = self.generalOVC;
			break;

		case STATE_FILTER_BUNDLE_OP:
			self.filterBundleOp = [ScanBundleOp operation];
			self.filterBundleOp.path = settings.source.sourcePath;
			op = self.filterBundleOp;
			break;
			
		case STATE_FILTER_BUNDLE_OVC:
			self.filterBundleOVC = [ScanBundleOVC createInstance];
            self.filterBundleOVC.node = self.filterBundleOp.node;
			op = self.filterBundleOVC;
			break;
			
		case STATE_ANALYZE_OP:
            // Note: use filterBundleOp and not filterBundleOVC node because in some cases the filter bundle ovc is not displayed
            // to the user (e.g. application).
            self.settings.source.sourceNode = self.filterBundleOp.node; 
			self.analyzeOp = [AnalyzeBundleOp operation];
            self.analyzeOp.node = self.settings.source.sourceNode;
			op = self.analyzeOp;
			break;
			
		case STATE_ANALYZE_PREVIEW_OVC: {
			AnalyzeBundleOVC *operation = [AnalyzeBundleOVC createInstance];
            operation.rootPath = self.settings.source.sourcePath;
			operation.problems = self.analyzeOp.problems;
			op = operation;
			break;
		}
			
		case STATE_LANGUAGES_OVC:
			self.languagesOVC = [NewProjectLanguagesOVC createInstance];
			self.languagesOVC.settings = self.settings;
			op = self.languagesOVC;
			break;
			
		case STATE_CREATE_PROJET: {
			NewProjectOperation *operation = [NewProjectOperation operation];
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
		case STATE_INITIAL:
		case STATE_GENERAL_OVC:
			previousState = STATE_END;
			break;
		
		case STATE_ANALYZE_OP:
		case STATE_ANALYZE_PREVIEW_OVC:
		case STATE_LANGUAGES_OVC:
		case STATE_CREATE_PROJET:
            if([self.settings.source.sourcePath isPathApplication]) {
                previousState = STATE_GENERAL_OVC;                
            } else {
                previousState = STATE_FILTER_BUNDLE_OVC;
            }
			break;
			
		case STATE_FILTER_BUNDLE_OVC:
			previousState = STATE_GENERAL_OVC;
			break;
	}
	return previousState;
}

- (int)nextState:(int)state
{
	int nextState = STATE_ERROR;
	switch (state) {
		case STATE_INITIAL:
			nextState = STATE_GENERAL_OVC;
			break;
			
		case STATE_GENERAL_OVC:
			nextState = STATE_FILTER_BUNDLE_OP;
			break;

		case STATE_FILTER_BUNDLE_OP:
            // If the source is an application, then do not allow the user to choose
            // which part to import because we need to import everything in order
            // to have a chance to launch the application within iLocalize (same as before).
            // However, if it is not an app, like a regular folder, then allow the user to
            // choose what to import.
            if([self.settings.source.sourcePath isPathApplication]) {
                nextState = STATE_ANALYZE_OP;                
            } else {
                nextState = STATE_FILTER_BUNDLE_OVC;
            }
			break;

		case STATE_FILTER_BUNDLE_OVC:
			nextState = STATE_ANALYZE_OP;
			break;
			
		case STATE_ANALYZE_OP:
			if([self.analyzeOp hasProblems]) {
				nextState = STATE_ANALYZE_PREVIEW_OVC;
			} else {
				nextState = STATE_LANGUAGES_OVC;
			}
			break;
			
		case STATE_ANALYZE_PREVIEW_OVC:
			nextState = STATE_LANGUAGES_OVC;
			break;
			
		case STATE_LANGUAGES_OVC:
			nextState = STATE_CREATE_PROJET;
			break;
			
		case STATE_CREATE_PROJET:
			nextState = STATE_END;
			break;
	}
	return nextState;
}

@end
