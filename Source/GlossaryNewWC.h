//
//  GlossaryNewWC.h
//  iLocalize3
//
//  Created by Jean on 09.04.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"

@interface GlossaryNewWC : NSWindowController {
    IBOutlet NSPopUpButton    *mPathPopup;    
}

@property (weak) id<ProjectProvider> projectProvider;

- (void)display;

- (IBAction)cancel:(id)sender;
- (IBAction)create:(id)sender;

@end
