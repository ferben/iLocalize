//
//  OperationDriverWC.h
//  iLocalize
//
//  Created by Jean Bovet on 2/12/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "AbstractWC.h"
#import "OperationDriver.h"

@class OperationViewController;
@class OperationDriver;

/**
 This class manages the window that will display each operation
 view. It resizes and hide the controls depending on the need of
 the operation driver.
 */
@interface OperationDriverWC : AbstractWC
{
    IBOutlet NSTextField              *titleField;
    IBOutlet NSBox                    *box;
    IBOutlet NSButton                 *cancelButton;
    IBOutlet NSButton                 *goBackButton;
    IBOutlet NSButton                 *nextButton;
    
    OperationViewController           *vc;
    OperationCompletionCallbackBlock   callback;
    BOOL showControls;
    
    /**
     Flag set by the operation driver if the go back button can be enabled.
     If it can be enabled, the operation driver will ask the operation view controller
     if it wants to go back and set the button state appropriately.
     */
    BOOL                               canGoBack;
    
    /**
     The origin of the box. It is used to stretch the box to fit the whole
     window then the controls are hidden and to restore it.
     */
    CGFloat                            boxOriginY;
    CGFloat                            controlsHeight;
    
    /**
     Original min size of the window. It is used when the controls are hidden.
     */
    NSSize                             originalMinSize;
    
    // True if the assistant view is already in place
    BOOL                               assistantInPlace;
}

/**
 Specifies if the controls (Cancel, Go Back and Next) should be visible.
 Usually progress operation won't show these buttons as the progress view
 controller already has the cancel button.
 */
@property BOOL showControls;

@property (weak) OperationDriver *driver;
@property (strong) OperationViewController *vc;
@property (copy) OperationCompletionCallbackBlock callback;

/**
 Specifies if the Go Back button is enabled or not.
 */
- (void)setCanGoBack:(BOOL)flag;

/**
 Shows the window with the corresponding view controller. The callback is used to indicate that the user has clicked (cancel, go back or next).
 */
- (void)show:(OperationViewController *)vc callback:(OperationCompletionCallbackBlock)callback;

/**
 This method is invoked by the OperationViewController when its state changed.
 */
- (void)viewControllerStateChanged:(OperationViewController *)vc;

/**
 Returns the first visible window. Either the operation driver window if visible, otherwise its
 parent which is likely to be the project window itself.
 */
- (NSWindow*)visibleWindow;

- (IBAction)operationCancel:(id)sender;
- (IBAction)operationGoBack:(id)sender;
- (IBAction)operationNext:(id)sender;

@end
