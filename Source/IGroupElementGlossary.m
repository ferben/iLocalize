//
//  IGroupElementGlossary.m
//  iLocalize
//
//  Created by Jean Bovet on 10/31/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "IGroupElementGlossary.h"


@implementation IGroupElementGlossary

@synthesize score;
@synthesize glossary;

+ (IGroupElementGlossary*)elementWithDictionary:(NSDictionary*)dic
{
	IGroupElementGlossary *e = [[self alloc] init];
	e.glossary = dic[@"glossary"];
	e.source = dic[@"base"];
	e.target = dic[@"translation"];
	e.score = [dic[@"score"] floatValue];
	return e;
}


@end
