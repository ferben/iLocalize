//
//  StatsWC.m
//  iLocalize3
//
//  Created by Jean on 30.05.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "StatsWC.h"

#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"
#import "StringController.h"

#define KEY_NUMBER_OF_FILES @"KEY_NUMBER_OF_FILES"
#define KEY_NUMBER_OF_NIB_FILES @"KEY_NUMBER_OF_NIB_FILES"
#define KEY_NUMBER_OF_STRINGS_FILES @"KEY_NUMBER_OF_STRINGS_FILES"
#define KEY_NUMBER_OF_STRINGS @"KEY_NUMBER_OF_STRINGS"
#define KEY_NUMBER_OF_STRINGS_PER_FILE @"KEY_NUMBER_OF_STRINGS_PER_FILE"
#define KEY_NUMBER_OF_WORDS @"KEY_NUMBER_OF_WORDS"
#define KEY_NUMBER_OF_WORDS_PER_STRING @"KEY_NUMBER_OF_WORDS_PER_STRING"
#define KEY_NUMBER_OF_CHARS @"KEY_NUMBER_OF_CHARS"

#define KEY_NUMBER_OF_FILES_TO_TRANSLATE @"KEY_NUMBER_OF_FILES_TO_TRANSLATE"
#define KEY_NUMBER_OF_NIB_FILES_TO_TRANSLATE @"KEY_NUMBER_OF_NIB_FILES_TO_TRANSLATE"
#define KEY_NUMBER_OF_STRINGS_FILES_TO_TRANSLATE @"KEY_NUMBER_OF_STRINGS_FILES_TO_TRANSLATE"
#define KEY_NUMBER_OF_STRINGS_TO_TRANSLATE @"KEY_NUMBER_OF_STRINGS_TO_TRANSLATE"
#define KEY_NUMBER_OF_STRINGS_PER_FILE_TO_TRANSLATE @"KEY_NUMBER_OF_STRINGS_PER_FILE_TO_TRANSLATE"
#define KEY_NUMBER_OF_WORDS_TO_TRANSLATE @"KEY_NUMBER_OF_WORDS_TO_TRANSLATE"
#define KEY_NUMBER_OF_WORDS_PER_STRING_TO_TRANSLATE @"KEY_NUMBER_OF_WORDS_PER_STRING_TO_TRANSLATE"
#define KEY_NUMBER_OF_CHARS_TO_TRANSLATE @"KEY_NUMBER_OF_CHARS_TO_TRANSLATE"

@implementation StatsWC

- (id)init
{
	if(self = [super initWithWindowNibName:@"Statistics"]) {
		mStatsDic = [[NSMutableDictionary alloc] init];
	}
	return self;
}


- (int)countWords:(NSString*)s
{
	if([s length] == 0) return 0;
	
	int count = 0;
	NSEnumerator *enumerator = [[s componentsSeparatedByString:@" "] objectEnumerator];
	NSString *c;
	while(c = [enumerator nextObject]) {
		if([c length] > 0) {
			count++;
		}
	}
	return count;
}

