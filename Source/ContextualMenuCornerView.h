//
//  ContextualMenuCornerView.h
//  iLocalize3
//
//  Created by Jean on 12/14/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "TableCornerViewCustom.h"

@interface ContextualMenuCornerView : TableCornerViewCustom {
	NSMenu *mMenu;
}
+ (id)cornerWithMenu:(NSMenu*)menu;
@end
