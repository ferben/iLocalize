//
//  PreferencesLocalization.h
//  iLocalize3
//
//  Created by Jean on 02.01.06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "PreferencesObject.h"

@interface PreferencesLocalization : PreferencesObject {

}

+ (id)shared;

- (IBAction)ignoreControlCharactersChanged:(id)sender;
- (IBAction)help:(id)sender;
- (IBAction)resetDialogWarnings:(id)sender;

- (BOOL)ignoreCase;
- (BOOL)ignoreControlCharacters;

- (void)togglePropagation;
- (NSInteger)propagationMode;

- (BOOL)autoPropagateTranslationNone;
- (BOOL)autoPropagateTranslationSelectedFiles;
- (BOOL)autoPropagateTranslationAllFiles;

@end
