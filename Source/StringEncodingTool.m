//
//  StringEncodingTool.m
//  iLocalize3
//
//  Created by Jean on 23.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "StringEncodingTool.h"
#import "Constants.h"
#import "StringEncoding.h"

@interface StringEncodingTool (Private)
+ (StringEncoding *)encodingOfData:(NSData *)data defaultEncoding:(StringEncoding *)defaultEncoding;
+ (StringEncoding *)encodingOfData:(NSData *)data defaultEncoding:(StringEncoding *)defaultEncoding hasEncodingInformation:(BOOL *)hasEncoding;
+ (NSData *)removeEncoding:(NSStringEncoding)encoding fromData:(NSData *)data removed:(BOOL *)removed;
@end

@implementation StringEncodingTool

static StringEncodingTool *encoding = nil;

+ (id)shared
{
    @synchronized(self)
    {
        if (encoding == nil)
            encoding = [[StringEncodingTool alloc] init];        
    }
    
	return encoding;
}

- (id)init
{
	if (self = [super init])
    {
		mAvailableEncodings = NULL;
	}
	
    return self;
}


NSInteger encodingSort(id obj1, id obj2, void *context)
{
	return [[obj1 encodingName] caseInsensitiveCompare:[obj2 encodingName]];
}

- (NSArray *)availableEncodings
{
	if (mAvailableEncodings)
		return mAvailableEncodings;
		
	mAvailableEncodings = [[NSMutableArray alloc] init];
    
	[mAvailableEncodings addObject:ENCODING_UTF8_BOM];
	[mAvailableEncodings addObject:ENCODING_UTF8];
	
	[mAvailableEncodings addObject:ENCODING_UNICODE_BOM];
	[mAvailableEncodings addObject:ENCODING_UNICODE];

	[mAvailableEncodings addObject:ENCODING_UTF16BE_BOM];
	[mAvailableEncodings addObject:ENCODING_UTF16BE];
	
	[mAvailableEncodings addObject:ENCODING_UTF16LE_BOM];
	[mAvailableEncodings addObject:ENCODING_UTF16LE];
	
	[mAvailableEncodings addObject:ENCODING_MACOS_ROMAN];
	[mAvailableEncodings addObject:ENCODING_ISO_LATIN];

	[mAvailableEncodings addObject:[StringEncoding stringEncoding:NSWindowsCP1252StringEncoding useBOM:NO]];
	[mAvailableEncodings addObject:[StringEncoding stringEncoding:NSNonLossyASCIIStringEncoding useBOM:NO]];
	
	NSMutableArray *array = [NSMutableArray array];
	
	const NSStringEncoding *encoding = [NSString availableStringEncodings];
    
	while (*encoding)
    {
		id n = [StringEncoding stringEncoding:*encoding++ useBOM:NO];
        
		if (![mAvailableEncodings containsObject:n])
			[array addObject:n];
	}
	
	[array sortUsingFunction:encodingSort context:NULL];

	[mAvailableEncodings addObjectsFromArray:array];
	
	return mAvailableEncodings;
}

- (void)fillAvailableEncodingsToMenu:(NSMenu *)menu target:(id)target action:(SEL)action
{	
	[menu removeAllItems];
	
	NSString *name;
	NSString *lastName = nil;
    
	for (StringEncoding *se in [self availableEncodings])
    {
		name = [se encodingName];
        
		// Name can be empty (bug on Mac OS 10.3.9 for example)
        if ([name length] == 0)
            continue;
		
		if (lastName && [lastName characterAtIndex:0] != [name characterAtIndex:0])
			[menu addItem:[NSMenuItem separatorItem]];

		NSString *menuName;
		if (se.bom)
        {
			menuName = [NSString stringWithFormat:NSLocalizedString(@"%@ - with BOM", @"Encoding with BOM header"), name];
		}
        else
        {
			menuName = name;
		}
		
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:menuName action:nil keyEquivalent:@""];
		
        if (target)
			[item setTarget:target];
		
        if (action)
			[item setAction:action];
		
        [item setRepresentedObject:se];
		[item setTag:[se identifier]];
		[menu addItem:item];
		lastName = name;
	}
}

- (NSMenu *)availableEncodingsMenu
{
	return [self availableEncodingsMenuWithTarget:nil action:nil];
}

- (NSMenu *)availableEncodingsMenuWithTarget:(id)target action:(SEL)action
{
	NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
	[self fillAvailableEncodingsToMenu:menu target:target action:action];
	return menu;
}

