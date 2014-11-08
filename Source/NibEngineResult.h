//
//  NibEngineResult.h
//  iLocalize
//
//  Created by Jean on 3/12/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

@interface NibEngineResult : NSObject {
	BOOL success;
	NSString *_error;
	NSString *_output;
}
@property BOOL success;
@property (strong) NSString *error;
@property (strong) NSString *output;
@end
