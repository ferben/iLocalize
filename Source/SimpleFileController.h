//
//  SimpleFileController.h
//  iLocalize
//
//  Created by Jean Bovet on 4/19/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "FileControllerProtocol.h"
#import "StringControllerProtocol.h"

@interface SimpleFileController : NSObject<FileControllerProtocol>
{
    NSMutableArray  *strings;
    NSString        *path;
}

@property (strong) NSString *path;

- (void)addString:(id<StringControllerProtocol>)string;

@end
