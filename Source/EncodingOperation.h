//
//  EncodingOperation.h
//  iLocalize3
//
//  Created by Jean on 11/25/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "AbstractOperation.h"

@class StringEncoding;

@interface EncodingOperation : AbstractOperation {

}
- (void)convertFileControllers:(NSArray*)fcs toEncoding:(StringEncoding*)encoding reload:(BOOL)reload;
@end