- (void)collectFilesStats:(NSArray*)fcs language:(NSString*)language
{
	NSMutableDictionary *stats = mStatsDic[language];
	if(!stats) {
		stats = [NSMutableDictionary dictionary];
		mStatsDic[language] = stats;
	}
		
	unsigned numberOfNibFiles = 0;
	unsigned numberOfNibFilesToTranslate = 0;
	unsigned numberOfStringsFiles = 0;
	unsigned numberOfStringsFilesToTranslate = 0;
	
	unsigned numberOfStrings = 0;
	unsigned numberOfWords = 0;
	unsigned numberOfChars = 0;
    
    unsigned numberOfStringsToTranslate = 0;
    unsigned numberOfWordsToTranslate = 0;
    unsigned numberOfCharsToTranslate = 0;
    
	FileController *fc;
	for(fc in fcs) {
		NSArray *scs = [fc filteredStringControllers];
		NSEnumerator *stringsEnumerator = [scs objectEnumerator];
		StringController *sc;
		while(sc = [stringsEnumerator nextObject]) {
            if(![sc isBaseString]) {
                if([sc statusToTranslate]) {
                    NSString *s = [sc base];
                    numberOfWordsToTranslate += [self countWords:s];
                    numberOfCharsToTranslate += [s length];
                    numberOfStringsToTranslate++;
                } else if([sc statusToCheck]) {
                    NSString *s = [sc base];
                    numberOfWordsToTranslate += [self countWords:s];
                    numberOfCharsToTranslate += [s length];
                    numberOfStringsToTranslate++;                
                }                
            }
			NSString *s = [sc translation];
			numberOfWords += [self countWords:s];
			numberOfChars += [s length];
			if([s length] > 0) {
				numberOfStrings++;
			}
		}
        
        if([fc percentCompleted] < 100 && ![fc isBaseFileController]) {
			// To translate
			
			if([[fc relativeFilePath] isPathNib])
				numberOfNibFilesToTranslate++;
			
			if([[fc relativeFilePath] isPathStrings])
				numberOfStringsFilesToTranslate++;			
		} else {
			if([[fc relativeFilePath] isPathNib])
				numberOfNibFiles++;
			
			if([[fc relativeFilePath] isPathStrings])
				numberOfStringsFiles++;			
		}		
	}
			
	unsigned numberOfFiles = [fcs count];
	unsigned numberOfFilesToTranslate = numberOfNibFilesToTranslate+numberOfStringsFilesToTranslate;
	
    // All strings
    
	stats[KEY_NUMBER_OF_FILES] = [NSNumber numberWithInt:numberOfFiles];
	stats[KEY_NUMBER_OF_NIB_FILES] = [NSNumber numberWithInt:numberOfNibFiles];
	stats[KEY_NUMBER_OF_STRINGS_FILES] = [NSNumber numberWithInt:numberOfStringsFiles];
	
	stats[KEY_NUMBER_OF_STRINGS] = [NSNumber numberWithInt:numberOfStrings];
	stats[KEY_NUMBER_OF_STRINGS_PER_FILE] = [NSNumber numberWithInt:numberOfFiles > 0?numberOfStrings/numberOfFiles:0];

	stats[KEY_NUMBER_OF_WORDS] = [NSNumber numberWithInt:numberOfWords];
	stats[KEY_NUMBER_OF_WORDS_PER_STRING] = [NSNumber numberWithInt:numberOfStrings > 0?numberOfWords/numberOfStrings:0];

	stats[KEY_NUMBER_OF_CHARS] = [NSNumber numberWithInt:numberOfChars];
    
    // Non-translated strings
    
	stats[KEY_NUMBER_OF_FILES_TO_TRANSLATE] = [NSNumber numberWithInt:numberOfFilesToTranslate];
	stats[KEY_NUMBER_OF_NIB_FILES_TO_TRANSLATE] = [NSNumber numberWithInt:numberOfNibFilesToTranslate];
	stats[KEY_NUMBER_OF_STRINGS_FILES_TO_TRANSLATE] = [NSNumber numberWithInt:numberOfStringsFilesToTranslate];
	
	stats[KEY_NUMBER_OF_STRINGS_TO_TRANSLATE] = [NSNumber numberWithInt:numberOfStringsToTranslate];
	stats[KEY_NUMBER_OF_STRINGS_PER_FILE_TO_TRANSLATE] = [NSNumber numberWithInt:numberOfFilesToTranslate > 0?numberOfStringsToTranslate/numberOfFilesToTranslate:0];
    
	stats[KEY_NUMBER_OF_WORDS_TO_TRANSLATE] = [NSNumber numberWithInt:numberOfWordsToTranslate];
	stats[KEY_NUMBER_OF_WORDS_PER_STRING_TO_TRANSLATE] = [NSNumber numberWithInt:numberOfStringsToTranslate > 0?numberOfWordsToTranslate/numberOfStringsToTranslate:0];
    
	stats[KEY_NUMBER_OF_CHARS_TO_TRANSLATE] = [NSNumber numberWithInt:numberOfCharsToTranslate];
    
}

