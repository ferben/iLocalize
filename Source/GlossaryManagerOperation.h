//
//  GlossaryManagerOperation.h
//  iLocalize
//
//  Created by Jean Bovet on 4/27/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

/**
 Operation used by the GlossaryManager to refresh the folder state
 based on the disk representation. This operation is meant to run asynchronously.
 */
@interface GlossaryManagerOperation : NSOperation {
	// The list of folders to analyze
	NSArray *folders;
	
	// Array of extensions allowed for glossary.
	NSArray *allowedExtensions;
}
@property (strong) NSArray *folders;
@end
