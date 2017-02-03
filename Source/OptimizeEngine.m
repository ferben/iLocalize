//
//  OptimizeEngine.m
//  iLocalize3
//
//  Created by Jean on 22.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "OptimizeEngine.h"
#import "OperationWC.h"
#import "Console.h"
#import "NibEngine.h"
#import "NibEngineResult.h"

@implementation OptimizeEngine

- (void)compactNibInApp:(NSString*)app
{
    // Remove info.nib and classes.nib file inside nib file
    
    [[self console] beginOperation:[NSString stringWithFormat:@"Compacting nib files in application \"%@\"", app] class:[self class]];

    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:app];
    NSString *relativeFile;
    while((relativeFile = [enumerator nextObject]) && ![[self operation] shouldCancel]) {
        
        NSString *file = [app stringByAppendingPathComponent:relativeFile];        
        if([file isPathNib]) {
            [[self console] addLog:[NSString stringWithFormat:@"Compacting nib file \"%@\"", file] class:[self class]];
            [[file stringByAppendingPathComponent:@"/info.nib"] removePathFromDisk];
            [[file stringByAppendingPathComponent:@"/classes.nib"] removePathFromDisk];                
            [[file stringByAppendingPathComponent:@"/designable.nib"] removePathFromDisk];
            if([file isPathNibBundle]) {
                [enumerator skipDescendents];                
            }
        }                    
    }    
    
    [[self console] endOperation];
}

- (void)upgradeNibInApp:(NSString*)app
{
    // Upgrade nib file into xib file
    
    [[self console] beginOperation:[NSString stringWithFormat:@"Upgrading nib files in application \"%@\"", app] class:[self class]];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:app];
    NSString *relativeFile;
    while((relativeFile = [enumerator nextObject]) && ![[self operation] shouldCancel]) {
        
        NSString *file = [app stringByAppendingPathComponent:relativeFile];
        if([file isPathNib]) {
            [[self console] addLog:[NSString stringWithFormat:@"Upgrading nib file \"%@\"", file] class:[self class]];
            NibEngine *ne = [NibEngine engineWithConsole:[self console]];
            NibEngineResult *r = [ne convertNibFile:file
                                          toXibFile:[[file stringByDeletingPathExtension] stringByAppendingString:@".xib"]];
            if(!r.success) {
                [[self console] addError:r.error description:r.description class:[self class]];
            } else {
                [file removePathFromDisk];
            }

            if([file isPathNibBundle]) {
                [enumerator skipDescendents];
            }
        }
    }
    
    [[self console] endOperation];
}

- (void)cleanApp:(NSString*)app
{
    // Remove ~.nib
    // Remove pbdevelopment.plist
    // Remove Resources Disabled
    
    [[self console] beginOperation:[NSString stringWithFormat:@"Cleaning application \"%@\"", app] class:[self class]];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:app];
    NSString *relativeFile;
    while((relativeFile = [enumerator nextObject]) && ![[self operation] shouldCancel]) {
        
        NSString *file = [app stringByAppendingPathComponent:relativeFile];        
        if([file hasSuffix:@"~.nib"]) {
            [[self console] addLog:[NSString stringWithFormat:@"Deleting file \"%@\"", file] class:[self class]];
            [file removePathFromDisk];            
        } else if([file hasSuffix:@"pbdevelopment.plist"]) {
            [[self console] addLog:[NSString stringWithFormat:@"Deleting file \"%@\"", file] class:[self class]];
            [file removePathFromDisk];                
        } else if([file hasSuffix:@"Resources Disabled"]) {
            [[self console] addLog:[NSString stringWithFormat:@"Deleting folder \"%@\"", file] class:[self class]];
            [file removePathFromDisk];
            [enumerator skipDescendents];
        } else if([file isPathNibBundle]) {
            [enumerator skipDescendents];
        }                    
    }    
    
    [[self console] endOperation];
}

@end
