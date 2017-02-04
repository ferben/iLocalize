//
//  ProjectMenuTranslate.h
//  iLocalize
//
//  Created by Jean on 12/29/08.
//  Copyright 2008 Arizona Software. All rights reserved.
//

#import "ProjectMenu.h"

@class GlossaryTranslateWC;
@class GlossaryScope;
@class GlossaryTranslator;

@interface ProjectMenuTranslate : ProjectMenu
{
    GlossaryTranslateWC  *wc;
    GlossaryScope        *scope;
    GlossaryTranslator   *translator;
}

- (IBAction)translateUsingGlossaries:(id)sender;
- (IBAction)translateUsingExternalStringsFile:(id)sender;
- (IBAction)translateUsingSelectedGlossaryEntry:(id)sender;

- (IBAction)approveString:(id)sender;
- (IBAction)approveFile:(id)sender;

- (IBAction)approveIdenticalStringsInSelectedFiles:(id)sender;
- (IBAction)approveIdenticalStringsInAllFiles:(id)sender;
- (IBAction)approveAutoTranslatedStringsInSelectedFiles:(id)sender;
- (IBAction)approveAutoTranslatedStringsInAllFiles:(id)sender;
- (IBAction)approveAutoInvariantStringsInSelectedFiles:(id)sender;
- (IBAction)approveAutoInvariantStringsInAllFiles:(id)sender;
- (IBAction)approveAutoHandledStringsInSelectedFiles:(id)sender;
- (IBAction)approveAutoHandledStringsInAllFiles:(id)sender;
- (IBAction)propagateTranslationToIdenticalStringsInSelectedFiles:(id)sender;
- (IBAction)propagateTranslationToIdenticalStringsInAllFiles:(id)sender;
- (IBAction)markStringsAsTranslated:(id)sender;
- (IBAction)unmarkStringsAsTranslated:(id)sender;
- (IBAction)copyBaseStringsToTranslation:(id)sender;
- (IBAction)swapBaseStringsToTranslation:(id)sender;
- (IBAction)clearBaseComments:(id)sender;
- (IBAction)clearTranslationComments:(id)sender;
- (IBAction)clearComments:(id)sender;
- (IBAction)clearTranslations:(id)sender;

- (IBAction)clearUpdatedFileSymbols:(id)sender;

@end
