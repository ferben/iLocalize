//
//  StringController.m
//  iLocalize3
//
//  Created by Jean on 30.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "StringController.h"
#import "FileController.h"
#import "ProjectController.h"
#import "LanguageTool.h"
#import "DirtyContext.h"
#import "StringModel.h"

#import "Constants.h"
#import "Preferences.h"
#import "CheckEngine.h"

#import "Explorer.h"

@interface StringController (PrivateMethods)
- (void)setAutomaticTranslation_:(NSString*)translation;
- (void)removeObserver;
@end

@implementation StringController

@synthesize baseStringModel;
@synthesize stringModel;
@synthesize contentMatching;

+ (void)initialize
{
//    [StringController setKeys:[NSArray arrayWithObjects:@"base", @"translation", @"baseComment", @"translationComment", @"lock", @"status", @"labelIndexes", nil]
//					triggerChangeNotificationsForDependentKey:@"selfValue"];
//	
//    [StringController setKeys:[NSArray arrayWithObjects:@"base", nil]
//					triggerChangeNotificationsForDependentKey:@"baseInfo"];
//	
//    [StringController setKeys:[NSArray arrayWithObjects:@"translation", nil]
//					triggerChangeNotificationsForDependentKey:@"translationInfo"];
//	
//    [StringController setKeys:[NSArray arrayWithObjects:@"baseComment", nil]
//					triggerChangeNotificationsForDependentKey:@"baseCommentInfo"];
	
//    [StringController setKeys:[NSArray arrayWithObjects:@"translationComment", nil]
//					triggerChangeNotificationsForDependentKey:@"translationCommentInfo"];
//	
//    [StringController setKeys:[NSArray arrayWithObjects:@"lock", nil]
//					triggerChangeNotificationsForDependentKey:@"editable"];
//	
//    [StringController setKeys:[NSArray arrayWithObjects:@"lock", nil]
//					triggerChangeNotificationsForDependentKey:@"baseEditable"];
	
//    [StringController setKeys:[NSArray arrayWithObjects:@"baseComment", nil]
//					triggerChangeNotificationsForDependentKey:@"base"];
//    [StringController setKeys:[NSArray arrayWithObjects:@"translationComment", nil]
//					triggerChangeNotificationsForDependentKey:@"translation"];
}

+ (NSSet*)keyPathsForValuesAffectingSelfValue
{
	return [NSSet setWithObjects:@"base", @"translation", @"baseComment", @"translationComment", @"lock", @"status", @"labelIndexes", nil];
}

+ (NSSet*)keyPathsForValuesAffectingBaseInfo
{
	return [NSSet setWithObjects:@"base", nil];
}

+ (NSSet*)keyPathsForValuesAffectingTranslationInfo
{
	return [NSSet setWithObjects:@"translation", nil];
}

+ (NSSet*)keyPathsForValuesAffectingBaseCommentInfo
{
	return [NSSet setWithObjects:@"baseComment", nil];
}

+ (NSSet*)keyPathsForValuesAffectingTranslationCommentInfo
{
	return [NSSet setWithObjects:@"translationComment", nil];
}

+ (NSSet*)keyPathsForValuesAffectingEditable
{
	return [NSSet setWithObjects:@"lock", nil];
}

+ (NSSet*)keyPathsForValuesAffectingBaseEditable
{
	return [NSSet setWithObjects:@"lock", nil];
}

// The following two bindings are used to update the comments of a string. The cell is bound in IB to the base/translation
// while the custom cell needs to have the StringModel object to display also the corresponding comments: the StringModel is
// passed in the TableViewCustom willDisplay method (using the custom delegate) but when a comment is modified in the interface,
// the only way to update the custom cell is to bind to the base/translation in order to the cell to be automatically refreshed
// by the binding mechanism.
+ (NSSet*)keyPathsForValuesAffectingBase
{
	return [NSSet setWithObjects:@"baseComment", nil];
}
+ (NSSet*)keyPathsForValuesAffectingTranslation
{
	return [NSSet setWithObjects:@"translationComment", nil];
}

