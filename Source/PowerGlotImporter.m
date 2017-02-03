//
//  PowerGlotImporter.m
//  iLocalize
//
//  Created by Jean Bovet on 11/12/13.
//  Copyright (c) 2013 Arizona Software. All rights reserved.
//

#import "PowerGlotImporter.h"

@implementation PowerGlotImporter

- (NSArray*)readableExtensions
{
    return @[@"text", @"txt"];
}

- (BOOL)importDocument:(NSURL*)url error:(NSError**)error
{
    NSString *content = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:url] encoding:NSUTF8StringEncoding];
    if(content == NULL) {
        content = [NSString stringWithContentsOfURL:url usedEncoding:nil error:error];
        if (nil == content) {
            return NO;
        }
    }
    
    unsigned index = 0;
    while(index < [content length]) {
        // Source
        unsigned sourceIndex = index;
        while([content characterAtIndex:index] != '\t') {
            index++;
            if(index >= [content length]) {
                return [NSError errorWithDomain:ILErrorDomain code:322 userInfo:@{NSLocalizedDescriptionKey: @"Unable to find the source string"}];
                return NO;
            }
        }
        NSString *source = [content substringWithRange:NSMakeRange(sourceIndex, index-sourceIndex)];
        index++;
        
        // Target
        unsigned targetIndex = index;
        while([content characterAtIndex:index] != '\r') {
            index++;
            if(index >= [content length]) {
                return [NSError errorWithDomain:ILErrorDomain code:323 userInfo:@{NSLocalizedDescriptionKey: @"Unable to find the target string"}];
                return NO;
            }
        }
        NSString *target = [content substringWithRange:NSMakeRange(targetIndex, index-targetIndex)];
        index++;
        
        // Add
        [self addStringWithKey:nil base:source translation:target file:nil];
    }

    self.sourceLanguage = nil;
    self.targetLanguage = nil;
    
    return YES;
}

@end
