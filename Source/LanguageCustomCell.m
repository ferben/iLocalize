//
//  LanguageCustomCell.m
//  iLocalize3
//
//  Created by Jean on 03.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "LanguageCustomCell.h"
#import "LanguageController.h"

static NSMutableDictionary    *mTitleAttributes = NULL;
static NSMutableDictionary    *mInfoAttributes = NULL;

@implementation LanguageCustomCell

- (void)checkAttributes
{
    if(mTitleAttributes == NULL) {
        mTitleAttributes = [[NSMutableDictionary alloc] init];
        mTitleAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande" size:13];        
    }
    
    if(mInfoAttributes == NULL) {
        mInfoAttributes = [[NSMutableDictionary alloc] init];
        mInfoAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande" size:10];        
    }    
}

- (LanguageController*)languageController
{
    return [[self objectValue] nonretainedObjectValue];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super drawInteriorWithFrame:cellFrame inView:controlView];

    [self checkAttributes];
    
    if([self isHighlighted]) {
        mTitleAttributes[NSForegroundColorAttributeName] = [NSColor whiteColor];        
        mInfoAttributes[NSForegroundColorAttributeName] = [NSColor whiteColor];        
    } else {
        mTitleAttributes[NSForegroundColorAttributeName] = [NSColor blackColor];        
        mInfoAttributes[NSForegroundColorAttributeName] = [NSColor blackColor];        
    }
    
    //if([[self languageController] isBaseLanguage])
    //    [mTitleAttributes setObject:[NSFont fontWithName:@"Lucida Grande Bold" size:13] forKey:NSFontAttributeName];        
    //else
        mTitleAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande" size:13];        
    
    NSString *language = [[self languageController] language];
    [language drawAtPoint:NSMakePoint(cellFrame.origin.x+4, cellFrame.origin.y) withAttributes:mTitleAttributes];        
    
    NSString *info = [NSString stringWithFormat:NSLocalizedString(@"%lu files", nil), (unsigned long)[[self languageController] numberOfFileControllers]];
    NSSize size = [info sizeWithAttributes:mInfoAttributes];
    [info drawAtPoint:NSMakePoint(cellFrame.origin.x+4, cellFrame.origin.y+cellFrame.size.height-size.height) withAttributes:mInfoAttributes];            

    NSString *percent;
    if([[self languageController] isBaseLanguage]) {
        percent = @"Base";
        size = [percent sizeWithAttributes:mInfoAttributes];            
    } else {
        float pvalue = [[self languageController] percentCompleted];
        if(pvalue < 100) {
            percent = [NSString stringWithFormat:@"%3.0f%%", pvalue>=99.5?99:pvalue];
            size = [@"100%" sizeWithAttributes:mInfoAttributes];            
        } else {
            percent = NSLocalizedString(@"Done", nil);
            size = [percent sizeWithAttributes:mInfoAttributes];            
        }
    }
    [percent drawAtPoint:NSMakePoint(cellFrame.origin.x+cellFrame.size.width-size.width-5, cellFrame.origin.y) withAttributes:mInfoAttributes];                        
}

@end
