//
//  RecentDocumentObject.h
//  iLocalize
//
//  Created by Jean on 5/9/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

@interface RecentDocumentObject : NSObject {
    NSURL *url;
    int disambiguationLevel;
}

@property (strong) NSURL *url;

+ (RecentDocumentObject*)createWithData:(NSData*)data;
+ (RecentDocumentObject*)createWithDocument:(NSDocument*)doc;
+ (RecentDocumentObject*)createWithURL:(NSURL*)url;

- (NSString*)menuTitle;
- (NSAttributedString*)menuAttributedTitle;

- (void)resetMenuTitleDisambiguationLevel;
- (void)incrementMenuTitleDisambiguationLevel;

- (BOOL)exists;

- (void)setData:(id)data;
- (id)data;

@end
