//
//  main_tool.m
//  iLocalize
//
//  Created by Jean Bovet on 1/20/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CmdLineProcessing.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        [CmdLineProcessing process];        
    }
}