#pragma mark -

- (id)init
{
	if((self = [super init])) {
		mStatusDescription = nil;
		mLabelIndexes = -1;
		baseStringController = nil;
	}
	return self;
}


#pragma mark -

- (void)copyBaseToTranslation
{
	if(![[self translation] isEqualToString:[self base]])
		[self setTranslation:[self base]];
	
	[self approve];
}

- (void)swapBaseAndTranslation
{
	NSString *temp = [[self translation] copy];
	[self setTranslation:[self base]];
	[self setBase:temp];
}

- (void)markAsTranslated
{
	[self beginDirty];
	[self setStatusMarkAsTranslated:YES];
	[self updateStatus];
	[self markDirty];
	[self endDirty];
}

- (void)unmarkAsTranslated
{
	[self beginDirty];
	[self setStatusMarkAsTranslated:NO];
	[self updateStatus];
	[self markDirty];
	[self endDirty];
}

- (void)clearBaseComment
{
	[self setBaseComment:@""];
}

- (void)clearTranslationComment
{
	[self setTranslationComment:@""];
}

- (void)clearComments
{
	[self clearBaseComment];
	[self clearTranslationComment];
}

- (void)clearTranslation
{
    [self setTranslation:@""];
}

#pragma mark -

- (void)setModified:(int)what
{
	[[self parent] setModified:what];	
}

- (BOOL)isBaseString
{
	return self.baseStringModel == self.stringModel;	
}

#pragma mark -

- (void)setStatus:(unsigned char)status
{
	if([self lock])
		return;

	if([self.stringModel status] != status) {
//		[(StringController*)[[self undoManager] prepareWithInvocationTarget:self] setStatus:[self status]];

		[self.stringModel setStatus:status];
	}
}

- (unsigned char)status
{
	return [self.stringModel status];
}

- (void)addStatusDescription:(NSString*)description forImage:(NSImage*)image
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"width"] = [NSNumber numberWithInt:[image size].width];
	dic[@"description"] = description;
	[mStatusDescription addObject:dic];
}

- (NSString*)statusDescriptionAtPosition:(NSPoint)p
{
	if(!NSPointInRect(p, mStatusImageRect))
		return nil;
	
	NSDictionary *info;
	int width = 0;
	for(info in mStatusDescription) {
		width += [info[@"width"] intValue];
		if(p.x - mStatusImageRect.origin.x <= width)
			return info[@"description"];
	}
	return nil;
}

- (NSString*)statusDescription
{
	NSMutableString *text = [NSMutableString string];
    for(NSDictionary *info in mStatusDescription) {
		if([text length] > 0) {
			[text appendString:@", "];			
		}
		[text appendString:info[@"description"]];
	}
	return text;
}

- (void)setStatusImageRect:(NSRect)r
{
	mStatusImageRect = r;
}

- (NSImage*)statusImage
{	
	NSMutableArray *images = [NSMutableArray array];
	NSImage *image;
	
	if(mStatusDescription == nil)
		mStatusDescription = [[NSMutableArray alloc] init];
	else
		[mStatusDescription removeAllObjects];
	
	[self checkStatus];

	if([self statusToTranslate]) {
		[images addObject:image = [NSImage imageNamed:@"string_to_translate"]];		
		[self addStatusDescription:NSLocalizedString(@"To translate", @"String status to translate") forImage:image];
	} else if([self statusInvariant]) {
		if([self statusToCheck]) {
			[images addObject:image = [NSImage imageNamed:@"string_auto_invariant"]];
			[self addStatusDescription:NSLocalizedString(@"Auto-invariant", @"String status auto-invariant") forImage:image];
		} else {
			[images addObject:image = [NSImage imageNamed:@"string_invariant"]];
			[self addStatusDescription:NSLocalizedString(@"Invariant", @"String status invariant") forImage:image];			
		}			
	} else {
		if([self statusToCheck]) {
			[images addObject:image = [NSImage imageNamed:@"string_auto_translated"]];		
			[self addStatusDescription:NSLocalizedString(@"Auto-translated", @"String status auto-translated") forImage:image];			
		}
	}
	
	if([self statusBaseModified]) {
		[images addObject:image = [NSImage imageNamed:@"string_base_modified"]];
		[self addStatusDescription:NSLocalizedString(@"Base string has changed", @"String status base string changed") forImage:image];					
	}
	if([self statusWarning]) {
		[images addObject:image = [NSImage imageNamed:@"_warning"]];
		NSArray *keys = [self warningsKeys];
		if([keys count]) {
			[self addStatusDescription:[keys componentsJoinedByString:@", "] forImage:image];					
		} else {
			[self addStatusDescription:NSLocalizedString(@"String has some inconsistencies", @"String status warning") forImage:image];								
		}
	}
		
	return [images imageUnion];
}

