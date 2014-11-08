//
//  ImportDiffItem.m
//  iLocalize
//
//  Created by Jean Bovet on 2/15/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ImportDiffItem.h"
#import "SmartPathParser.h"

@implementation ImportDiffItem

@synthesize enabled;
@synthesize operation;
@synthesize file;
@synthesize source;

- (NSString*)operationNameForOpcode:(unsigned)op
{
    switch(op) {
        case OPERATION_ADD:
			return NSLocalizedString(@"add", @"Diff Operation Add");
        case OPERATION_DELETE:
			return NSLocalizedString(@"delete", @"Diff Operation Delete");
        case OPERATION_UPDATE:
			return NSLocalizedString(@"update", @"Diff Operation Update");
        case OPERATION_IDENTICAL:
            return @"";
    }
    return @"";
}

- (NSImage*)operationImageForOpcode:(unsigned)op
{
    switch(op) {
        case OPERATION_ADD:
			return [NSImage imageNamed:@"_file_added"];
        case OPERATION_DELETE:
			return [NSImage imageNamed:@"_file_deleted"];
        case OPERATION_UPDATE:
			return [NSImage imageNamed:@"_file_updated"];
        case OPERATION_IDENTICAL:
            return nil;
    }
	return nil;
}

- (NSColor*)operationColorForOpcode:(unsigned)op
{
    switch(op) {
        case OPERATION_ADD:
            return [NSColor greenColor];
        case OPERATION_DELETE:
            return [NSColor redColor];
        case OPERATION_UPDATE:
            return [NSColor blackColor];
        case OPERATION_IDENTICAL:
            return [NSColor blackColor];
    }
    return [NSColor blackColor];
}

- (NSString*)operationName
{
	return [self operationNameForOpcode:self.operation];
}

- (NSImage*)image
{
	return [self operationImageForOpcode:self.operation];
}

- (NSColor*)color
{
	return [self operationColorForOpcode:self.operation];
}

- (NSString*)description
{
	NSMutableString *s = [NSMutableString string];
	[s appendFormat:@"Op=%ld", self.operation];
	[s appendString:@","];
	[s appendFormat:@"File=%@", self.file];	
	return s;
}

//- (NSString*)source
//{
//	return [[SmartPathParser smartPath:self.file] stringByAppendingPathComponent:[self.file lastPathComponent]];
//}

@end
