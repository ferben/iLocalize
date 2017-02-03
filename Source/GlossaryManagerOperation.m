//
//  GlossaryManagerOperation.m
//  iLocalize
//
//  Created by Jean Bovet on 4/27/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "GlossaryManagerOperation.h"
#import "GlossaryManager.h"
#import "GlossaryNotification.h"
#import "GlossaryFolderDiff.h"
#import "SEIManager.h"

@implementation GlossaryManagerOperation

@synthesize folders;

- (id) init
{
    self = [super init];
    if (self != nil) {
        allowedExtensions = [[SEIManager sharedInstance] allImportableExtensions];
    }
    return self;
}


- (void)main
{
    if([self isCancelled]) return;
    
    GlossaryManager *gm = [GlossaryManager sharedInstance];

    @try {
        gm.processing = YES;
        [gm notifyGlossaryProcessingChanged:[GlossaryNotification notificationWithAction:PROCESSING_STARTED]];
        
        NSMutableDictionary *folderDiffs = [NSMutableDictionary dictionary];
        NSUInteger totalChangeCount = 0;
        
        // Analyze what needs to be updated
        for(GlossaryFolder *folder in self.folders) {
            GlossaryFolderDiff *diff = [GlossaryFolderDiff diffWithAllowedExtensions:allowedExtensions];
            NSUInteger itemCount = [diff analyzeFolder:folder];
            @synchronized(self) {
                totalChangeCount += itemCount;                
            }
            folderDiffs[[NSValue valueWithNonretainedObject:folder]] = diff;            
            if([self isCancelled]) {
                break;
            }
        };
        
        // Apply the changes
        if(![self isCancelled]) {
            __block NSUInteger currentChangeCount = 0;
            for(GlossaryFolder *folder in self.folders) {
                GlossaryFolderDiff *diff = folderDiffs[[NSValue valueWithNonretainedObject:folder]];
                GlossaryNotification *notif = [diff applyToFolder:folder callback:^BOOL() {
                    currentChangeCount++;
                    GlossaryNotification *n = [GlossaryNotification notificationWithAction:PROCESSING_UPDATED];
                    n.processingPercentage = (double)currentChangeCount/totalChangeCount*100;
                    [gm notifyGlossaryProcessingChanged:n];                        
                    return ![self isCancelled];
                }];
                if(notif) {
                    [gm notifyGlossaryChanged:notif];                
                }                
                
                if([self isCancelled]) {
                    break;
                }
            };            
        }
    }
    @catch (NSException * e) {
        EXCEPTION2(@"Error while detecting glossaries changes", e);
    }
    @finally {
        gm.processing = NO;
        [gm notifyGlossaryProcessingChanged:[GlossaryNotification notificationWithAction:PROCESSING_STOPPED]];
    }
}

@end
