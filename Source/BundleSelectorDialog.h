//
//  BundleSelectorDialog.h
//  iLocalize
//
//  Created by Jean on 3/29/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

@class BundleSelectorDialog;

typedef void(^CallbackBlockWithFile)(NSString *);

@interface BundleSelectorDialog : NSObject<NSOpenSavePanelDelegate>
{
    NSString               *defaultPath;
    CallbackBlockWithFile   callback;
}

@property (copy) NSString *defaultPath;
@property (copy) CallbackBlockWithFile callback;

- (NSString *)promptForBundle;
- (void)promptForBundleForWindow:(NSWindow *)window callback:(CallbackBlockWithFile)callback;

@end
