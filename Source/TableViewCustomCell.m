//
//  TableViewCustomCell.m
//  iLocalize3
//
//  Created by Jean on 03.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "TableViewCustomCell.h"
#import "LayoutManagerCustom.h"
#import "FindContentMatching.h"
#import "TableViewHeightCache.h"

@implementation TableViewCustomCell

@synthesize showInvisibleCharacters;
@synthesize contentMatching;
@synthesize contentMatchingItem;

static NSMutableDictionary    *sharedValueAttributes = NULL;

+ (TableViewCustomCell*)cell
{
    return [[self alloc] init];
}

+ (TableViewCustomCell*)textCell
{
    return [[self alloc] initTextCell:@""];
}

- (id)init
{
    if((self = [super init])) {
        [self awake];
    }
    return self;
}

- (id)initTextCell:(NSString*)text
{
    if((self = [super initTextCell:text])) {
        [self awake];
    }
    return self;    
}

- (id)initImageCell:(NSImage *)anImage
{
    if((self = [super initImageCell:anImage])) {
        [self awake];
    }
    return self;    
}

- (id)copyWithZone:(NSZone *)zone
{
    TableViewCustomCell *newCell = [super copyWithZone:zone];
    [newCell awake];
    return newCell;
}

- (void)awake
{
    mTextStorage = [[NSTextStorage alloc] initWithString:@""];
    mLayoutManager = [[LayoutManagerCustom alloc] init];
    mTextContainer = [[NSTextContainer alloc] init];
    [mLayoutManager addTextContainer:mTextContainer];
    [mTextStorage addLayoutManager:mLayoutManager];    
        
    if(!sharedValueAttributes) {
        sharedValueAttributes = [[NSMutableDictionary alloc] init];
        sharedValueAttributes[NSFontAttributeName] = [NSFont fontWithName:@"Lucida Grande" size:13];                
    }
}


#pragma mark -

- (void)setPlaceholderString:(NSString *)string
{
    // empty implementation because in 10.5 the table view
    // is invoking that on an NSTextFieldCell so we fake that we are
    // such a cell.
}

- (float)heightForWidth:(float)width defaultHeight:(float)height
{
    return [TableViewHeightCache heightForValue:self.value width:width defaultHeight:height attributes:sharedValueAttributes];        
}

- (void)drawString:(NSString*)string inRect:(NSRect)r attributes:(NSDictionary*)attrs
{
    if(![[mTextStorage string] isEqualToString:string]) {
        [mTextStorage replaceCharactersInRange:NSMakeRange(0, [mTextStorage length]) withString:string];    
    }
    if([mTextStorage length] > 0 && ![[mTextStorage attributesAtIndex:0 effectiveRange:nil] isEqualTo:attrs]) {
        [mTextStorage setAttributes:attrs range:NSMakeRange(0, [mTextStorage length])];        
    }
    
    if(!NSEqualSizes([mTextContainer containerSize], r.size)) {
        [mTextContainer setContainerSize:r.size];
    }
    
    if(contentMatching) {
        NSMutableDictionary *matchingAttrs = [NSMutableDictionary dictionaryWithDictionary:attrs];
        matchingAttrs[NSForegroundColorAttributeName] = [NSColor redColor];
        for(NSValue *range in [contentMatching rangesForItem:contentMatchingItem]) {
            NSRange r = [range rangeValue];
            if(r.location+r.length <= [mTextStorage length]) {
                [mTextStorage setAttributes:matchingAttrs range:r];                            
            } else {
                // This means the text has changed so remove the find content matching because it
                // wont match anymore.
                [contentMatching removeRangesForItem:contentMatchingItem];
                break;
            }
        }
    }
    
    [mLayoutManager setShowInvisibleCharacters:self.showInvisibleCharacters];
    NSRange glyphRange = [mLayoutManager glyphRangeForTextContainer:mTextContainer];
    [mLayoutManager drawGlyphsForGlyphRange:glyphRange atPoint:r.origin];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{    
    if(self.foregroundColor) {
        sharedValueAttributes[NSForegroundColorAttributeName] = self.foregroundColor;            
    }
    if(self.value) {
        [self drawString:self.value inRect:cellFrame attributes:sharedValueAttributes];            
    }
}

@end
