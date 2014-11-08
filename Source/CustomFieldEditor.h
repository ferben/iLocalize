//
//  CustomFieldEditor.h
//  iLocalize3
//
//  Created by Jean on 16.12.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"

@interface CustomFieldEditor : NSTextView

@property (nonatomic, weak) id<ProjectProvider> provider;

- (void)setShowInvisibleCharacters:(BOOL)flag;

@end
