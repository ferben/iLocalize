//
//  AddCustomLanguageWC.h
//  iLocalize3
//
//  Created by Jean on 7/29/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "AbstractWC.h"

@interface AddCustomLanguageWC : AbstractWC {
    IBOutlet NSTextField    *mNameField;
    IBOutlet NSButton *mOKButton;
}
- (void)setRenameLanguage:(BOOL)flag;
- (NSString*)language;
- (IBAction)cancel:(id)sender;
- (IBAction)add:(id)sender;
@end
