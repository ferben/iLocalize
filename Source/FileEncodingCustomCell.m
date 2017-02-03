//
//  FileEncodingCustomCell.m
//  iLocalize3
//
//  Created by Jean on 11/24/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "FileEncodingCustomCell.h"

#import "FileController.h"

static NSMutableDictionary    *mInfoAttributes = NULL;

@implementation FileEncodingCustomCell

- (void)checkAttributes
{
    if(mInfoAttributes == NULL) {
        mInfoAttributes = [[NSMutableDictionary alloc] init];
        mInfoAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande" size:10];        
        
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByTruncatingMiddle];
        mInfoAttributes[NSParagraphStyleAttributeName] = style;        
    }
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super drawInteriorWithFrame:cellFrame inView:controlView];
    if([[self fileController] ignore]) return;
    
    [self checkAttributes];
    
    if([self isHighlighted])
        mInfoAttributes[NSForegroundColorAttributeName] = [NSColor whiteColor];        
    else
        mInfoAttributes[NSForegroundColorAttributeName] = [NSColor blackColor];                
    
    NSString *info = [[self fileController] encodingName];
    NSSize size = [info sizeWithAttributes:mInfoAttributes];
    
    NSAttributedString *p = [[NSAttributedString alloc] initWithString:info attributes:mInfoAttributes];
    [p drawInRect:NSMakeRect(cellFrame.origin.x, cellFrame.origin.y+cellFrame.size.height*0.5-size.height*0.5, cellFrame.size.width, size.height)];
}

@end
