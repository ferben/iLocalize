//
//  ProjectLabels.h
//  iLocalize3
//
//  Created by Jean on 3/21/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "AbstractWC.h"

@interface ProjectLabelsWC : AbstractWC {
    IBOutlet NSArrayController    *mLabelsController;
    IBOutlet NSMenu                *mColorMenu;
}

- (IBAction)remove:(id)sender;
- (IBAction)ok:(id)sender;

@end
