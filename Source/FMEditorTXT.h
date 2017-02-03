//
//  FMEditorTXT.h
//  iLocalize3
//
//  Created by Jean on 28.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEditor.h"

@class TextViewCustom;

@interface FMEditorTXT : FMEditor {
    IBOutlet TextViewCustom                *mBaseBaseTextView;
    IBOutlet TextViewCustom                *mLocalizedBaseTextView;
    IBOutlet TextViewCustom                *mLocalizedTranslationTextView;    
}

@end
