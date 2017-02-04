//
//  WindowLayerView.h
//  iLocalize3
//
//  Created by Jean on 08.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@interface WindowLayerView : NSView
{
    NSString  *mTitle;
    NSString  *mInfo;
}

- (void)setTitle:(NSString *)title;
- (void)setInfo:(NSString *)info;

@end
