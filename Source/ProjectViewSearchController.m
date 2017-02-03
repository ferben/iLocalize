//
//  ProjectViewSearchController.m
//  iLocalize
//
//  Created by Jean on 1/18/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "ProjectViewSearchController.h"
#import "AZGradientView.h"
#import "ProjectWC.h"
#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"
#import "StringController.h"
#import "ExplorerFilter.h"
#import "FindContentMatching.h"
#import "SearchContext.h"
#import "AZVerticalLineView.h"

@implementation ProjectViewSearchController

@synthesize context;

+ (ProjectViewSearchController*)newInstance:(ProjectWC*)projectWC
{
    ProjectViewSearchController *p = [[ProjectViewSearchController alloc] initWithNibName:@"ProjectViewSearch" bundle:nil];
    p.projectWC = projectWC;
    return p;
}


- (BOOL)canReplace
{
    return !((context.scope & SCOPE_FILES) || (context.scope & SCOPE_KEY));
}

- (void)setButton:(NSButton*)button contextContains:(int)flag
{
    [button setState:(context.scope & flag) ? NSOnState : NSOffState];
}

- (void)updateInterface
{
    [self setButton:scopeFilesButton contextContains:SCOPE_FILES];
    [self setButton:scopeKeyButton contextContains:SCOPE_KEY];
    [self setButton:scopeStringsBaseButton contextContains:SCOPE_STRINGS_BASE];
    [self setButton:scopeStringsTranslationButton contextContains:SCOPE_STRINGS_TRANSLATION];
    [self setButton:scopeCommentsBaseButton contextContains:SCOPE_COMMENTS_BASE];
    [self setButton:scopeCommentsTranslationButton contextContains:SCOPE_COMMENTS_TRANSLATION];
    
    BOOL canReplace = [self canReplace];
    [replaceTextField setEnabled:canReplace];
    
    BOOL replaceStringNotEmpty = [self replaceString].length > 0;
    [replaceButton setEnabled:canReplace && replaceStringNotEmpty];
    [replaceAllButton setEnabled:canReplace && replaceStringNotEmpty];    
}

- (NSButton*)createButtonWithTitle:(NSString*)title action:(SEL)action tag:(NSInteger)tag at:(NSPoint*)p
{
    NSFont *font = [NSFont controlContentFontOfSize:NSRegularControlSize];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = font;        
    NSSize size = [title sizeWithAttributes:attributes];
                                       
    NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(p->x, p->y, size.width+26, size.height+4)];
    p->x += (int)size.width+26;
    p->x += 13;
    
    [button setAutoresizingMask:NSViewMinYMargin];
    [button setBezelStyle:NSRoundRectBezelStyle];
    [button setButtonType:NSPushOnPushOffButton];
    [button setTitle:title];
    [button setTarget:self];
    [button setAction:action];
    [button setTag:tag];

    return button;
}

- (NSView*)createVerticalSeparatorAt:(NSPoint*)p height:(CGFloat)height
{    
    AZVerticalLineView *v = [[AZVerticalLineView alloc] initWithFrame:NSMakeRect(p->x, p->y, 10, height)];    
    [v setAutoresizingMask:NSViewMinYMargin];
    
    p->x += 13;

    return v;
}

- (void)awakeFromNib
{
    // Build the buttons programmatically to be able to resize them automatically depending on the current language
    SEL action = @selector(contextChanged:);
    
    NSPoint p = NSMakePoint(65, 39);
    
    [self.view addSubview:scopeFilesButton=[self createButtonWithTitle:NSLocalizedString(@"File", @"Search Context Button") action:action tag:0 at:&p]];
    [self.view addSubview:[self createVerticalSeparatorAt:&p height:20]];
    [self.view addSubview:scopeKeyButton=[self createButtonWithTitle:NSLocalizedString(@"Key", @"Search Context Button") action:action tag:1 at:&p]];
    [self.view addSubview:scopeStringsBaseButton=[self createButtonWithTitle:NSLocalizedString(@"Base", @"Search Context Button") action:action tag:2 at:&p]];
    [self.view addSubview:scopeStringsTranslationButton=[self createButtonWithTitle:NSLocalizedString(@"Translation", @"Search Context Button") action:action tag:3 at:&p]];
    [self.view addSubview:scopeCommentsBaseButton=[self createButtonWithTitle:NSLocalizedString(@"Base Comment", @"Search Context Button") action:action tag:4 at:&p]];
    [self.view addSubview:scopeCommentsTranslationButton=[self createButtonWithTitle:NSLocalizedString(@"Translation Comment", @"Search Context Button") action:action tag:5 at:&p]];
    
    // ---
    
    AZGradientView *gv = (AZGradientView*)self.view;
    gv.bottomLine = YES;
    context = [[SearchContext alloc] init];
    [replaceTextField setDelegate:self];
    [self updateInterface];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    [self updateInterface];
}

- (CGFloat)viewHeight
{
    return [self canReplace]?65:32;
}

- (NSString*)replaceString
{
    return [replaceTextField stringValue];
}

- (void)addOrRemoveIfAlreadyExist:(int)key
{
    if((context.scope & key) > 0) {
        context.scope = context.scope & ~key;
    } else {
        context.scope = context.scope | key;        
    }
}

- (IBAction)contextChanged:(id)sender
{
    // Maintain now a scope only between File and the others.
    NSInteger tag = [sender tag];
    
    switch (tag)
    {
        case 0: // File
            context.scope = SCOPE_FILES;
            break;

        case 1: // Key
            if (context.scope == SCOPE_FILES)
            {
                context.scope = SCOPE_KEY;                
            }
            else
            {
                [self addOrRemoveIfAlreadyExist:SCOPE_KEY];
            }
            
            break;
            
        case 2: // Base string
            if (context.scope == SCOPE_FILES)
            {
                context.scope = SCOPE_KEY;                
            }
            else
            {
                [self addOrRemoveIfAlreadyExist:SCOPE_STRINGS_BASE];
            }
            
            break;
        
        case 3: // Translation string
            if (context.scope == SCOPE_FILES)
            {
                context.scope = SCOPE_KEY;                
            }
            else
            {
                [self addOrRemoveIfAlreadyExist:SCOPE_STRINGS_TRANSLATION];
            }
            
            break;

        case 4: // Base comment
            if (context.scope == SCOPE_FILES)
            {
                context.scope = SCOPE_KEY;                
            }
            else
            {
                [self addOrRemoveIfAlreadyExist:SCOPE_COMMENTS_BASE];
            }
            
            break;
        
        case 5: // Translation comment
            if (context.scope == SCOPE_FILES)
            {
                context.scope = SCOPE_KEY;                
            }
            else
            {
                [self addOrRemoveIfAlreadyExist:SCOPE_COMMENTS_TRANSLATION];
            }
            
            break;
    }
            
    [self updateInterface];
    
    [self.projectWC hideSearchView];
    [self.projectWC showSearchView];        
    
    [self.projectWC doSearch];
}

- (IBAction)save:(id)sender
{
    [self.projectWC doSaveSearch];
}

- (IBAction)replace:(id)sender
{
    [self.projectWC doReplace];
}

- (IBAction)replaceAll:(id)sender
{
    [self.projectWC doReplaceAll];
}

@end
