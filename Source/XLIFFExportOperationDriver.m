//
//  XLIFFExportOperationDriver.m
//  iLocalize
//
//  Created by Jean Bovet on 3/23/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XLIFFExportOperationDriver.h"
#import "XLIFFExportSettings.h"
#import "XLIFFExportOVC.h"
#import "XLIFFExportOperation.h"
#import "LanguageController.h"
#import "ProjectPrefs.h"
#import "ProjectWC.h"

@implementation XLIFFExportOperationDriver

- (id) init
{
	self = [super init];
	if (self != nil) {
		settings = [[XLIFFExportSettings alloc] init];
	}
	return self;
}


#define STATE_EXPORT_OVC 1
#define STATE_EXPORT_OP 2

- (id)operationForState:(int)state
{
	id op = nil;
	switch (state) {
		case STATE_EXPORT_OVC: {
			XLIFFExportOVC *operation = [XLIFFExportOVC createInstance];
			operation.settings = settings;
			op = operation;
			break;			
		}
			
		case STATE_EXPORT_OP: {
			XLIFFExportOperation *operation = [XLIFFExportOperation operation];
			operation.settings = settings;
			op = operation;
			break;						
		}
	}
	return op;
}

- (void)loadSettings
{
	[settings setData:[[self.provider projectPrefs] exportXLIFFSettings]];
	settings.sourceLanguage = [[self.provider selectedLanguageController] baseLanguage];
	settings.targetLanguage = [[self.provider selectedLanguageController] language];
	
	NSArray *files = arguments[@"fcs"];
	if(files) {
		settings.files = files;
	} else {
		settings.files = [[[self.provider projectWC] filesController] arrangedObjects];		
	}
}

- (void)saveSettings
{
	[[self.provider projectPrefs] setExportXLIFFSettings:[settings data]];
}

- (int)previousState:(int)state
{
	int previousState = STATE_ERROR;
	switch (state) {
		case STATE_INITIAL:
			previousState = STATE_END;
			break;
			
		case STATE_EXPORT_OVC:
			previousState = STATE_END;			
			break;	
						
		case STATE_EXPORT_OP:
			previousState = STATE_EXPORT_OVC;			
			break;				
	}	
	return previousState;
}

- (int)nextState:(int)state
{
	int nextState = STATE_ERROR;
	switch (state) {
		case STATE_INITIAL:
			[self loadSettings];
			nextState = STATE_EXPORT_OVC;
			break;
			
		case STATE_EXPORT_OVC:
			[self saveSettings];
			nextState = STATE_EXPORT_OP;
			break;	
						
		case STATE_EXPORT_OP:
			nextState = STATE_END;
			break;
	}
	return nextState;
}

@end
