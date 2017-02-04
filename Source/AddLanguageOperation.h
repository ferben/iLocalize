//
//  AddLanguageOperation.h
//  iLocalize3
//
//  Created by Jean on 09.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractOperation.h"

@interface AddLanguageOperation : AbstractOperation
{
}

- (void)addLanguage;
- (void)addCustomLanguage;

- (void)renameLanguage;
- (void)renameCustomLanguage;

@end