- (void)approve
{
	[self beginDirty];
	[self setStatusToCheck:NO];
	[self setStatusBaseModified:NO];
    [self setModified:MODIFY_STATUS];
	[self markDirty];
	[self endDirty];
}

- (BOOL)isInvariant
{
	BOOL ignoreCase = [[Preferences shared] ignoreCase];
	return [[self translation] isEqualToString:[self base] ignoreCase:ignoreCase];
}

- (void)checkStatus
{
	// Status:
	// - identical = invariant
	// - check + identical = auto-invariant
	// - different = translated
	// - check + different = auto-translated
	// - empty translation = to translate
	
	if([self status] & (1 << STRING_STATUS_NONE)) {		
		// Need to clear all bits before first computing
		[self setStatus:0];

		// No status if base string or base length is null
		if([self isBaseString] || [[self base] length] == 0)
			return;
			
		// If translation is equal to base, this is an invariant
		if([self isInvariant])
			[self setStatusInvariant:YES];

		// If translation is empty the string has to be translated ;-)
		if([[self translation] length] == 0)
			[self setStatusToTranslate:YES];		
	}
}

- (void)updateStatus
{
	[self checkStatus];
	
	[self setStatusToTranslate:NO];
	[self setStatusInvariant:NO];

	if(![self isBaseString] && [[self base] length] > 0) {
		if([[self translation] length] == 0) {
            [self setStatusToCheck:NO]; // Fix in 3.1.1 (because when to translate, to check is ignored)
			[self setStatusToTranslate:YES];				
		} else {
			if([self isInvariant])
				[self setStatusInvariant:YES];
			else
				[self setStatusInvariant:NO];				
		}
	}		
}

- (void)updateAutoStatus
{
	[self checkStatus];

	[self setStatusToCheck:YES];
	[self setStatusToTranslate:NO];
	
	if(![self isBaseString] && [[self base] length] > 0) {
		if([[self translation] length] == 0) {
            [self setStatusToCheck:NO]; // Fix in 3.1.1 (because when to translate, to check is ignored)
			[self setStatusToTranslate:YES];
		} else {
			if([self isInvariant])
				[self setStatusInvariant:YES];
			else
				[self setStatusInvariant:NO];				
		}
	}			
}

- (NSString*)displayableWarningKey:(NSString*)key
{
	if([key isEqualToString:WARNING_DUPLICATE_KEYS]) {
		return NSLocalizedString(@"Duplicate keys", @"String warning");
	}
	if([key isEqualToString:WARNING_MISSING_KEYS]) {
		return NSLocalizedString(@"Missing keys", @"String warning");		
	}
	if([key isEqualToString:WARNING_MISMATCH_KEYS]) {
		return NSLocalizedString(@"Unused keys", @"String warning");
	}
	if([key isEqualToString:WARNING_MISMATCH_FORMATTING_CHARS]) {
		return NSLocalizedString(@"Formatting characters", @"String warning");
	}
	
	return nil;
}

