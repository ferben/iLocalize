//
//  IGroupElementAlternate.h
//  iLocalize
//
//  Created by Jean Bovet on 11/1/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroupElement.h"

@interface IGroupElementAlternate : IGroupElement {
	float score;
	NSString *file;
}

@property float score;
@property (strong) NSString *file;

+ (IGroupElementAlternate*)elementWithDictionary:(NSDictionary*)dic;

@end
