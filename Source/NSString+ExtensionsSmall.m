//
//  NSString+ExtensionsSmall.m
//  iLocalize3
//
//  Created by Jean on 6/25/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "NSString+ExtensionsSmall.h"

@implementation NSString (iLocalizeExtensionsSmall)

- (BOOL)isPathExisting
{
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:self];
	if(!exists) {
		// If the file is actually a symbolic link and the destination of the link does not exist,
		// the fileExistsAtPath will return false. But we are interested in the path itself, not
		// the destination of the symbolic link, so try to get the attributes of the symblink and if it
		// is successful, then the path indeed exists.
		exists = [[NSFileManager defaultManager] attributesOfItemAtPath:self error:nil] != nil;
	}
	return exists;
}

- (NSString*)parentPath
{
	NSArray *components = [self pathComponents];
	return [NSString pathWithComponents:[components subarrayWithRange:NSMakeRange(0, [components count]-1)]];
}

static unichar uls = 0;
static unichar ups = 0;

- (int)numberOfLines
{
	/*
	 A line is delimited by any of these characters, the longest possible sequence being preferred to any shorter:
	 
	 U+000D (\r or CR)
	 U+2028 (Unicode line separator)
	 U+000A (\n or LF)
	 U+2029 (Unicode paragraph separator)
	 \r\n, in that order (also known as CRLF)
	*/
		
	if(uls == 0) {
		uls = [@"\u2028" characterAtIndex:0];		
	}
	if(ups == 0) {
		ups = [@"\u2029" characterAtIndex:0];		
	}
	
	int count = 1;
	for(int index=0; index<[self length]; index++) {
		unichar c = [self characterAtIndex:index];
		
		if(c == '\r') {
			if(index+1 < [self length]) {
				unichar c1 = [self characterAtIndex:index+1];
				if(c1 == '\n') {
					// CRLF detected
					count++;
					index++;
				} else {
					// CR detected
					count++;
				}				
			} else {
				// CR detected
				count++;				
			}
		} else if(c == '\n') {
			// LF detected
			count++;
		} else if(c == uls) {
			// unicode line separator
			count++;
		} else if(c == ups) {
			// unicode paragraph separator
			count++;
		}
		
	}
	return count;
}

@end