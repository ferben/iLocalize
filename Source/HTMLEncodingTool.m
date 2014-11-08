//
//  HTMLEncodingTool.m
//  Tests
//
//  Created by Jean on 9/2/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "HTMLEncodingTool.h"
#import "StringEncodingTool.h"
#import "StringEncoding.h"
#import "XMLParser.h"

@interface HTMLEncodingTool (Private)
- (NSArray*)parseContentAndReturnRangeToReplace:(NSString*)content;
- (NSString*)parseFile:(NSString*)file;
@end

@implementation HTMLEncodingTool

+ (StringEncoding*)encodingOfFile:(NSString*)file hasEncoding:(BOOL*)hasEncoding
{
	return [StringEncodingTool encodingOfFile:file defaultEncoding:ENCODING_UTF8 hasEncodingInformation:hasEncoding];
}

+ (StringEncoding*)encodingOfContent:(NSString*)file hasEncoding:(BOOL*)hasEncoding
{
	if(![file isPathExisting]) return nil;
	
	HTMLEncodingTool *tool = [[HTMLEncodingTool alloc] init];
	NSString *encoding = [tool parseFile:file];
	
	NSStringEncoding e;
	if(encoding) {
		if(hasEncoding) *hasEncoding = YES;
		e = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)encoding));		
	} else {
		if(hasEncoding) *hasEncoding = NO;
		e = NSUTF8StringEncoding;
	}
	return [StringEncoding stringEncoding:e useBOM:NO];
}

/** Look at the first line of the string to see:
<?xml version="1.0" encoding="UTF-8"?>
*/

+ (StringEncoding*)encodingOfContentInXMLHeader:(NSString*)file hasEncoding:(BOOL*)hasEncoding
{
	if(hasEncoding) *hasEncoding = NO;
	StringEncoding *defaultEncoding = ENCODING_UTF8;
			
	NSString *s = [StringEncodingTool stringWithContentOfFile:file encodingUsed:nil defaultEncoding:defaultEncoding];
	if(s == nil) {
		s = [StringEncodingTool stringWithContentOfFile:file encodingUsed:nil defaultEncoding:ENCODING_MACOS_ROMAN];		
	}
	
	NSScanner *scanner = [NSScanner scannerWithString:s];
	if(![scanner scanString:@"<?xml" intoString:nil]) return defaultEncoding;
	
	if([scanner scanString:@"version" intoString:nil]) {
		[scanner scanString:@"=" intoString:nil];
		[scanner scanString:@"\"" intoString:nil];
		[scanner scanUpToString:@"\"" intoString:nil];		
		[scanner scanString:@"\"" intoString:nil];
	}
	
	if(![scanner scanString:@"encoding" intoString:nil]) return defaultEncoding;	
	if(![scanner scanString:@"=" intoString:nil]) return defaultEncoding;
	if(![scanner scanString:@"\"" intoString:nil]) return defaultEncoding;
	
	NSString *encoding = nil;
	if(![scanner scanUpToString:@"\"" intoString:&encoding]) return defaultEncoding;	
			
	if(hasEncoding) *hasEncoding = YES;
	return [StringEncoding stringEncoding:CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)encoding)) useBOM: NO];
}

+ (NSString*)replaceEncodingInformationOfString:(NSString*)content fromEncoding:(StringEncoding*)source toEncoding:(StringEncoding*)target
{
	NSString *ianaName = (NSString*)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(target.encoding));
	
	NSMutableString *mutableContent = [NSMutableString stringWithString:content];
	
	HTMLEncodingTool *tool = [[HTMLEncodingTool alloc] init];
	NSEnumerator *enumerator = [[tool parseContentAndReturnRangeToReplace:content] reverseObjectEnumerator];
	NSValue *value;
	while(value = [enumerator nextObject]) {
		NSRange range = [value rangeValue];
		[mutableContent replaceCharactersInRange:range withString:ianaName];
	}
	return mutableContent;
}

#pragma mark XMLParser Delegate

- (NSString*)parseFile:(NSString*)file
{	
	mLookingForEncoding = YES;
	mScannerEncoding = nil;

	NSString *s = [StringEncodingTool stringWithContentOfFile:file encodingUsed:nil defaultEncoding:ENCODING_UTF8];
	if(s == nil) {
		s = [StringEncodingTool stringWithContentOfFile:file encodingUsed:nil defaultEncoding:ENCODING_MACOS_ROMAN];		
	}
	
	XMLParser *parser = [[XMLParser alloc] init];
	[parser setString:s];
	[parser setDelegate:self];
	[parser parse];
	
	return mScannerEncoding;
}

- (NSArray*)parseContentAndReturnRangeToReplace:(NSString*)content
{
	mInsideXMLHeader = 0;
	mInsideMeta = 0;
	mReplaceRanges = [NSMutableArray array];
	mLookingForEncoding = NO;
	
	XMLParser *parser = [[XMLParser alloc] init];
	[parser setString:content];
	[parser setDelegate:self];
	[parser parse];
	
	return mReplaceRanges;
}

- (void)parser:(XMLParser*)parser beginElement:(NSString*)name
{
	if([name isEqualToString:@"?xml"]) {
		mInsideXMLHeader++;
	}
	if([name isEqualToString:@"meta"]) {
		mInsideMeta++;
	}
}

- (void)parser:(XMLParser*)parser endElement:(NSString*)name
{
	if([name isEqualToString:@"?xml"]) {
		mInsideXMLHeader--;
	}
	if([name isEqualToString:@"meta"]) {
		mInsideMeta--;
	}
}

- (void)parser:(XMLParser*)parser element:(NSString*)element attributeName:(NSString*)name content:(NSString*)content info:(id)info
{
	if([element isEqualToString:@"?xml"]) {
		if([name isEqualToString:@"encoding"]) {
			int start = [info[INFO_START_LOCATION] intValue];
			int end = [info[INFO_END_LOCATION] intValue];
			[mReplaceRanges addObject:[NSValue valueWithRange:NSMakeRange(start, end-start)]];		
		}
	}
	if([element isEqualToString:@"meta"] && [name isEqualToString:@"content"]) {
		if(mLookingForEncoding) {
			NSRange charsetRange = [content rangeOfString:@"charset="];
			if(charsetRange.location != NSNotFound) {
				NSScanner *scanner = [NSScanner scannerWithString:content];
				if([scanner scanUpToString:@"charset=" intoString:nil]) {
					[scanner scanString:@"charset=" intoString:nil];
					mScannerEncoding = [content substringFromIndex:[scanner scanLocation]];
					[parser abort];
				}			
			}
		} else {
			NSRange charsetRange = [content rangeOfString:@"charset="];
			if(charsetRange.location != NSNotFound) {
				//text/html;charset=iso-8859-1
				
				int start = [info[INFO_START_LOCATION] intValue];
				int end = [info[INFO_END_LOCATION] intValue];
				
				start += charsetRange.location+charsetRange.length;
				[mReplaceRanges addObject:[NSValue valueWithRange:NSMakeRange(start, end-start)]];		
				
				// abort when the meta attribute is changed (because it is the last one we care about)
				[parser abort];
			}			
		}
	}
}

- (void)parser:(XMLParser*)parser content:(NSString*)content
{
}

- (void)parser:(XMLParser*)parser comment:(NSString*)comment
{
}

- (void)parser:(XMLParser*)parser error:(NSString*)reason
{
	NSLog(@"[HTMLEncodingTool] %@", reason);
}

@end
