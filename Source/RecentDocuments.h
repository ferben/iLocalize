//
//  RecentDocuments.h
//  iLocalize
//
//  Created by Jean on 5/9/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

@interface RecentDocuments : NSObject<NSMenuDelegate> {
    NSMutableArray *recentObjects;
    BOOL dirtyMenu;
}

@property (strong) NSString *identifier;
@property (weak) NSMenu *recentMenu;
@property (strong) NSArray *extensions;

+ (void)loadAll;
+ (void)saveAll;

+ (void)documentOpened:(NSDocument*)doc;
+ (void)documentClosed:(NSDocument*)doc;

+ (RecentDocuments*)findInstanceWithID:(NSString*)identifier;
+ (RecentDocuments*)createInstanceForDocumentExtensions:(NSArray*)extensions identifier:(NSString*)identifier;

- (void)setMenu:(NSMenu*)menu;

- (NSArray*)urls;

- (void)load;
- (void)save;

@end