- (NSArray*)warningsKeys
{
	NSMutableArray *keys = [NSMutableArray array];
	NSMutableDictionary *info = [[self parent] auxiliaryDataForKey:@"warning_info"];    
	NSEnumerator *enumerator = [info keyEnumerator];
	NSString *key;
	while((key = [enumerator nextObject])) {
		NSString *displayableKey = nil;
		
		id content = info[key];
		if([content isKindOfClass:[NSSet class]] || [content isKindOfClass:[NSArray class]]) {
			if([content containsObject:[self key]])
			{
				displayableKey = [self displayableWarningKey:key];
			}			
		}
		if([content isKindOfClass:[NSDictionary class]]) {
			if(content[[self key]])
			{
				displayableKey = [self displayableWarningKey:key];
			}			
		}
		
		if(displayableKey) {
			[keys addObject:displayableKey];			
		}
	}	
	return keys;
}

#pragma mark -

#define STATUS_BIT_SET(bit) { [self setStatus:[self.stringModel status] | (1 << bit)]; }
#define STATUS_BIT_CLEAR(bit) { [self setStatus:[self.stringModel status] & ~(1 << bit)]; }

- (BOOL)statusBitTest:(long)bit
{
	NSAssert(bit >= 0 && bit <= 7, @"StringController: * WARNING * cannot handle more than 8 bits");
	return [self.stringModel status] & (1 << bit);
}

- (void)setStatusMarkAsTranslated:(BOOL)flag
{
	if([self statusMarkAsTranslated] == flag)
		return;
	
	if(flag) {
		STATUS_BIT_SET(STRING_STATUS_MARKASTRANSLATED);		
	} else {
		STATUS_BIT_CLEAR(STRING_STATUS_MARKASTRANSLATED);		
	}
}

- (BOOL)statusMarkAsTranslated
{
	return [self statusBitTest:STRING_STATUS_MARKASTRANSLATED];
}

- (void)setStatusToTranslate:(BOOL)flag
{
	if([self statusToTranslate] == flag)
		return;
	
	if(flag) {
		STATUS_BIT_SET(STRING_STATUS_TOTRANSLATE);		
	} else {
		STATUS_BIT_CLEAR(STRING_STATUS_TOTRANSLATE);		
	}
}

- (BOOL)statusToTranslate
{
	if([self statusMarkAsTranslated]) {
		return NO;
	} else {
		return [self statusBitTest:STRING_STATUS_TOTRANSLATE];		
	}
}

- (void)setStatusInvariant:(BOOL)flag
{
	if([self statusInvariant] == flag)
		return;

	if(flag) {
		STATUS_BIT_SET(STRING_STATUS_INVARIANT);		
	} else {
		STATUS_BIT_CLEAR(STRING_STATUS_INVARIANT);		
	}
}

- (BOOL)statusInvariant
{
	return [self statusBitTest:STRING_STATUS_INVARIANT];
}

- (void)setStatusToCheck:(BOOL)flag
{
	if([self statusToCheck] == flag)
		return;

	if(flag) {
		STATUS_BIT_SET(STRING_STATUS_TOCHECK);		
	} else {
		STATUS_BIT_CLEAR(STRING_STATUS_TOCHECK);		
	}
}

- (BOOL)statusToCheck
{
	return [self statusBitTest:STRING_STATUS_TOCHECK];	
}

- (void)setStatusBaseModified:(BOOL)flag
{
	if([self statusBaseModified] == flag)
		return;

	if(flag) {
		STATUS_BIT_SET(STRING_STATUS_BASE_MODIFIED);		
	} else {
		STATUS_BIT_CLEAR(STRING_STATUS_BASE_MODIFIED);		
	}
}

- (BOOL)statusBaseModified
{
	return [self statusBitTest:STRING_STATUS_BASE_MODIFIED];
}

- (void)setStatusWarning:(BOOL)flag
{
	if([self statusWarning] == flag)
		return;

	if(flag) {
		STATUS_BIT_SET(STRING_STATUS_WARNING);		
	} else {
		STATUS_BIT_CLEAR(STRING_STATUS_WARNING);		
	}
}

- (BOOL)statusWarning
{
	return [self statusBitTest:STRING_STATUS_WARNING];
}

#pragma mark -

