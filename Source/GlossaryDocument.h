//
//  GlossaryDocument.h
//  iLocalize3
//
//  Created by Jean on 09.04.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "ProjectProvider.h"

@class GlossaryWC;
@class Glossary;

@interface GlossaryDocument : NSDocument {
    Glossary *glossary;
}
@property (strong) Glossary *glossary;
- (GlossaryWC*)glossaryWC;
@end
