//
//  ProjectMenu.m
//  iLocalize
//
//  Created by Jean on 12/24/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectMenu.h"
#import "ProjectWC.h"

@implementation ProjectMenu

+ (ProjectMenu*)newInstance:(ProjectWC*)projectWC
{
	ProjectMenu *menu = [[self alloc] init];
	menu.projectWC = projectWC;
	[projectWC addToAsNextResponder:menu];
	// awake with a little delay so the projectDocument returns something non-null
	[menu performSelector:@selector(awake) withObject:nil afterDelay:0];
	return menu;
}

- (void)awake
{
	
}

- (void)destroy
{
	self.projectWC = nil;
}

- (ProjectDocument*)projectDocument
{
	return [self.projectWC projectDocument];
}

- (ProjectFilesController*)projectFiles
{
	return [self.projectWC projectFiles];
}

- (ProjectExplorerController*)projectExplorer
{
	return [self.projectWC projectExplorer];
}

- (ProjectDetailsController*)projectDetails
{
	return [self.projectWC projectDetailsController];
}

- (NSWindow*)window
{
	return [self.projectWC window];
}

@end
