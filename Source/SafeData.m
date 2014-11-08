//
//  SafeData.m
//  iLocalize3
//
//  Created by Jean on 02.02.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "SafeData.h"


@implementation SafeData

- (id)init
{
	if(self = [super init]) {
		mData = NULL;
		mDirty = NO;
	}
	return self;
}


- (void)setData:(id)data
{
	@synchronized(self) {
		mData = data;
		mDirty = YES;		
	}
}

- (id)data
{
	id temp = NULL;
	
	@synchronized(self) {
		temp = mData;
		mDirty = NO;		
	}
	
	return temp;
}

- (id)dataIfDirtyAndClear
{
	id temp = NULL;
	
	@synchronized(self) {
		if(mDirty)
			temp = [self data];		
	}
	
	return temp;
}

@end
