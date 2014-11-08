//
//  FMEngineStrings.h
//  iLocalize3
//
//  Created by Jean on 25.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEngine.h"

@class StringsContentModel;

@interface FMEngineStrings : FMEngine {
}

- (void)fmRebaseFileContentWithContent:(StringsContentModel*)content fileController:(FileController*)fileController;
- (void)fmRebaseTranslateContentWithContent:(StringsContentModel*)content fileController:(FileController*)fileController;
- (void)fmRebaseAndTranslateContentWithContent:(StringsContentModel*)content fileController:(FileController*)fileController usingPreviousLayout:(BOOL)previousLayout;

- (void)fmReloadFileController:(FileController*)fileController usingFile:(NSString*)file;

@end
