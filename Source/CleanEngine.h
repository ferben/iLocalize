//
//  CleanEngine.h
//  iLocalize3
//
//  Created by Jean on 30.05.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractEngine.h"

@interface CleanEngine : AbstractEngine {
	BOOL mCleanDoubleQuotationMark;
	BOOL mCleanQuotationMark;
	BOOL mCleanEllipsis;
	BOOL mCleanNonbreakableSpace;
	BOOL mCleanTrailingSpace;
	
	BOOL mCleanMarkModifiedStrings;
}
- (void)cleanWithAttributes:(NSDictionary*)attributes;
@end
