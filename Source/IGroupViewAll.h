//
//  IGroupViewAll.h
//  iLocalize
//
//  Created by Jean Bovet on 11/1/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"

@interface IGroupViewAll : NSView
{
}

@property (weak) id<ProjectProvider> projectProvider;

- (void)addToView:(NSView *)parentView;

@end
