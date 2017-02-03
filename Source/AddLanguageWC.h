//
//  AddLanguageWC.h
//  iLocalize3
//
//  Created by Jean on 06.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractWC.h"
#import "LanguageMenuProvider.h"

@interface AddLanguageWC : AbstractWC <LanguageMenuProviderDelegate> {
    IBOutlet NSPopUpButton *mLocalePopUpButton;
    IBOutlet NSButton *mFillTranslationButton;
    IBOutlet NSButton *mOKButton;
        
    // The class that populates the popup
    LanguageMenuProvider *languageMenuProvider;
    
    NSString *initialLanguageSelection;
    BOOL mCheckForExistingLanguage;
}

@property (strong) NSString *initialLanguageSelection;

- (void)setCheckForExistingLanguage:(BOOL)flag;
- (void)setRenameLanguage:(BOOL)flag;

- (NSString*)language;

- (IBAction)cancel:(id)sender;
- (IBAction)add:(id)sender;

@end
