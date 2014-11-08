//
//  AZPathControl.h
//  iLocalize
//
//  Created by Jean on 2/18/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "AZGradientView.h"

@class AZPathControl;

@protocol AZPathControlDelegate
- (void)pathChanged:(AZPathControl*)control;
- (BOOL)isValidPath:(NSString*)path;
@end

@interface AZPathControl : AZGradientView<NSMenuDelegate> {
	NSString *_basePath;
	NSMutableArray *components;
	NSMutableArray *elements;
	id<AZPathControlDelegate> delegate;
}

@property (strong) NSString *basePath;

- (void)setPath:(NSString*)path;
- (NSString*)selectedPath;

- (void)setDelegate:(id<AZPathControlDelegate>)delegate;

@end
