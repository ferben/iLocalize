//
//  NibEngine.h
//  iLocalize3
//
//  Created by Jean on 22.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "AbstractStringsEngine.h"

@class Console;
@class StringsContentModel;
@class NibEngineResult;

@interface NibEngine : AbstractStringsEngine {
	NSString		*mNibFile;
	
	NSMutableData	*mTaskData;
	NSMutableData	*mTaskErrorData;
	
	Console			*mConsole;
}
+ (NibEngine*)engineWithConsole:(Console*)console;
+ (BOOL)ensureTool;
- (NSString*)nibtoolPath;
- (NSArray*)nibtoolArguments:(id)firstObject, ...;
- (NSString*)versionOfIbtool;
@end

@interface NibEngine (Parsing)
- (NSString*)stringsOfNibFile:(NSString*)nib;
- (StringsContentModel*)parseStringModelsFromText:(NSString*)text;
- (StringsContentModel*)parseStringModelsOfNibFile:(NSString*)nib;
@end

@interface NibEngine (Encoding)
- (void)translateNibFile:(NSString*)nibFile usingStringFile:(NSString*)stringFile;
- (void)translateNibFile:(NSString*)file usingStringModels:(StringsContentModel*)stringModels;
- (void)translateNibFile:(NSString*)nibFile usingLayoutFromNibFile:(NSString*)layoutNibFile;
- (void)translateNibFile:(NSString*)nibFile usingLayoutFromNibFile:(NSString*)layoutNibFile usingStringFile:(NSString*)stringFile;
- (void)translateNibFile:(NSString*)nibFile usingLayoutFromNibFile:(NSString*)layoutNibFile usingStringModels:(StringsContentModel*)stringModels;
@end

@interface NibEngine (Task)
- (NibEngineResult*)launchAndWaitTask:(NSTask*)task workingFile:(NSString*)workingFile;
@end

@interface NibEngine (Operations)
- (NSString*)strings;
- (NibEngineResult*)convertNibFile:(NSString*)nibFile toXibFile:(NSString*)xibFile;
- (BOOL)isNibFile:(NSString*)source identicalToFile:(NSString*)target error:(NSError**)error;
- (void)_translateNibFile:(NSString*)nibFile usingStringFile:(NSString*)stringFile;
- (void)_translateNibFile:(NSString*)nibFile usingLayoutFromNibFile:(NSString*)layoutNibFile;
- (void)_translateNibFile:(NSString*)nibFile usingLayoutFromNibFile:(NSString*)layoutNibFile usingStringFile:(NSString*)stringFile;
- (void)taskCompletedWithStatus:(int)status error:(NSString*)errorText output:(NSString*)outputText workingFile:(NSString*)workingFile task:(NSTask*)task;
@end
