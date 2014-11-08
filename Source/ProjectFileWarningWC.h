//
//  ProjectFileWarning.h
//  iLocalize3
//
//  Created by Jean on 5/28/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "AbstractWC.h"

@class FileController;

@interface ProjectFileWarningWC : AbstractWC {
	IBOutlet NSArrayController	*mWarningsController;
	IBOutlet NSArrayController	*mKeysController;
	FileController	*mFileController;
}
- (void)setFileController:(FileController*)fc;
- (IBAction)help:(id)sender;
- (IBAction)export:(id)sender;
- (IBAction)ok:(id)sender;
@end
