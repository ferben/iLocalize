//
//  ASCommandOpenProject.m
//  iLocalize
//
//  Created by Jean on 12/17/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "ASCommandOpenProject.h"
#import "ASProject.h"
#import "ProjectDocument.h"

@implementation ASCommandOpenProject

- (id)performDefaultImplementation
{
	NSURL *url = [self directParameter];
	ProjectDocument *document = [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:url
																									   display:YES];	
	return [ASProject projectWithDocument:document];
}

@end
