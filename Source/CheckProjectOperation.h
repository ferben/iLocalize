//
//  CheckProjectOperation.h
//  iLocalize3
//
//  Created by Jean on 5/28/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "AbstractOperation.h"
#import "CheckProjectDelegate.h"

@interface CheckProjectOperation : AbstractOperation {
    id<CheckProjectDelegate> mDelegate;
    BOOL mDisplayAlertIfSuccess;
}
- (void)setDelegate:(id<CheckProjectDelegate>)delegate;
- (void)checkSelectedFile;
- (void)checkProject;
- (void)checkAllProject;
- (void)checkAllProjectNoAlertIfSuccess;
- (void)checkLanguages:(NSArray*)languages;
@end
