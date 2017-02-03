//
//  NSURL+Extensions.m
//  iLocalize
//
//  Created by Jean on 5/9/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "NSURL+Extensions.h"


@implementation NSURL (Extensions)

- (NSData *)createAliasData
{
    FSRef fsRef;
    
    if (CFURLGetFSRef((CFURLRef)self, &fsRef))
    {
        AliasHandle aliasHandle;
        OSErr err = FSNewAliasMinimal(&fsRef, &aliasHandle);
        
        if (err == noErr)
        {
            Size aliasSize = GetAliasSize(aliasHandle);
            return [NSData dataWithBytes:*aliasHandle length:aliasSize];            
        }
        else
        {
            NSLog(@"Failed to create alias record (%d) for URL %@", err, self);
        }
    }
    else
    {
        NSLog(@"Failed to create FSRef from URL %@", self);
    }
    
    return nil;
}

@end