- (void)setLabelIndexes:(NSSet*)indexes
{
	[self.stringModel setLabelIndexes:indexes];	
	[self updateLabelIndexes];
	[[self parent] stringLabelsDidChange];
}

- (NSSet*)labelIndexes
{
	return [self.stringModel labelIndexes];
}

#pragma mark -

- (void)setKey:(NSString*)key
{
	[self.stringModel setKey:key];
}

- (NSString*)key
{
	return [self.stringModel key];
}

#pragma mark -

- (void)setBaseComment:(NSString*)comment
{
	if(![[self.baseStringModel comment] isEqualToString:comment]) {
//		[[[self undoManager] prepareWithInvocationTarget:self] setBaseComment:[self baseComment]];

		[self.baseStringModel setComment:comment];
		self.contentMatching = nil;
		[self setModified:MODIFY_COMMENT];
	}
}

- (NSString*)baseComment
{
	return [self.baseStringModel comment];
}

- (void)notifyBaseStringChanged
{
	[[[self projectProvider] projectController] baseStringModelDidChange:self.baseStringModel fileController:[self parent]];
}

- (StringController*)baseStringController
{	
	@synchronized(self) {
		if(baseStringController == nil) {
			baseStringController = [[self parent] baseStringController:self];
		}
	}
	return baseStringController;
}

- (void)setBase:(NSString*)base
{
	if(![[self.baseStringModel value] isEqualToString:base]) {
//		[[[self undoManager] prepareWithInvocationTarget:self] setBase:[self base]];
		
		[self.baseStringModel setValue:base];
		self.contentMatching = nil;
				
		[self notifyBaseStringChanged];
	}
}

- (NSString*)base
{
	return [self.baseStringModel value];
}

#pragma mark -

- (void)setTranslationComment:(NSString*)comment
{
	if([self editable] == NO)
		return;
	
	if(![[self.stringModel comment] isEqualToString:comment]) {
//		[[[self undoManager] prepareWithInvocationTarget:self] setTranslationComment:[self translationComment]];

		[self.stringModel setComment:comment];
		self.contentMatching = nil;
		[self setModified:MODIFY_COMMENT];
	}
}

- (NSString*)translationComment
{
	return [self.stringModel comment];
}

- (void)setAutomaticTranslation:(NSString*)translation
{
	[self setAutomaticTranslation:translation force:NO];
}

// The force flag is used currently by iLocalize to differenciate between
// automatic translation coming from "soft" operations like glossary translation or
// propagation and "hard" operations like reloading a file where the translation
// has to be updated without considering any other status (because otherwise
// the state of the file won't be consistent with the one on the disk).
- (void)setAutomaticTranslation:(NSString*)translation force:(BOOL)force
{
	// Invoked when the translation is done by iLocalize (i.e. update)
	if(!force && ![self editable])
		return;
	
	if(![[self.stringModel value] isEqualToString:translation]) {
		// Make sure to perform this method on the main thread because it will trigger the bindings which will modify the UI
		// and may cause a dead-lock if called from another thread than the main one (NSTextView seems to dead-lock often)
		
		// FIX CASE 47: waitUntilDone to YES to prevent this issue
		[self performSelectorOnMainThread:@selector(setAutomaticTranslation_:) withObject:translation waitUntilDone:YES];
	}
}

// Method invoked to perform the raw translation: used to be executed in the main thread
- (void)setAutomaticTranslation_:(NSString*)translation
{
//	[[[self undoManager] prepareWithInvocationTarget:self] setAutomaticTranslation:[self translation]];
	[self.stringModel setValue:translation];
	self.contentMatching = nil;
	
	if([self isBaseString]) {
		[self willChangeValueForKey:@"base"];
		[self didChangeValueForKey:@"base"];	
		[self notifyBaseStringChanged];
	} else {
		[self willChangeValueForKey:@"translation"];
		[self didChangeValueForKey:@"translation"];			
	}

	[self beginDirty];
	[self setModified:MODIFY_TRANSLATION];
	[self updateAutoStatus];	
	[self markDirty];
	[self endDirty];
}

