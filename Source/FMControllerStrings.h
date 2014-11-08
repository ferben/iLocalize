//
//  FMControllerStrings.h
//  iLocalize3
//
//  Created by Jean on 25.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMController.h"

@interface FMControllerStrings : FMController {
	NSMutableArray	*mStringControllers;
	
	NSMutableArray	*mCachedVisibleStringControllers;	// cache only
	NSMutableDictionary *mCachedStringControllers; // cache only
	
	// Statistics (not saved)
    int             mNumberOfStrings;
    int             mNumberOfTranslatedStrings;
	int				mNumberOfNonTranslatedStrings;
	int				mNumberOfToCheckStrings;	
	int				mNumberOfInvariantStrings;	
	int				mNumberOfBaseModifiedStrings;
    int             mNumberOfLockedStrings;
	int				mNumberOfAutoTranslatedStrings;
	int				mNumberOfAutoInvariantStrings;
}
@end
