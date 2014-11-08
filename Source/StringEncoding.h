//
//  StringEncoding.h
//  iLocalize
//
//  Created by Jean on 9/27/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#define ENCODING_UTF8 [StringEncoding stringEncoding:NSUTF8StringEncoding useBOM:NO]
#define ENCODING_UTF8_BOM [StringEncoding stringEncoding:NSUTF8StringEncoding useBOM:YES]

#define ENCODING_UTF16BE [StringEncoding stringEncoding:NSStringEncodingUTF16BE useBOM:NO]
#define ENCODING_UTF16BE_BOM [StringEncoding stringEncoding:NSStringEncodingUTF16BE useBOM:YES]

#define ENCODING_UTF16LE [StringEncoding stringEncoding:NSStringEncodingUTF16LE useBOM:NO]
#define ENCODING_UTF16LE_BOM [StringEncoding stringEncoding:NSStringEncodingUTF16LE useBOM:YES]

#define ENCODING_UTF32BE [StringEncoding stringEncoding:NSStringEncodingUTF32BE useBOM:NO]
#define ENCODING_UTF32BE_BOM [StringEncoding stringEncoding:NSStringEncodingUTF32BE useBOM:YES]

#define ENCODING_UTF32LE [StringEncoding stringEncoding:NSStringEncodingUTF32LE useBOM:NO]
#define ENCODING_UTF32LE_BOM [StringEncoding stringEncoding:NSStringEncodingUTF32LE useBOM:YES]

#define ENCODING_ISO_LATIN [StringEncoding stringEncoding:NSISOLatin1StringEncoding useBOM:NO]
#define ENCODING_MACOS_ROMAN [StringEncoding stringEncoding:NSMacOSRomanStringEncoding useBOM:NO]

#define ENCODING_UNICODE [StringEncoding stringEncoding:NSUnicodeStringEncoding useBOM:NO]
#define ENCODING_UNICODE_BOM [StringEncoding stringEncoding:NSUnicodeStringEncoding useBOM:YES]

@interface StringEncoding : NSObject {
	// The encoding of the string
	NSStringEncoding encoding;
	
	// YES if the encoding needs a BOM header or not
	// when writing it to a file
	BOOL bom;
}

@property NSStringEncoding encoding;
@property BOOL bom;

+ (StringEncoding*)stringEncodingForIdentifier:(NSInteger)identifier;
+ (StringEncoding*)stringEncoding:(NSStringEncoding)encoding useBOM:(BOOL)useBOM;
- (NSString*)encodingName;
- (NSInteger)identifier;

- (id)data;
+ (StringEncoding*)stringEncodingWithData:(id)data;

@end
