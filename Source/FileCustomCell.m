//
//  FileCustomCell.m
//  iLocalize3
//
//  Created by Jean on 03.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FileCustomCell.h"
#import "FileController.h"

#import "ProjectModel.h"
#import "ProjectPrefs.h"

#import "PreferencesGeneral.h"

static NSMutableDictionary    *mTitleAttributes = NULL;
static NSMutableDictionary    *mSmartPathAttributes = NULL;

@implementation FileCustomCell

- (void)checkAttributes
{
    if(mTitleAttributes == NULL) {
        mTitleAttributes = [[NSMutableDictionary alloc] init];
        mTitleAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande" size:13];        

        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByTruncatingTail];
        mTitleAttributes[NSParagraphStyleAttributeName] = style;        
    }
    
    if(mSmartPathAttributes == NULL) {
        mSmartPathAttributes = [[NSMutableDictionary alloc] init];
        
        mSmartPathAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande" size:10];        

        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByTruncatingTail];
        mSmartPathAttributes[NSParagraphStyleAttributeName] = style;        
    }    
}

- (void)drawImage:(NSImage*)image atPoint:(NSPoint)p
{
    [image drawAtPoint:p operation:NSCompositingOperationSourceOver fraction:1];
}

- (void)drawImage:(NSImage*)image atPoint:(NSPoint)p width:(float)width
{
    NSSize size = [image size];
    NSRect dr = NSMakeRect(p.x, p.y, width, size.height);
    [image drawInRect:dr operation:NSCompositingOperationSourceOver fraction:1];
}

- (void)drawBackgroundInRect:(NSRect)r completed:(BOOL)completed
{
    [self drawImage:[NSImage imageNamed:completed?@"PatchLeftGreen":@"PatchLeftRed"] atPoint:NSMakePoint(r.origin.x-5, r.origin.y)];
    [self drawImage:[NSImage imageNamed:completed?@"PatchCenterGreen":@"PatchCenterRed"] atPoint:NSMakePoint(r.origin.x-3, r.origin.y) width:r.size.width+4];
    [self drawImage:[NSImage imageNamed:completed?@"PatchRightGreen":@"PatchRightRed"] atPoint:NSMakePoint(r.origin.x+r.size.width+1, r.origin.y)];
}

- (void)drawFileNameAtPoint:(NSPoint)point size:(NSSize)size cellFrame:(NSRect)cellFrame
{
    NSString *filename = [[self fileController] filename];
    NSAttributedString *p = [[NSAttributedString alloc] initWithString:filename attributes:mTitleAttributes];
    [p drawInRect:NSMakeRect(point.x, point.y, cellFrame.size.width, size.height)];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super drawInteriorWithFrame:cellFrame inView:controlView];

    [NSGraphicsContext saveGraphicsState];
    NSRectClip(cellFrame);
        
    [self checkAttributes];
    
    if([[self fileController] ignore]) {
        mTitleAttributes[NSForegroundColorAttributeName] = [NSColor lightGrayColor];        
        mSmartPathAttributes[NSForegroundColorAttributeName] = [NSColor lightGrayColor];                
    } else {
        if([self isHighlighted]) {
            mTitleAttributes[NSForegroundColorAttributeName] = [NSColor whiteColor];        
            mSmartPathAttributes[NSForegroundColorAttributeName] = [NSColor whiteColor];        
        } else {
            mTitleAttributes[NSForegroundColorAttributeName] = [NSColor blackColor];        
            mSmartPathAttributes[NSForegroundColorAttributeName] = [NSColor blackColor];                
        }        
    }
        
    if([[self fileController] statusSynchToDisk])
        mTitleAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande Bold" size:11];        
    else
        mTitleAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande" size:11];        

    NSString *filename = [[self fileController] filename];
    NSSize size = [filename sizeWithAttributes:mTitleAttributes];
    [self drawFileNameAtPoint:NSMakePoint(cellFrame.origin.x, cellFrame.origin.y) size:size cellFrame:cellFrame];

    [NSGraphicsContext restoreGraphicsState];
}

- (NSArray *)accessibilityAttributeNames
{
    id o = [super accessibilityAttributeNames];
    return [o arrayByAddingObject:NSAccessibilityValueAttribute];    
}

- (id)accessibilityAttributeValue:(NSString *)attribute
{
    id o = [super accessibilityAttributeValue:attribute];    
    if([attribute isEqualToString:NSAccessibilityRoleAttribute]) {
        o = NSAccessibilityTextFieldRole;
    } else if([attribute isEqualToString:NSAccessibilityRoleDescriptionAttribute]) {
        o = NSAccessibilityRoleDescription(NSAccessibilityTextFieldRole, nil);
    } else if([attribute isEqualToString:NSAccessibilityValueAttribute]) {
        o = [[self fileController] filename];
    }
    return o;    
}

@end
