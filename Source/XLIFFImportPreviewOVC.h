//
//  XLIFFImportPreviewOVC.h
//  iLocalize
//
//  Created by Jean Bovet on 3/24/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "OperationViewController.h"
#import "AZListSelectionView.h"

@class XLIFFImportSettings;

/**
 This view allows the user to see which file is going to be updated and
 can deselect the files he doesn't want to be updated.
 */
@interface XLIFFImportPreviewOVC : OperationViewController<NSOutlineViewDelegate> {
    IBOutlet NSOutlineView *outlineView;
    AZListSelectionView *listSelectionView;

    XLIFFImportSettings *settings;
}
@property (strong) XLIFFImportSettings *settings;

@end
