//
//  XMLExporter.m
//  iLocalize
//
//  Created by Jean Bovet on 4/19/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XMLExporter.h"

@implementation XMLExporter

@synthesize sourceLanguage;
@synthesize targetLanguage;
@synthesize content;
@synthesize errorCallback;

- (id) init
{
    self = [super init];
    if (self != nil) {
        content = [[NSMutableString alloc] init];
        globalStringIndex = 0;
    }
    return self;
}


+ (NSString*)writableExtension
{
    return @"xml";
}

- (void)reportInvalidXMLCharacters:(NSString*)s location:(NSUInteger)location fc:(id<FileControllerProtocol>)fc sc:(id<StringControllerProtocol>)sc
{
    NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Invalid character 0x%x detected in string \"%@\" for file \"%@\"", @"XLIFF Export"), [s characterAtIndex:location], s, [fc filename]];
    NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: description};
    NSError *error = [NSError errorWithDomain:ILErrorDomain code:100 userInfo:errorInfo];    
    if(errorCallback) {
        errorCallback(error);
    } else {
        ERROR(@"Error while exporting in XML: %@", [error description]);
    }
}

- (void)buildHeader 
{
    // subclass    
}

- (void)buildFooter
{
    // subclass
}

- (void)buildFileHeader:(id<FileControllerProtocol>)fc
{
    // subclass
}

- (void)buildFileFooter:(id<FileControllerProtocol>)fc
{
    // subclass
}

/**
 Builds a single string.
 @param sc The string controller
 @param index The index relative to the file
 @param globalIndex The global index, encompassing all the files
 @param fc The file controller of the file containing the string or null if no file
 */
- (void)buildStringWithString:(id<StringControllerProtocol>)sc index:(NSUInteger)index globalIndex:(NSUInteger)globalIndex file:(id<FileControllerProtocol>)fc
{
    // subclass
}

- (void)buildFile:(id<FileControllerProtocol>)fc
{
    [self buildFileHeader:fc];
    
    // Header for the file        
    NSUInteger counter = 0;
    for(id<StringControllerProtocol> sc in [fc filteredStringControllers]) {
        @autoreleasepool {

            NSString *base = [sc base];
            NSUInteger baseCharLocation;
            if(![base containsValidXMLCharacters:&baseCharLocation]) {
                [self reportInvalidXMLCharacters:base location:baseCharLocation fc:fc sc:sc];
                continue;
            }
            NSString *translation = [sc translation];
            if(![translation containsValidXMLCharacters:&baseCharLocation]) {
                [self reportInvalidXMLCharacters:translation location:baseCharLocation fc:fc sc:sc];
                continue;
            }
            
            [self buildStringWithString:sc index:counter globalIndex:globalStringIndex file:fc];
            
            counter++;
            globalStringIndex++;
        
        }
    }
    
    [self buildFileFooter:fc];
}

@end
