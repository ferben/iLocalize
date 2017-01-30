//
//  FileController.m
//  iLocalize3
//
//  Created by Jean on 30.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "FileController.h"
#import "LanguageController.h"
#import "StringController.h"
#import "DirtyContext.h"

#import "FileModel.h"
#import "FileModelContent.h"

#import "FileTool.h"
#import "ImageTool.h"
#import "StringEncodingTool.h"
#import "StringEncoding.h"

#import "FMManager.h"
#import "FMModule.h"
#import "FMEngine.h"

#import "SmartPathParser.h"
#import "Exploreritem.h"

#import "PreferencesLanguages.h"

#import "Constants.h"

@interface FileController (PrivateMethods)
- (void)computeStatistics;
@end

@implementation FileController

+ (void)initialize
{
//    [FileController setKeys:[NSArray arrayWithObjects:@"stringControllers", @"modificationDate", @"status", @"labelIndexes", nil]
//					triggerChangeNotificationsForDependentKey:@"selfValue"];
}

+ (NSSet*)keyPathsForValuesAffectingSelfValue
{
	return [NSSet setWithObjects:@"stringControllers", @"modificationDate", @"status", @"labelIndexes", nil];
}

#pragma mark -

- (id)init
{
	if((self = [super init])) {
		mBaseFileModel = NULL;
		mFileModel = NULL;
		
		mSmartPath = NULL;
		mFileModule = NULL;
		
		mMarkUsed = NO;
		mStatusDescription = nil;
		
		mStringsLabelIndexes = [[NSMutableSet alloc] init];
	}
	return self;
}


- (NSString*)description
{
	return [NSString stringWithFormat:@"%@ - %@", [super description], [self absoluteFilePath]];
}

- (void)changeSelfValueKey
{
	[self willChangeValueForKey:@"selfValue"];
	[self didChangeValueForKey:@"selfValue"];
}

- (void)clearCache
{
    
}

#pragma mark -

- (void)setBaseFileModel:(FileModel*)model
{
	mBaseFileModel = model;
}

- (FileModel*)baseFileModel
{
	return mBaseFileModel;
}

- (void)setFileModel:(FileModel*)model
{
	mFileModel = model;
}

- (FileModel*)fileModel
{
	return mFileModel;
}

- (void)markUsed
{
	mMarkUsed = YES;
	[self changeSelfValueKey];
}

- (void)unmarkUsed
{
	mMarkUsed = NO;
	[self changeSelfValueKey];
}

- (BOOL)isUsed
{
	return mMarkUsed;
}

- (void)setAuxiliaryData:(id)data forKey:(NSString*)key
{
	[[self fileModel] setAuxiliaryData:data forKey:key];
	[self setDirty];
}

- (id)auxiliaryDataForKey:(NSString*)key
{
	return [[self fileModel] auxiliaryDataForKey:key];
}

#pragma mark -

- (void)rebuildFromModel
{	
	// Subclasses should build themselves accordingly

	// Don't rebuild a local file
	if([self isLocal]) return;
	
	// Pre-version 4. Some local files were marked with localPlaceholder but this flag is not
	// available in version 4. If the fileModel is null, this file was a placeholder so skip it.
	if(!mFileModel) return;
	
	mFileModule = [[FMManager shared] fileModuleForFileExtension:[[self filename] pathExtension]];

	if(![self hasEncoding] && [self supportsEncoding]) {
		FMEngine *e = [[self projectProvider] fileModuleEngineForFile:[self absoluteFilePath]];		
		[self setEncoding:[e encodingOfFile:[self absoluteFilePath] language:[self language]]];

		[self setHasEncoding:YES];
		[self setDirty];
	}
	
    [self setStatusNotFound:![[self absoluteFilePath] isPathExisting]];        
	[self computeStatistics];	
	[self stringLabelsDidChange];
}

#pragma mark -

#define STATUS_BIT_SET(bit) { [self setStatus:[mFileModel status] | (1 << bit)]; }
#define STATUS_BIT_CLEAR(bit) { [self setStatus:[mFileModel status] & ~(1 << bit)]; }

- (BOOL)statusBitTest:(long)bit
{
	NSAssert(bit >= 0 && bit <= 7, @"FileController: * WARNING * cannot handle more than 8 bits");
	return [mFileModel status] & (1 << bit);
}

- (void)setStatusSynchDone
{
	if(![self statusSynchDone]) {
		STATUS_BIT_CLEAR(FILE_STATUS_SYNCH_TO_DISK);
		STATUS_BIT_CLEAR(FILE_STATUS_SYNCH_FROM_DISK);		
	}
}

