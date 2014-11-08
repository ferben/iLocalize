//
//  OpenAndRevealOperation.h
//  iLocalize3
//
//  Created by Jean on 02.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractOperation.h"

@interface OpenAndRevealOperation : AbstractOperation {
	NSArray				*mFileControllers;
}
- (void)openFileControllers:(NSArray*)fileControllers;
- (void)revealFileControllers:(NSArray*)fileControllers;
@end
