//
//  XLIFFExportOperation.m
//  iLocalize
//
//  Created by Jean Bovet on 3/23/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XLIFFExportOperation.h"
#import "XLIFFExportSettings.h"
#import "XMLExporter.h"
#import "SEIManager.h"
#import "FileController.h"
#import "StringController.h"
#import "Console.h"

@implementation XLIFFExportOperation

@synthesize settings;

- (NSString*)buildXLIFF
{
    XMLExporter *exporter = [[SEIManager sharedInstance] exporterForFormat:self.settings.format];
    exporter.sourceLanguage = self.settings.sourceLanguage;
    exporter.targetLanguage = self.settings.targetLanguage;
    exporter.errorCallback = ^(NSError *error) {
        [self notifyWarning:error];
    };
    
    [exporter buildHeader];
    for(id<FileControllerProtocol> fc in self.settings.files) {
        [[self console] beginOperation:[NSString stringWithFormat:@"Export file %@", [fc relativeFilePath]] class:[self class]];
        [exporter buildFile:fc];
        [self progressIncrement];
        [[self console] endOperation];
    }
    [exporter buildFooter];    
    
    return exporter.content;
}

- (void)execute
{
    [self setOperationName:NSLocalizedString(@"Exporting…", nil)];
    [self setProgressMax:self.settings.files.count];
            
    [[self console] beginOperation:@"Export XML" class:[self class]];
     
    NSString *content = [self buildXLIFF];
    
    if([self.settings.targetFile isPathExisting]) {
        [self.settings.targetFile removePathFromDisk];
    }
    
    NSError *error = nil;
    if(![content writeToFile:self.settings.targetFile atomically:NO encoding:NSUTF8StringEncoding error:&error]) {
        [self notifyError:error];
    }
    
    [[self console] endOperation];    
}

@end
