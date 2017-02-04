//
//  OperationWindowController.h
//  iLocalize
//
//  Created by Jean Bovet on 4/1/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@class OperationViewController;

@interface OperationWindowController : NSWindowController
{
    IBOutlet NSBox           *box;
    NSSize                    originalContentMaxSize;
    OperationViewController  *viewController;
}

@property (strong) OperationViewController *viewController;

- (void)viewControllerStateChanged:(OperationViewController *)_vc;
- (void)runModalSheetForWindow:(NSWindow *)parent;
- (IBAction)done:(id)sender;

@end