#pragma mark Reading file content

+ (NSString *)stringWithContentOfFile:(NSString *)file encoding:(StringEncoding *)encoding
{
	NSData *data = [[NSData alloc] initWithContentsOfFile:file];
	NSString *text = [[NSString alloc] initWithData:[StringEncodingTool removeEncoding:encoding.encoding fromData:data removed:nil] encoding:encoding.encoding];
	
    return text;
}

+ (NSString *)stringWithContentOfFile:(NSString *)file encodingUsed:(StringEncoding **)encoding defaultEncoding:(StringEncoding *)defaultEncoding
{
	return [StringEncodingTool stringWithContentOfFile:file defaultEncoding:defaultEncoding detectedEncoding:encoding hasEncodingInformation:nil];
}

+ (NSString *)stringWithContentOfFile:(NSString *)file defaultEncoding:(StringEncoding *)defaultEncoding detectedEncoding:(StringEncoding **)detectedEncoding hasEncodingInformation:(BOOL *)hasEncoding
{	
	BOOL hasEncoding_;
	NSData *data = [[NSData alloc] initWithContentsOfFile:file];
	StringEncoding *encoding = [StringEncodingTool encodingOfData:data defaultEncoding:defaultEncoding hasEncodingInformation:&hasEncoding_];
	
	NSString *content = nil;
    
	// If no encoding detected, use the Cocoa framework to see if it can give some more useful information
	if (!hasEncoding_)
    {
		NSStringEncoding cocoaEncoding;
		NSError *error = nil;
		NSString *text = [NSString stringWithContentsOfFile:file usedEncoding:&cocoaEncoding error:&error];
        
		if (text != nil && !error)
        {
			// no error, use this encoding
			encoding.encoding = cocoaEncoding;
			encoding.bom = NO; // no BOM if detected here (otherwise encodingOfData would have discovered it)
			content = text;
		}
	}
	
	if (!content)
    {
		content = [[NSString alloc] initWithData:[StringEncodingTool removeEncoding:encoding.encoding fromData:data removed:nil] encoding:encoding.encoding];
	}
	
	if (hasEncoding)
    {
		*hasEncoding = hasEncoding_;
	}
	
	if (detectedEncoding)
    {
		*detectedEncoding = encoding;
	}
	
    return content;
}

#pragma mark File encoding

+ (StringEncoding *)encodingOfFile:(NSString *)file defaultEncoding:(StringEncoding *)defaultEncoding
{
	return [StringEncodingTool encodingOfFile:file defaultEncoding:defaultEncoding hasEncodingInformation:nil];
}

+ (StringEncoding *)encodingOfFile:(NSString *)file defaultEncoding:(StringEncoding *)defaultEncoding hasEncodingInformation:(BOOL *)hasEncoding
{
	StringEncoding* encoding = defaultEncoding;
	[StringEncodingTool stringWithContentOfFile:file defaultEncoding:defaultEncoding detectedEncoding:&encoding hasEncodingInformation:hasEncoding];
	return encoding;
}

#pragma mark Data encoding (Private)

+ (StringEncoding *)encodingOfData:(NSData *)data defaultEncoding:(StringEncoding *)defaultEncoding
{
	return [StringEncodingTool encodingOfData:data defaultEncoding:defaultEncoding hasEncodingInformation:nil];
}

// http://www.unicode.org/faq/utf_bom.html#BOM

static const char bom_utf8[3]     = { 0xEF, 0xBB, 0xBF };
static const char bom_utf16_be[2] = { 0xFE, 0xFF };
static const char bom_utf16_le[2] = { 0xFF, 0xFE };
static const char bom_utf32_be[4] = { 0x00, 0x00, 0xFE, 0xFF };
static const char bom_utf32_le[4] = { 0xFF, 0xFE, 0x00, 0x00 };

