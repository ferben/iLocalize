//
//  LanguageIdToTagTransformer.m
//  iLocalize
//
//  Created by Jean on 3/28/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "LanguageIdToTagTransformer.h"
#import "LanguageTool.h"
#import "LanguageInfoModel.h"

@implementation LanguageIdToTagTransformer

static NSMutableDictionary *identifierToTag = nil;
static NSMutableDictionary *tagToIdentifier = nil;

- (id)init
{
    if(self = [super init]) {
        if(!identifierToTag) {
            identifierToTag = [[NSMutableDictionary alloc] init];
        }
        if(!tagToIdentifier) {
            tagToIdentifier = [[NSMutableDictionary alloc] init];            
        }

        [identifierToTag removeAllObjects];
        [tagToIdentifier removeAllObjects];
        
        int tag = 0;
        for(LanguageInfoModel *model in [LanguageTool availableLanguageInfos]) {
            identifierToTag[model.identifier] = @(tag);
            tagToIdentifier[@(tag)] = model.identifier;
            tag++;
        }        
    }
    return self;
}

+ (Class)transformedValueClass
{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

// Language identifier to tag
- (id)transformedValue:(id)value
{
    return identifierToTag[value];
}

// tag to language identifier
- (id)reverseTransformedValue:(id)value
{
    return tagToIdentifier[value];
}

@end
