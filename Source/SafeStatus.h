//
//  SafeStatus.h
//  iLocalize3
//
//  Created by Jean on 02.02.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//


@interface SafeStatus : NSObject {
	int				mStatus;
}

- (void)setStatus:(int)status;
- (int)status;

- (BOOL)setStatus:(int)newStatus ifStatusEquals:(int)status;
- (void)waitForStatus:(int)status;

@end
