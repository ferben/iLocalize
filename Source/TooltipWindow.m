//
//  TooltipWindow.m

#import "TooltipWindow.h"

float defaultDuration;
BOOL doneInitialSetup;
NSDictionary *textAttributes;
NSColor *backgroundColor;

@implementation TooltipWindow

+ (void)setDefaultBackgroundColor:(NSColor *)bgColor
{
    backgroundColor = bgColor;
}

+ (NSColor *)defaultBackgroundColor
{
    if (!backgroundColor)
        [TooltipWindow setDefaultBackgroundColor: [NSColor colorWithDeviceRed:1.0 green:0.96 blue:0.76 alpha:1.0]];
    
    return backgroundColor;
}


+ (void)setDefaultDuration:(NSTimeInterval)inSeconds
{
    doneInitialSetup = YES;
    defaultDuration = inSeconds;
}

+ (NSTimeInterval)defaultDuration
{
    return defaultDuration;
}


+ (id)tipWithString:(NSString *)tip frame:(NSRect)frame display:(BOOL)display
{
    return [TooltipWindow tipWithAttributedString:[[NSAttributedString alloc] initWithString:tip] frame:frame display:display];
}

+ (id)tipWithAttributedString:(NSAttributedString *)tip frame:(NSRect)frame display:(BOOL)display
{
    TooltipWindow *window = [[TooltipWindow alloc] init]; // blank slate
    
    // if the defaultDuration hasn't been set we set it to a default of 5 seconds
    // we like to cache the text attributes used for plain string drawing..
    if (!doneInitialSetup) {
        [TooltipWindow setDefaultDuration:5];
        [window setTooltip:@" "]; // Just having at least 1 char to allow the next message...
        textAttributes = [[[window contentView] attributedStringValue] attributesAtIndex:0 effectiveRange:nil];
    }
    
    [window setTooltip:tip]; // set the tip
    [window setReleasedWhenClosed:display]; // if we display right away we release on close
    [window setFrame:frame display:YES];
    
    if (display) {
        [window orderFrontWithDuration:[TooltipWindow defaultDuration]]; // this is affectively autoreleasing the window after 'defaultDuration'
        return window;
    } else // it's not set to auto-magically go away so make the caller responsible..
        return window;
}

+ (NSSize)suggestedSizeForTooltip:(id)tooltip
{
    NSSize tipSize = NSZeroSize;
    
    if ([tooltip isKindOfClass:[NSAttributedString class]]) tipSize = [tooltip size];
    else
        if ([tooltip isKindOfClass:[NSString class]]) tipSize = [tooltip sizeWithAttributes:textAttributes];
    else
        return tipSize; // we don't know how to get the size of 'tooltip' so return NSZeroSize
    
    if (!NSEqualSizes(tipSize, NSZeroSize))
        tipSize.width += 4;
    
    return tipSize;
}


- (id)init
{
    self = [super initWithContentRect:NSMakeRect(0,0,0,0)
                            styleMask:NSWindowStyleMaskBorderless
                              backing:NSBackingStoreBuffered
                                defer:NO];
    { // window setup...
        [self setAlphaValue:0.90];
        [self setOpaque:NO];
        [self setBackgroundColor:[TooltipWindow defaultBackgroundColor]];
        [self setHasShadow:YES];
        [self setLevel:NSStatusWindowLevel];
        [self setHidesOnDeactivate:YES];
        [self setIgnoresMouseEvents:YES];
        [self setReleasedWhenClosed:NO];
    }
    
    { // textfield setup...
        NSTextField *field = [[NSTextField alloc] initWithFrame:NSMakeRect(0,0,0,0)];
        
        [field setEditable:NO];
        [field setSelectable:NO];
        [field setBezeled:NO];
        [field setBordered:NO];
        [field setDrawsBackground:NO];
        [field setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [field setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
        [self setContentView:field];
        [self setFrame:[self frameRectForContentRect:[field frame]] display:NO];
        
        if (!doneInitialSetup) {
            [TooltipWindow setDefaultDuration:5];
            [field setStringValue:@" "]; // Just having at least 1 char to allow the next message...
            textAttributes = [[field attributedStringValue] attributesAtIndex:0 effectiveRange:nil];
        }
        
    }
    
    closeTimer = nil;
    tooltipObject = nil;
    
    return self;
}


- (void)dealloc
{
    if (closeTimer) {
        [closeTimer invalidate];
    }
}

- (id)tooltip { return tooltipObject; }

- (void)setTooltip:(id)tip
{
    id contentView = [self contentView];
    
    tooltipObject = tip;
    
    if ([contentView isKindOfClass:[NSTextField class]]) {
        if ([tip isKindOfClass:[NSString class]]) 
            [contentView setStringValue:tip];
        else if ([tip isKindOfClass:[NSAttributedString class]])
            [contentView setAttributedStringValue:tip];
    }
}

- (void)orderFrontWithDuration:(NSTimeInterval)seconds
{
    [super orderFront:nil];
    
    if (closeTimer) { [closeTimer invalidate];  }
    closeTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(close) userInfo:nil repeats:NO];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"TooltipWindow:\n%@", [[self contentView] stringValue]];
}


@end
