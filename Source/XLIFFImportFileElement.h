//
//  XLIFFImportElement.h
//  iLocalize
//
//  Created by Jean Bovet on 4/21/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "AZListSelectionView.h"

@class FileController;

/**
 File to import.
 */
@interface XLIFFImportFileElement : NSObject<AZListSelectionViewItem>
{
    BOOL             selected;
    FileController  *fc;
    
    // Array of XLIFFImportStringElement
    NSArray         *stringElements;
}

@property BOOL selected;
@property (strong) FileController *fc;
@property (strong) NSArray *stringElements;

@end
