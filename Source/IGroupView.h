//
//  IGroupView.h
//  iLocalize
//
//  Created by Jean Bovet on 10/16/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroup.h"


@interface IGroupView : NSView {
	IGroup *group;
	NSTrackingArea *trackingArea;
	int selectedElementIndex;
}
@property (strong) IGroup *group;
@end
