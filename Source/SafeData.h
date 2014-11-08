//
//  SafeData.h
//  iLocalize3
//
//  Created by Jean on 02.02.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//


@interface SafeData : NSObject {
	id				mData;
	BOOL			mDirty;
}
- (void)setData:(id)data;
- (id)data;
- (id)dataIfDirtyAndClear;
@end
