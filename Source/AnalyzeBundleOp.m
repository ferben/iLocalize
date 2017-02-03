//
//  AnalyzeBundleOp.m
//  iLocalize
//
//  Created by Jean Bovet on 2/13/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "AnalyzeBundleOp.h"
#import "LanguageTool.h"
#import "FileTool.h"
#import "AZPathNode.h"

@implementation AnalyzeBundleOp

@synthesize node;
@synthesize files;

- (id)init
{
    if((self = [super init])) {
        mProblems = [[NSMutableArray alloc] init];
        mOutsideNibs = [[NSMutableArray alloc] init];
        mCompiledNibs = [[NSMutableArray alloc] init];
        mDuplicateFiles = [[NSMutableArray alloc] init];
        mReadOnlyFiles = [[NSMutableArray alloc] init];
        
        mVisitedLanguages = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (NSString*)displayPath:(NSString*)file
{
    if(self.node) {
        return [file stringByRemovingPrefix:[self.node absolutePath]];                
    } else {
        return file;
    }
}

- (void)analyzeOutsideNib:(NSString*)file
{
    if([[LanguageTool languageOfFile:file] length] == 0) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[@"display"] = [self displayPath:file];
        info[@"file"] = file;            
        [mOutsideNibs addObject:info];
    }
}

- (void)analyzeCompiledNib:(NSString*)file
{
    BOOL compiled = [file isPathNibCompiledForIbtool];
    
    if(compiled) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[@"display"] = [self displayPath:file];
        info[@"file"] = file;        
        [mCompiledNibs addObject:info];
    }    
}

- (void)analyzeDuplicateFile:(NSString*)file
{
    NSString *language = [LanguageTool languageOfFile:file];
    NSString *isoLanguage = [language isoLanguage];
    NSMutableDictionary *duplicateFiles = mVisitedLanguages[isoLanguage];
    if(duplicateFiles == nil) {
        duplicateFiles = [NSMutableDictionary dictionary];
        mVisitedLanguages[isoLanguage] = duplicateFiles;
    }
    
    NSString *agnosticFile = [LanguageTool fileByDeletingLanguageComponent:file];
    
    NSString *previousLanguage = duplicateFiles[agnosticFile];
    if([previousLanguage isEquivalentToLanguage:language] && ![previousLanguage isEqualToString:language]) {
        // file is both in iso and legacy folder
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[@"display"] = [self displayPath:file];
        info[@"file"] = file;        
        [mDuplicateFiles addObject:info];
    }
    if(previousLanguage == nil) {
        duplicateFiles[agnosticFile] = language;        
    }
}

- (void)analyzeReadOnlyFile:(NSString*)file
{
    if(![file isPathWritable]) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[@"display"] = [self displayPath:file];
        info[@"file"] = file;        
        [mReadOnlyFiles addObject:info];        
    }
}

- (void)analyzeFile:(NSString*)file insideBundle:(BOOL)insideBundle
{
    if([file isPathNib]) {
        if(insideBundle) {
            [self analyzeOutsideNib:file];                    
        }
        [self analyzeCompiledNib:file];        
    }    
    if([file isPathRegular]) {
        [self analyzeDuplicateFile:file];                    
        [self analyzeReadOnlyFile:file];                        
    }    
}

- (void)collectOutsideNibs
{
    if([mOutsideNibs count] > 0) {
        NSMutableDictionary *description = [NSMutableDictionary dictionary];
        description[@"type"] = PROBLEM_OUTSIDE_NIBS;
        NSString *displayString;
        if(mOutsideNibs.count > 1) {
            displayString = NSLocalizedString(@"%d nib files are not located in language folder", @"");
        } else {
            displayString = NSLocalizedString(@"One nib file is not located in language folder", @"");            
        }
        description[@"typeDisplay"] = [NSString stringWithFormat:displayString, mOutsideNibs.count];
        description[@"tooltip"] = NSLocalizedString(@"Several nib files of this bundle are located outside of a language folder (e.g. a folder that has the .lproj suffix). These files will be ignored by iLocalize.", nil);                
        description[@"files"] = mOutsideNibs;
        [mProblems addObject:description];            
    }
}

