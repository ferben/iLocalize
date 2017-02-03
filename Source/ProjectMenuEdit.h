//
//  ProjectMenuEdit.h
//  iLocalize
//
//  Created by Jean on 1/8/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "ProjectMenu.h"

@class ProjectViewSearchController;
@class StringEncoding;

@interface ProjectMenuEdit : ProjectMenu {
    StringEncoding*                    mWillConvertUsingEncoding;
    BOOL                            mWillConvertUsingReload;
}

- (IBAction)smartQuoteSubstitution:(id)sender;
- (IBAction)lockString:(id)sender;

- (IBAction)fileEncodingMenuAction:(id)sender;

- (IBAction)searchProject:(id)sender;
- (IBAction)search:(id)sender;

@end