- (BOOL)statusSynchDone
{
	return ![self statusSynchToDisk] && ![self statusSynchFromDisk];
}

- (void)setStatusSynchToDisk
{
	if(![self statusSynchToDisk]) {
		STATUS_BIT_SET(FILE_STATUS_SYNCH_TO_DISK);
		STATUS_BIT_CLEAR(FILE_STATUS_SYNCH_FROM_DISK);		
	}
}

- (BOOL)statusSynchToDisk
{
	return [self statusBitTest:FILE_STATUS_SYNCH_TO_DISK];
}

- (void)setStatusSynchFromDisk
{
	if(![self statusSynchFromDisk]) {
		STATUS_BIT_SET(FILE_STATUS_SYNCH_FROM_DISK);
		STATUS_BIT_CLEAR(FILE_STATUS_SYNCH_TO_DISK);		
	}
}

- (BOOL)statusSynchFromDisk
{
	return [self statusBitTest:FILE_STATUS_SYNCH_FROM_DISK];
}

- (void)setStatusWarning:(BOOL)flag
{
	if(flag && ![self statusWarning]) {
		STATUS_BIT_SET(FILE_STATUS_WARNING);			
	} else if(!flag && [self statusWarning]) {
		STATUS_BIT_CLEAR(FILE_STATUS_WARNING);			
	}	
}

- (BOOL)statusWarning
{
	return [self statusBitTest:FILE_STATUS_WARNING];
}

- (void)setStatusCheckLayout:(BOOL)flag
{
	if(![mFileModule supportsFlagLayout])
		return;
	
	if([self isBaseFileController])
		return;
			
	if(flag && ![self statusCheckLayout]) {
		STATUS_BIT_SET(FILE_STATUS_CHECK_LAYOUT);			
	} else if(!flag && [self statusCheckLayout]) {
		STATUS_BIT_CLEAR(FILE_STATUS_CHECK_LAYOUT);			
	}	
}

- (BOOL)statusCheckLayout
{
	return [self statusBitTest:FILE_STATUS_CHECK_LAYOUT];
}

- (void)setStatusNotFound:(BOOL)flag
{
	if(flag && ![self statusNotFound]) {
		STATUS_BIT_SET(FILE_STATUS_NOT_FOUND);			
	} else if(!flag && [self statusNotFound]) {
		STATUS_BIT_CLEAR(FILE_STATUS_NOT_FOUND);			
	}	
}

- (BOOL)statusNotFound
{
	return [self statusBitTest:FILE_STATUS_NOT_FOUND];
}

- (void)setStatusUpdateAdded:(BOOL)flag
{
	if(flag && ![self statusUpdateAdded]) {
		STATUS_BIT_SET(FILE_STATUS_UPDATE_ADDED);			
	} else if(!flag && [self statusUpdateAdded]) {
		STATUS_BIT_CLEAR(FILE_STATUS_UPDATE_ADDED);			
	}		
}

- (BOOL)statusUpdateAdded
{
	return [self statusBitTest:FILE_STATUS_UPDATE_ADDED];
}

- (void)setStatusUpdateUpdated:(BOOL)flag
{
	if(flag && ![self statusUpdateUpdated]) {
		STATUS_BIT_SET(FILE_STATUS_UPDATE_UPDATED);			
	} else if(!flag && [self statusUpdateUpdated]) {
		STATUS_BIT_CLEAR(FILE_STATUS_UPDATE_UPDATED);			
	}		
}

- (BOOL)statusUpdateUpdated
{
	return [self statusBitTest:FILE_STATUS_UPDATE_UPDATED];
}

- (BOOL)statusDone
{
	return [self statusSynchDone] && ![self statusCheckLayout];
}

- (void)setStatus:(int)status
{
	if([mFileModel status] != status) {
		[mFileModel setStatus:status];
		[self beginDirty];		
		[self changeSelfValueKey];
		[self markDirty];
		[self endDirty];
	}
}

// FIX CASE 42: don't return unsigned char because NSNumber does not work with unsigned number (known bug in CFNumber)
- (int)status
{
	return [mFileModel status];		
}

