//
//  SEIManager.m
//  iLocalize
//
//  Created by Jean Bovet on 4/22/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "SEIManager.h"
#import "SEIFormat.h"

#import "XLIFFImporter.h"
#import "TXMLImporter.h"
#import "TMXImporter.h"
#import "ILGImporter.h"
#import "AppleGlotImporter.h"
#import "StringsImporter.h"

#import "XLIFFExporter.h"
#import "TXMLExporter.h"
#import "TMXExporter.h"
#import "ILGExporter.h"
#import "StringsExporter.h"
#import "PowerGlotImporter.h"

@implementation SEIManager

static SEIManager *instance = nil;

+ (SEIManager*)sharedInstance
{
	@synchronized(self) {
		if(!instance) {
			instance = [[SEIManager alloc] init];
		}		
	}
	return instance;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		formats = [[NSMutableArray alloc] init];
		[formats addObject:[self createXLIFFFormat]];
		[formats addObject:[self createTXMLFormat]];
		[formats addObject:[self createTMXFormat]];
		[formats addObject:[self createILGFormat]];
		[formats addObject:[self createAppleGlotFormat]];
		[formats addObject:[self createStringsFormat]];
		[formats addObject:[self createPowerGlotFormat]];
	}
	return self;
}

- (SEIFormat*)createXLIFFFormat
{
	SEIFormat *f = [[SEIFormat alloc] init];
	f.displayName = NSLocalizedString(@"XLIFF", @"XLIFF Display Name Format");
	f.format = XLIFF;
	f.importerClassName = NSStringFromClass([XLIFFImporter class]);
	f.exporterClassName = NSStringFromClass([XLIFFExporter class]);
	f.readableExtensions = [[XLIFFImporter importer] readableExtensions];
	f.writableExtension = [XLIFFExporter writableExtension];
	return f;
}

- (SEIFormat*)createTXMLFormat
{
	SEIFormat *f = [[SEIFormat alloc] init];
	f.displayName = NSLocalizedString(@"TXML (Wordfast)", @"TXML Display Name Format");
	f.format = TXML;
	f.importerClassName = NSStringFromClass([TXMLImporter class]);
	f.exporterClassName = NSStringFromClass([TXMLExporter class]);
	f.readableExtensions = [[TXMLImporter importer] readableExtensions];
	f.writableExtension = [TXMLExporter writableExtension];
	return f;
}

- (SEIFormat*)createTMXFormat
{
	SEIFormat *f = [[SEIFormat alloc] init];
	f.displayName = NSLocalizedString(@"TMX", @"TMX Display Name Format");
	f.format = TMX;
	f.importerClassName = NSStringFromClass([TMXImporter class]);
	f.exporterClassName = NSStringFromClass([TMXExporter class]);
	f.readableExtensions = [[TMXImporter importer] readableExtensions];
	f.writableExtension = [TMXExporter writableExtension];
	return f;
}

- (SEIFormat*)createILGFormat
{
	SEIFormat *f = [[SEIFormat alloc] init];
	f.displayName = NSLocalizedString(@"ILG (iLocalize 3)", @"ILG Display Name Format");
	f.format = ILG;
	f.importerClassName = NSStringFromClass([ILGImporter class]);
	f.exporterClassName = NSStringFromClass([ILGExporter class]);
	f.readableExtensions = [[ILGImporter importer] readableExtensions];
	f.writableExtension = [ILGExporter writableExtension];
	return f;
}

- (SEIFormat*)createAppleGlotFormat
{
	SEIFormat *f = [[SEIFormat alloc] init];
	f.displayName = NSLocalizedString(@"AppleGlot", @"AppleGlot Display Name Format");
	f.format = APPLEGLOT;
	f.importerClassName = NSStringFromClass([AppleGlotImporter class]);
	f.exporterClassName = nil;
	f.readableExtensions = [[AppleGlotImporter importer] readableExtensions];
	f.writableExtension = nil;
	return f;
}

- (SEIFormat*)createStringsFormat
{
	SEIFormat *f = [[SEIFormat alloc] init];
	f.displayName = NSLocalizedString(@"Strings", @"Strings Display Name Format");
	f.format = STRINGS;
	f.importerClassName = NSStringFromClass([StringsImporter class]);
	f.exporterClassName = NSStringFromClass([StringsExporter class]);
	f.readableExtensions = [[StringsImporter importer] readableExtensions];
	f.writableExtension = [StringsExporter writableExtension];
	return f;
}

