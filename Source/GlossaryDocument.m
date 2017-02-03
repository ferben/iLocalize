//
//  GlossaryDocument.m
//  iLocalize3
//
//  Created by Jean on 09.04.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "GlossaryDocument.h"
#import "GlossaryWC.h"
#import "GlossaryNewWC.h"

#import "Glossary.h"
#import "GlossaryEntry.h"
#import "GlossaryManager.h"

#import "SEIConstants.h"
#import "SEIManager.h"
#import "StringTool.h"

@implementation GlossaryDocument

@synthesize glossary;

- (id)init
{
    if(self = [super init]) {
        glossary = [[Glossary alloc] init];
    }
    return self;
}


- (void)makeWindowControllers
{        
    GlossaryWC *wc = [GlossaryWC controller];
    wc.glossary = glossary;
    [wc reload];
    [self addWindowController:wc];
}

- (GlossaryWC*)glossaryWC
{
    return [self windowControllers][0];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    glossary.file = [absoluteURL path];
    glossary.targetFile = glossary.file;
    
    BOOL success = [glossary loadContent];

    // Make sure all the entries are unescaped
    BOOL unescaped = NO;
    for(GlossaryEntry *entry in [glossary entries]) {
        NSString *source = [StringTool unescapeDoubleQuoteInString:entry.source];
        if(![source isEqualToString:entry.source]) {
            unescaped = YES;
            entry.source = source;
        }
        NSString *target = [StringTool unescapeDoubleQuoteInString:entry.translation];
        if(![target isEqualToString:entry.translation]) {
            unescaped = YES;
            entry.translation = target;
        }        
    }
    if(unescaped) {
        // Some entries were unescaped.
        [self updateChangeCount:NSChangeDone];
    }
    
    return success;    
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    SEI_FORMAT format = [[SEIManager sharedInstance] formatOfDocType:typeName defaultFormat:glossary.format];
    if(format == NO_FORMAT) {
        ERROR(@"No format found for type name: %@", typeName);
        return NO;
    }

    [[self glossaryWC] applyChanges];
    
    glossary.format = format;
    glossary.file = [[self fileURL] path];
    glossary.targetFile = [absoluteURL path];
    return [glossary writeToFile:outError];
}

@end
