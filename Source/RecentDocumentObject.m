//
//  RecentDocumentObject.m
//  iLocalize
//
//  Created by Jean on 5/9/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "RecentDocumentObject.h"


@implementation RecentDocumentObject

@synthesize url;

+ (RecentDocumentObject*)createWithData:(NSData*)data
{
	RecentDocumentObject *rdo = [[RecentDocumentObject alloc] init];
	[rdo setData:data];
	return rdo;	
}

+ (RecentDocumentObject*)createWithDocument:(NSDocument*)doc
{
	RecentDocumentObject *rdo = [[RecentDocumentObject alloc] init];
	rdo.url = [doc fileURL];
	return rdo;
}

+ (RecentDocumentObject*)createWithURL:(NSURL*)url
{
	RecentDocumentObject *rdo = [[RecentDocumentObject alloc] init];
	rdo.url = url;
	return rdo;	
}

- (id)init
{
	if(self = [super init]) {
		disambiguationLevel = 0;
	}
	return self;
}


- (NSString*)menuTitle
{
	return [[self menuAttributedTitle] string];
}

- (NSAttributedString *)attributedStringWithImage:(NSImage *)image
{
    NSTextAttachment *ta = [[NSTextAttachment alloc] init];
    NSTextAttachmentCell *tac = [[NSTextAttachmentCell alloc] init];
    
	image.size = NSMakeSize(16, 16);
    //  [image setScalesWhenResized:YES];  // no longer required since Mac OS X 10.6

    [tac setImage:image];
    [ta setAttachmentCell: tac];

    NSAttributedString *as = [NSAttributedString attributedStringWithAttachment:ta];
    
	return as;
}

- (NSAttributedString*)attributedStringWithString:(NSString*)string
{
	NSAttributedString *as = [[NSAttributedString alloc] initWithString:string 
															 attributes:@{NSFontAttributeName: [NSFont systemFontOfSize:14]}];
	return as;
}

- (NSAttributedString*)menuAttributedTitle
{
	NSString *path = [self.url path];
	if(path == nil) {
		return [self attributedStringWithString:@"(null)"];
	}
	
	NSString *documentTitle = [path lastPathComponent];
	NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
	
	// add the icon of the document itself
	[title appendAttributedString:[self attributedStringWithImage:[[self.url path] imageOfPath]]];
	[title appendAttributedString:[self attributedStringWithString:@" "]];

	// add the name of the document
	[title appendAttributedString:[self attributedStringWithString:documentTitle]];

	// look if there is a need for disambiguation
	if(disambiguationLevel > 0) {
		NSMutableArray *components = [NSMutableArray arrayWithArray:[path pathComponents]];
		[components removeLastObject];				
		NSString *parentPath = [NSString pathWithComponents:components];
		
		// add separator
		[title appendAttributedString:[self attributedStringWithString:@" — "]];

		// add the icon of the parent folder
		[title appendAttributedString:[self attributedStringWithImage:[parentPath imageOfPath]]];
		[title appendAttributedString:[self attributedStringWithString:@" "]];

		// add the parent folder
		[title appendAttributedString:[self attributedStringWithString:[parentPath lastPathComponent]]];
	}	
	return title;
}

- (NSString*)documentLocation
{
	return [self.url path];
}

- (void)resetMenuTitleDisambiguationLevel
{
	disambiguationLevel = 0;
}

- (void)incrementMenuTitleDisambiguationLevel
{
	disambiguationLevel++;
}

- (BOOL)isEqual:(id)anObject
{	
	if(![anObject isKindOfClass:[RecentDocumentObject class]]) {
		return NO;
	}
	
	return [self.url isEqual:[anObject url]];
}

- (NSUInteger)hash
{
	return [self.url hash];
}

- (BOOL)exists
{
	return [[self.url path] isPathExisting];
}

- (void)setData:(id)data
{
	self.url = [data[@"aliasData"] newURLFromAliasData];
}

- (id)data
{
	NSData *data = [self.url createAliasData];
	if(data) {
		return @{@"aliasData": data};		
	} else {
		return nil;
	}
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@ (%d)", self.url, disambiguationLevel];
}

@end
