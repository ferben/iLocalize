//
//  GlossaryScopeAbstractWC.h
//  iLocalize
//
//  Created by Jean Bovet on 1/30/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "AbstractWC.h"

@class GlossaryScope;
@class TreeNode;

@interface GlossaryScopeAbstractWC : AbstractWC {
    IBOutlet NSOutlineView *outlineView;
    IBOutlet NSTextField *titleTextField;
    IBOutlet NSButton *cancelButton;
    TreeNode *rootNode;
}

@property (weak) GlossaryScope *scope;

- (void)setTitle:(NSString*)string;
- (void)setCancellable:(BOOL)flag;

@end
