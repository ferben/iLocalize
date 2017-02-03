//
//  NewLanguageItem.h
//  iLocalize3
//
//  Created by Jean on 05.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AZListSelectionView.h"

@interface NewLanguageItem : NSObject<AZListSelectionViewItem> {
    NSString    *mLanguage;
    NSString    *mDisplay;
    BOOL        mIsBaseLanguage;
    BOOL        mImport;
}

+ (id)itemWithLanguage:(NSString*)language;

- (void)setLanguage:(NSString*)language;
- (NSString*)language;

- (void)setIsBaseLanguage:(BOOL)flag;
- (BOOL)isBaseLanguage;

- (void)setImport:(BOOL)flag;
- (BOOL)import;

- (void)setDisplay:(NSString*)display;
- (NSString*)display;

@end
