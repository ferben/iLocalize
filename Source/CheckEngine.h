//
//  CheckEngine.h
//  iLocalize3
//
//  Created by Jean on 5/28/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "AbstractEngine.h"

#define WARNING_DUPLICATE_KEYS @"duplicateKeys"
#define WARNING_MISSING_KEYS @"missingKeys"
#define WARNING_MISMATCH_KEYS @"mismatchKeys"
#define WARNING_MISMATCH_FORMATTING_CHARS @"mismatchFormattingCharsKeys"
#define WARNING_READONLY_FILE @"readOnlyFile"
#define WARNING_COMPILEDNIB_FILE @"compiledNibFile"

@class FileController;
@class StringController;

@interface CheckEngine : AbstractEngine
{
}

- (void)checkFileController:(FileController *)fc;
- (NSUInteger)checkLanguages:(NSArray *)languages;
- (BOOL)checkFormattingCharactersOfBaseString:(NSString *)base localizedString:(NSString *)localized;
- (void)markStringController:(StringController *)sc;

@end
