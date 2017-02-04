//
//  IGroupElementGlossary.h
//  iLocalize
//
//  Created by Jean Bovet on 10/31/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroupElement.h"

@class Glossary;

@interface IGroupElementGlossary : IGroupElement
{
    float      score;
    Glossary  *glossary;
}

@property float score;
@property (strong) Glossary *glossary;

+ (IGroupElementGlossary *)elementWithDictionary:(NSDictionary *)dic;

@end
