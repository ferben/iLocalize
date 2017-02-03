//
//  BackgroundUpdaterDriver.m
//  iLocalize
//
//  Created by Jean Bovet on 10/13/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import "BackgroundUpdaterDriver.h"
#import "BackgroundUpdaterOperation.h"

@implementation BackgroundUpdaterDriver

enum
{
    STATE_BACKGROUND_OP,
};

- (id)operationForState:(int)state
{
    id op = nil;
    
    switch (state)
    {
        case STATE_BACKGROUND_OP:
        {
            BackgroundUpdaterOperation *operation = [BackgroundUpdaterOperation operation];
            operation.fcs = [self arguments][@"fcs"];
            op = operation;
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

@end