- (void)setTranslation:(NSString*)translation
{
	if([self editable] == NO)
		return;
		
	if(![[self.stringModel value] isEqualToString:translation]) {		
//		[[[self undoManager] prepareWithInvocationTarget:self] setTranslation:[self translation]];
		
		[self beginDirty];

		[self.stringModel setValue:translation];
		self.contentMatching = nil;

		[self checkStatus];
		
		if([self isBaseString]) {
			[self willChangeValueForKey:@"base"];
			[self didChangeValueForKey:@"base"];		
			[self notifyBaseStringChanged];
		}

		[self markDirty];

		// Note: needs to update the status before the modified method because
		// the modified method updates the file statistics
		[self updateStatus];
		[self setModified:MODIFY_TRANSLATION];
		[self endDirty];
	} else {
		[self updateStatus];
	}

	// Always unmark the check status when doing a manual translation
	[self setStatusToCheck:NO];		
}

- (NSString*)translation
{
	return [self.stringModel value];
}

#pragma mark -

- (NSString*)infoForLanguage:(NSString*)language length:(int)length
{
	NSString *displayLanguage = [language displayLanguageName];
	if(length <= 1) {
		return [NSString stringWithFormat:NSLocalizedString(@"%@ (%d character)", nil), displayLanguage, length];
	} else {
		return [NSString stringWithFormat:NSLocalizedString(@"%@ (%d characters)", nil), displayLanguage, length];		
	}
}

- (NSString*)baseInfo
{
	return [self infoForLanguage:[[self parent] baseLanguage] length:[[self base] length]];
}

- (NSString*)baseCommentInfo
{
	return [self infoForLanguage:[[self parent] baseLanguage] length:[[self baseComment] length]];
}

- (NSString*)translationInfo
{
	return [self infoForLanguage:[[self parent] language] length:[[self translation] length]];
}

- (NSString*)translationCommentInfo
{
	return [self infoForLanguage:[[self parent] language] length:[[self translationComment] length]];
}

#pragma mark -

- (void)setLock:(BOOL)lock
{
	if([self.stringModel lock] != lock) {
		[self beginDirty];
		[self markDirty];
		[self.stringModel setLock:lock];
		[self endDirty];
	}
}

- (BOOL)lock
{
	return [self.stringModel lock];
}

- (BOOL)editable
{
    if([self isBaseString]) {
        return [self baseEditable];
    } else {
        return ![self lock];        
    }
}

- (BOOL)baseLock
{
	return [self.baseStringModel lock];
}

- (BOOL)baseEditable
{
	return ![[Preferences shared] baseLanguageReadOnly] && ![self baseLock];
}

#pragma mark -

- (NSString*)pKey
{
	return [self key];
}

- (StringController*)pBase
{
	return [self baseStringController];
}

- (id)pFile
{
	return [self parent];
}

- (NSArray*)pString
{
	return @[self];
}

- (id)pStatus
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"toTranslate"] = @([self statusToTranslate]);
	dic[@"translated"] = [NSNumber numberWithBool:![self statusToTranslate]];
	dic[@"toCheck"] = @([self statusToCheck]);
	dic[@"invariant"] = @([self statusInvariant]);
	dic[@"baseModified"] = @([self statusBaseModified]);
	dic[@"warning"] = @([self statusWarning]);
	dic[@"locked"] = @([self lock]);
	return dic;
}

- (NSString*)pTranslation
{
	return [self translation];
}

- (NSString*)pComment
{
	return [self translationComment];
}

- (NSString*)pLabel
{
	if(mLabelString == nil) {
		[self updateLabelIndexes];
	}
	return mLabelString;
}

#pragma mark -

- (void)debugSetStatus:(NSNumber*)status
{
	int bit = [status intValue];
	STATUS_BIT_SET(bit);
}

- (void)debugClearStatus:(NSNumber*)status
{
	int bit = [status intValue];
	STATUS_BIT_CLEAR(bit);
}

@end
