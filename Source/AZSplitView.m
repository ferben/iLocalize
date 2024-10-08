//
//  AZSplitView.m
//  iLocalize
//
//  Created by Jean on 12/27/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "AZSplitView.h"
#import <Quartz/Quartz.h>

@interface AZImageView : NSView
{
    NSImage *image;
}
@property (strong) NSImage *image;
@end

@implementation AZImageView

@synthesize image;

- (void)drawRect:(NSRect)dirtyRect
{
    NSEraseRect(self.frame);
    [image drawAtPoint:NSMakePoint(0, self.frame.size.height-image.size.height) operation:NSCompositingOperationCopy fraction:1];
}

@end

// --------------------------------------------------------------------------

@interface AZAnimationRequest : NSObject
{
    BOOL collapse;
    BOOL animation;
    CallbackBlock completionBlock;
}
@property BOOL collapse;
@property BOOL animation;
// block called after completion of the collapse (with or without animation)
@property (copy) CallbackBlock completionBlock;
@end

@implementation AZAnimationRequest

@synthesize collapse;
@synthesize animation;
@synthesize completionBlock;


@end

// --------------------------------------------------------------------------

@interface AZSplitView (PrivateMethods)
- (void)animationCompleted;
- (void)executeRequest:(AZAnimationRequest*)request;
@end

@implementation AZSplitView

@synthesize title;
@synthesize actionMenu;
@synthesize currentRequest;

static NSString *KEY_TITLE = @"title";

#define ACTION_IMAGE_OFFSET 5

- (id)initWithFrame:(NSRect)frameRect
{
    if(self = [super initWithFrame:frameRect]) {
        self.title = nil;
        requests = [[NSMutableArray alloc] init];                
        [self addObserver:self forKeyPath:KEY_TITLE options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:KEY_TITLE];
}

- (NSImage*)actionImage
{
    return [NSImage imageNamed:NSImageNameActionTemplate];
}

- (void)resetCursorRects
{
    // Make sure to have the resize cursor only when on top of the resize icon
    NSRect thumbRect = dividerRect;
    thumbRect.origin.x = thumbRect.size.width - 20;
    thumbRect.size.width = 20;
    [self addCursorRect:thumbRect cursor:[NSCursor resizeUpDownCursor]];
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint event_location = [theEvent locationInWindow];
    NSPoint local_point = [self convertPoint:event_location fromView:nil];

    if(local_point.x >= self.frame.size.width - 20) {
        [super mouseDown:theEvent];        
    } else if(local_point.x <= [self actionImage].size.width+ACTION_IMAGE_OFFSET) {
        [self.actionMenu popUpMenuPositioningItem:nil atLocation:local_point inView:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:KEY_TITLE]) {
        [self setNeedsDisplay:YES];
    }
}

- (CGFloat)dividerThickness
{
    return 18;
}

- (CGFloat)bottomExpandedHeight
{
    return [self frame].size.height - mPreviousPosition - [self dividerThickness];
}

- (void)drawDividerInRect:(NSRect)rect
{
    dividerRect = rect;

    NSImage *startCap = [NSImage imageNamed:@"vertical-divider.png"];
    NSImage *centerFill = [NSImage imageNamed:@"vertical-divider.png"];
    NSImage *endCap = [NSImage imageNamed:@"vertical-divider.png"];
    
    NSDrawThreePartImage(rect, startCap, centerFill, endCap, NO, NSCompositingOperationCopy, 1.0, NO);    
    
    NSImage *thumb = [NSImage imageNamed:@"vertical-thumb.png"];
    NSSize is = [thumb size];
    [thumb drawAtPoint:NSMakePoint(rect.origin.x+rect.size.width-is.width-5, rect.origin.y+(rect.size.height-is.height)/2) operation:NSCompositingOperationSourceOver fraction:1.0];
    
    if(title) {
        NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
        attrs[NSFontAttributeName] = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];        
        NSSize size = [title sizeWithAttributes:attrs];
        [title drawAtPoint:NSMakePoint(rect.origin.x+(rect.size.width-size.width)/2, rect.origin.y+(rect.size.height-size.height)/2) withAttributes:attrs];
    }

    // Draw the action menu
    if(actionMenu) {
        [NSGraphicsContext saveGraphicsState];
        
        NSImage *action = [self actionImage];
        NSSize as = [action size];
        NSPoint point = NSMakePoint(rect.origin.x+ACTION_IMAGE_OFFSET, rect.origin.y+(rect.size.height-as.height)/2);
        
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:point.x yBy:point.y + as.height*0];
        [transform scaleXBy:1 yBy:-1];
        [transform translateXBy:-point.x yBy:-(point.y + as.height)];
        [transform concat];
        
        [action drawAtPoint:point operation:NSCompositingOperationSourceOver fraction:1.0];
        
        [NSGraphicsContext restoreGraphicsState];
    }
}

