//
//  CheckEngine.m
//  iLocalize3
//
//  Created by Jean on 5/28/06.
//  Copyright 2006 Arizona Software. All rights reserved.
//

#import "CheckEngine.h"

#import "ProjectController.h"
#import "LanguageController.h"
#import "FileController.h"
#import "StringController.h"

#import "StringsEngine.h"
#import "NibEngine.h"
#import "ReplaceEngine.h"

#import "StringsContentModel.h"
#import "StringModel.h"

#import "OperationWC.h"
#import "FMStringsExtensions.h"

#include <libkern/OSAtomic.h>

@implementation CheckEngine

- (NSMutableSet*)keysOfFileModel:(StringsContentModel*)content duplicateKeys:(NSMutableSet*)duplicateKeys
{
	NSMutableSet *keys = [NSMutableSet set];
	
    for(StringModel *sm in [content stringsEnumerator]) {
		if(duplicateKeys != nil && [keys containsObject:[sm key]])
			[duplicateKeys addObject:[sm key]];
		
		[keys addObject:[sm key]];        
    }
	
	return keys;
}

- (NSDictionary*)valuesFromContent:(StringsContentModel*)content forKeys:(NSSet*)keys
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	NSString *key;
	for(key in keys) {
        id value = [[content stringModelForKey:key] value];
        if (value) {
            dic[key] = value;            
        }
	}
	return dic;
}

- (NSDictionary*)checkKeys:(FileController*)fc
{
	NSMutableSet *duplicateKeys = [NSMutableSet set];
	NSMutableSet *baseKeys = nil;
	NSMutableSet *localizedKeys = nil;
	StringsContentModel* localizedModelContent = nil;

	if([fc isBaseFileController]) {
		baseKeys = [self keysOfFileModel:[fc baseModelStringsContent] duplicateKeys:duplicateKeys];		
	} else {
		baseKeys = [self keysOfFileModel:[fc baseModelStringsContent] duplicateKeys:nil];
		// Load manually the content of the localized file to detect any duplicate or mismatch keys.
		// We have to do that because the modelContent is based on the baseModelContent which automatically
		// hides any problems.
		if([[fc filename] isPathStrings]) {
			StringsEngine *engine = [StringsEngine engineWithConsole:nil];
			localizedModelContent = [engine parseStringModelsOfStringsFile:[fc absoluteFilePath]];
		} else if([[fc filename] isPathNib]) {
			NibEngine *engine = [NibEngine engineWithConsole:nil];
			localizedModelContent = [engine parseStringModelsOfNibFile:[fc absoluteFilePath]];
		}
		
		localizedKeys = [self keysOfFileModel:localizedModelContent duplicateKeys:duplicateKeys];		
	}
	
	BOOL duplicate = [duplicateKeys count] > 0;
	BOOL mismatch = localizedKeys != nil && ![baseKeys isEqualToSet:localizedKeys];
	
	if(duplicate || mismatch) {	
		NSMutableDictionary *info = [NSMutableDictionary dictionary];
		NSMutableDictionary *values = [NSMutableDictionary dictionary];
		
		info[@"values"] = values;
		
		if(duplicate) {
			info[WARNING_DUPLICATE_KEYS] = duplicateKeys;
		}
		
		if(mismatch) {
			NSMutableSet *missingKeys = [NSMutableSet setWithSet:baseKeys];
			[missingKeys minusSet:localizedKeys];
			
			NSMutableSet *mismatchKeys = [NSMutableSet setWithSet:localizedKeys];
			[mismatchKeys minusSet:baseKeys];
			
			info[WARNING_MISSING_KEYS] = missingKeys;
			info[WARNING_MISMATCH_KEYS] = mismatchKeys;
			
			[values addEntriesFromDictionary:[self valuesFromContent:[fc baseModelContent] forKeys:missingKeys]];
			[values addEntriesFromDictionary:[self valuesFromContent:localizedModelContent forKeys:mismatchKeys]];
		}
		
		return info;
	}	
	
	return nil;
}

#pragma mark -