- (SEIFormat*)createPowerGlotFormat
{
	SEIFormat *f = [[SEIFormat alloc] init];
	f.displayName = NSLocalizedString(@"Text", @"Text Display Name Format");
	f.format = POWERGLOT;
	f.importerClassName = NSStringFromClass([PowerGlotImporter class]);
	f.exporterClassName = nil;
	f.readableExtensions = [[PowerGlotImporter importer] readableExtensions];
	f.writableExtension = nil;
	return f;
}

#pragma mark NSPopUpButton support

- (NSArray*)writableFormats
{
	NSMutableArray *writableFormats = [NSMutableArray array];
	for(SEIFormat *f in formats) {
		if([f writable]) {
			[writableFormats addObject:f];
		}
	}	
	return writableFormats;
}

- (SEIFormat*)formatObjectForFormat:(SEI_FORMAT)format
{
	for(SEIFormat *f in formats) {
		if(f.format == format) {
			return f;
		}
	}
	return nil;
}

- (void)populatePopup:(NSPopUpButton*)popup
{
	[popup removeAllItems];
	for(SEIFormat *f in [self writableFormats]) {
		[popup addItemWithTitle:f.displayName];			
	}
}

- (void)selectPopup:(NSPopUpButton*)popup itemForFormat:(SEI_FORMAT)format
{
	SEIFormat *f = [self formatObjectForFormat:format];
	if([f writable]) {
		[popup selectItemWithTitle:f.displayName];		
	}
}

- (SEI_FORMAT)selectedFormat:(NSPopUpButton*)popup
{
	SEIFormat *f;
	int selectedIndex = [popup indexOfSelectedItem];
	if(selectedIndex >= 0 && selectedIndex < [popup numberOfItems]) {
		f = [self writableFormats][selectedIndex];
	} else {
		f = [[self writableFormats] firstObject];
	}
	return f.format;
}

- (NSString*)writableExtensionForFormat:(SEI_FORMAT)format
{
	return [[self formatObjectForFormat:format] writableExtension];
}

#pragma mark Factories

- (NSArray*)allImportableExtensions
{
	NSMutableArray *extensions = [NSMutableArray array];
	for(SEIFormat *f in formats) {
		[extensions addObjectsFromArray:[f readableExtensions]];
	}
	[extensions addObjectsFromArray:[[XMLImporter importer] genericExtensions]];
	return extensions;
}

- (SEI_FORMAT)formatOfDocType:(NSString*)docType defaultFormat:(SEI_FORMAT)defaultFormat
{
	if([docType isEqualToString:@"iLocalize 3 Glossary"]) {
		return ILG;
	} else if([docType isEqualToString:@"TXML Glossary"]) {
		return TXML;
	} else if([docType isEqualToString:@"XLIFF Glossary"]) {
		return XLIFF;
	} else if([docType isEqualToString:@"AppleGlot Glossary"]) {
		return APPLEGLOT;
	} else if([docType isEqualToString:@"TMX Glossary"]) {
		return TMX;
	} else if([docType isEqualToString:@"Strings Glossary"]) {
		return STRINGS;
	} else {
		return defaultFormat;
	}
}

- (SEI_FORMAT)formatOfFile:(NSURL*)url error:(NSError**)error
{
	for(SEIFormat *f in formats) {
		XMLImporter *importer = [f createImporter];
		if([importer canImportDocument:url error:error]) {
			return f.format;
		}
	}
	if(error) {
		*error = [Logger errorWithMessage:NSLocalizedString(@"Cannot determine format of file: %@", @"Strings Importer"), url];
	}
	return NO_FORMAT;
}

- (XMLImporter*)importerForFile:(NSURL*)url error:(NSError**)error
{
	for(SEIFormat *f in formats) {
		XMLImporter *importer = [f createImporter];
		if([importer canImportDocument:url error:error]) {
			return importer;
		}
	}
	if(error) {
		*error = [Logger errorWithMessage:NSLocalizedString(@"Cannot find the suitable importer for file: %@", @"Strings Importer"), url];
	}
	return nil;
}

- (XMLExporter*)exporterForFormat:(SEI_FORMAT)format
{
	return [[self formatObjectForFormat:format] createExporter];
}

@end
