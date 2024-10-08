//
//  ProjectLabels.m
//  iLocalize
//
//  Created by Jean on 12/20/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectLabels.h"
#import "ProjectPrefs.h"
#import "ProjectWC.h"
#import "ProjectLabelsWC.h"
#import "ProjectLabelsProtocol.h"
#import "ProjectDocument.h"
#import "StringController.h"

#define WHITE_COLOR   0
#define BLACK_COLOR   1
#define GREEN_COLOR   2
#define RED_COLOR     3
#define BLUE_COLOR    4
#define ORANGE_COLOR  5
#define PURPLE_COLOR  6
#define YELLOW_COLOR  7

#define MAX_COLOR     8

static NSString *KEY_ID = @"ID";
static NSString *KEY_DESCRIPTION = @"Description";
static NSString *KEY_COLOR = @"Color";

static NSString *COLOR_IMAGE_NAMES[] = { @"label_white", @"label_black", @"label_green", @"label_red", @"label_blue", @"label_orange", @"label_purple", @"label_yellow" };

@implementation ProjectLabels

+ (NSMutableDictionary *)createLabelWithID:(NSString *)identifier description:(NSString *)description color:(int)color
{
    return [NSMutableDictionary dictionaryWithObjects:@[identifier, description, @(color)]
                                              forKeys:@[KEY_ID, KEY_DESCRIPTION, KEY_COLOR]];    
}

+ (NSMutableArray *)defaultLabels
{
    NSMutableArray *labels = [NSMutableArray array];
    
    [labels addObject:[ProjectLabels createLabelWithID:@"T" description:NSLocalizedString(@"In Translation", @"Label") color:BLACK_COLOR]];
    [labels addObject:[ProjectLabels createLabelWithID:@"R" description:NSLocalizedString(@"For Review", @"Label") color:RED_COLOR]];
    [labels addObject:[ProjectLabels createLabelWithID:@"A" description:NSLocalizedString(@"Approved", @"Label") color:GREEN_COLOR]];
    
    return labels;
}

+ (NSString *)labelImageColorNameForColorIndex:(int)color
{
    return COLOR_IMAGE_NAMES[color];
}

+ (NSColor *)labelTextColorForLabelImageColor:(int)color
{
    switch (color)
    {
        case WHITE_COLOR:  return [NSColor blackColor];
        case BLACK_COLOR:  return [NSColor whiteColor];
        case GREEN_COLOR:  return [NSColor whiteColor];
        case RED_COLOR:    return [NSColor whiteColor];
        case BLUE_COLOR:   return [NSColor whiteColor];
        case ORANGE_COLOR: return [NSColor blackColor];
        case PURPLE_COLOR: return [NSColor blackColor];
        case YELLOW_COLOR: return [NSColor blackColor];
    }
    
    return [NSColor blackColor];
}

static NSMutableDictionary *labelAttributes = nil;

+ (NSImage *)createLabelImageForColor:(int)color identifier:(NSString *)identifier
{
    // Prepare the identifier text to be displayed
    if (labelAttributes == nil)
    {
        labelAttributes = [[NSMutableDictionary alloc] init];
        labelAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande" size:10];        
    }    
    
    labelAttributes[NSForegroundColorAttributeName] = [ProjectLabels labelTextColorForLabelImageColor:color];
    
    NSSize size = [identifier sizeWithAttributes:labelAttributes];    
    
    NSImage *image = [NSImage imageNamed:[ProjectLabels labelImageColorNameForColorIndex:color]];
    NSSize imageSize = [image size];
    
    int imageWidth = MAX(imageSize.width, size.width+8);
    
    // Create the image
    NSImage *labelImage = [[NSImage alloc] initWithSize:NSMakeSize(imageWidth, 14)];
    [labelImage lockFocus];
    
    // Draw the label by stretching it if needed to accomodate the label width
    NSPoint p = NSZeroPoint;
    [image drawInRect:NSMakeRect(p.x, p.y, imageWidth, imageSize.height) operation:NSCompositeCopy fraction:1];
    
    // Draw the label
    p.x += imageWidth * 0.5 - size.width * 0.5 + 1;
    [identifier drawAtPoint:p withAttributes:labelAttributes];    
    
    [labelImage unlockFocus];
    return labelImage;
}

