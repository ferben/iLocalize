//
//  StringStatusCustomCell.m
//  iLocalize3
//
//  Created by Jean on 04.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "StringStatusCustomCell.h"
#import "StringController.h"

@implementation StringStatusCustomCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super drawInteriorWithFrame:cellFrame inView:controlView];
    
    NSImage *image = [[self stringController] statusImage];
    NSSize imageSize = [image size];
    NSPoint p = cellFrame.origin;
    p.x += (int)(cellFrame.size.width*0.5-imageSize.width*0.5);
    p.y += (int)(cellFrame.size.height*0.5+imageSize.height*0.5);
    
    [image drawInRect:cellFrame fraction:1];

    [[self stringController] setStatusImageRect:NSMakeRect(p.x - cellFrame.origin.x, p.y - cellFrame.origin.y - imageSize.height,
                                                         imageSize.width, imageSize.height)];

}

- (NSArray *)accessibilityAttributeNames
{
    id o = [super accessibilityAttributeNames];
    // add value attribute to describe the status
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
        // return the description of the status
        o = [[self stringController] statusDescription];
    }
    
    return o;    
}

@end
