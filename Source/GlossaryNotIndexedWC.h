//
//  GlossaryNotIndexed.h
//  iLocalize3
//
//  Created by Jean on 09.07.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@interface GlossaryNotIndexedWC : NSWindowController {
    IBOutlet NSPopUpButton    *mActionPopUp;
    IBOutlet NSPopUpButton    *mPathPopUp;
    
    NSString    *mGlossaryPath;
    NSArray        *mPaths;
    BOOL        mLocalPathExists;
    NSString    *targetPath;
    
    CallbackBlock didCloseCallback;
}

@property (copy) CallbackBlock didCloseCallback;
@property (strong) NSString *targetPath;

- (void)setGlossaryPath:(NSString*)glossaryPath;;
- (void)showWithParent:(NSWindow*)parent;

- (IBAction)cancel:(id)sender;
- (IBAction)ok:(id)sender;

@end
