//
//  FileConflictItem.h
//  iLocalize
//
//  Created by Jean Bovet on 2/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

/**
 This class holds a file information with its source and its corresponding project file.
 */
@interface FileConflictItem : NSObject {
	NSString *source;
	NSString *project;
}
@property (strong) NSString *source;
@property (strong) NSString *project;
@end