- (void)collectStats
{
	NSEnumerator *enumerator = [[[[self projectProvider] projectController] languageControllers] objectEnumerator];
	LanguageController *lc;
	while(lc = [enumerator nextObject]) {
		[self collectFilesStats:[lc fileControllers] language:[lc displayLanguage]];		
	}
}

- (NSNumber*)statNumberForKey:(NSString*)key mean:(BOOL)mean
{
	if([mSourcePopUp indexOfSelectedItem] == 0) {
		NSEnumerator *enumerator = [[mStatsDic allValues] objectEnumerator];
		NSDictionary *dic;
		unsigned total = 0;
		unsigned count = 0;
		while(dic = [enumerator nextObject]) {
			NSNumber *number = dic[key];
			if(number) {
				total += [number intValue];
				count++;
			}
		}
		if(count == 0) {
			return NULL;
		} else {
			if(mean)
				return [NSNumber numberWithInt:total/count];
			else
				return [NSNumber numberWithInt:total];
		}
	} else {
		NSDictionary *dic = mStatsDic[[mSourcePopUp titleOfSelectedItem]];
		return dic[key];
	}	
}

- (NSString*)formatNumber:(NSNumber*)n
{
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setFormat:@"###,##0"];
	[formatter setThousandSeparator:[[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
	return [formatter stringForObjectValue:n];
}

- (NSString*)statForKey:(NSString*)key mean:(BOOL)mean
{	
	NSNumber *number = [self statNumberForKey:key mean:mean];
	if(number)
		return [self formatNumber:number];
	else
		return NSLocalizedStringFromTable(@"n/a", @"LocalizableStatistics", nil);		
}

- (void)addStat:(NSString*)title keyAll:(NSString*)all keyToTranslate:(NSString*)totranslate mean:(BOOL)mean
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"title"] = title;
	dic[@"all"] = [self statForKey:all mean:mean];
	dic[@"totranslate"] = [self statForKey:totranslate mean:mean];
	dic[@"bold"] = @NO;
	[mStatsController addObject:dic];
}

- (void)addStat:(NSString*)title all:(NSString*)all toTranslate:(NSString*)totranslate bold:(BOOL)bold
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	dic[@"title"] = title;
	dic[@"all"] = all;
	dic[@"totranslate"] = totranslate;
	dic[@"bold"] = @(bold);
	[mStatsController addObject:dic];
}

- (void)addStatSeparator
{
	[mStatsController addObject:[NSMutableDictionary dictionary]];	
}

- (void)updatePrice
{
	float priceBase = [mPriceBaseField floatValue];
	mPriceTotal = 0;
    mPriceToTranslateTotal = 0;
	switch([mPriceUnitPopUp indexOfSelectedItem]) {
		case 0:	// per word
			mPriceTotal = priceBase*[[self statNumberForKey:KEY_NUMBER_OF_WORDS mean:NO] floatValue];
			mPriceToTranslateTotal = priceBase*[[self statNumberForKey:KEY_NUMBER_OF_WORDS_TO_TRANSLATE mean:NO] floatValue];
			break;
		case 1: // per characters
			mPriceTotal = priceBase*[[self statNumberForKey:KEY_NUMBER_OF_CHARS mean:NO] floatValue];
			mPriceToTranslateTotal = priceBase*[[self statNumberForKey:KEY_NUMBER_OF_CHARS_TO_TRANSLATE mean:NO] floatValue];
			break;
		case 2: // per string
			mPriceTotal = priceBase*[[self statNumberForKey:KEY_NUMBER_OF_STRINGS mean:NO] floatValue];
			mPriceToTranslateTotal = priceBase*[[self statNumberForKey:KEY_NUMBER_OF_STRINGS_TO_TRANSLATE mean:NO] floatValue];
			break;
	}
}

