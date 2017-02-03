//
//  XLIFFImportPreviewOVC.m
//  iLocalize
//
//  Created by Jean Bovet on 3/24/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XLIFFImportPreviewOVC.h"
#import "XLIFFImportSettings.h"
#import "XLIFFImportFileElement.h"
#import "FileController.h"

@implementation XLIFFImportPreviewOVC

@synthesize settings;

- (id)init
{
    if(self = [super initWithNibName:@"XLIFFImportPreview"]) {
        listSelectionView = [[AZListSelectionView alloc] init];
    }
    return self;
}


- (NSString*)nextButtonTitle
{
    return NSLocalizedString(@"Import", nil);
}

- (void)willShow
{
    NSMutableArray *elements = [NSMutableArray array];
    for(XLIFFImportFileElement *fileElement in settings.fileElements) {
        if(fileElement.fc) {
            [elements addObject:fileElement];
        }
    }
    listSelectionView.elements = elements;
    listSelectionView.outlineView = outlineView;
    [listSelectionView reloadData];    
}

- (void)willContinue
{
    self.settings.fileElements = [listSelectionView selectedElements];
}

@end
