//
//  LineEndingsConverterOperation.m
//  iLocalize3
//
//  Created by Jean on 23.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "LineEndingsConverterOperation.h"
#import "LineEndingsConverterWC.h"

#import "FileController.h"
#import "StringController.h"

#import "StringTool.h"

#import "Constants.h"

@implementation LineEndingsConverterOperation

- (LineEndingsConverterWC*)lineEndingsConverterWC
{
	return (LineEndingsConverterWC*)[self instanceOfAbstractWCName:@"LineEndingsConverterWC"];
}

- (void)awake
{
	mFileControllers = NULL;
}


- (void)generateApplication
{
}

- (void)convertFileControllers:(NSArray*)fileControllers
{
	mFileControllers = fileControllers;
	
	[[self lineEndingsConverterWC] setDidCloseSelector:@selector(performConvert) target:self];
	[[self lineEndingsConverterWC] showAsSheet];
}

- (void)convertStringController:(StringController*)sc
{
	int from = 0;
	if([[self lineEndingsConverterWC] fromMac])
		from |= 1 << MAC_LINE_ENDINGS;
	if([[self lineEndingsConverterWC] fromUnix])
		from |= 1 << UNIX_LINE_ENDINGS;
	if([[self lineEndingsConverterWC] fromWindows])
		from |= 1 << WINDOWS_LINE_ENDINGS;

	// Backup status because this transformation should not change the status of the string
	unsigned char status = [sc status];
	[sc setTranslation:[StringTool convertLineEndingsString:[sc translation] from:from to:[[self lineEndingsConverterWC] toLineEnding]]];
	[sc setStatus:status];
}

- (void)performConvert
{
	if([[self lineEndingsConverterWC] hideCode] == 0) {
		[self close];
		return;
	}
	
	FileController *fc;
	for(fc in mFileControllers) {
		NSEnumerator *stringEnumerator = [[fc visibleStringControllers] objectEnumerator];
		StringController *sc;
		while(sc = [stringEnumerator nextObject]) {
			[self convertStringController:sc];
		}
	}
	[[self projectProvider] rearrangeFilesController];
	[self close];
}

@end
