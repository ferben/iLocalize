//
//  AZLevelIndicatorCell.m
//  iLocalize
//
//  Created by Jean Bovet on 5/18/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "AZLevelIndicatorCell.h"


@implementation AZLevelIndicatorCell

- (id) init
{
    self = [super initTextCell:@""];
    if (self != nil) {
    }
    return self;
}

- (double)levelValue
{
    return [self doubleValue];
}

- (NSString*)levelString
{
    return [NSString stringWithFormat:@"%2.0f%%", [self levelValue]];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSImage *image;
    
    double value = [self levelValue];
    if(value >= 100) {
        image = [NSImage imageNamed:@"level_green"];
    } else if(value >= 34 && value < 100) {
        image = [NSImage imageNamed:@"level_orange"];        
    } else {
        image = [NSImage imageNamed:@"level_gray"];
    }

    NSRect r = NSInsetRect(cellFrame, 0, 1);
    r.size.width = r.size.width * value / 100;
    int barWidth = 3;
    for(CGFloat x=r.origin.x; x<r.origin.x+r.size.width; x+=barWidth) {
        NSRect ir = NSMakeRect(x, r.origin.y, barWidth-1, r.size.height);
        ir.size.width = MIN(ir.size.width, r.origin.x+r.size.width - x);
        [image drawInRect:ir operation:NSCompositingOperationSourceOver fraction:1];
    }
    //[image drawInRect:r operation:NSCompositingOperationSourceOver fraction:1];
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
        o = [self levelString];
    }
    return o;    
}

@end
