//
//  RemoveLanguageOperation.h
//  iLocalize3
//
//  Created by Jean on 09.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractOperation.h"

@class LanguageController;

@interface RemoveLanguageOperation : AbstractOperation {

}
- (void)removeLanguage:(LanguageController*)language;
@end
