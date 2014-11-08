//
//  FMEditorImage.h
//  iLocalize3
//
//  Created by Jean on 26.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEditor.h"

@interface FMEditorImage : FMEditor {
	IBOutlet NSImageView	*mBaseBaseImageView;
	IBOutlet NSImageView	*mLocalizedBaseImageView;
	IBOutlet NSImageView	*mLocalizedTranslationImageView;
}

@end
