//
//  LabelCustomCellRender.m
//  iLocalize3
//
//  Created by Jean on 12/2/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "LabelCustomCellRender.h"
#import "ProjectLabels.h"
#import "Constants.h"

#define IMAGE_SIZE 14

@implementation LabelCustomCellRender

- (void)awake
{
    mCachedImage = nil;
    mCachedSet = [[NSMutableSet alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self        
                                             selector:@selector(projectLabelsDidChange:)
                                                 name:ILProjectLabelsDidChange
                                               object:nil];            
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)clearCache
{
    mCachedImage = nil;
}

- (void)projectLabelsDidChange:(NSNotification*)notif
{
    [self clearCache];
}

- (NSImage*)labelImageForIndexes:(NSSet*)labelIndexes labels:(ProjectLabels*)labels
{
    if(![mCachedSet isEqualToSet:labelIndexes]) {
        mCachedImage = nil;
    }
    
    if(!mCachedImage && [labelIndexes count] > 0) {
        [mCachedSet setSet:labelIndexes];
        
        mCachedImage = [[NSImage alloc] initWithSize:NSMakeSize(IMAGE_SIZE*[labelIndexes count], IMAGE_SIZE)];
        [mCachedImage lockFocus];
        
        NSNumber *index;
        int imageWidth = 0;
        for(index in labelIndexes) {        
            NSImage *image = [labels createLabelImageForLabelIndex:[index intValue]];
            [image drawInRect:NSMakeRect(imageWidth, 0, image.size.width, IMAGE_SIZE) fraction:1];
            imageWidth += [image size].width;
        }
        
        [mCachedImage unlockFocus];
    }
    return mCachedImage;        
}

- (void)drawLabelCellWithFrame:(NSRect)cellFrame indexes:(NSSet*)labelIndexes labels:(ProjectLabels*)labels
{
    NSImage *image = [self labelImageForIndexes:labelIndexes labels:labels];
    if(image == nil)
        return;
    
    NSSize size = [image size];
    
    NSPoint p = cellFrame.origin;
    p.x += cellFrame.size.width*0.5-size.width*0.5;
    p.y += cellFrame.size.height*0.5+size.height*0.5;
    
    // For some reason we need to disable the interpolation otherwise the
    // file icons are a bit blurry.
    NSImageInterpolation oldInterpolation = [[NSGraphicsContext currentContext] imageInterpolation];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];

    [image drawInRect:cellFrame fraction:1];
    
    [[NSGraphicsContext currentContext] setImageInterpolation:oldInterpolation];
}

@end
