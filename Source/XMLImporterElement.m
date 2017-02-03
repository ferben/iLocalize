//
//  XMLImporterElement.m
//  iLocalize
//
//  Created by Jean Bovet on 4/20/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XMLImporterElement.h"


@implementation XMLImporterElement

@synthesize file;
@synthesize key;
@synthesize source;
@synthesize translation;


- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ : [%@] %@ = %@", [super description], self.key, self.source, self.translation];
}

@end
