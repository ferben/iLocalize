//
//  FileStatusCustomCell.m
//  iLocalize3
//
//  Created by Jean on 04.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FileStatusCustomCell.h"
#import "FileController.h"

@implementation FileStatusCustomCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super drawInteriorWithFrame:cellFrame inView:controlView];
    if([[self fileController] ignore]) return;

    if([[self fileController] displayStatus]) {
        NSImage *image = [[self fileController] statusImage];
        NSSize imageSize = [image size];
        NSPoint p = cellFrame.origin;
        p.x += cellFrame.size.width*0.5-imageSize.width*0.5;
        p.y += cellFrame.size.height*0.5+imageSize.height*0.5;
        
        NSImageInterpolation oldInterpolation = [[NSGraphicsContext currentContext] imageInterpolation];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];

        [image drawInRect:cellFrame fraction:1];
        [[NSGraphicsContext currentContext] setImageInterpolation:oldInterpolation];
        
        [[self fileController] setStatusImageRect:NSMakeRect(p.x - cellFrame.origin.x, p.y - cellFrame.origin.y - imageSize.height,
                                                             imageSize.width, imageSize.height)];
    }
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
        o = [[self fileController] statusDescription];
    }
    return o;    
}

@end
