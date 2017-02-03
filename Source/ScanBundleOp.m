//
//  FilterBundleOp.m
//  iLocalize
//
//  Created by Jean Bovet on 5/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ScanBundleOp.h"
#import "FileOperationManager.h"
#import "AZPathNode.h"

@implementation ScanBundleOp

@synthesize path;
@synthesize node;

- (id)init
{
    if (self = [super init])
    {
    }
    
    return self;
}


- (void)analyzePath
{
    // Retrieve all the files in the source path
    NSMutableArray *files = [NSMutableArray array];
    FileOperationManager *fm = [FileOperationManager manager];
    
    [fm enumerateDirectory:self.path files:files errorHandler:^(NSURL *url, NSError *error)
    {
        [self notifyError:error];
        return NO;
    }];
        
    // Now create the tree representation of the source path, using all the discovered files
    self.node = [AZPathNode rootNodeWithPath:self.path];
    [self.node beginModifications];
    
    for (NSString *file in files)
    {
        [self.node addRelativePath:file];
    }    

    [self.node endModifications];    
}

- (void)execute
{
    [self setOperationName:NSLocalizedString(@"Analyzing…", nil)];
    
    [self analyzePath];        
  
    // Import only the localized resources if the source path is not an application that iLocalize can launch.
    // This is because non-localized resources are not useful if the app cannot be launched.
    [self.node setUseLocalizedOnly:![self.path isPathApplication]];
    
    // Use placeholder so the user can choose the languages for each folder that contains some
    [self.node setUseLanguagePlaceholder:YES];
    
    // Select all the paths by default
    [self.node applyState:NSOnState];    
}

@end
