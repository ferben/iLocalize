//
//  RecentDocuments.m
//  iLocalize
//
//  Created by Jean on 5/9/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "RecentDocuments.h"
#import "RecentDocumentObject.h"

@interface RecentDocuments (Private)
- (void)_documentOpened:(NSDocument*)doc;
- (void)_documentClosed:(NSDocument*)doc;
@end

@implementation RecentDocuments

static NSMutableArray *instances = nil;

+ (void)initialize
{
	instances = [[NSMutableArray alloc] init];
}

+ (void)loadAll
{
	[instances makeObjectsPerformSelector:@selector(load)];
}

+ (void)saveAll
{
	[instances makeObjectsPerformSelector:@selector(save)];
}

+ (void)documentOpened:(NSDocument*)doc
{
	[instances makeObjectsPerformSelector:@selector(_documentOpened:) withObject:doc];
}

+ (void)documentClosed:(NSDocument*)doc
{
	[instances makeObjectsPerformSelector:@selector(_documentClosed:) withObject:doc];
}

+ (RecentDocuments*)findInstanceWithID:(NSString*)identifier
{
	for(RecentDocuments *d in instances) {
		if([d.identifier isEqualToString:identifier]) {
			return d;
		}
	}
	return nil;
}

+ (RecentDocuments*)createInstanceForDocumentExtensions:(NSArray*)extensions identifier:(NSString*)identifier
{
	RecentDocuments *rc = [[RecentDocuments alloc] init];
	rc.extensions = extensions;
	rc.identifier = identifier;
	[instances addObject:rc];
	return rc;
}

- (id)init
{
	if((self = [super init])) {
		recentObjects = [[NSMutableArray alloc] init];
		dirtyMenu = YES;
	}
	return self;
}

- (void)dealloc
{
	[instances removeObject:self];
}

- (void)setMenu:(NSMenu*)menu
{
	self.recentMenu = menu;
	[self.recentMenu setDelegate:self];
}

- (NSArray*)urls
{
	NSMutableArray *array = [NSMutableArray array];
	for(RecentDocumentObject *rdo in recentObjects) {
		[array addObject:rdo.url];
	}
	return array;
}

- (int)maxAmountOfDocuments
{
	int max = 0;
	
	// Get from system property
	id maxDocuments = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.apple.recentitems"][@"Documents"][@"MaxAmount"];
	if(maxDocuments) {
		max = [maxDocuments intValue];
	}
	
	return max > 0 ? max : 10;
}

- (BOOL)acceptsURL:(NSURL*)url
{
    NSString *path = [url path];
    BOOL accept = [self.extensions containsObject:[path pathExtension]];
    // Exclude backup file
    return accept && ![path hasSuffix:[NSString stringWithFormat:@"~.%@", [path pathExtension]]];
}

- (BOOL)acceptsObject:(RecentDocumentObject*)object
{
    return [self acceptsURL:[object url]] && [object exists];
}

- (void)insertObject:(RecentDocumentObject*)object
{
	dirtyMenu = YES;
	[recentObjects removeObject:object];
	[recentObjects insertObject:object atIndex:0];
	while([recentObjects count] > [self maxAmountOfDocuments]) {
		[recentObjects removeLastObject];
	}
}

- (void)_documentOpened:(NSDocument*)doc
{
	if([self acceptsURL:[doc fileURL]]) {
		[self insertObject:[RecentDocumentObject createWithDocument:doc]];
	}
}

- (void)_documentClosed:(NSDocument*)doc
{
	if([self acceptsURL:[doc fileURL]]) {
		// move this document to the top of the array
		[self insertObject:[RecentDocumentObject createWithDocument:doc]];
	}	
}

- (NSArray*)findAllIdenticalObjectAs:(RecentDocumentObject*)original
{
	NSMutableArray *similars = [NSMutableArray array];
	for(RecentDocumentObject *rdo in recentObjects) {
		if([[rdo menuTitle] isEqualToString:[original menuTitle]]) {
			[similars addObject:rdo];
		}
	}	
	return similars;
}

