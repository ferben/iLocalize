//
//  ProjectLabels.h
//  iLocalize
//
//  Created by Jean on 12/20/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

@class ProjectWC;

@interface ProjectLabels : NSObject
{
}

+ (NSMutableArray *)defaultLabels;

+ (NSImage *)createLabelImageForColor:(int)color identifier:(NSString *)identifier;

+ (void)updateLabelsMenuForCurrentSelection:(NSMenu *)menu controllers:(NSArray *)controllers;
+ (void)labelContextMenuAction:(id)sender controllers:(NSArray *)controllers;

@property (nonatomic, assign) ProjectWC *projectWC;

- (void)buildLabelColorsMenu:(NSMenu *)menu;
- (void)buildLabelsMenu:(NSMenu *)menu target:(id)target action:(SEL)action;
- (NSImage *)createLabelImageForLabelIndex:(int)index;

- (int)labelIndexForIdentifier:(NSString *)identifier;
- (NSString *)labelIdentifierForIndex:(int)index;

- (NSMutableArray *)labels;

- (NSMenu *)fileLabelsMenu;

@end
