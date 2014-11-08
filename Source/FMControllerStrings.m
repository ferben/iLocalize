//
//  FMControllerStrings.m
//  iLocalize3
//
//  Created by Jean on 25.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "FMControllerStrings.h"
#import "FMStringsExtensions.h"

#import "FileModel.h"
#import "StringsContentModel.h"
#import "StringModel.h"

#import "StringController.h"

#import "ExplorerItem.h"
#import "ExplorerFilter.h"
#import "ProjectWC.h"

#ifndef TARGET_TOOL
#import "PreferencesFilters.h"
#endif

#import "Constants.h"

@implementation FMControllerStrings

- (id)init
{
	if((self = [super init])) {
		mStringControllers = [[NSMutableArray alloc] init];
		mCachedVisibleStringControllers = nil;
		mCachedStringControllers = [[NSMutableDictionary alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(stringsFilterDidChange:)
													 name:ILStringsFilterDidChange
												   object:nil];		
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

}

#pragma mark -

- (void)clearCache
{
	mCachedVisibleStringControllers = nil;
}

- (void)stringsFilterDidChange:(NSNotification*)notif
{
	[self clearCache];
}

- (void)clearStringControllers
{
	// Don't forget to clear the cache!
	[self clearCache];	
	[mStringControllers removeAllObjects];
}

- (void)rebuildFromModel
{
	if([self isLocal]) return;
	
	[self clearStringControllers];
	[mCachedStringControllers removeAllObjects];

	// The base language is always the reference.
	for(StringModel *baseStringModel in [[[mBaseFileModel fileModelContent] stringsContent] strings]) {
		StringController *controller = [StringController controller];
		[controller setParent:self];
		[controller setBaseStringModel:baseStringModel];
		StringModel *stringModel = [[[mFileModel fileModelContent] stringsContent] stringModelForKey:[baseStringModel key]];
		if(stringModel) {
			[controller setStringModel:stringModel];			
		} else {
			[Logger throwExceptionWithReason:[NSString stringWithFormat:@"String model not found for key %@ and file %@", [baseStringModel key], mFileModel]];
		}

		[controller updateStatus];
		[mStringControllers addObject:controller];
		mCachedStringControllers[[baseStringModel key]] = controller;
	}		
	
	[super rebuildFromModel];
}

- (BOOL)supportsEncoding
{
	return YES;
}

- (BOOL)displayNumberOfStrings
{
	return YES;
}

- (BOOL)displayStatus
{
	return YES;
}

- (BOOL)displayProgress
{
	return ![self isBaseFileController] && ![self isLocal];
}

- (void)computeStatistics
{
    NSArray *vsc = [self visibleStringControllers];
    mNumberOfStrings = [vsc count]; 
    mNumberOfTranslatedStrings = 0;
	mNumberOfNonTranslatedStrings = 0;
	mNumberOfToCheckStrings = 0;
	mNumberOfInvariantStrings = 0;
	mNumberOfBaseModifiedStrings = 0;
    mNumberOfLockedStrings = 0;
	mNumberOfAutoTranslatedStrings = 0;
	mNumberOfAutoInvariantStrings = 0;
	
	if(![self displayProgress])
		return;
	
	if(mNumberOfStrings == 0)
        return;

	StringController *sc;
	for(sc in vsc) {
        if([sc statusToTranslate]) {
            mNumberOfNonTranslatedStrings++;            
        } else if([sc statusInvariant]) {
            mNumberOfInvariantStrings++;
            if([sc statusToCheck]) {
                mNumberOfToCheckStrings++;				
				mNumberOfAutoInvariantStrings++;
			} else {
                mNumberOfTranslatedStrings++;				
			}
        } else {
            if([sc statusToCheck]) {
                mNumberOfToCheckStrings++;
				mNumberOfAutoTranslatedStrings++;
			} else {
                mNumberOfTranslatedStrings++;				
			}
        }
                                
		if([sc statusBaseModified])		
            // check to see where it is used
			mNumberOfBaseModifiedStrings++;		
        
        if([sc lock])
            mNumberOfLockedStrings++;
	}
}

- (float)percentCompleted
{
    if(mNumberOfStrings <= 0)
        return 100.0;
    else
        return 100.0*mNumberOfTranslatedStrings/mNumberOfStrings;
}

- (float)percentTranslated
{
    if(mNumberOfStrings <= 0)
        return 0;
    else
        return 100.0*mNumberOfTranslatedStrings/mNumberOfStrings;
}

- (float)percentAutoTranslated
{
    if(mNumberOfStrings <= 0)
        return 0;
    else
        return 100.0*mNumberOfToCheckStrings/mNumberOfStrings;
}

- (float)percentToTranslate
{
    if(mNumberOfStrings <= 0)
        return 0;
    else
        return 100.0*mNumberOfNonTranslatedStrings/mNumberOfStrings;
}

- (int)numberOfStrings
{
    return mNumberOfStrings;
}

- (int)numberOfTranslatedStrings
{
    return mNumberOfTranslatedStrings;
}

- (int)numberOfNonTranslatedStrings
{
	return mNumberOfNonTranslatedStrings;
}

- (int)numberOfToCheckStrings
{
	return mNumberOfToCheckStrings;
}

- (int)numberOfInvariantStrings
{
	return mNumberOfInvariantStrings;
}

- (int)numberOfBaseModifiedStrings
{
	return mNumberOfBaseModifiedStrings;
}

- (int)numberOfLockedStrings
{
	return mNumberOfLockedStrings;
}

- (int)numberOfAutoTranslatedStrings
{
	return mNumberOfAutoTranslatedStrings;
}

- (int)numberOfAutoInvariantStrings
{
	return mNumberOfAutoInvariantStrings;
}

#pragma mark -

- (int)totalContentCount
{
	return [[self stringControllers] count];
}

- (int)filteredContentCount
{
	return [[self filteredStringControllers] count];
}

- (NSString*)contentInfo
{
	int filteredCount = [self filteredContentCount];
	int totalCount = [self totalContentCount];
	
	if(totalCount == 0)
		return NSLocalizedString(@"(empty)", @"File Content Empty");
	
	if(totalCount == filteredCount)
		return [NSString stringWithFormat:@"%d", totalCount];
	else
		return [NSString stringWithFormat:NSLocalizedString(@"%d of %d", @"File Content Info"), filteredCount, totalCount];
}

- (id)visibleStringControllers
{
	if(!mCachedVisibleStringControllers) {
		mCachedVisibleStringControllers = [[NSMutableArray alloc] init];
		
		for(StringController *sc in mStringControllers) {
			// IL 3.2: removed these lines because we still want empty base value to be displayed (the key is valid)
/*			BOOL accept = [[sc base] length]>0;
			if(!accept)
				continue;*/
			
#ifndef TARGET_TOOL
			BOOL accept = ![[PreferencesFilters shared] stringControllerMatchAnyRegex:sc];
			if(accept) {
				[mCachedVisibleStringControllers addObject:sc];				
			}
#else
			[mCachedVisibleStringControllers addObject:sc];
#endif
		}		
	}
	
	return mCachedVisibleStringControllers;	
}

- (id)stringControllerForKey:(NSString*)key
{
	id sc = mCachedStringControllers[key];
	if(!sc) {
		sc = [[self stringControllers] stringControllerForKey:key];
		if(sc) {
			NSLog(@"[%@] Cache doesn't have sc for %@ but the array of string controllers does.", [self filename], key);
		}
	}
	return sc;
}

- (id)stringControllers
{
	return mStringControllers;
}

- (id)filteredStringControllers
{
	NSMutableArray *array = [self visibleStringControllers];
	NSPredicate *p = [[[self projectProvider] projectWC] currentFilterPredicate];
	return [array filteredArrayUsingPredicate:p];
}

@end
