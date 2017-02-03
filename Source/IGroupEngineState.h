//
//  IGroupEngineState.h
//  iLocalize
//
//  Created by Jean Bovet on 10/22/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"

@interface IGroupEngineState : NSObject<NSCopying> {
    NSString *baseLanguage;
    NSString *targetLanguage;
    NSString *selectedString;
    
    // transient properties
    BOOL languageChanged;
    BOOL selectedStringChanged;

    // if true, this state is outdated
    BOOL outdated;
}

@property (copy) NSString *baseLanguage;
@property (copy) NSString *targetLanguage;
@property (copy) NSString *selectedString;

@property (weak) id<ProjectProvider> projectProvider;
@property (assign) BOOL languageChanged;
@property (assign) BOOL selectedStringChanged;
@property (assign) BOOL outdated;

+ (IGroupEngineState*)stateWithOriginalState:(IGroupEngineState*)original;

@end
