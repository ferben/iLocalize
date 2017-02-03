//
//  FileContentCustomCell.m
//  iLocalize3
//
//  Created by Jean on 11.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FileContentCustomCell.h"
#import "FileController.h"
#import "ProjectWC.h"

static NSMutableDictionary    *mInfoAttributes = NULL;

@implementation FileContentCustomCell

- (void)checkAttributes
{
    if(mInfoAttributes == NULL) {
        mInfoAttributes = [[NSMutableDictionary alloc] init];
        mInfoAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande" size:10];        
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
        
    NSString *info = [[self fileController] contentInfo];
    if([[self fileController] isUsed] && [self isHighlighted] && [[[self projectWC] selectedFileControllers] count] > 1) {
        info = [[NSString stringWithFormat:@" %C", (unichar)0x2712] stringByAppendingString:info];
    }
    NSSize size = [info sizeWithAttributes:mInfoAttributes];
    NSPoint p = NSMakePoint(cellFrame.origin.x+2, cellFrame.origin.y+cellFrame.size.height*0.5-size.height*0.5);
    [info drawAtPoint:p withAttributes:mInfoAttributes];                
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
        o = [[self fileController] contentInfo];
    }
    return o;    
}

@end
