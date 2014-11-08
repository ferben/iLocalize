//
//  PropagationEngine.m
//  iLocalize
//
//  Created by Jean Bovet on 3/30/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "PropagationEngine.h"

/**
 Extraction instance that contains information about a string.
 For example: "House …" will return
	- punctuationIndex = 6
	- punctuation = …
	- root = "House"
	- space = " "
	- remaining = ""
 */
@interface Extraction : NSObject
{
	/**
	 The starting index of the punctuation.
	 */
	NSInteger punctuationIndex;
	
	/**
	 The punctuation string.
	 */
	NSString *punctuation;
	
	/**
	 The root of the string.
	 */
	NSString *root;
	
	/**
	 Any spaces between the root and the punctuation.
	 */
	NSString *space;
	
	/**
	 Any character after the punctuation.
	 */
	NSString *remaining;
}

@property NSInteger punctuationIndex;
@property (strong) NSString *punctuation;
@property (strong) NSString *root;
@property (strong) NSString *space;
@property (strong) NSString *remaining;

@end

@implementation Extraction

@synthesize punctuationIndex;
@synthesize punctuation;
@synthesize root;
@synthesize space;
@synthesize remaining;

@end

// ====================== Engine implementation ================================

@implementation PropagationEngine

+ (PropagationEngine*)engine
{
	return [[self alloc] init];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		punctuationList = [[NSMutableArray alloc] init];
		[punctuationList addObject:@":"];
		[punctuationList addObject:@"..."];
		[punctuationList addObject:@"…"];
	}
	return self;
}


- (Extraction*)extract:(NSString*)s
{
	Extraction *e = [[Extraction alloc] init];
	e.punctuationIndex = -1;
	int index;
	for(index=0; index<[s length]; index++) {
		unichar c = [s characterAtIndex:index];
		
		for(NSString *p in punctuationList) {
			if([p length] > 0 && [p characterAtIndex:0] == c) {
				// Character seems to match the punctuation. Confirm that.
				BOOL match = YES;
				for(int pi = 0; pi < [p length]; pi++) {
					if(index+pi >= [s length]) {
						// End of the string, not a complete match
						match = NO;
						break;
					}
					if([p characterAtIndex:pi] != [s characterAtIndex:index+pi]) {
						// The character does not correspond, no match.
						match = NO;
						break;
					}
				}
				
				if(match) {
                    // Make sure that there are only white spaces after the punctuation
                    // until the end of the string. It might be possible in the future
                    // to also allow parameters in there (e.g. %@ or %d).
                    BOOL onlyWhiteSpace = YES;
                    for (NSUInteger i = index + p.length; i<s.length; i++) {
                        unichar c = [s characterAtIndex:i];
                        if (![[NSCharacterSet whitespaceCharacterSet] characterIsMember:c]) {
                            onlyWhiteSpace = NO;
                            break;
                        }
                    }
                    if (onlyWhiteSpace) {
                        e.punctuationIndex = index;
                        e.punctuation = p;
                        e.remaining = [s substringFromIndex:index+[p length]];                        
                        goto end;
                    }
				}
			}
		}
	}
	if(e.punctuationIndex == -1) {
		e.punctuationIndex = index;
		e.punctuation = @"";
		e.remaining = @"";
	}
end:
	e.root = nil;
	// Find the root and the space between the punctuation.
	NSMutableString *space = [NSMutableString string];
	while(index > 0) {
		index--;
		unichar c = [s characterAtIndex:index];
		if(c == ' ') {
			[space appendString:@" "];			
		} else {
			e.root = [s substringToIndex:index+1];
			break;
		}
	}
	e.space = space;
	return e;
}

- (void)propagateString:(id<StringControllerProtocol>)string toStrings:(NSArray*)scs ignoreCase:(BOOL)ignoreCase block:(PropagationEngineWillChangeStringController)block
{
	// Extract the root content of the string
	Extraction *sourceBaseExtration = [self extract:string.base];
	if(!sourceBaseExtration.root) return;

	Extraction *sourceTranslationExtraction = [self extract:string.translation];
	
	// Example:
	// House… => House
	for(id<StringControllerProtocol> scp in scs) {		
		Extraction *baseExtration = [self extract:scp.base];
		Extraction *translationExtration = [self extract:scp.translation];

		if([sourceBaseExtration.root isEqualToString:baseExtration.root ignoreCase:ignoreCase] && [sourceBaseExtration.space isEqualToString:baseExtration.space]) {
			NSString *translation;
			BOOL samePunctuation = [sourceTranslationExtraction.punctuation isEqualToString:translationExtration.punctuation];			
			if(samePunctuation) {
				// Same punctuation as the source string. In this case, we use the space of the source string.
				translation = [NSString stringWithFormat:@"%@%@%@%@", sourceTranslationExtraction.root?:@"", sourceTranslationExtraction.space, 
								   baseExtration.punctuation, baseExtration.remaining];
			} else {
				// Not the same punctuation as the source string. In this case, we use the space of the translation.
				translation = [NSString stringWithFormat:@"%@%@%@%@", sourceTranslationExtraction.root?:@"", translationExtration.space, 
								   baseExtration.punctuation, baseExtration.remaining];
			}
            if (block) block(scp);
            [scp setAutomaticTranslation:translation];
		}
	}
}

@end
