//
//  FileControllerProtocol.h
//  iLocalize
//
//  Created by Jean Bovet on 4/19/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@protocol FileControllerProtocol

- (NSArray*)stringControllers;
- (NSArray*)filteredStringControllers;

- (NSString*)filename;
- (NSString*)relativeFilePath;

@end

