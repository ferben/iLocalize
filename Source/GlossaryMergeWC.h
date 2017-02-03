//
//  GlossaryMergeWC.h
//  iLocalize3
//
//  Created by Jean on 26.12.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@interface GlossaryMergeWC : NSWindowController {
    IBOutlet NSArrayController  *mMergeController;
    IBOutlet NSPopUpButton      *mMergeDestPopUp;    
    IBOutlet NSButton            *mRemoveDuplicateEntriesButton;
}
- (void)setGlossaries:(NSArray*)glossaries;
- (void)showWithParent:(NSWindow*)parent;
- (IBAction)cancel:(id)sender;
- (IBAction)merge:(id)sender;
@end
