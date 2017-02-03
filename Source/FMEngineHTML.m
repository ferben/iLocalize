//
//  FMEngineHTML.m
//  iLocalize3
//
//  Created by Jean on 28.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMEngineHTML.h"

#import "FileController.h"

#import "FileModel.h"
#import "FileModelContent.h"

#import "StringEncodingTool.h"
#import "HTMLEncodingTool.h"
#import "Constants.h"
#import "StringEncoding.h"

@implementation FMEngineHTML

- (BOOL)supportsStringEncoding
{
    return YES;    
}

- (BOOL)loadContentsOnlyWhenDisplaying
{
    return YES;
}

- (StringEncoding*)stringEncodingOfFile:(NSString*)file hasEncoding:(BOOL*)hasEncoding
{
    if(hasEncoding) *hasEncoding = NO;
    
    StringEncoding* encoding = [HTMLEncodingTool encodingOfFile:file hasEncoding:hasEncoding];
    if(hasEncoding && *hasEncoding) {
        return encoding;
    }
    
    encoding = [HTMLEncodingTool encodingOfContentInXMLHeader:file hasEncoding:hasEncoding];
    if(hasEncoding && *hasEncoding) {
        return encoding;
    }
    
    encoding = [HTMLEncodingTool encodingOfContent:file hasEncoding:hasEncoding];
    if(hasEncoding && *hasEncoding) {
        return encoding;
    }

    return ENCODING_UTF8;
}

- (StringEncoding*)stringEncodingOfFile:(NSString*)file content:(NSString**)content
{
    BOOL hasEncoding = NO;
    StringEncoding* encoding = [self stringEncodingOfFile:file hasEncoding:&hasEncoding];
    if(hasEncoding) {
        *content = [StringEncodingTool stringWithContentOfFile:file encoding:encoding];
    } else {
        *content = [StringEncodingTool stringWithContentOfFile:file encodingUsed:nil defaultEncoding:ENCODING_UTF8];
        if(*content == nil) {
            *content = [StringEncodingTool stringWithContentOfFile:file encoding:ENCODING_MACOS_ROMAN];        
            encoding = ENCODING_MACOS_ROMAN;
        } else {
            encoding = ENCODING_UTF8;
        }
    }    
    return encoding;
}

- (StringEncoding*)encodingOfFile:(NSString*)file language:(NSString*)language
{
    BOOL hasEncoding = NO;
    StringEncoding* encoding = [self stringEncodingOfFile:file hasEncoding:&hasEncoding];
    if(hasEncoding) {
        return encoding;
    } else {
        return [self encodingForLanguage:language];
    }
}

- (void)fmLoadEncoding:(NSString*)file intoFileModel:(FileModel*)fileModel
{
    NSString *content;
    [fileModel setEncoding:[self stringEncodingOfFile:file content:&content]];    
}

- (void)fmLoadFile:(NSString*)file intoFileModel:(FileModel*)fileModel
{
    NSString *content;
    [fileModel setEncoding:[self stringEncodingOfFile:file content:&content]];
    [[fileModel fileModelContent] setNonPersistentContent:YES];
    [[fileModel fileModelContent] setContent:content];
}

- (void)fmReloadFileController:(FileController*)fileController usingFile:(NSString*)file
{
    [self fmLoadFile:file intoFileModel:[fileController fileModel]];
}

- (void)fmSaveFileController:(FileController*)fileController usingEncoding:(StringEncoding*)encoding
{
    NSData *data = [StringEncodingTool encodeString:[fileController modelContent]
                                toDataUsingEncoding:encoding];        
    
    [data writeToFile:[fileController absoluteFilePath] atomically:NO];
}

- (BOOL)fmWillConvertFileController:(FileController*)fileController toEncoding:(StringEncoding*)encoding
{
    // Perform in-memory translation only if the encoding is changing
    if([fileController encoding] == encoding) return NO;
    
    if([fileController modelContent] == nil) {
        // The content is loaded only when the html file is made visible. Load it here because
        // we need to convert the content to the new specified encoding.
        [self fmLoadFile:[fileController absoluteFilePath] intoFileModel:[fileController fileModel]];    
    }
    
    NSString *content = [HTMLEncodingTool replaceEncodingInformationOfString:[fileController modelContent]
                                                      fromEncoding:[fileController encoding]
                                                        toEncoding:encoding];
    [fileController setModelContent:content];
    return YES;
}

@end
