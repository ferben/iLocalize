//
//  ImportDiffItem.h
//  iLocalize
//
//  Created by Jean Bovet on 2/15/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#define OPERATION_ADD        1
#define OPERATION_DELETE     2
#define OPERATION_UPDATE     3
#define OPERATION_IDENTICAL  4

@interface ImportDiffItem : NSObject
{
    BOOL         enabled;
    NSUInteger   operation;
    
    // The relative file
    NSString    *file;
    
    // The source path
    NSString    *source;
}

@property BOOL enabled;
@property NSUInteger operation;
@property (strong) NSString *file;
@property (strong) NSString *source;

- (NSString *)operationName;
- (NSImage *)image;
- (NSColor *)color;

@end