- (void)updateStats
{	
	[mStatsController removeObjects:[mStatsController content]];
	
	[self addStat:NSLocalizedStringFromTable(@"All files", @"LocalizableStatistics", @"Statistics") keyAll:KEY_NUMBER_OF_FILES keyToTranslate:KEY_NUMBER_OF_FILES_TO_TRANSLATE mean:NO];
	[self addStat:NSLocalizedStringFromTable(@"Nib files", @"LocalizableStatistics", @"Statistics") keyAll:KEY_NUMBER_OF_NIB_FILES keyToTranslate:KEY_NUMBER_OF_NIB_FILES_TO_TRANSLATE mean:NO];
	[self addStat:NSLocalizedStringFromTable(@"Strings files", @"LocalizableStatistics", @"Statistics") keyAll:KEY_NUMBER_OF_STRINGS_FILES keyToTranslate:KEY_NUMBER_OF_STRINGS_FILES_TO_TRANSLATE mean:NO];
	
	[self addStatSeparator];
	
	[self addStat:NSLocalizedStringFromTable(@"Strings", @"LocalizableStatistics", @"Statistics") keyAll:KEY_NUMBER_OF_STRINGS keyToTranslate:KEY_NUMBER_OF_STRINGS_TO_TRANSLATE mean:NO];
	[self addStat:NSLocalizedStringFromTable(@"Strings per file (mean)", @"LocalizableStatistics", @"Statistics") keyAll:KEY_NUMBER_OF_STRINGS_PER_FILE keyToTranslate:KEY_NUMBER_OF_STRINGS_PER_FILE_TO_TRANSLATE mean:YES];
	
	[self addStatSeparator];
	
	[self addStat:NSLocalizedStringFromTable(@"Words", @"LocalizableStatistics", @"Statistics") keyAll:KEY_NUMBER_OF_WORDS keyToTranslate:KEY_NUMBER_OF_WORDS_TO_TRANSLATE mean:NO];
	[self addStat:NSLocalizedStringFromTable(@"Words per string (mean)", @"LocalizableStatistics", @"Statistics") keyAll:KEY_NUMBER_OF_WORDS_PER_STRING keyToTranslate:KEY_NUMBER_OF_WORDS_PER_STRING_TO_TRANSLATE mean:YES];
	
	[self addStatSeparator];
	
	[self addStat:NSLocalizedStringFromTable(@"Characters", @"LocalizableStatistics", @"Statistics") keyAll:KEY_NUMBER_OF_CHARS keyToTranslate:KEY_NUMBER_OF_CHARS_TO_TRANSLATE mean:NO];
	
	[self addStatSeparator];
	
	[self updatePrice];
	[self addStat:NSLocalizedStringFromTable(@"Price", @"LocalizableStatistics", @"Statistics")
			  all:[self formatNumber:@(mPriceTotal)]
	  toTranslate:[self formatNumber:@(mPriceToTranslateTotal)]
			 bold:YES];
}

- (void)willShow
{
	while([[mSourcePopUp itemArray] count] > 2)
		[mSourcePopUp removeItemAtIndex:2];
	
	[mSourcePopUp addItemsWithTitles:[[[self projectProvider] projectController] displayLanguages]];
}

- (void)didShow
{
	[mProgressInfoField setHidden:NO];
	[mProgressIndicator setHidden:NO];
	[mProgressIndicator setUsesThreadedAnimation:YES];
	[mProgressIndicator startAnimation:self];
	
	[self collectStats];
	[self updateStats];
	
	[mProgressIndicator stopAnimation:self];
	[mProgressIndicator setHidden:YES];
	[mProgressInfoField setHidden:YES];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	[self updateStats];    
}

- (IBAction)changeSource:(id)sender
{
	[self updateStats];
}

- (IBAction)changePriceBase:(id)sender
{
	[self updateStats];
}

- (IBAction)changePriceUnit:(id)sender
{
	[self updateStats];	
}

