#import "ILDocumentController.h"
#import "Constants.h"
#import "PreferencesGeneral.h"

@implementation ILDocumentController

- (void)noteNewRecentDocument:(NSDocument *)doc
{
    // prevent the standard mechanism to record the recent documents
    // so previous version of iLocalize are not affected by that.
    // Version 4 manages itself the list of recent documents.    
}


@end
