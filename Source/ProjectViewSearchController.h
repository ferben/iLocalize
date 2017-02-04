//
//  ProjectViewSearchController.h
//  iLocalize
//
//  Created by Jean on 1/18/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

@class ProjectWC;
@class ExplorerFilter;
@class SearchContext;

@interface ProjectViewSearchController : NSViewController<NSTextFieldDelegate>
{
    IBOutlet NSTextField  *replaceTextField;
    IBOutlet NSButton     *replaceButton;
    IBOutlet NSButton     *replaceAllButton;
    
    IBOutlet NSButton     *scopeFilesButton;
    IBOutlet NSButton     *scopeKeyButton;
    IBOutlet NSButton     *scopeStringsBaseButton;
    IBOutlet NSButton     *scopeStringsTranslationButton;
    IBOutlet NSButton     *scopeCommentsBaseButton;
    IBOutlet NSButton     *scopeCommentsTranslationButton;
    
    SearchContext         *context;
}

@property (assign) ProjectWC *projectWC;
@property (strong) SearchContext *context;

+ (ProjectViewSearchController *)newInstance:(ProjectWC *)projectWC;

- (void)updateInterface;

- (CGFloat)viewHeight;

- (NSString *)replaceString;

- (IBAction)contextChanged:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)replace:(id)sender;
- (IBAction)replaceAll:(id)sender;

@end
