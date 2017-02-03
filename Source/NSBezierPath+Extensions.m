//
//  NSBezierPath+Extensions.m
//  iLocalize3
//
//  Created by Jean on 08.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "NSBezierPath+Extensions.h"

@implementation NSBezierPath (iLocalize)

+ (void)fillRoundRect:(NSRect)rect radius:(float)radius
{
    float x0 = rect.origin.x;
    float y0 = rect.origin.y;
    float x1 = rect.origin.x+rect.size.width;
    float y1 = rect.origin.y+rect.size.height;
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(x0+radius, y0)];
    [path lineToPoint:NSMakePoint(x1-radius, y0)];
    [path curveToPoint:NSMakePoint(x1, y0+radius) controlPoint1:NSMakePoint(x1, y0) controlPoint2:NSMakePoint(x1, y0)];
    [path lineToPoint:NSMakePoint(x1, y1-radius)];
    [path curveToPoint:NSMakePoint(x1-radius, y1) controlPoint1:NSMakePoint(x1, y1) controlPoint2:NSMakePoint(x1, y1)];
    [path lineToPoint:NSMakePoint(x0+radius, y1)];
    [path curveToPoint:NSMakePoint(x0, y1-radius) controlPoint1:NSMakePoint(x0, y1) controlPoint2:NSMakePoint(x0, y1)];
    [path lineToPoint:NSMakePoint(x0, y0+radius)];
    [path curveToPoint:NSMakePoint(x0+radius, y0) controlPoint1:NSMakePoint(x0, y0) controlPoint2:NSMakePoint(x0, y0)];
    [path closePath];
    [path fill];    
}
    
@end
