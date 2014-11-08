//
//  TableViewCustomController.h
//  iLocalize3
//
//  Created by Jean on 03.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@interface TableViewCustomController : NSObject {
	IBOutlet NSView		*mView;
}
- (id)initWithNibName:(NSString*)nibname;
- (NSView*)view;
- (void)willDisplayCell:(NSCell*)cell;
@end