- (void)addStatusDescription:(NSString*)description forImage:(NSImage*)image
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"width"] = [NSNumber numberWithInt:[image size].width];
	dic[@"description"] = description;
	[mStatusDescription addObject:dic];
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
	
	// statusSynchToDisk is displayed using the bold font (see FileCustomCell)
	
	if([self statusNotFound]) {
		[images addObject:image = [NSImage imageNamed:@"_warning_red"]];
		[self addStatusDescription:NSLocalizedString(@"File does not exist on the disk", @"File Status") forImage:image];
	} else {
		if([self statusWarning]) {
			[images addObject:image = [NSImage imageNamed:@"_warning"]];					
			[self addStatusDescription:NSLocalizedString(@"File has warnings (double-click for more info)", @"File Status") forImage:image];
		}
		
		if([self statusSynchFromDisk]) {
			[images addObject:image = [NSImage imageNamed:@"_file_sync_from_disk"]];			
			[self addStatusDescription:NSLocalizedString(@"File needs to be reloaded", @"File Status") forImage:image];
		}
		
		if([self statusCheckLayout]) {
			[images addObject:image = [NSImage imageNamed:@"_file_check_layout"]];
			[self addStatusDescription:NSLocalizedString(@"File layout needs to be checked", @"File Status") forImage:image];
		}

		if([self statusUpdateAdded]) {
			[images addObject:image = [NSImage imageNamed:@"_file_added"]];
			[self addStatusDescription:NSLocalizedString(@"File has been added during last update", @"File Status") forImage:image];
		}
		
	}
	
	// FIX CASE 42
	if([self statusUpdateUpdated]) {
		[images addObject:image = [NSImage imageNamed:@"_file_updated"]];					
		[self addStatusDescription:NSLocalizedString(@"File has been updated", @"File Status") forImage:image];
	}
	
	return [images imageUnion];
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
	NSEnumerator *enumerator = [mStatusDescription objectEnumerator];
	NSDictionary *info;
	while(info = [enumerator nextObject]) {
		if([text length] > 0) {
			[text appendString:@", "];			
		}
		[text appendString:info[@"description"]];
	}
	return text;
}

- (void)approve
{
	[self setStatusCheckLayout:NO];
}

- (void)clearUpdatedStatus
{
	[self setStatusUpdateAdded:NO];
	[self setStatusUpdateUpdated:NO];	
}

- (BOOL)needsToUpdateStatus {
    NSString *file = [self absoluteFilePath];
	if([self statusNotFound] && [file isPathExisting] == YES) {
        return YES;
    }
	if(![self statusNotFound] && [file isPathExisting] == NO) {
        return YES;
    }

    return [[mFileModel modificationDate] compare:[file pathModificationDate]] != NSOrderedSame;
}

- (void)updateStatus
{
	NSString *file = [self absoluteFilePath];
	if([file isPathExisting] == NO) {
		[self setStatusNotFound:YES];
		return;
	} else {
		[self setStatusNotFound:NO];
	}

	switch([[mFileModel modificationDate] compare:[file pathModificationDate]]) {
		case NSOrderedAscending:		// File newer on disk
			[self setStatusSynchFromDisk];
			break;
		case NSOrderedDescending:		// File older on disk
			[self setStatusSynchToDisk];
			break;
		case NSOrderedSame:				// File identical on disk
			[self setStatusSynchDone];
			break;
	}
	
	[self changeSelfValueKey];
}

#pragma mark -

- (void)setDirty
{
	[self beginDirty];
	[self markDirty];
	[self endDirty];
}

/**
 Intercept this method call to update the statistics of the file.
 This method is invoked by this file controller but also by the string controllers
 which is why we need to update the statistics here.
 */
- (void)markDirty
{
	[self computeStatistics];
	[self updateStatus];
	[super markDirty];
}

- (void)setModified:(int)what
{
	// layout is not marked as "to check" if a comment has been modified
	[self setStatusCheckLayout:what != MODIFY_COMMENT];		
	[self setModificationDate:[NSDate date]];
}

- (BOOL)displayNumberOfStrings
{
	return NO;
}

- (BOOL)displayStatus
{
	return YES;
}

- (BOOL)displayProgress
{
	return NO;
}

#pragma mark -

- (BOOL)isBaseFileController
{
	return (mBaseFileModel == mFileModel);
}

- (FileController *)baseFileController
{
	return [[self parent] correspondingBaseFileControllerForFileController:self];
}

- (NSString *)baseLanguage
{
    return [[self parent] baseLanguage];
}

- (NSString*)language
{
	return [[self parent] language];
}

#pragma mark -

- (void)setModificationDate:(NSDate*)date
{
	[self changeSelfValueKey];

	[mFileModel setModificationDate:date];
	[self setDirty];
}

