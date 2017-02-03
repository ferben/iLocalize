//
//  LabelCustomCellRender.h
//  iLocalize3
//
//  Created by Jean on 12/2/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

@class ProjectLabels;

@interface LabelCustomCellRender : NSObject {
    NSImage            *mCachedImage;
    NSMutableSet    *mCachedSet;
}
- (void)drawLabelCellWithFrame:(NSRect)cellFrame indexes:(NSSet*)labelIndexes labels:(ProjectLabels*)labels;
@end