- (IBAction)copyToClipboard:(id)sender
{
	NSMutableString *s = [NSMutableString string];
	
	if([mSourcePopUp indexOfSelectedItem] == 0)
		[s appendString:NSLocalizedStringFromTable(@"Source: All", @"LocalizableStatistics", @"Statistics")];
	else
		[s appendFormat:NSLocalizedStringFromTable(@"Source: %@", @"LocalizableStatistics", @"Statistics"), [mSourcePopUp titleOfSelectedItem]];
	[s appendString:@"\n"];

	[s appendFormat:NSLocalizedStringFromTable(@"Number of files = %@", @"LocalizableStatistics", @"Statistics"), [self statForKey:KEY_NUMBER_OF_FILES mean:NO]];
	[s appendString:@"\n"];
	[s appendFormat:NSLocalizedStringFromTable(@"Number of nib files = %@", @"LocalizableStatistics", @"Statistics"), [self statForKey:KEY_NUMBER_OF_NIB_FILES mean:NO]];
	[s appendString:@"\n"];
	[s appendFormat:NSLocalizedStringFromTable(@"Number of strings files = %@", @"LocalizableStatistics", @"Statistics"), [self statForKey:KEY_NUMBER_OF_STRINGS_FILES mean:NO]];
	[s appendString:@"\n"];
	[s appendFormat:NSLocalizedStringFromTable(@"Number of strings = %@", @"LocalizableStatistics", @"Statistics"), [self statForKey:KEY_NUMBER_OF_STRINGS mean:NO]];
	[s appendString:@"\n"];
	[s appendFormat:NSLocalizedStringFromTable(@"Number of strings per file = %@", @"LocalizableStatistics", @"Statistics"), [self statForKey:KEY_NUMBER_OF_STRINGS_PER_FILE mean:YES]];
	[s appendString:@"\n"];
	[s appendFormat:NSLocalizedStringFromTable(@"Number of words = %@", @"LocalizableStatistics", @"Statistics"), [self statForKey:KEY_NUMBER_OF_WORDS mean:NO]];
	[s appendString:@"\n"];
	[s appendFormat:NSLocalizedStringFromTable(@"Number of words per string = %@", @"LocalizableStatistics", @"Statistics"), [self statForKey:KEY_NUMBER_OF_WORDS_PER_STRING mean:YES]];
	[s appendString:@"\n"];
	[s appendFormat:NSLocalizedStringFromTable(@"Number of characters = %@", @"LocalizableStatistics", @"Statistics"), [self statForKey:KEY_NUMBER_OF_CHARS mean:NO]];
	[s appendString:@"\n"];

    [s appendString:NSLocalizedStringFromTable(@"To translate:", @"LocalizableStatistics", @"Statistics")];
	[s appendString:@"\n"];
    [s appendFormat:NSLocalizedStringFromTable(@"Number of files = %@", @"LocalizableStatistics", @"Statistics"), [self statForKey:KEY_NUMBER_OF_FILES_TO_TRANSLATE mean:NO]];
	[s appendString:@"\n"];
	[s appendFormat:NSLocalizedStringFromTable(@"Number of strings = %@", @"LocalizableStatistics", @"Statistics"), [self statForKey:KEY_NUMBER_OF_STRINGS_TO_TRANSLATE mean:NO]];
	[s appendString:@"\n"];
	[s appendFormat:NSLocalizedStringFromTable(@"Number of strings per file = %@", @"LocalizableStatistics", @"Statistics"), [self statForKey:KEY_NUMBER_OF_STRINGS_PER_FILE_TO_TRANSLATE mean:YES]];
	[s appendString:@"\n"];
	[s appendFormat:NSLocalizedStringFromTable(@"Number of words = %@", @"LocalizableStatistics", @"Statistics"), [self statForKey:KEY_NUMBER_OF_WORDS_TO_TRANSLATE mean:NO]];
	[s appendString:@"\n"];
	[s appendFormat:NSLocalizedStringFromTable(@"Number of words per string = %@", @"LocalizableStatistics", @"Statistics"), [self statForKey:KEY_NUMBER_OF_WORDS_PER_STRING_TO_TRANSLATE mean:YES]];
	[s appendString:@"\n"];
	[s appendFormat:NSLocalizedStringFromTable(@"Number of characters = %@", @"LocalizableStatistics", @"Statistics"), [self statForKey:KEY_NUMBER_OF_CHARS_TO_TRANSLATE mean:NO]];
	[s appendString:@"\n"];
    
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	[pb declareTypes:@[NSStringPboardType] owner:nil];
	[pb setString:s forType:NSStringPboardType];
}

- (IBAction)close:(id)sender
{
	[self hide];		
}

@end
