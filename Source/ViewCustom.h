//
//  ViewCustom.h
//  iLocalize3
//
//  Created by Jean on 03.02.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@interface ViewCustom : NSView {
    id delegate;
}
- (void)registerDraggedTypes;
@end
