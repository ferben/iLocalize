//
//  GlossaryImportWC.m
//  iLocalize3
//
//  Created by Jean on 14.11.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "GlossaryImportWC.h"
#import "GlossaryDocument.h"
#import "GlossaryWC.h"

#import "GlossaryModel.h"

#import "LanguageTool.h"
#import "LanguageMenuProvider.h"

@implementation GlossaryImportWC

static GlossaryImportWC *shared = nil;

+ (GlossaryImportWC*)shared
{
    @synchronized(self) {
        if(shared == nil)
            shared = [[GlossaryImportWC alloc] init];        
    }
    return shared;
}

- (id)init
{
    if(self = [super initWithWindowNibName:@"GlossaryImport"]) {
		sourceLanguageMenuProvider = [[LanguageMenuProvider alloc] init];
		targetLanguageMenuProvider = [[LanguageMenuProvider alloc] init];
        [self window];
    }
    return self;
}

- (void)dealloc
{
	[sourceLanguageMenuProvider release];
	[targetLanguageMenuProvider release];
	[super dealloc];
}

- (void)awakeFromNib
{
	sourceLanguageMenuProvider.popupButton = mSourceLanguagePopUp;
	targetLanguageMenuProvider.popupButton = mTargetLanguagePopUp;
	
	[sourceLanguageMenuProvider refreshPopUp];
	[targetLanguageMenuProvider refreshPopUp];
		
	[sourceLanguageMenuProvider selectLanguage:[@"en" displayLanguageName]];
	[targetLanguageMenuProvider selectCurrentLanguage];
}

- (void)import
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setAccessoryView:mImportAccessoryView];
    if([panel runModalForDirectory:NULL file:NULL types:[NSArray arrayWithObject:@"txt"]] == NSOKButton) {
        if([NSApp runModalForWindow:mImportPanel] == 1) {
            GlossaryDocument *document = [[NSDocumentController sharedDocumentController] makeUntitledDocumentOfType:@"iLocalize 3 Glossary"];
            [[NSDocumentController sharedDocumentController] addDocument:document];

            NSMutableDictionary *model = [NSMutableDictionary dictionary];
            [model setSourceLanguage:[sourceLanguageMenuProvider selectedLanguage]];
            [model setTargetLanguage:[targetLanguageMenuProvider selectedLanguage]];
			[model setEntries:[NSMutableArray array]];

            [document setModel:model];
            [document makeWindowControllers];
            
            GlossaryWC *glossary = [document glossaryWC];
            if([mImportFormatMatrix selectedTag] == 0)
                [glossary importFromILText:[panel filename]];
            else
                [glossary importFromPowerGlotText:[panel filename]];
            [[glossary window] makeKeyAndOrderFront:self];            
        }
    }
}

- (int)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
	return [[LanguageTool defaultLanguageIdentifiers] count];
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(int)index
{
	return [[LanguageTool defaultLanguageIdentifiers] objectAtIndex:index];	
}

- (IBAction)cancel:(id)sender
{
    [mImportPanel orderOut:self];
    [NSApp stopModalWithCode:0];
}

- (IBAction)ok:(id)sender
{
    [mImportPanel orderOut:self];
    [NSApp stopModalWithCode:1];    
}

- (void)importIntoGlossary:(GlossaryWC*)glossary
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setAccessoryView:mImportAccessoryView];
	[panel beginSheetForDirectory:NULL
                             file:NULL
                            types:[NSArray arrayWithObject:@"txt"]
                   modalForWindow:[glossary window] 
                    modalDelegate:self
                   didEndSelector:@selector(importIntoGlossaryFilePanelDidEnd:returnCode:contextInfo:) 
                      contextInfo:[glossary retain]];    
}

- (void)importIntoGlossaryFilePanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [(GlossaryWC*)contextInfo autorelease];
    
	if(returnCode != NSOKButton)
		return;	
	
    GlossaryWC *glossary = (GlossaryWC*)contextInfo;    
	if([mImportFormatMatrix selectedTag] == 0)
		[glossary importFromILText:[panel filename]];
	else
		[glossary importFromPowerGlotText:[panel filename]];
}

@end