- (BOOL)matchModifiersAndType:(NSString*)s position:(int*)position
{
	int pos = *position;
	if(pos >= [s length]) {
		return NO;
	}
	
	unichar c = [s characterAtIndex:pos++];
	unichar c2 = 0;
	if(pos < [s length]) {
		c2 = [s characterAtIndex:pos];
	}
	
	if((c == 'h' && c2 == 'i') ||
	   (c == 'h' && c2 == 'u') ||
	   (c == 'q' && c2 == 'i') ||
	   (c == 'q' && c2 == 'u') ||
	   (c == 'q' && c2 == 'x') ||
	   (c == 'q' && c2 == 'X'))
	{
		// two letters formatter
		(*position)+=2;
		return YES;
	} else if(c == '@' || c == 'd' || c == 'D' || c == 'i' ||
			  c == 'u' || c == 'U' || c == 'l' ||
			  c == 'x' || c == 'X' || c == 'o' || c == 'O' ||
			  c == 'f' || c == 'e' || c == 'E' || c == 'g' || c == 'G' ||
			  c == 'c' || c == 'C' || c == 's' || c == 'S' || c == 'p')
	{
		// one letter formatter
		(*position)++;
		return YES;
	} else {
		return NO;
	}	
}

- (BOOL)matchNumber:(NSString*)s position:(int*)position
{
	BOOL matched = NO;
	int pos = *position;	
	while(pos < [s length]) {
		unichar c = [s characterAtIndex:pos];
		if(c >= '0' && c <= '9') {
			matched = YES;
			pos++;			
		} else {
			break;
		}		
	}	
	
	if(matched) {
		*position = pos;
		return YES;		
	} else {
		return NO;
	}	
}

- (BOOL)matchPrecision:(NSString*)s position:(int*)position
{
	// .number
	
	int pos = *position;
	if(pos >= [s length]) {
		return NO;
	}
	
	unichar c = [s characterAtIndex:pos];
	if(c != '.') {
		return NO;
	} else {
		pos++;
	}
	
	if([self matchNumber:s position:&pos]) {
		*position = pos;
		return YES;		
	} else {
		return NO;
	}	
}

- (BOOL)matchWidth:(NSString*)s position:(int*)position
{
	// *, 0number, number
	
	unichar c = [s characterAtIndex:*position];
	if(c == '*') {
		(*position)++;
		return YES;
	}
	
	BOOL matched = NO;
	int pos = *position;
	if(c == '0') {
		pos++;
		matched = YES;
	}
	
	if([self matchNumber:s position:&pos] || matched) {
		*position = pos;
		return YES;		
	} else {
		return NO;
	}	
}

- (BOOL)matchFlag:(NSString*)s position:(int*)position
{
	// -, +, blank, #

	unichar c = [s characterAtIndex:*position];
	return c == '-' || c == '+' || c == ' ' || c == '#';
}

// See http://www.cplusplus.com/ref/cstdio/printf.html
// See http://en.wikipedia.org/wiki/Printf
// %[flags][width][.precision][modifiers]type

