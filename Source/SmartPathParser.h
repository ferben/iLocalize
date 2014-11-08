//
//  SmartPathParser.h
//  iLocalize3
//
//  Created by Jean on 05.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@interface SmartPathParser : NSObject {
	NSArray *mComponents;
	NSMutableArray	*mSmartPathComponents;
	int		mCurrentComponentIndex;
	BOOL	mIncludeLProj;
}
+ (NSString*)smartPath:(NSString*)path;
+ (NSString*)smartPath:(NSString*)path lproj:(BOOL)lproj;
@end
