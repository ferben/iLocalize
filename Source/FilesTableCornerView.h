//
//  FilesTableCornerView.h
//  iLocalize3
//
//  Created by Jean on 08.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "TableCornerViewCustom.h"

@interface FilesTableCornerView : TableCornerViewCustom {
	NSMenu *mMenu;
}
+ (id)cornerWithMenu:(NSMenu*)menu;
@end
