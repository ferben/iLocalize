//
//  StringEncoding.m
//  iLocalize
//
//  Created by Jean on 9/27/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "StringEncoding.h"

@implementation StringEncoding

@synthesize encoding;
@synthesize bom;

+ (StringEncoding*)stringEncodingForIdentifier:(NSInteger)identifier
{
	BOOL bom = identifier < 0;
	return [StringEncoding stringEncoding:ABS(identifier) useBOM:bom];
}

+ (StringEncoding*)stringEncoding:(NSStringEncoding)encoding useBOM:(BOOL)useBOM
{
	StringEncoding *se = [[StringEncoding alloc] init];
	se.encoding = encoding;
	se.bom = useBOM;
	return se;
}

- (NSString*)encodingName
{
	return [NSString localizedNameOfStringEncoding:self.encoding];
}

- (NSInteger)identifier
{
	return self.bom?-self.encoding:self.encoding;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@, e=%lu, b=%d", [self encodingName], [self encoding], [self bom]];
}

- (BOOL)isEqual:(id)other
{
	if(other == self) return YES;
	
	if(!other || ![other isKindOfClass:[self class]]) return NO;
	
	return self.encoding == [other encoding] && self.bom == [other bom];
}

- (NSUInteger)hash
{
	return [[NSString stringWithFormat:@"%lu-%d", self.encoding, self.bom] hash];
}

- (id)data
{
	return @[@(self.encoding), @(self.bom)];
}

+ (StringEncoding*)stringEncodingWithData:(id)data
{
	StringEncoding *e = [[StringEncoding alloc] init];
	if([data isKindOfClass:[NSArray class]]) {
		e.encoding = [data[0] unsignedLongValue];
		e.bom = [data[1] boolValue];
	} else {
		e.encoding = [data unsignedLongValue];
		e.bom = NO;
	}
	return e;
}

@end
