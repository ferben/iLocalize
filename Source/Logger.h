//
//  Logger.h
//  ilocalize
//
//  Created by Jean Bovet on 12/20/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

#define LEVEL_DEBUG 0
#define LEVEL_LOG 1
#define LEVEL_ERROR 2

#define FILE_STRING [NSString stringWithUTF8String:__FILE__]

#define LOG_DEBUG(format, ...) [Logger source:self file:FILE_STRING \
line:__LINE__ \
func:__PRETTY_FUNCTION__ \
text:[NSString stringWithFormat:format, ##__VA_ARGS__] level:LEVEL_DEBUG];

#define LOG(format, ...) [Logger source:self file:FILE_STRING \
line:__LINE__ \
func:__PRETTY_FUNCTION__ \
text:[NSString stringWithFormat:format, ##__VA_ARGS__] level:LEVEL_LOG];

#define ERROR(format, ...) [Logger source:self file:FILE_STRING \
line:__LINE__ \
func:__PRETTY_FUNCTION__ \
text:[NSString stringWithFormat:format, ##__VA_ARGS__] level:LEVEL_ERROR];

#define EXCEPTION(e) ERROR(@"%@", [Logger exceptionDescription:(e)])

#define EXCEPTION2(descr, e) ERROR(@"%@: %@", descr, [Logger exceptionDescription:(e)])

@protocol LogAppender
- (void)logText:(NSString*)text source:(id)source file:(NSString*)file line:(int)line;
@end

@interface Logger : NSObject {

}

+ (void)addAppender:(id <LogAppender>)appender;
+ (void)removeAppender:(id <LogAppender>)appender;
+ (void)source:(id)source file:(NSString*)file line:(int)line func:(const char*)func text:(NSString*)text level:(int)level;

+ (NSString*)errorDescription:(NSError*)error;
+ (NSString*)exceptionDescription:(NSException*)e;

+ (void)throwExceptionWithReason:(NSString*)format, ...;
+ (void)throwErrorException:(NSError*)error;

+ (NSError*)errorWithMessage:(NSString*)format, ...;

@end
