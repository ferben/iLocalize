//
//  FMEditorRTF.h
//  iLocalize3
//
//  Created by Jean on 27.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEditor.h"

@class TextViewCustom;

@interface FMEditorRTF : FMEditor {    
    IBOutlet TextViewCustom                *mBaseBaseTextView;
    IBOutlet TextViewCustom                *mLocalizedBaseTextView;
    IBOutlet TextViewCustom                *mLocalizedTranslationTextView;
}

@end
