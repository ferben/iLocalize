//
//  StringsEngine.h
//  iLocalize3
//
//  Created by Jean on 21.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "AbstractStringsEngine.h"

@class Console;
@class StringModel;
@class StringsContentModel;
@class StringEncoding;

@interface StringsEngine : AbstractStringsEngine {
	// parsing
	NSString		*mText;
	
	int				position;	// current absolute position
	int				column;		// current column
	int				row;		// current row
	int				lastRow;	// row of the last element
	
	StringsContentModel	*mStringModels;
	StringModel		*mCurrentStringModel;
	
	// encoding
	NSMutableString	*mEncodedString;
	int				mCurrentLine;
	int				mLastLine;
	BOOL			mSkipEmptyValue;
	
	// general
	Class			mModelClass;
	
	// console
	Console			*mConsole;	
}

+ (StringsEngine*)engineWithConsole:(Console*)console;

- (void)setModelClass:(Class)modelClass;

- (StringsContentModel*)parseStringModelsOfStringsFile:(NSString*)file;
- (StringsContentModel*)parseStringModelsOfStringsFile:(NSString*)file encodingUsed:(StringEncoding**)encoding defaultEncoding:(StringEncoding*)defaultEncoding;
- (StringsContentModel*)parseStringModelsOfStringsFile:(NSString*)file encoding:(StringEncoding*)encoding;

- (StringsContentModel*)parseStringModelsOfText:(NSString*)text;
- (StringsContentModel*)parseStringModelsOfText:(NSString*)text usingModel:(Class)modelClass;

- (NSString*)encodeStringModels:(StringsContentModel*)strings baseStringModels:(StringsContentModel*)baseStrings skipEmpty:(BOOL)skipEmpty format:(NSUInteger)format encoding:(StringEncoding*)encoding;

@end
