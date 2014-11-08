//
//  OperationCustomCell.h
//  iLocalize
//
//  Created by Jean on 12/18/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

@interface OperationCustomCell : NSCell {
	id mCustomValue;
}
+ (OperationCustomCell*)cell;
- (void)setCustomValue:(id)value;
@end
