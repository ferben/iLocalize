//
//  LanguageMenuProvider.h
//  iLocalize
//
//  Created by Jean Bovet on 2/24/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@protocol LanguageMenuProviderDelegate
- (BOOL)enableMenuItemForLanguage:(NSString*)language;
@end

/**
 Create one instance of this class per popup to manage.
 */
@interface LanguageMenuProvider : NSObject {
    // Array containing all the selected languages during this session
    NSMutableArray *mSelectedLanguages;

    // Map from displayed language name to language info class
    NSMutableDictionary *mDisplayLanguageToInfo;

    // Array of common used languages
    NSMutableArray *mCommonLanguages;
    
    // Array of available languages as provided by the system
    NSMutableDictionary *mLanguages;    
}

@property (weak) NSPopUpButton *popupButton;

// The target instance for the menu item
@property (weak) id actionTarget;

// The delegate
@property (weak) id<LanguageMenuProviderDelegate> delegate;

- (void)refreshPopUp;

- (void)selectLanguage:(NSString*)language;
- (void)selectCurrentLanguage;

- (NSString*)selectedLanguage;

@end
