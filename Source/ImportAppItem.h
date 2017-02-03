//
//  ImportAppItem.h
//  iLocalize3
//
//  Created by Jean on 12.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AZListSelectionView.h"

@interface ImportAppItem : NSObject<AZListSelectionViewItem> {
    NSString    *mLanguage;
    BOOL        mImport;
}

+ (id)itemWithLanguage:(NSString*)language;

- (NSString*)language;
- (NSString*)displayLanguage;

- (void)setImport:(BOOL)flag;
- (BOOL)import;

@end
