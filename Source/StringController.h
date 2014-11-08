//
//  StringController.h
//  iLocalize3
//
//  Created by Jean on 30.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "AbstractController.h"
#import "ProjectLabelsProtocol.h"
#import "StringControllerProtocol.h"

@class StringModel;
@class FindContentMatching;

@interface StringController : AbstractController <ProjectLabelPersistent, StringControllerProtocol> {
	StringModel		*baseStringModel;
	StringModel		*stringModel;	
	
	// Display only
	FindContentMatching *contentMatching;
	NSMutableArray	*mStatusDescription;	// description of each status icon used by the tooltips
	NSRect			mStatusImageRect;		// last rect used to display the status icons (currently only in project window)
	
	// Cache only
	StringController *baseStringController;
}

@property (strong) StringModel *baseStringModel;
@property (strong) StringModel *stringModel;
@property (strong) FindContentMatching *contentMatching;

- (void)copyBaseToTranslation;

- (void)markAsTranslated;
- (void)unmarkAsTranslated;

- (void)setModified:(int)what;
- (BOOL)isBaseString;

- (void)setStatus:(unsigned char)status;
- (unsigned char)status;
- (void)setStatusImageRect:(NSRect)r;
- (NSImage*)statusImage;
- (NSString*)statusDescriptionAtPosition:(NSPoint)p;
- (NSString*)statusDescription;

- (void)approve;
- (void)checkStatus;
- (void)updateStatus;
- (void)updateAutoStatus;

- (NSArray*)warningsKeys;

- (void)setStatusMarkAsTranslated:(BOOL)flag;
- (BOOL)statusMarkAsTranslated;

- (void)setStatusToTranslate:(BOOL)flag;
- (BOOL)statusToTranslate;

- (void)setStatusInvariant:(BOOL)flag;
- (BOOL)statusInvariant;

- (void)setStatusToCheck:(BOOL)flag;
- (BOOL)statusToCheck;

- (void)setStatusBaseModified:(BOOL)flag;
- (BOOL)statusBaseModified;

- (void)setStatusWarning:(BOOL)flag;
- (BOOL)statusWarning;

- (NSString*)key;

- (void)setBaseComment:(NSString*)comment;
- (NSString*)baseComment;

- (void)setBase:(NSString*)base;
- (NSString*)base;

- (StringController*)baseStringController;

- (void)setTranslationComment:(NSString*)comment;
- (NSString*)translationComment;

- (void)setAutomaticTranslation:(NSString*)translation;
- (void)setAutomaticTranslation:(NSString*)translation force:(BOOL)force;
- (void)setTranslation:(NSString*)translation;
- (NSString*)translation;

- (void)setLock:(BOOL)lock;
- (BOOL)lock;

- (BOOL)editable;

- (BOOL)baseLock;
- (BOOL)baseEditable;

- (StringController*)pBase;
- (id)pFile;
- (NSString*)pTranslation;

- (NSString*)pLabel;
- (NSArray*)pString;
- (NSString*)pComment;
- (NSString*)pKey;

@end