+ (NSMenuItem *)createMenuItemForColor:(int)color
{
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    [item setImage:[NSImage imageNamed:[ProjectLabels labelImageColorNameForColorIndex:color]]];
    
    return item;
}

+ (NSMenuItem *)createMenuItemForColor:(int)color identifier:(NSString *)identifier description:(NSString *)description
{
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:description action:@selector(labelContextMenuAction:) keyEquivalent:@""];
    
    [item setTarget:self];
    [item setState:NSControlStateValueOff];
    [item setImage:[ProjectLabels createLabelImageForColor:color identifier:identifier]];
    
    return item;
}

+ (void)updateLabelsMenuForCurrentSelection:(NSMenu *)menu controllers:(NSArray *)controllers
{
    NSMutableSet *labelsSet = [[NSMutableSet alloc] init];
    
    NSMutableDictionary *countDic = [NSMutableDictionary dictionary];
    NSUInteger total = [controllers count];
    
    for (StringController *sc in controllers)
    {
        for (NSNumber *index in [sc labelIndexes])
        {
            [labelsSet addObject:index];            
            NSNumber *count = countDic[index];
            
            if (count == nil)
                count = @0;
            
            countDic[index] = @([count intValue]+1);            
        }
    }
    
    for (NSNumber *index in labelsSet)
    {
        BOOL partial = [countDic[index] intValue] < total;
        [[menu itemAtIndex:[index intValue]] setState:partial?NSControlStateValueMixed:NSControlStateValueOn];        
    }
    
}

+ (void)labelContextMenuAction:(id)sender controllers:(NSArray *)controllers
{
    int state = [sender state] == NSControlStateValueOn?NSControlStateValueOff:NSControlStateValueOn;
    [sender setState:state];
    
    NSNumber *index = [NSNumber numberWithInteger:[sender tag]];
    
    for (id<ProjectLabelPersistent> c in controllers)
    {
        NSMutableSet *set = [[NSMutableSet alloc] initWithSet:[c labelIndexes]];
    
        if (state == NSControlStateValueOn)
            [set addObject:index];
        else
            [set removeObject:index];

        [c setLabelIndexes:set];
    }
}

#pragma mark -

- (void)buildLabelColorsMenu:(NSMenu *)menu
{
    [menu removeAllItems];
    
    for (int c = 0; c < MAX_COLOR; c++)
    {
        [menu addItem:[ProjectLabels createMenuItemForColor:c]];
    }
}

- (void)buildLabelsMenu:(NSMenu *)menu target:(id)target action:(SEL)action
{
    unsigned index = 0;
    
    for (NSDictionary *label in [self labels])
    {
        NSMenuItem *item = [ProjectLabels createMenuItemForColor:[label[KEY_COLOR] intValue]
                                                      identifier:label[KEY_ID] 
                                                     description:label[KEY_DESCRIPTION]];
        [item setTarget:target];
        [item setAction:action];
        [item setTag:index++];
        [menu addItem:item];            
    }
}

- (NSImage *)createLabelImageForLabelIndex:(int)index
{
    NSDictionary *label = [self labels][index];
    
    return [ProjectLabels createLabelImageForColor:[label[KEY_COLOR] intValue]
                                        identifier:label[KEY_ID]];
}

- (int)labelIndexForIdentifier:(NSString *)identifier
{
    unsigned index = 0;
    
    for (NSDictionary *label in [self labels])
    {
        if ([label[KEY_ID] isEqualToString:identifier])
            return index;
        
        index++;        
    }
    
    return -1;
}

- (NSString *)labelIdentifierForIndex:(int)index
{
    NSMutableArray *labels = [self labels];
    
    if (index < [labels count])
    {
        return labels[index][KEY_ID];        
    }
    else
    {
        return nil;
    }
}

- (NSArray *)labels
{
    return [[self.projectWC projectPreferences] labels];
}

- (NSMenu *)fileLabelsMenu
{
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Labels"];
    [self buildLabelsMenu:menu target:self action:@selector(labelContextMenuAction:)];
    [ProjectLabels updateLabelsMenuForCurrentSelection:menu controllers:[self.projectWC selectedFileControllers]];
    
    return menu;
}

- (IBAction)labelContextMenuAction:(id)sender
{
    [ProjectLabels labelContextMenuAction:sender controllers:[self.projectWC selectedFileControllers]];
    [[self.projectWC projectDocument] setDirty];
}

@end