- (void)collectCompiledNibs
{
    if([mCompiledNibs count] > 0) {
        NSMutableDictionary *description = [NSMutableDictionary dictionary];
        NSString *displayString;
        if(mCompiledNibs.count > 1) {
            displayString = NSLocalizedString(@"%d nib files are compiled and cannot be localized", @"");
        } else {
            displayString = NSLocalizedString(@"One nib file is compiled and cannot be localized", @"");
        }        
        description[@"type"] = PROBLEM_COMPILE_NIBS;
        description[@"typeDisplay"] = [NSString stringWithFormat:displayString, mCompiledNibs.count];
        description[@"tooltip"] = NSLocalizedString(@"Several nib files located in this bundle are compiled and cannot be localized. Try to contact the author of the bundle to obtain the non-compiled version of these nib files or if you are the developer, make sure to disable the IBC_FLATTEN_NIBS option before building your bundle.", nil);                
        description[@"files"] = mCompiledNibs;
        [mProblems addObject:description];            
    }
}

- (void)collectDuplicateFiles
{
    if([mDuplicateFiles count] > 0) {
        NSMutableDictionary *description = [NSMutableDictionary dictionary];
        description[@"type"] = PROBLEM_DUPLICATE_FILES;
        NSString *displayString;
        if(mDuplicateFiles.count > 1) {
            displayString = NSLocalizedString(@"%d files are duplicates", @"");
        } else {
            displayString = NSLocalizedString(@"One file is a duplicate", @"");
        }        
        description[@"typeDisplay"] = [NSString stringWithFormat:displayString, mDuplicateFiles.count];
        description[@"tooltip"] = NSLocalizedString(@"Several files in this bundle exist in two equivalent language folders (e.g. English.lproj and en.lproj). Make sure the file exists only in one language folder (e.g. either in English.lproj or en.lproj but not in both).", nil);                
        description[@"files"] = mDuplicateFiles;
        [mProblems addObject:description];            
    }
}

- (void)collectReadOnlyFiles
{
    if([mReadOnlyFiles count] > 0) {
        NSMutableDictionary *description = [NSMutableDictionary dictionary];
        description[@"type"] = PROBLEM_READONLY_FILES;
        NSString *displayString;
        if(mReadOnlyFiles.count > 1) {
            displayString = NSLocalizedString(@"%d files are read-only", @"");
        } else {
            displayString = NSLocalizedString(@"One file is read-only", @"");
        }        
        description[@"typeDisplay"] = [NSString stringWithFormat:displayString, mReadOnlyFiles.count];
        description[@"tooltip"] = NSLocalizedString(@"Several files in this bundle are read-only. Make sure they are writable in order for iLocalize to be able to localize them.", nil);                
        description[@"files"] = mReadOnlyFiles;
        [mProblems addObject:description];            
    }
}

- (BOOL)hasProblems
{
    return [mProblems count] > 0;
}

- (NSArray*)problems
{
    return mProblems;
}

- (void)execute
{
    [self setOperationName:NSLocalizedString(@"Analyzing Files for Problems…", nil)];
    
    // Reset results
    [mOutsideNibs removeAllObjects];
    [mCompiledNibs removeAllObjects];
    [mDuplicateFiles removeAllObjects];
    [mVisitedLanguages removeAllObjects];
    
    if(self.node) {
        for(NSString *path in [self.node selectedAbsolutePaths]) {
            [self analyzeFile:path insideBundle:YES];            
        }
    } else {
        for(NSString *file in self.files) {
            [self analyzeFile:file insideBundle:NO];            
        }
    }
        
    // Collect results
    [mProblems removeAllObjects];
    [self collectReadOnlyFiles];
    [self collectDuplicateFiles];
    [self collectOutsideNibs];
    [self collectCompiledNibs];    
}

@end
