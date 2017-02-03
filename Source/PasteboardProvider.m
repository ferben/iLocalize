//
//  PasteboardProvider.m
//  iLocalize3
//
//  Created by Jean on 24.07.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "PasteboardProvider.h"


@implementation PasteboardProvider

static PasteboardProvider *pb = nil;

+ (PasteboardProvider*)shared
{
    @synchronized(self) {
        if(pb == nil)
            pb = [[PasteboardProvider alloc] init];        
    }
    return pb;
}

- (id)init
{
    if(self = [super init]) {
        mTypes = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void)declareTypes:(NSArray*)types owner:(id)owner pasteboard:(NSPasteboard*)pb
{
    [pb declareTypes:types owner:self];
    
    NSString *type;
    for(type in types) {
        mTypes[type] = [NSValue valueWithNonretainedObject:owner];
    }
}

- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type
{
    NSValue *value = mTypes[type];
    if(value) {
        [[value nonretainedObjectValue] pasteboard:sender provideDataForType:type];
    }
}

- (void)removeOwner:(id)owner
{
    NSEnumerator *enumerator = [[mTypes allKeys] reverseObjectEnumerator];
    NSString *key;
    while(key = [enumerator nextObject]) {
        NSValue *value = mTypes[key];
        if([value nonretainedObjectValue] == owner)
            [mTypes removeObjectForKey:key];            
    }
}

@end
