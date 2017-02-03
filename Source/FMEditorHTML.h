//
//  FMEditorHTML.h
//  iLocalize3
//
//  Created by Jean on 28.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEditor.h"
#import <WebKit/WebView.h>
#import <WebKit/WebFrame.h>

@interface FMEditorHTML : FMEditor {
    IBOutlet NSTextView                *mBaseBaseTextView;
    IBOutlet NSTextView                *mLocalizedBaseTextView;
    IBOutlet NSTextView                *mLocalizedTranslationTextView;    
    
    IBOutlet WebView                *mBaseBaseWebView;
    IBOutlet WebView                *mLocalizedBaseWebView;
    IBOutlet WebView                *mLocalizedTranslationWebView;
    
    BOOL mReloadBasePreview;
    BOOL mReloadLocalizedPreview;
}
- (IBAction)back:(id)sender;
- (IBAction)forward:(id)sender;
- (IBAction)makeLarger:(id)sender;
- (IBAction)makeSmaller:(id)sender;
@end
