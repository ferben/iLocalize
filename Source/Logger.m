//
//  Logger.m
//  ilocalize
//
//  Created by Jean Bovet on 12/20/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#import "Logger.h"


@implementation Logger

static NSMutableArray *_appenders = nil;
static BOOL logDebug = NO;

+ (void)initialize
{
	_appenders = [[NSMutableArray alloc] init];
	// Make the debug level output only if the environment variable "EnableDebugLog" is set.
	NSDictionary *env = [[NSProcessInfo processInfo] environment];
	logDebug = [env[@"EnableDebugLog"] boolValue];
}

+ (void)addAppender:(id<LogAppender>)appender
{
	[_appenders addObject:appender];
}

+ (void)removeAppender:(id<LogAppender>)appender
{
	[_appenders removeObject:appender];
}

+ (void)source:(id)source file:(NSString*)file line:(int)line func:(const char*)func text:(NSString*)text level:(int)level
{
	if(level == LEVEL_DEBUG && !logDebug) return;
	
//	NSLog(@"[%@ - %d] %@", [source class], line, text);
	NSMutableString *s = [NSMutableString string];
	switch (level) {
		case LEVEL_DEBUG:
			[s appendString:@"[DEBUG]"];
			break;
		case LEVEL_LOG:
			[s appendString:@"[LOG]"];
			break;
		case LEVEL_ERROR:
			[s appendString:@"[ERROR]"];
			break;
		default:
			break;
	}
	[s appendFormat:@" class=%@, method=%s, message=%@", [source class], func, text];
	NSLog(@"%@", s);
	for(id<LogAppender> appender in _appenders) {
		[appender logText:text source:source file:file line:line];
	}
}

#pragma mark -

+ (NSString *)errorDescription:(NSError *)error
{
	NSString *domain = [error domain];
	NSInteger code = [error code];
	
	NSMutableString *reason = [NSMutableString string];
    
	if ([domain isEqualToString:NSCocoaErrorDomain] && code >= NSValidationErrorMinimum && code <= NSValidationErrorMaximum)
    {
		// Core data validation error
		if (error.code == NSValidationMultipleErrorsError)
        {
			[reason appendFormat:@"Multiple validation errors: %@", [error userInfo][@"NSDetailedErrors"]];
		}
        else
        {
			[reason appendFormat:@"Validation error: %@", [error description]];
		}
    }
    else
    {
		// Other type of error
		[reason appendFormat:@"Error: %@", [error description]];
	}
	
    return reason;
}

#define EXCEPTION_REASON @"ReasonException"
#define EXCEPTION_ERROR @"ErrorException"

+ (NSString*)exceptionDescription:(NSException*)e
{
	if([[e name] isEqualToString:EXCEPTION_ERROR]) {
		return [Logger errorDescription:[e userInfo][@"error"]];
	} else {
		return [e description];
	}
}

+ (void)throwExceptionWithReason:(NSString*)formatString, ...
{
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	userInfo[@"file"] = FILE_STRING;
	userInfo[@"line"] = @__LINE__;

	NSString *reason;
	va_list args;
    va_start(args, formatString);
    reason = [[NSString alloc] initWithFormat:formatString arguments:args];
    va_end(args);
	
	[[NSException exceptionWithName:EXCEPTION_REASON
							 reason:reason
						   userInfo:userInfo] raise];	
}

+ (void)throwErrorException:(NSError*)error
{
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	userInfo[@"error"] = error;

	[[NSException exceptionWithName:EXCEPTION_ERROR 
							 reason:[self errorDescription:error]
						   userInfo:userInfo] raise];
}

+ (NSError*)errorWithMessage:(NSString*)format, ...
{
	NSString *reason;
	va_list args;
    va_start(args, format);
    reason = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
	
	NSDictionary *errorInfo = @{NSLocalizedDescriptionKey: reason};
	return [NSError errorWithDomain:ILErrorDomain code:100 userInfo:errorInfo];
}

@end
