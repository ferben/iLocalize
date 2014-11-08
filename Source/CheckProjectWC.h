//
//  CheckProjectWC.h
//  iLocalize3
//
//  Created by Jean on 5/28/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "AbstractWC.h"
#import "AZListSelectionView.h"

@interface CheckProjectWC : AbstractWC<AZListSelectionViewDelegate> {
	IBOutlet NSOutlineView *outlineView;
	IBOutlet NSButton *checkButton;
	AZListSelectionView *selectionView;
}
- (NSArray*)checkLanguages;
- (IBAction)cancel:(id)sender;
- (IBAction)check:(id)sender;
@end
