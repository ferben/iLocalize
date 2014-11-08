//
//  SimpleStringController.h
//  iLocalize
//
//  Created by Jean Bovet on 3/30/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "StringController.h"

@interface SimpleStringController : NSObject<StringControllerProtocol>
{
	NSString *key;
	NSString *base;
	NSString *translation;
}

+ (SimpleStringController*)stringWithBase:(NSString*)base translation:(NSString*)translation;

@property (strong) NSString *key;
@property (strong) NSString *base;
@property (strong) NSString *translation;

@end
