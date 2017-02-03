//
//  XLIFFImportOperation.m
//  iLocalize
//
//  Created by Jean Bovet on 3/24/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XLIFFImportOperation.h"
#import "XLIFFImportSettings.h"
#import "XLIFFImportFileElement.h"
#import "XLIFFImportStringElement.h"

#import "LanguageController.h"
#import "FileController.h"
#import "StringController.h"

#import "Console.h"

@implementation XLIFFImportOperation

@synthesize settings;

- (void)execute
{
	[self setOperationName:NSLocalizedString(@"Updating Project…", nil)];
	[self setProgressMax:settings.fileElements.count];
	
	[[self console] beginOperation:@"Import XML" class:[self class]];

	for (XLIFFImportFileElement *fileElement in settings.fileElements)
    {
		if (fileElement.fc)
        {
			[[self console] beginOperation:[NSString stringWithFormat:@"Updating file %@", [fileElement.fc relativeFilePath]] class:[self class]];
            
			for (XLIFFImportStringElement *stringElement in fileElement.stringElements)
            {
				if (stringElement.sc)
                {
					[[self console] addLog:[NSString stringWithFormat:@"Updating string with key '%@' to value '%@'", [stringElement.sc key], stringElement.translation] class:[self class]];
					[stringElement.sc setAutomaticTranslation:stringElement.translation];									
				}
			}
            
			[[self console] endOperation];			
		}
        
		[self progressIncrement];
	}
	
	[[self console] endOperation];
}

@end
