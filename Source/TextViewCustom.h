//
//  TextViewCustom.h
//  iLocalize3
//
//  Created by Jean on 06.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "TextViewCustomDelegate.h"

@interface TextViewCustom : NSTextView {
    id <TextViewCustomDelegate> mCustomDelegate;
    NSString *language;
    BOOL drawBorder;
}

/**
 The language in which this text view is editing.
 */
@property (strong) NSString *language;

/**
 YES to draw a black border around the text view.
 */
@property BOOL drawBorder;

- (void)setCustomDelegate:(id<TextViewCustomDelegate>)delegate;
- (void)setShowInvisibleCharacters:(BOOL)flag;

@end