- (NSString*)filename
{
	return [mFileModel filename];		
}

- (NSString*)sortableFilename
{
	return [[self filename] lowercaseString];
}

- (NSString*)smartPathName
{
	return [[self smartPath] stringByAppendingPathComponent:[self filename]];
}

- (NSString*)smartPath
{
	if(mSmartPath == NULL)
		mSmartPath = [SmartPathParser smartPath:[self relativeFilePath]];
	return mSmartPath;
}

- (void)setRelativeFilePath:(NSString*)path
{
	[[self parent] removeFromCache:self];
	[mFileModel setRelativeFilePath:path];
	[[self parent] addToCache:self];
}

- (NSString*)relativeFilePath
{
	return [mFileModel relativeFilePath];		
}

- (NSString*)relativeBaseFilePath
{
	return [mBaseFileModel relativeFilePath];
}

- (NSString*)absoluteFilePath
{
	return [self absoluteProjectPathFromRelativePath:[mFileModel relativeFilePath]];
}

- (NSString*)absoluteBaseFilePath
{
	return [self absoluteProjectPathFromRelativePath:[mBaseFileModel relativeFilePath]];
}

#pragma mark -

/**
 Used by the table column to sort the column by type.
 */
- (NSString*)type
{
	return [mFileModule name];
}

- (NSImage*)typeImage
{
	// Version 3.4: use the Finder icon instead
	// Version 3.6: now with global/local files, check if the base file exists because in the
	//              case of local files, it does not.
	if([[self absoluteBaseFilePath] isPathExisting]) {
		return [[NSWorkspace sharedWorkspace] iconForFile:[self absoluteBaseFilePath]];		
	} else {
		return [[NSWorkspace sharedWorkspace] iconForFile:[self absoluteFilePath]];
	}
}

- (void)setIgnore:(BOOL)flag
{
	[mFileModel setIgnore:flag];
}

- (BOOL)ignore
{
	return [mFileModel ignore];
}

- (void)setLocal:(BOOL)flag
{
	[mFileModel setLocal:flag];
}

- (BOOL)isLocal
{
	return [mFileModel isLocal];
}

- (BOOL)supportOperation:(int)op
{
	if((op & OPERATION_REBUILD) > 0) {
		return ![self isLocal];
	}
	return YES;
}

#pragma mark -

- (void)setHasEncoding:(BOOL)flag
{
	[mFileModel setHasEncoding:flag];
}

- (BOOL)hasEncoding
{
	return [mFileModel hasEncoding];
}

- (void)setEncoding:(StringEncoding*)encoding
{
	[mFileModel setEncoding:encoding];
}

- (StringEncoding*)encoding
{
	return [mFileModel encoding];
}

- (NSString*)encodingName
{
	StringEncoding* encoding = [self encoding];
	if(encoding == 0) {
		return @"";
	} else {
		if(encoding.bom) {
			return [NSString stringWithFormat:NSLocalizedString(@"%@, with BOM", @"Encoding with BOM header"), encoding.encodingName];
		} else {
			return encoding.encodingName;
		}
	}
}

- (BOOL)supportsEncoding
{
	return NO;
}

#pragma mark -

- (void)setLabelIndexes:(NSSet*)indexes
{
	[mFileModel setLabelIndexes:indexes];	
	[self updateLabelIndexes];
	[self changeSelfValueKey];
}

- (NSSet*)labelIndexes
{
	return [mFileModel labelIndexes];
}

- (NSSet*)stringsLabelIndexes
{
	return mStringsLabelIndexes;
}

- (void)stringLabelsDidChange
{
	[mStringsLabelIndexes removeAllObjects];
	
	NSEnumerator *enumerator = [[self stringControllers] objectEnumerator];
	StringController *sc;
	while(sc = [enumerator nextObject]) {
		[mStringsLabelIndexes unionSet:[sc labelIndexes]];
	}	
}

#pragma mark -

- (void)computeStatistics
{
	// Subclass does the actual computing
}

// This value is used only by the binding for the NSTableColumn in order to
// display the items in the following order:
// (1) in progress file
// (2) file done (100%)
// (3) other files (n/a percentCompleted value)
- (float)percentCompletedSortValue
{
	float p = [self percentCompleted];
	if(p == -1) {
		return 2;
	} else if(p == 100) {
		return 1;
	} else {
		return -p;
	}
}

- (float)percentCompleted
{
	return -1;
}

