//
//  ProjectMenuGlossary.h
//  iLocalize
//
//  Created by Jean on 1/8/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "ProjectMenu.h"

@class GlossaryNewWC;
@class GlossaryScope;
@class GlossaryScopeWC;

@interface ProjectMenuGlossary : ProjectMenu
{
    GlossaryNewWC  *mGlossaryNew;
    GlossaryScope  *glossaryScope;
}

@property (nonatomic, strong) GlossaryScopeWC *scopeWC;

- (IBAction)newGlossary:(id)sender;
- (IBAction)newGlossaryWithCurrentLanguage:(id)sender;
- (IBAction)newGlossaryWithAllLanguages:(id)sender;

//- (IBAction)addToGlossary:(id)sender;
- (IBAction)updateInGlossary:(id)sender;

@end
