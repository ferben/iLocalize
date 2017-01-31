//
//  NewGlossaryDriver.m
//  iLocalize
//
//  Created by Jean Bovet on 11/30/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import "NewGlossaryOperationDriver.h"
#import "NewGlossaryOperation.h"
#import "ProjectWC.h"
#import "Preferences.h"

@implementation NewGlossaryOperationDriver

enum
{
    STATE_BACKGROUND_OP,
};

- (NewGlossaryOperation *)glossaryOperation
{
    NewGlossaryOperation *operation = [NewGlossaryOperation operation];
    
    operation.languages = [self arguments][@"languages"];

    return operation;
}

- (id)operationForState:(int)state
{
	id op = nil;
	
    switch (state)
    {
		case STATE_BACKGROUND_OP:
        {
			op = [self glossaryOperation];
			break;
		}
	}
    
	return op;
}

- (int)previousState:(int)state
{
	int previousState = STATE_ERROR;
    
	switch (state)
    {
		case STATE_INITIAL:
			previousState = STATE_END;
			break;
			
		case STATE_BACKGROUND_OP:
			previousState = STATE_END;
			break;
	}
    
	return previousState;
}

- (int)nextState:(int)state
{
	int nextState = STATE_ERROR;
    
	switch (state)
    {
		case STATE_INITIAL:
            nextState = STATE_BACKGROUND_OP;
			break;
			
		case STATE_BACKGROUND_OP:
			nextState = STATE_END;
			break;
	}
    
	return nextState;
}

- (void)validate:(dispatch_block_t)continueBlock
{
    // See if a glossary path already exists on the disk and
    // ask the user what to do.
    NewGlossaryOperation *operation = [self glossaryOperation];
    operation.driver = self;
    operation.projectProvider = self.provider;

    BOOL alwaysOverwrite = [[NSUserDefaults standardUserDefaults] boolForKey:kAlwaysOverwriteGlossaryPrefs];
    
    if ([operation needsToOverwrite] && !alwaysOverwrite)
    {
        NSString *title;
        NSString *message;
        
        if (operation.languages.count == 1)
        {
            title = NSLocalizedStringFromTable(@"NewGlossaryOperationDriverGlossaryTitle", @"Alerts", nil);
            message = NSLocalizedStringFromTable(@"NewGlossaryOperationDriverGlossariesDescr", @"Alerts", nil);
        }
        else
        {
            title = NSLocalizedStringFromTable(@"NewGlossaryOperationDriverGlossaryTitle", @"Alerts", nil);
            message = NSLocalizedStringFromTable(@"NewGlossaryOperationDriverGlossariesDescr", @"Alerts", nil);
        }

        // compose alert
        NSAlert *alert = [NSAlert new];
        
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert setMessageText:title];
        [alert setInformativeText:message];
        [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextOverwrite",@"Alerts",nil)];   // 1st button
        [alert addButtonWithTitle:NSLocalizedStringFromTable(@"AlertButtonTextCancel",@"Alerts",nil)];      // 2nd button

        [alert setShowsSuppressionButton:YES];
        
        // show alert
        [alert beginSheetModalForWindow:[[self.provider projectWC] window] completionHandler:^(NSModalResponse alertReturnCode)
        {
            if (alertReturnCode == NSAlertFirstButtonReturn)
            {
                // Overwrite
                BOOL suppressWarning = [alert suppressionButton].state == NSOnState;
                
                if (suppressWarning)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAlwaysOverwriteGlossaryPrefs];
                }
                
                continueBlock();
            }
            else
            {
                // Cancel
            }
        }];
    }
    else
    {
        continueBlock();
    }
}

@end
