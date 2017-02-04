//
//  DirtyContext.h
//  iLocalize
//
//  Created by Jean Bovet on 2/22/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@class StringController;
@class FileController;
@class LanguageController;
@class ProjectController;

/**
 This class contains the context associated with a dirty event.
 A dirty even is triggered whenever a controller state changes,
 for example when a string controller changes. The context helps keep
 track of which class changed so optimization can be done in the project
 window to refresh only the parties that are concerned.
 */
@interface DirtyContext : NSObject
{
}

@property (weak) StringController *sc;
@property (weak) FileController *fc;
@property (weak) LanguageController *lc;
@property (weak) ProjectController *pc;

+ (DirtyContext *)contextWithStringController:(StringController *)sc;
+ (DirtyContext *)contextWithFileController:(FileController *)sc;

- (void)accumulate:(DirtyContext *)other;
- (void)pushSource:(id)source;
- (void)reset;

@end