- (void)setDividerLocation:(CGFloat)location animate:(BOOL)animate collapse:(BOOL)collapse
{
    NSView *view0 = (self.subviews)[0];
    NSView *view1 = (self.subviews)[1];

    NSRect view0TargetFrame;
    NSRect view1TargetFrame;
    
    if([self isVertical]) {
        view0TargetFrame = NSMakeRect( view0.frame.origin.x, view0.frame.origin.y, location, view0.frame.size.height);
        if(collapse) {
            view1TargetFrame = NSMakeRect( view1.frame.origin.x + location + self.dividerThickness, view1.frame.origin.y, -self.dividerThickness, view1.frame.size.height);        
        } else {
            view1TargetFrame = NSMakeRect( view1.frame.origin.x + location + self.dividerThickness, view1.frame.origin.y, self.frame.size.width - view0TargetFrame.size.width - self.dividerThickness, view1.frame.size.height);            
        }
    } else {
        view0TargetFrame = NSMakeRect( view0.frame.origin.x, view0.frame.origin.y, view0.frame.size.width, location);
        if(collapse) {
            // Note: on Mac OS 10.9, the height cannot be negative, otherwise the view isn't collapsed completely.
            view1TargetFrame = NSMakeRect( view1.frame.origin.x, view0.frame.origin.y + location + self.dividerThickness, view1.frame.size.width, 0);
        } else {
            view1TargetFrame = NSMakeRect( view1.frame.origin.x, view0.frame.origin.y + location + self.dividerThickness, view1.frame.size.width, self.frame.size.height - view0TargetFrame.size.height - self.dividerThickness);
        }
    }

    if(animate) {
        CAAnimation *animation = [self animationForKey:@"frameSize"];
        animation.delegate = self;

        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:0.4];
        [[view0 animator] setFrame: view0TargetFrame];
        [[view1 animator] setFrame: view1TargetFrame];        
        
        [NSAnimationContext endGrouping];                                    
    } else {
        [view0 setFrame:view0TargetFrame];
        [view1 setFrame:view1TargetFrame];

        [self animationCompleted];
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    // Invoke the completion block at the next run loop execution to be sure it doesn't execute
    // before the views have completed animated.
    [self performSelector:@selector(animationCompleted) withObject:nil afterDelay:0];
}

- (void)animationCompleted
{
    // Note: this method gets invoked multiple times for each end of animation!!
    @synchronized(requests) {
        if(self.currentRequest) {
            if(self.currentRequest.completionBlock) {
                self.currentRequest.completionBlock();
            }
            self.currentRequest = nil;
            [self performSelector:@selector(executeNextRequest) withObject:nil afterDelay:1];            
        }
    }
}

- (void)executeNextRequest
{
    @synchronized(requests) {
        if(self.currentRequest == nil) {
            self.currentRequest = [requests firstObject];
            [requests removeFirstObject];
            if(self.currentRequest) {
                [self executeRequest:self.currentRequest];
            }            
        }        
    }
}

- (void)executeRequest:(AZAnimationRequest*)request
{
    if (request.collapse) {
        if([self isVertical]) {
            mPreviousPosition = [(self.subviews)[0] frame].size.width;        
        } else {
            mPreviousPosition = [(self.subviews)[0] frame].size.height;
        }
        [self setDividerLocation:[self isVertical]?self.frame.size.width:self.frame.size.height animate:request.animation collapse:request.collapse];        
    } else {
        if([self isVertical]) {
            if([(self.subviews)[1] frame].size.width <= 0) {
                [self setDividerLocation:mPreviousPosition animate:request.animation collapse:request.collapse];        
            } else {
                [self animationCompleted];
            }
        } else {
            if([(self.subviews)[1] frame].size.height <= 0) {
                [self setDividerLocation:mPreviousPosition animate:request.animation collapse:request.collapse];        
            } else {
                [self animationCompleted];            
            }            
        }        
    }    
}

- (void)collapse:(BOOL)collapse animation:(BOOL)animation completionBlock:(CallbackBlock)block
{
    @synchronized(requests) {
        AZAnimationRequest *request = [[AZAnimationRequest alloc] init];
        request.collapse = collapse;
        request.animation = animation;
        request.completionBlock = block;
        [requests addObject:request];
        [self performSelector:@selector(executeNextRequest) withObject:nil afterDelay:0];            
    }
}

@end
