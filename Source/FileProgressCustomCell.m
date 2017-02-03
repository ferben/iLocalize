//
//  FileProgressCustomCell.m
//  iLocalize3
//
//  Created by Jean on 9/23/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "FileProgressCustomCell.h"
#import "FileController.h"

@implementation FileProgressCustomCell

static NSMutableDictionary    *mInfoAttributes = NULL;

- (void)checkAttributes
{
    if(mInfoAttributes == NULL) {
        mInfoAttributes = [[NSMutableDictionary alloc] init];
        mInfoAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande" size:10];        
    }
}

- (void)drawProgressTranslated:(float)translated autoTranslated:(float)autotranslated toTranslate:(float)totranslate inRect:(NSRect)rect
{    
    float greenWidth = rect.size.width*translated;
    float redWidth = rect.size.width*autotranslated;
    float blackWidth = rect.size.width*totranslate;
    
    if(greenWidth > 0) {
        NSImage *greenImage = [NSImage imageNamed:@"progress_green"];
        [greenImage drawInRect:NSMakeRect(rect.origin.x, rect.origin.y, greenWidth, rect.size.height) operation:NSCompositeSourceOver fraction:1];        
    }
    
    if(redWidth > 0) {
        NSImage *redImage = [NSImage imageNamed:@"progress_red"];
        [redImage drawInRect:NSMakeRect(rect.origin.x+greenWidth, rect.origin.y, redWidth, rect.size.height) operation:NSCompositeSourceOver fraction:1];
    }
    
    if(blackWidth > 0) {
        NSImage *redImage = [NSImage imageNamed:@"progress_gray"];
        [redImage drawInRect:NSMakeRect(rect.origin.x+greenWidth+redWidth, rect.origin.y, blackWidth, rect.size.height) operation:NSCompositeSourceOver fraction:1];
    }
}

- (NSString*)localizedDoneText
{
    return NSLocalizedString(@"Done", nil);
}

- (float)maximumTextWidth
{
    float a = [@"99%%" sizeWithAttributes:mInfoAttributes].width;
    float b = [[self localizedDoneText] sizeWithAttributes:mInfoAttributes].width;
    return MAX(a, b);
}

- (NSString*)progressInfo
{
    float v = [[self fileController] percentCompleted];
    if(v == 100) {
        return [self localizedDoneText];
    } else {
        return [NSString stringWithFormat:@"%2.0f%%", v>=99.5?99:v];
    }        
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super drawInteriorWithFrame:cellFrame inView:controlView];
    if([[self fileController] ignore]) return;

    [self checkAttributes];

    FileController *controller = [self fileController];
    if([controller displayProgress]) {
        float pvalue = [controller percentCompleted];
        NSString *progressInfo = [self progressInfo];
        if(pvalue == 100) {
            NSSize progressInfoSize = NSMakeSize([self maximumTextWidth], [progressInfo sizeWithAttributes:mInfoAttributes].height);
            NSPoint p = NSMakePoint(cellFrame.origin.x, cellFrame.origin.y+cellFrame.size.height*0.5-progressInfoSize.height*0.5);
            [progressInfo drawAtPoint:p withAttributes:mInfoAttributes];
        } else {
            NSSize progressInfoSize = NSMakeSize([self maximumTextWidth], [progressInfo sizeWithAttributes:mInfoAttributes].height);
                    
            int progressHeight = 12; // 16
            
            NSRect progressRect = cellFrame;
            progressRect.origin.y = cellFrame.origin.y + (cellFrame.size.height - progressHeight) * 0.5;
            progressRect.size.height = progressHeight;
            progressRect.size.width -= progressInfoSize.width + 5;            

            [self drawProgressTranslated:[controller percentTranslated]*0.01
                          autoTranslated:[controller percentAutoTranslated]*0.01
                             toTranslate:[controller percentToTranslate]*0.01
                                  inRect:progressRect];            

            NSPoint p = NSMakePoint(cellFrame.origin.x+cellFrame.size.width-progressInfoSize.width-2, cellFrame.origin.y+cellFrame.size.height*0.5-progressInfoSize.height*0.5);
            [progressInfo drawAtPoint:p withAttributes:mInfoAttributes];
        }                        
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
        o = [self progressInfo];
    }
    return o;    
}

@end
