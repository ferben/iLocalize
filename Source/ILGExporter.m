//
//  ILGExporter.m
//  iLocalize
//
//  Created by Jean Bovet on 5/15/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ILGExporter.h"


@implementation ILGExporter


/* Sample file:
 
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>displaySourceLanguage</key>
	<string>English</string>
	<key>displayTargetLanguage</key>
	<string>Swedish</string>
	<key>entries</key>
	<array>
		<dict>
			<key>source</key>
			<string>hdhomerun2</string>
			<key>target</key>
			<string>hdhomerun3</string>
		</dict>
		<dict>
			<key>source</key>
			<string>EyeTVImporter version 1.0, Copyright (c) 2007-2009 Elgato Systems GmbH.</string>
			<key>target</key>
			<string>EyeTVImporter version 1.0, Copyright (c) 2007-2009 Elgato Systems GmbH.</string>
		</dict>
		<dict>
			<key>source</key>
			<string>Copyright (c) 2007-2009 Elgato Systems GmbH.</string>
			<key>target</key>
			<string>Copyright (c) 2007-2009 Elgato Systems GmbH.</string>
		</dict>
	</array>
	<key>sourceLanguage</key>
	<string>English</string>
	<key>targetLanguage</key>
	<string>sv</string>
</dict>
</plist>
 
 */

+ (NSString*)writableExtension
{
	return @"ilg";
}

- (void)buildHeader
{
	[self.content appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
	[self.content appendString:@"<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"];
	[self.content appendString:@"<plist version=\"1.0\">\n"];
	[self.content appendString:@"<dict>\n"];
	[self.content appendString:@"  <key>sourceLanguage</key>\n"];
	[self.content appendFormat:@"  <string>%@</string>\n", self.sourceLanguage];
	[self.content appendString:@"  <key>targetLanguage</key>\n"];
	[self.content appendFormat:@"  <string>%@</string>\n", self.targetLanguage];
	[self.content appendString:@"  <key>entries</key>\n"];
	[self.content appendString:@"  <array>\n"];
}

- (void)buildFooter
{
	[self.content appendString:@"  </array>\n"];
	[self.content appendString:@"</dict>\n"];
	[self.content appendString:@"</plist>\n"];
}

- (void)buildFileHeader:(id<FileControllerProtocol>)fc
{
	
	// there is no nothing of file segment in ILG
}

- (void)buildFileFooter:(id<FileControllerProtocol>)fc
{
	// there is no nothing of file segment in ILG
}

- (void)buildStringWithString:(id<StringControllerProtocol>)sc index:(NSUInteger)index globalIndex:(NSUInteger)globalIndex file:(id<FileControllerProtocol>)fc
{
	[self.content appendString:@"    <dict>\n"];
	
	[self.content appendString:@"      <key>source</key>\n"];
	[self.content appendFormat:@"      <string>%@</string>\n", [sc.base xmlEscaped]];
	[self.content appendString:@"      <key>target</key>\n"];
	[self.content appendFormat:@"      <string>%@</string>\n", [sc.translation xmlEscaped]];

	[self.content appendString:@"    </dict>\n"];
}

@end
