//
//  AZPathControl.m
//  iLocalize
//
//  Created by Jean on 2/18/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "AZPathControl.h"

@interface AZPathMenu : NSMenu
{
    NSString *_path;
    id<AZPathControlDelegate> pathDelegate;
}

@property (strong) NSString *path;

- (NSArray *)folders;

@end

@implementation AZPathMenu

@synthesize path=_path;

- (id)initWithDelegate:(id<AZPathControlDelegate>)_pathDelegate
{
    if (self = [super init])
    {
        pathDelegate = _pathDelegate;
    }
    
    return self;
}


- (NSArray *)folders
{
    NSMutableArray *folders = [NSMutableArray array];
        
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.path];
    NSString *file;
    
    while (file = [enumerator nextObject])
    {
        if ([pathDelegate isValidPath:[self.path stringByAppendingPathComponent:file]])
        {
            if ([[enumerator fileAttributes][NSFileType] isEqualToString:NSFileTypeDirectory])
            {
                [folders addObject:[file lastPathComponent]];
            }
        }
        
        [enumerator skipDescendents];
    }
    
    return folders;
}

@end

#pragma mark -

@interface AZPathElement : NSObject
{
    NSString *_element;
    NSMutableDictionary *attrs;
    
    NSUInteger x;
    NSUInteger y;
    NSUInteger height;
    NSUInteger index;
}

@property (strong) NSString *element;
@property NSUInteger x;
@property NSUInteger y;
@property NSUInteger height;
@property NSUInteger index;

+ (AZPathElement *)elementWithComponent:(NSString *)component;

@end

@implementation AZPathElement

@synthesize element=_element;
@synthesize x, y, height, index;

static int offset = 10;
static int triangle = 10;

+ (AZPathElement *)elementWithComponent:(NSString *)component
{
    AZPathElement *e = [[AZPathElement alloc] init];
    e.element = component;
    return e;
}

- (id)init
{
    if (self = [super init])
    {
        attrs = [[NSMutableDictionary alloc] init];
        attrs[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande" size:12];            
    }
    
    return self;
}


- (float)width
{
    NSSize esize = [self.element sizeWithAttributes:attrs];
    return esize.width + triangle + offset * 1.5;
}

- (NSRect)frame
{
    return NSMakeRect(x, y, [self width], height);
}

- (void)draw
{
    int width = [self width];
    
    NSBezierPath *bp = [NSBezierPath bezierPath];
    [bp moveToPoint:NSMakePoint(x, y)];
    [bp moveToPoint:NSMakePoint(x, y + height)];
    [bp moveToPoint:NSMakePoint(x + width - triangle, y + height)];
    [bp lineToPoint:NSMakePoint(x + width, y + height / 2)];
    [bp lineToPoint:NSMakePoint(x + width - triangle, y)];
    [bp moveToPoint:NSMakePoint(x, y)];
    
    [[NSColor grayColor] set];
    [bp stroke];
    
    [[NSColor blackColor] set];
    [self.element drawAtPoint:NSMakePoint(x+offset, height / 2 - [self.element sizeWithAttributes:attrs].height / 2) withAttributes:attrs];
}

- (BOOL)pointInFrame:(NSPoint)point
{
    return NSPointInRect(point, [self frame]);
}

- (BOOL)pointInArrow:(NSPoint)point
{
    if ([self pointInFrame:point])
    {
        return point.x > [self frame].origin.x + [self frame].size.width - triangle;
    }
    else
    {
        return NO;
    }
}

@end

#pragma mark -

@implementation AZPathControl

@synthesize basePath=_basePath;

- (id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        components = [[NSMutableArray alloc] init];
        elements = [[NSMutableArray alloc] init];
        delegate = nil;
    }
    
    return self;
}


- (void)setPath:(NSString *)path
{
    [components removeAllObjects];
    [components addObjectsFromArray:[path pathComponents]];
    
    [components removeObjectsInRange:NSMakeRange(0, [self.basePath pathComponents].count)];
    
    [elements removeAllObjects];
    
    for (NSString *component in components)
    {
        AZPathElement *e = [AZPathElement elementWithComponent:component];
        e.index = elements.count;
        [elements addObject:e];
    }
    
    [self setNeedsDisplay:YES];
}

- (NSString *)selectedPath
{
    NSMutableArray *cps = [NSMutableArray array];
    [cps addObjectsFromArray:[self.basePath pathComponents]];
    [cps addObjectsFromArray:components];
    
    return [NSString pathWithComponents:cps];
}

- (void)setDelegate:(id<AZPathControlDelegate>)d
{
    delegate = d;
}