- (BOOL)matchPrintfStyle:(NSString*)s position:(int*)position
{
	// This method is called just after the % character.
	int pos = *position;
	[self matchFlag:s position:&pos];
	[self matchWidth:s position:&pos];
	[self matchPrecision:s position:&pos];
	if([self matchModifiersAndType:s position:&pos]) {
		*position = pos;
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)matchPosition:(int*)posNum followedByPrintfStyle:(NSString*)s position:(int*)position dollar:(int*)dollar
{
	// "this is an example of %3$@ and %2$7.4f"
	int pos = *position;
	if(![self matchNumber:s position:&pos]) {
		return NO;
	}
	
	if(pos >= [s length]) {
		return NO;
	}
	
	if([s characterAtIndex:pos++] != '$') {
		return NO;
	}
	
	*posNum = [[s substringWithRange:NSMakeRange(*position, pos - *position)] intValue] - 1;
	*dollar = pos-1;
	
	if([self matchPrintfStyle:s position:&pos]) {
		*position = pos;
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)matchSimplePositionMarker:(NSString*)s position:(int*)position
{
	// "this is an example of %3 and %1."
	return [self matchNumber:s position:position];
}

- (NSDictionary*)parseFormattingCharacters:(NSString*)s
{
	// %3.2f %@ => [3.2f, @]
	// %1 %3 %2 => [1, 3, 2]
	// %2$@%3$@ => [2, 3]
	
	NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];

	int pi = 0; // previous value of i
	int i = 0;
	BOOL control = NO;
	int defaultPosition = 0;
	int position = 0;
	int dollar = 0;
	while(i < [s length]) {
		unichar c = [s characterAtIndex:i];		
		if(c == '%') {
			if(control) {
				control = NO;
				// skip %%
			} else {
				control = YES;
			}				
		} else if(control) {
			// Formatting characters
			int formatterStart = i;
			if([self matchPrintfStyle:s position:&i]) {
				// %3.2f or %3hu
				NSString *f = [s substringWithRange:NSMakeRange(formatterStart, i - formatterStart)];
				infoDic[[NSString stringWithFormat:@"%d", position]] = f;
				position = ++defaultPosition;
			} else if([self matchPosition:&position followedByPrintfStyle:s position:&i dollar:&dollar]) {
				// %3$@ or %4$2.3f
				NSString *f = [s substringWithRange:NSMakeRange(dollar+1, i - dollar - 1)];
				infoDic[[NSString stringWithFormat:@"%d", position]] = [NSString stringWithFormat:@"%d%@", position, f];
			} else if([self matchSimplePositionMarker:s position:&i]) {
				// %1 or %2
				// May-06-2007: in Cocoa, the position mark has to be followed by a $. Where does this simple marker comes from? A Windows strings file?
				// We might need to remove this check completely.
				
				//position = [[s substringWithRange:NSMakeRange(formatterStart, i - formatterStart)] intValue];
				//[infoDic setObject:@"" forKey:[NSString stringWithFormat:@"%d", position]];
			}			
			control = NO;			
		}
		// Increment i if it was not incremented already
		if(i == pi) {
			i++;
		}
		pi = i;
	}
	
	return infoDic;
}

#pragma mark -

- (BOOL)checkFormattingCharactersOfBaseString:(NSString*)base localizedString:(NSString*)localized
{
	@try {
		NSDictionary *baseFormatting = [self parseFormattingCharacters:base];
		NSDictionary *localizedFormatting = [self parseFormattingCharacters:localized];
		return [baseFormatting isEqualToDictionary:localizedFormatting];	
	} @catch(id exception) {
		[exception printStackTrace];
		NSLog(@"[CheckEngine] Exception while checking formatting characters of base '%@' against localized '%@': %@", base, localized, exception);		
	}
	return NO;
}

- (BOOL)hasAssignedWarnings:(StringController*)sc
{
	return [[sc warningsKeys] count] > 0;
}

- (BOOL)hasInvalidFormattingCharacters:(StringController *) sc
{
	return ![sc statusToTranslate] && ![self checkFormattingCharactersOfBaseString:[sc base] localizedString:[sc translation]];
}

- (BOOL)hasFileControllerWarnings:(FileController*)fc
{
	NSMutableDictionary *info = [fc auxiliaryDataForKey:@"warning_info"];
	if(!info) return NO;

    for(NSString *key in [info keyEnumerator]) {
		if([info[key] count] > 0) return YES;        
    }
	return NO;
}

- (void)markStringController:(StringController*)sc
{	
	FileController *fc = [sc parent];
	NSMutableDictionary *info = [fc auxiliaryDataForKey:@"warning_info"];
	NSMutableArray *array = info[WARNING_MISMATCH_FORMATTING_CHARS];

	BOOL warning = [self hasInvalidFormattingCharacters:sc];
	[sc setStatusWarning:warning];
	if(warning) {
		if(array == nil) {
			array = [NSMutableArray array];
			if(info == nil) {
				info = [NSMutableDictionary dictionary];
			}
			info[WARNING_MISMATCH_FORMATTING_CHARS] = array;
		}
		if(![array containsObject:[sc key]]) {
			[array addObject:[sc key]];			
		}
	} else {
		[array removeObject:[sc key]];		
	}
	
	[fc setStatusWarning:[self hasFileControllerWarnings:fc]];
	if(info) {
		[fc setAuxiliaryData:info forKey:@"warning_info"];			
	}
}

- (NSDictionary*)checkFormattingCharacters:(FileController*)fc
{
	if([fc isBaseFileController])
		return nil;
	
	// Check to see if the localized strings are consistent, in terms of formatting characters,
	// with the base language. Type and order of the formatting characters are checked.
	// See http://developer.apple.com/documentation/MacOSX/Conceptual/BPInternational/index.html#//apple_ref/doc/uid/10000171i
	
	NSMutableArray *array = [NSMutableArray array];
	
	BOOL warning = NO;
    for(StringController *sc in [fc stringControllers]) {
		if([self hasInvalidFormattingCharacters:sc]) {
			warning = YES;
			[array addObject:[sc key]];			
		}        
    }
	
	if(warning) {
		NSMutableDictionary *info = [NSMutableDictionary dictionary];
		info[WARNING_MISMATCH_FORMATTING_CHARS] = array;
		return info;
	} else {
		return nil;
	}
}

- (BOOL)canRepairFileController:(NSDictionary*)info
{
	NSArray *keys = [info allKeys];			
	return [keys containsObject:WARNING_DUPLICATE_KEYS] || [keys containsObject:WARNING_MISSING_KEYS] || [keys containsObject:WARNING_MISMATCH_KEYS];
}

- (void)checkFileController:(FileController*)fc
{
	[fc setStatusWarning:NO];

	/* Ignore local files */
	if([fc isLocal]) {
		return;
	}
	
	/* Ignore non-existing file */
	if(![[fc absoluteFilePath] isPathExisting]) {
		return;
	}
	
	/* Ignore for non .strings/nib files */
	if(![[fc absoluteFilePath] isPathNib] && ![[fc absoluteFilePath] isPathStrings]) {
		return;		
	}
	
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[fc setAuxiliaryData:info forKey:@"warning_info"];	

	/* Warning if the file is readonly */
	if(![[fc absoluteFilePath] isPathWritable]) {
		info[WARNING_READONLY_FILE] = [NSSet setWithObject:[fc filename]];
		[fc setStatusWarning:YES];		
		[fc setAuxiliaryData:info forKey:@"warning_info"];	
	}
	
	/* Warning if the nib file is compiled */
	if([[fc absoluteFilePath] isPathNib]) {
//		BOOL compiled = [[self projectProvider] nibEngineType] == TYPE_NIBTOOL && [[fc absoluteFilePath] isPathNibCompiledForNibtool];
		BOOL compiled = [[fc absoluteFilePath] isPathNibCompiledForIbtool];
		if(compiled) {
			info[WARNING_COMPILEDNIB_FILE] = [NSSet setWithObject:[fc filename]];
			
			[fc setStatusWarning:YES];		
			[fc setAuxiliaryData:info forKey:@"warning_info"];						
		}
	}
	
	NSDictionary *dic = [self checkKeys:fc];
	if(dic != nil) {
		if([self canRepairFileController:dic] && ![fc isBaseFileController]) {
			// Try to fix using the localized layout
			[[[self engineProvider] replaceEngine] replaceLocalizedFileControllerWithCorrespondingBase:fc keepLayout:YES];
			dic = [self checkKeys:fc];
			if(dic != nil) {
				// Try to fix by not using the localized layout
				[[[self engineProvider] replaceEngine] replaceLocalizedFileControllerWithCorrespondingBase:fc keepLayout:NO];
				dic = [self checkKeys:fc];
				if(dic != nil) {
					// Nothing we can do... let the user know about this problem. This happen mostly because of nibtool's bugs.
				}					
			}
		}
		
		if(dic != nil) {
			[fc setStatusWarning:YES];
			[info addEntriesFromDictionary:dic];
			[fc setAuxiliaryData:info forKey:@"warning_info"];	
		}			
	}
	
	dic = [self checkFormattingCharacters:fc];
	if(dic != nil) {
		[fc setStatusWarning:YES];
		[info addEntriesFromDictionary:dic];
		[fc setAuxiliaryData:info forKey:@"warning_info"];	
	}	

    for(StringController *sc in [fc stringControllers]) {
		[sc setStatusWarning:[self hasAssignedWarnings:sc]];        
    }
}

- (NSArray*)fileControllersToCheck:(NSArray*)languages
{
	NSMutableArray *array = [NSMutableArray array];
	
    for(NSString *language in languages) {
        for(FileController *fc in [[[[self projectProvider] projectController] languageControllerForLanguage:language] fileControllers]) {            
			if([[fc filename] isPathNib] || [[fc filename] isPathStrings]) {
				[array addObject:fc];			                
            }        
            if([[self operation] shouldCancel]) break;
        }
        if([[self operation] shouldCancel]) break;
    }
	return array;
}

- (NSUInteger)checkLanguages:(NSArray *)languages
{
	NSArray *fcs = [self fileControllersToCheck:languages];    
	[[self operation] setMaxSteps:[fcs count]];
	
	__block int32_t count = 0;
    
    [fcs enumerateObjectsWithOptions:CONCURRENT_OP_OPTIONS usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        FileController *fc = obj;
        
        if ([[self operation] shouldCancel])
        {
            *stop = YES;
            return;
        }
        
        [[self operation] increment];
        
        @autoreleasepool
        {
            [self checkFileController:fc];
        
            if ([fc statusWarning])
            {
                OSAtomicIncrement32(&count);
            }
        
        }        
    }];        
	
	return count;
}

@end