+ (StringEncoding *)encodingOfData:(NSData *)data defaultEncoding:(StringEncoding *)defaultEncoding hasEncodingInformation:(BOOL *)hasEncoding
{
	if (hasEncoding)
        *hasEncoding = YES;

	const char *bytes = [data bytes];
    
	if (bytes == nil)
    {
		if (hasEncoding)
            *hasEncoding = NO;
		
        return defaultEncoding;
	}
	
	NSUInteger length = [data length];
	
	CFStringBuiltInEncodings encoding;
    
    if (length >= 3 && memcmp(bytes, &bom_utf8, 3) == 0)
    {
		encoding = kCFStringEncodingUTF8;
	}
    else if(length >= 4 && memcmp(bytes, &bom_utf32_be, 4) == 0)
    {
		encoding = kCFStringEncodingUTF32BE;
	}
    else if(length >= 4 && memcmp(bytes, &bom_utf32_le, 4) == 0)
    {
		encoding = kCFStringEncodingUTF32LE;
	}
    else if(length >= 2 && memcmp(bytes, &bom_utf16_be, 2) == 0)
    {
		encoding = kCFStringEncodingUTF16BE;
	}
    else if(length >= 2 && memcmp(bytes, &bom_utf16_le, 2) == 0)
    {
		encoding = kCFStringEncodingUTF16LE;
	}
    else
    {
		if (hasEncoding)
            *hasEncoding = NO;
		
        return defaultEncoding;
	}
	
    if (encoding == 0)
    {
		LOG_DEBUG(@"Invalid encoding: %u", encoding);
	}	
	
	NSStringEncoding se = CFStringConvertEncodingToNSStringEncoding(encoding);
	
    // The BOM is YES because this is how this method discovers the encoding: only
	// if the data has a BOM header.
	return [StringEncoding stringEncoding:se useBOM:YES];
}

#pragma mark Utilities

+ (NSData *)bomDataForEncoding:(NSStringEncoding)encoding
{
	switch (encoding)
    {
		case NSUTF8StringEncoding:    return [NSData dataWithBytes:bom_utf8 length:3];
		case NSUnicodeStringEncoding:
		case NSStringEncodingUTF16BE: return [NSData dataWithBytes:bom_utf16_be length:2];
		case NSStringEncodingUTF16LE: return [NSData dataWithBytes:bom_utf16_le length:2];
		case NSStringEncodingUTF32BE: return [NSData dataWithBytes:bom_utf32_be length:4];
		case NSStringEncodingUTF32LE: return [NSData dataWithBytes:bom_utf32_le length:4];
	}
    
	return nil;
}

+ (NSData *)removeEncoding:(NSStringEncoding)encoding fromData:(NSData *)data removed:(BOOL *)removed
{
	if (removed)
        *removed = NO;
	
	if (data == nil)
    {
		return nil;
	}
	
	NSData *bomData = [StringEncodingTool bomDataForEncoding:encoding];
    
	if (bomData)
    {
		NSUInteger length = [bomData length];
        
		// If the data has a bom header, remove it
		if ([data length] >= length && [[data subdataWithRange:NSMakeRange(0, length)] isEqualTo:bomData])
        {
			if (removed)
                *removed = YES;
			
            return [data subdataWithRange:NSMakeRange(length, [data length] - length)];
		}
	}
    
	return data;
}

+ (NSData *)removeAnyBOMEncodingFromData:(NSData *)data
{
	if (data == nil)
    {
		return nil;
	}

	BOOL removed = NO;
    
	data = [StringEncodingTool removeEncoding:NSUTF8StringEncoding fromData:data removed:&removed];
	
    if (removed)
        return data;
	
    data = [StringEncodingTool removeEncoding:NSStringEncodingUTF16BE fromData:data removed:&removed];
	
    if (removed)
        return data;
	
    data = [StringEncodingTool removeEncoding:NSStringEncodingUTF16LE fromData:data removed:&removed];
	
    if (removed)
        return data;
	
    data = [StringEncodingTool removeEncoding:NSStringEncodingUTF32BE fromData:data removed:&removed];
	
    if (removed)
        return data;
	
    data = [StringEncodingTool removeEncoding:NSStringEncodingUTF32LE fromData:data removed:&removed];
	
    if (removed)
        return data;
	
	return data;
}

+ (NSData *)encodeString:(NSString *)string toDataUsingEncoding:(StringEncoding *)encoding
{
	NSData *outData = [StringEncodingTool removeAnyBOMEncodingFromData:[string dataUsingEncoding:encoding.encoding]];
    
	if (encoding.bom)
    {
		NSMutableData *data = [NSMutableData dataWithData:outData];		
		NSData *bomData = [StringEncodingTool bomDataForEncoding:encoding.encoding];
        
		if (bomData)
        {
			[data replaceBytesInRange:NSMakeRange(0, 0) withBytes:[bomData bytes] length:[bomData length]];			
		}
		
        return data;
	}
    else
    {
		return outData;
	}	
}

@end