- (void)resolveIdenticalFileNames
{
	// reset the level of disambiguation for all items
	[recentObjects makeObjectsPerformSelector:@selector(resetMenuTitleDisambiguationLevel)];

	NSMutableSet *alreadyProcessed = [NSMutableSet set];
	NSMutableArray *uniqueObjects = [NSMutableArray array];
	for(RecentDocumentObject *o in recentObjects) {
		if(![alreadyProcessed containsObject:o]) {
			[uniqueObjects addObject:o];
			[alreadyProcessed addObject:o];
		}
	}
	[recentObjects removeAllObjects];
	[recentObjects addObjectsFromArray:uniqueObjects];
	
	// loop until all the items are disambiguated
	NSMutableArray *identicals = [NSMutableArray arrayWithArray:recentObjects];
	while([identicals count] > 0) {
		NSEnumerator *enumerator = [identicals objectEnumerator];
		RecentDocumentObject *rdo;
		while((rdo = [enumerator nextObject])) {
			NSArray *similars = [self findAllIdenticalObjectAs:rdo];
			if(similars.count == 1) {
				// ok, there is only one like that
				[identicals removeObject:rdo];
				enumerator = [identicals objectEnumerator];
			} else {
				// more than one similar items so increment the level for all of them
				for(RecentDocumentObject *srdo in similars) {
					[srdo incrementMenuTitleDisambiguationLevel];
				}
				[identicals removeObjectsInArray:similars];
				enumerator = [identicals objectEnumerator];
			}			
		}
	}
}

- (void)menuNeedsUpdate:(NSMenu *)menu
{
	if(dirtyMenu) {
		dirtyMenu = NO;

		[self resolveIdenticalFileNames];
		
		[menu removeAllItems];
        NSInteger count = 0;
		for(RecentDocumentObject *rdo in recentObjects) {
            if(![self acceptsObject:rdo]) {
                continue;
            }
            
            count++;
			NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[rdo menuTitle] action:@selector(openRecent:) keyEquivalent:@""];
			[item setAttributedTitle:[rdo menuAttributedTitle]];
			[item setTarget:self];
			[item setTag:[recentObjects indexOfObject:rdo]];
			[menu addItem:item];
		}
		
		if(count == 0) {
			[menu addItemWithTitle:NSLocalizedString(@"No Recent Document", nil) action:nil keyEquivalent:@""];
		}
		[menu addItem:[NSMenuItem separatorItem]];
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Clear Menu", nil) action:@selector(clear:) keyEquivalent:@""];
		[item setTarget:self];
		[menu addItem:item];		
	}
}

- (void)openRecent:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[recentObjects[[sender tag]] url]];
}

- (void)clear:(id)sender
{
	dirtyMenu = YES;
	[recentObjects removeAllObjects];
}

- (NSString*)storageKey
{
	return [NSString stringWithFormat:@"RecentDocument-%@", self.identifier];
}

- (void)load
{
	dirtyMenu = YES;
	[recentObjects removeAllObjects];
	NSArray *datas = [[NSUserDefaults standardUserDefaults] arrayForKey:[self storageKey]];
	if(datas) {
		for(NSData *d in datas) {
			RecentDocumentObject *rdo = [RecentDocumentObject createWithData:d];
			if([self acceptsObject:rdo]) {
				[recentObjects addObject:rdo];			
			}
		}		
	} else {
		// load from the System Open Recent menu
		for(NSURL *url in [[NSDocumentController sharedDocumentController] recentDocumentURLs]) {
			if(![self acceptsURL:url]) continue;
			
			RecentDocumentObject *rdo = [RecentDocumentObject createWithURL:url];
			if([self acceptsObject:rdo]) {
				[recentObjects addObject:rdo];			
			}			
		}
	}
}

- (void)save
{
	NSMutableArray *datas = [NSMutableArray array];
	for(RecentDocumentObject *rdo in recentObjects) {
		id data = [rdo data];
		if(data) {
			[datas addObject:data];			
		}
	}
	[[NSUserDefaults standardUserDefaults] setObject:datas forKey:[self storageKey]];
}

@end
