//
//  IGroupEngineGlossary.h
//  iLocalize
//
//  Created by Jean Bovet on 10/18/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroupEngine.h"

@class GlossaryScope;

@interface IGroupEngineGlossary : IGroupEngine {
	GlossaryScope *scope;
}
@property (strong) GlossaryScope *scope;
@end