- (float)percentTranslated
{
	return -1;
}

- (float)percentAutoTranslated
{
	return -1;
}

- (float)percentToTranslate
{
	return -1;
}

- (int)numberOfStrings
{
    return -1;
}

- (int)numberOfTranslatedStrings
{
	return -1;
}

- (int)numberOfNonTranslatedStrings
{
	return -1;
}

- (int)numberOfToCheckStrings
{
	return -1;
}

- (int)numberOfInvariantStrings
{
	return -1;
}

- (int)numberOfBaseModifiedStrings
{
	return -1;
}

- (int)numberOfLockedStrings
{
	return -1;
}

- (int)numberOfAutoTranslatedStrings
{
	return -1;
}

- (int)numberOfAutoInvariantStrings
{
	return -1;
}

#pragma mark -

- (int)totalContentCount
{
	return -1;
}

- (int)filteredContentCount
{
	return -1;
}

- (NSString*)contentInfo
{
	return @"";
}

#pragma mark -

- (void)setBaseModelContent:(id)content
{
	[[[self baseFileModel] fileModelContent] setContent:content];
	[[self baseFileController] setModified:MODIFY_ALL];
}

- (id)baseModelContent
{
	return [[[self baseFileModel] fileModelContent] content];
}

- (BOOL)hasBaseModelContent
{
	return [[[self baseFileModel] fileModelContent] hasContent];		
}

- (StringsContentModel*)baseModelStringsContent
{
	return [[[self baseFileModel] fileModelContent] stringsContent];
}

- (void)setModelContent:(id)content
{
	[[[self fileModel] fileModelContent] setContent:content];
	[self setModified:MODIFY_ALL];
}

- (id)modelContent
{
	return [[[self fileModel] fileModelContent] content];	
}

- (StringsContentModel*)modelStringsContent
{
	return [[[self fileModel] fileModelContent] stringsContent];	
}

- (BOOL)hasModelContent
{
	return [[[self fileModel] fileModelContent] hasContent];		
}

#pragma mark -

- (void)stringControllersDidChange
{
	[self willChangeValueForKey:@"stringControllers"];
	[self didChangeValueForKey:@"stringControllers"];
	[self filteredStringControllersDidChange];
}

- (void)filteredStringControllersDidChange
{
	[self willChangeValueForKey:@"filteredStringControllers"];
	[self didChangeValueForKey:@"filteredStringControllers"];
}

- (void)baseStringModelDidChange:(StringModel*)model
{
	NSEnumerator *enumerator = [[self stringControllers] objectEnumerator];
	StringController *sc;
	BOOL modified = NO;
	while(sc = [enumerator nextObject]) {
		if([sc baseStringModel] == model) {
			modified = YES;
			[sc setStatusBaseModified:YES];
			[sc updateStatus];
		}
	}
	
	// Base file controller should be marked as "modified" if a base string model has changed ;-)
	if(modified && [self isBaseFileController])
		[self setModified:MODIFY_ALL];
}

#pragma mark -

/**
 Returns the string controller corresponding to the specified key.
 This method must be very fast.
 */
- (id)stringControllerForKey:(NSString*)key
{
	// subclass
	return NULL;
}

- (id)baseStringController:(StringController*)sc
{
	return [[self baseFileController] stringControllerForKey:[sc key]];
}

- (id)stringControllerMatchingBaseStringController:(StringController*)bsc
{
	return [self stringControllerForKey:[bsc key]];
}

- (id)stringControllers
{
	return NULL;
}

- (id)visibleStringControllers
{
	return NULL;
}

- (id)filteredStringControllers
{
	return NULL;
}

#pragma mark -

- (FileController*)pFile
{
	return self;
}

- (NSString*)pFilePath
{
	return [self absoluteFilePath];
}

- (NSString*)pFileName
{
	return [self filename];
}

- (NSString*)pFileLabel
{
	if(mLabelString == nil) {
		[self updateLabelIndexes];
	}
	return mLabelString;
}

- (NSString*)pFileType
{
	return [[self filename] pathExtension];
}

- (id)pStatus
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"checkLayout"] = @([self statusCheckLayout]);
	dic[@"updateAdded"] = @([self statusUpdateAdded]);
	dic[@"updateUpdated"] = @([self statusUpdateUpdated]);
	dic[@"warning"] = @([self statusWarning]);
	dic[@"doNotExist"] = @([self statusNotFound]);
	return dic;
}

- (id)pString
{
	return [self visibleStringControllers];	
}

@end