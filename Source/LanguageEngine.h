//
//  LanguageEngine.h
//  iLocalize3
//
//  Created by Jean on 13.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractEngine.h"
#import "BundleSource.h"

@interface LanguageEngine : AbstractEngine {

}

- (void)addLanguage:(NSString*)language;
- (void)addLanguage:(NSString*)language identical:(BOOL)identical layout:(BOOL)layout copyOnlyIfExists:(BOOL)copyOnlyIfExists source:(BundleSource*)source;
- (void)addLanguages:(NSArray*)languages identical:(BOOL)identical layout:(BOOL)layout copyOnlyIfExists:(BOOL)copyOnlyIfExists source:(BundleSource*)source;

- (void)renameLanguage:(NSString*)source toLanguage:(NSString*)target;

- (void)removeLanguage:(NSString*)language;

@end