- (AZPathElement *)elementAtPosition:(NSPoint)p
{
    for (AZPathElement *e in elements)
    {
        if ([e pointInFrame:p])
        {
            return e;
        }
    }
    
    return nil;
}

- (NSString *)pathAtIndex:(NSUInteger)index
{
    NSMutableArray *cps = [NSMutableArray array];
    [cps addObjectsFromArray:[self.basePath pathComponents]];
    [cps addObjectsFromArray:[components subarrayWithRange:NSMakeRange(0, index+1)]];
    
    return [NSString pathWithComponents:cps];
}

- (void)drawRect:(NSRect)rect
{    
    [super drawRect:rect];
    
//    [[NSColor darkGrayColor] set];
//    NSFrameRect(rect);
    
    NSUInteger x = 0;
    NSUInteger y = 0;
    NSUInteger height = self.frame.size.height;
    
    for (AZPathElement *e in elements)
    {
        e.x = x;
        e.y = y;
        e.height = height;
        [e draw];
        x += [e width];
    }
}

- (void)displayHierarchyPopup:(AZPathElement *)e event:(NSEvent *)theEvent
{
    AZPathMenu *menu = [[AZPathMenu alloc] initWithDelegate:delegate];
    [menu setPath:[self pathAtIndex:e.index]];
    [menu setDelegate:self];

    if (menu)
    {
        NSRect elementFrame = [self convertRect:[e frame] toView:nil];
        NSEvent *evt = [NSEvent mouseEventWithType:[theEvent type]
                                          location:NSMakePoint(elementFrame.origin.x+elementFrame.size.width, elementFrame.origin.y+elementFrame.size.height)
                                     modifierFlags:[theEvent modifierFlags]
                                         timestamp:[theEvent timestamp]
                                      windowNumber:[theEvent windowNumber]
                                           context: nil /*[theEvent context]*/
                                       eventNumber:[theEvent eventNumber]
                                        clickCount:[theEvent clickCount]
                                          pressure:[theEvent pressure]];
        [NSMenu popUpContextMenu:menu withEvent:evt forView:self];
    }            
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint curLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    AZPathElement *e = [self elementAtPosition:curLoc];
    
    if (e)
    {
        if ([e pointInArrow:curLoc])
        {
            [self displayHierarchyPopup:e event:theEvent];            
        }
        else
        {
            [self setPath:[self pathAtIndex:e.index]];
            [delegate pathChanged:self];                        
        }
    }
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    NSPoint curLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    AZPathElement *e = [self elementAtPosition:curLoc];
    
    if (e)
    {
        [self displayHierarchyPopup:e event:theEvent];
    }
}

- (IBAction)selectFolder:(id)sender
{
    NSMenuItem *item = sender;
    AZPathMenu *menu = (AZPathMenu *)item.menu;
    NSString *path = [menu.path stringByAppendingPathComponent:item.title];
    [self setPath:path];
    [delegate pathChanged:self];
}

#pragma mark -
#pragma mark Delegate

- (NSInteger)numberOfItemsInMenu:(NSMenu *)menu
{
    return [[(AZPathMenu *)menu folders] count];
}

- (BOOL)hasExplorableDirectories:(NSString *)path
{
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    NSString *file;
    
    while (file = [enumerator nextObject])
    {
        if ([delegate isValidPath:[path stringByAppendingPathComponent:file]])
        {
            if ([[enumerator fileAttributes][NSFileType] isEqualToString:NSFileTypeDirectory])
            {
                return YES;
            }            
        }
        
        [enumerator skipDescendents];
    }
    
    return NO;
}

- (BOOL)menu:(NSMenu *)menu updateItem:(NSMenuItem *)item atIndex:(NSInteger)index shouldCancel:(BOOL)shouldCancel
{    
    NSDictionary *attrs = @{NSFontAttributeName: [NSFont fontWithName:@"Lucida Grande" size:[NSFont smallSystemFontSize]]};
    NSString *rawTitle = [(AZPathMenu*)menu folders][index];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:rawTitle attributes:attrs];
    
    [item setAttributedTitle:title];
    [item setTarget:self];
    [item setAction:@selector(selectFolder:)];
    
    NSString *path = [[(AZPathMenu*)menu path] stringByAppendingPathComponent:rawTitle];
    
    if ([path isPathDirectory] && ![path isPathNib] && [self hasExplorableDirectories:path])
    {
        AZPathMenu *submenu = [[AZPathMenu alloc] initWithDelegate:delegate];
        [submenu setPath:path];
        [submenu setDelegate:self];
        [item setSubmenu:submenu];            
    }
    
    return YES;
}

@end
