//
//  OperationReportWC.h
//  iLocalize3
//
//  Created by Jean on 6/3/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

@class Console;
@class TableViewCustom;

@interface OperationReportWC : NSWindowController<NSTableViewDelegate>
{
	IBOutlet NSArrayController  *mLogsController;
	IBOutlet TableViewCustom    *mTableView;
	IBOutlet NSTextView         *mDetailedTextView;
	Console                     *mConsole;
	NSUInteger                   mFromIndex;
	NSUInteger                   mToIndex;
}

+ (void)showConsoleIfWarningsOrErrorsSinceLastMark:(Console *)console;
+ (void)showConsoleIfWarningsOrErrorsSinceLastMarkWithDelay:(Console *)console;

- (void)setConsole:(Console *)console fromIndex:(NSUInteger)index;
- (void)display;

- (IBAction)export:(id)sender;
- (IBAction)close:(id)sender;

@end
