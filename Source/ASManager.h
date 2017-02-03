//
//  ASManager.h
//  iLocalize
//
//  Created by Jean on 12/2/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#define ATTRIBUTE_KEY_IMPORT_BASE @"ATTRIBUTE_KEY_IMPORT_BASE"
#define ATTRIBUTE_KEY_BASESOURCE @"ATTRIBUTE_KEY_BASESOURCE"
#define ATTRIBUTE_KEY_KEEPLAYOUTS @"ATTRIBUTE_KEY_KEEPLAYOUTS"

#define ATTRIBUTE_KEY_IMPORT_LOCALIZED @"ATTRIBUTE_KEY_IMPORT_LOCALIZED"
#define ATTRIBUTE_KEY_LOCALIZEDSOURCE @"ATTRIBUTE_KEY_LOCALIZEDSOURCE"
#define ATTRIBUTE_KEY_LANGUAGES @"ATTRIBUTE_KEY_LANGUAGES"
#define ATTRIBUTE_KEY_VERSIONIDENTICAL @"ATTRIBUTE_KEY_VERSIONIDENTICAL"
#define ATTRIBUTE_KEY_IMPORTLAYOUTS @"ATTRIBUTE_KEY_IMPORTLAYOUTS"
#define ATTRIBUTE_KEY_COPYONLYIFEXISTS @"ATTRIBUTE_KEY_COPYONLYIFEXISTS"
#define ATTRIBUTE_KEY_CONFLICTINGFILESDECISION @"ATTRIBUTE_KEY_CONFLICTINGFILESDECISION"

#define ATTRIBUTE_EXPORT_TARGET @"ATTRIBUTE_EXPORT_TARGET"
#define ATTRIBUTE_EXPORT_LANGUAGES @"ATTRIBUTE_EXPORT_LANGUAGES"
#define ATTRIBUTE_EXPORT_COMPRESS @"ATTRIBUTE_EXPORT_COMPRESS"
#define ATTRIBUTE_EXPORT_COMPACTNIB @"ATTRIBUTE_EXPORT_COMPACTNIB"
#define ATTRIBUTE_EXPORT_EMAIL @"ATTRIBUTE_EXPORT_EMAIL"
#define ATTRIBUTE_EXPORT_LOCALIZATION @"ATTRIBUTE_EXPORT_LOCALIZATION"

#define SCRIPT_OPERATION_UPDATE_BASE @"update base"
#define SCRIPT_OPERATION_UPDATE_LOCALIZED @"update localized"
#define SCRIPT_OPERATION_EXPORT @"export"

@protocol ASManagerDelegate
- (id)scriptAttributeForKey:(NSString*)key command:(NSScriptCommand*)cmd;
- (BOOL)scriptBoolValueForKey:(NSString*)key command:(NSScriptCommand*)cmd;
- (int)scriptIntValueForKey:(NSString*)key command:(NSScriptCommand*)cmd;
- (void)scriptOperationCompleted:(NSString*)op;
@end

@interface ASManager : NSObject {
    NSAppleEventManagerSuspensionID mSuspensionID;
    NSScriptCommand *mCommandInProgress;
    id mDelegate;
}

+ (ASManager*)shared;

- (void)beginAsyncCommand:(NSScriptCommand*)cmd delegate:(id<ASManagerDelegate>)delegate;
- (void)endAsyncCommandWithResult:(id)result;
- (void)endAsyncCommand;

- (void)beginSyncCommand:(NSScriptCommand*)cmd delegate:(id<ASManagerDelegate>)delegate;
- (void)endSyncCommand;

- (BOOL)isCommandInProgress;

- (id)attributeForKey:(NSString*)key;
- (BOOL)boolValueForKey:(NSString*)key;

- (id)attributeForKey:(NSString*)key defaultAttribute:(id)attribute;
- (BOOL)boolValueForKey:(NSString*)key defaultValue:(BOOL)value;
- (int)intValueForKey:(NSString*)key defaultValue:(int)value;

- (void)operationCompleted:(NSString*)op;

@end
