//
//  ProjectDetails.m
//  iLocalize
//
//  Created by Jean on 12/28/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectDetails.h"
#import "ProjectDocument.h"

@implementation ProjectDetails

- (void)awakeFromNib
{
	resizingMask = [[self view] autoresizingMask];
	displayed = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(stringSelectionDidChange:)
												 name:ILStringSelectionDidChange
											   object:nil];		
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)close
{
	
}

- (void)stringSelectionDidChange:(NSNotification*)notif
{
}

- (id<ProjectProvider>)projectProvider
{
	return [self.projectWC projectDocument];
}

- (BOOL)displayed
{
	return displayed;
}

- (void)setResizableFlag:(BOOL)flag
{
	if(flag) {
		[[self view] setAutoresizingMask:resizingMask];
		[[self view] setAutoresizesSubviews:YES];
	} else {
		[[self view] setAutoresizingMask:0];	
		[[self view] setAutoresizesSubviews:NO];
	}
}

- (NSMenu*)actionMenu
{
	return nil;
}

- (NSView*)keyView
{
    return nil;
}

- (void)willShow
{
	displayed = YES;
	[self update];
    [[self keyView] setHidden:NO];
}

- (void)willHide
{

}

- (void)didHide
{
    // Make sure the key view is hidden so it does not participate in the key view loop.
    [[self keyView] setHidden:YES];    
}

- (void)update
{
	// for subclass
}

- (NSTextStorage*)textStorage
{
	// for subclass
	return nil;
}

- (void)begin
{
	NSTextStorage *ts = [self textStorage];	
	[ts deleteCharactersInRange:NSMakeRange(0, [ts length])];	
	[ts addAttribute:NSFontAttributeName 
			   value:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] 
			   range:NSMakeRange(0, [ts length])];		
}

- (void)commit
{
	NSTextStorage *ts = [self textStorage];	
	
	// applies the small system font
	[ts addAttribute:NSFontAttributeName 
			   value:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] 
			   range:NSMakeRange(0, [ts length])];	
	
	NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
	[ps setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
	[ps setLineSpacing:5];
	[ts addAttribute:NSParagraphStyleAttributeName 
			   value:ps
			   range:NSMakeRange(0, [ts length])];		
}

- (void)addDetail:(NSString*)detail
{
	NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:detail];
	[as addAttribute:NSForegroundColorAttributeName
			   value:[NSColor lightGrayColor]
			   range:NSMakeRange(0, [detail length])];
	
	[[self textStorage] appendAttributedString:as];			
}

- (void)addDetail:(NSString*)detail value:(NSString*)value
{
	NSString *s = [NSString stringWithFormat:@"%@: %@\n", detail, value];
	NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:s];
	[as addAttribute:NSForegroundColorAttributeName
			   value:[NSColor lightGrayColor]
			   range:NSMakeRange(0, [detail length]+1)];
	
	[[self textStorage] appendAttributedString:as];			
}

- (void)addSection:(NSString*)title
{
	NSString *s = @"<b>This is a separation</b><br><hr/>";
	NSAttributedString *as = [[NSAttributedString alloc] initWithHTML:[s dataUsingEncoding:NSUTF8StringEncoding] documentAttributes:nil];
		
//	NSString *s = [NSString stringWithFormat:@"%@:\n", title];
//	NSMutableAttributedString *as = [[[NSMutableAttributedString alloc] initWithString:s] autorelease];
////	[as addAttribute:NSForegroundColorAttributeName
////			   value:[NSColor lightGrayColor]
////			   range:NSMakeRange(0, [s length])];
//	[as addAttribute:NSFontAttributeName
//			   value:[NSColor lightGrayColor]
//			   range:NSMakeRange(0, [s length])];
	
	[[self textStorage] appendAttributedString:as];					
}

- (void)addSeparator
{
	NSString *s = @"\n";
	NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:s];
//	[as addAttribute:NSForegroundColorAttributeName
//			   value:[NSColor lightGrayColor]
//			   range:NSMakeRange(0, [s length]+1)];
	
	[[self textStorage] appendAttributedString:as];				
}

- (BOOL)canExecuteCommand:(SEL)command {
    return NO;
}

- (void)executeCommand:(SEL)command {
    
}

@end
