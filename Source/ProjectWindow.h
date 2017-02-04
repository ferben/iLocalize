//
//  ProjectWindow.h
//  iLocalize3
//
//  Created by Jean on 6/21/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

@class TooltipWindow;

@interface ProjectWindow : NSWindow
{
    NSTimer        *mToolTipTimer;
    TooltipWindow  *mTooltipWindow;
    BOOL            mMouseDidMove;
    BOOL            mTooltipDisplayed;
}

- (void)showTooltip:(NSString *)tt;
- (void)hideTooltip;

@end
