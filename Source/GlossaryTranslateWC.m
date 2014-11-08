//
//  GlossaryTranslateWC.m
//  iLocalize
//
//  Created by Jean Bovet on 1/30/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "GlossaryTranslateWC.h"


@implementation GlossaryTranslateWC

- (id)init
{
	if(self = [super initWithWindowNibName:@"GlossaryTranslate"]) {
		
	}
	return self;
}

- (IBAction)translateAllFiles:(id)sender
{
	[self hideWithCode:1];	
}

- (IBAction)translateSelectedFiles:(id)sender
{
	[self hideWithCode:2];
}

@end
