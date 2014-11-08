//
//  PopupTableColumn.h
//  iLocalize3
//
//  Created by Jean on 09.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "Protocols.h"

@interface PopupTableColumn : NSTableColumn {
	id<PopupTableColumnDelegate> mDelegate;
}
@end
