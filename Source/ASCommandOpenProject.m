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
    NSDocument *document;

    NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
    
    [documentController openDocumentWithContentsOfURL:url display:YES completionHandler:
    ^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error)
    {
        if (error)
            [documentController presentError:error];
    }];
    
    ProjectDocument *myDocument = (ProjectDocument *)document;
    
	return [ASProject projectWithDocument:myDocument];
}

@end
