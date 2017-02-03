//
//  ExportOptionsOVC.m
//  iLocalize
//
//  Created by Jean Bovet on 2/15/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ExportProjectOptionsOVC.h"
#import "ProjectExportMailScripts.h"
#import "ExportProjectSettings.h"

@implementation ExportProjectOptionsOVC

@synthesize settings;

- (id)init
{
    if (self = [super initWithNibName:@"ExportProjectOptions"])
    {
        [self loadView];
        originalSize = self.view.frame.size;
    }
    
    return self;
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
    BOOL result = NO;
    
    if (command == @selector(insertNewline:))
    {
        // new line action:
        // always insert a line-break character and don’t cause the receiver to end editing
        [textView insertNewlineIgnoringFieldEditor:self]; 
        result = YES;
    }
    else if (command == @selector(insertTab:))
    {
        // tab action:
        // always insert a tab character and don’t cause the receiver to end editing
        [textView insertTabIgnoringFieldEditor:self];
        result = YES;
    }
    
    return result;
}

//- (void)updateMailPrograms
//{
//    [mMailProgramPopUp removeAllItems];
//    for(NSString *program in [[ProjectExportMailScripts shared] programs])
//  {
//        [mMailProgramPopUp addItemWithTitle:program];        
//    }
//}

- (IBAction)email:(id)sender
{
    [self stateChanged];
}

- (NSSize)viewSize
{
    if (self.settings.email)
    {
        [hideEmailComponentsView setHidden:NO];

        return originalSize;
    }
    else
    {
        [hideEmailComponentsView setHidden:YES];
        
        return NSMakeSize(originalSize.width, originalSize.height - hideEmailComponentsView.frame.size.height);
    }
}

- (BOOL)canResize
{
    return NO;
}

- (void)willShow
{
    [objectController setContent:self.settings];
}

@end
