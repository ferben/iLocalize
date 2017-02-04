//
//  XMLExporter.h
//  iLocalize
//
//  Created by Jean Bovet on 4/19/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "FileControllerProtocol.h"
#import "StringControllerProtocol.h"

@interface XMLExporter : NSObject
{
    NSString            *sourceLanguage;
    NSString            *targetLanguage;
    NSMutableString     *content;
    CallbackErrorBlock   errorCallback;
    NSUInteger           globalStringIndex;
}

@property (strong) NSString *sourceLanguage;
@property (strong) NSString *targetLanguage;
@property (strong, readonly) NSMutableString *content;
@property (copy) CallbackErrorBlock errorCallback;

+ (NSString *)writableExtension;

- (void)reportInvalidXMLCharacters:(NSString *)s location:(NSUInteger)location fc:(id<FileControllerProtocol>)fc sc:(id<StringControllerProtocol>)sc;

- (void)buildHeader;
- (void)buildFooter;

- (void)buildFile:(id<FileControllerProtocol>)fc;

@end
