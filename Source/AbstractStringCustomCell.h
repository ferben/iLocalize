//
//  AbstractStringCustomCell.h
//  iLocalize3
//
//  Created by Jean on 04.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "TableViewCustomCell.h"

@class StringController;

@interface AbstractStringCustomCell : TableViewCustomCell {
}
- (StringController*)stringController;
@end
