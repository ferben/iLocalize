//
//  GlossaryNotification.m
//  iLocalize
//
//  Created by Jean Bovet on 4/28/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "GlossaryNotification.h"


@implementation GlossaryNotification

@synthesize listOfNewFiles;
@synthesize modifiedFiles;
@synthesize deletedFiles;
@synthesize folder;
@synthesize processingPercentage;
@synthesize source;
@synthesize action;

+ (GlossaryNotification*)notificationWithAction:(int)action
{
	GlossaryNotification *n = [[GlossaryNotification alloc] init];
	n.action = action;
	return n;
}

- (NSString*)description
{
	switch (action) {
		case INDEX_CHANGED:
			return [NSString stringWithFormat:@"New=%@, modified=%@, deleted=%@, folder=%@, source=%@", listOfNewFiles, modifiedFiles, deletedFiles, folder, source];
		case GLOSSARY_SAVED:
			return [NSString stringWithFormat:@"Modified=%@, source=%@", modifiedFiles, source];
		case FOLDER_ADDED:
			return [NSString stringWithFormat:@"New folder=%@, source=%@", folder, source];
		case FOLDER_DELETED:
			return [NSString stringWithFormat:@"Removed folder=%@, source=%@", folder, source];
	}
	return [NSString stringWithFormat:@"New=%@, modified=%@, deleted=%@, folder=%@, source=%@", listOfNewFiles, modifiedFiles, deletedFiles, folder, source];
}

@end
