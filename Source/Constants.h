
#define CR   '\r'
#define LF   '\n'
#define TAB  '\t'

#define NOBREAK_SPACE 0x00A0

#define MAC_EOL      @"\r"
#define UNIX_EOL     @"\n"
#define WINDOWS_EOL  @"\r\n"

#define MAC_LINE_ENDINGS      1
#define UNIX_LINE_ENDINGS     2
#define WINDOWS_LINE_ENDINGS  4

#define STRINGS_FORMAT_APPLE_STRINGS  0 // default format
#define STRINGS_FORMAT_APPLE_XML      1
#define STRINGS_FORMAT_ABVENT_XML     2

#define PROJET_EXT @"ilocalize"
#define LPROJ @".lproj"
#define PROJECT_DOCUMENT_TYPE @"iLocalize 3 Project"

#define SMART_FILTER_EXTENSION @"xml"

// Scope of the search
#define SCOPE_FILES                  1
#define SCOPE_STRINGS_BASE           2
#define SCOPE_STRINGS_TRANSLATION    4
#define SCOPE_COMMENTS_BASE          8
#define SCOPE_COMMENTS_TRANSLATION  16
#define SCOPE_KEY                   32

// Options of the search
#define SEARCH_CONTAINS     1
#define SEARCH_BEGINSWITH   2
#define SEARCH_ENDSWITH     3
#define SEARCH_IS           4
#define SEARCH_IS_NOT       5
#define SEARCH_MATCHES      6
#define SEARCH_IGNORE_CASE  7

#define FILE_STATUS_DONE             0
#define FILE_STATUS_SYNCH_TO_DISK    1
#define FILE_STATUS_SYNCH_FROM_DISK  2
#define FILE_STATUS_CHECK_LAYOUT     3
#define FILE_STATUS_NOT_FOUND        4
#define FILE_STATUS_WARNING          5
#define FILE_STATUS_UPDATE_ADDED     6
#define FILE_STATUS_UPDATE_UPDATED   7

#define STRING_STATUS_NONE              0  // no status - needs to be computed
#define STRING_STATUS_TOTRANSLATE       1  // to translate
#define STRING_STATUS_TOCHECK           2  // check translation
#define STRING_STATUS_BASE_MODIFIED     3  // when the base value has changed (i.e. after rebase)
#define STRING_STATUS_INVARIANT         4  // when base == translation
#define STRING_STATUS_WARNING           5  // when inconsistency detected
#define STRING_STATUS_MARKASTRANSLATED  6  // when manually marked as translated

#define MODIFY_ALL          1  // when everything is modified
#define MODIFY_TRANSLATION  2  // when a translation is modified
#define MODIFY_COMMENT      3  // when a comment is modified
#define MODIFY_STATUS       4  // when a status is modified

#define PBOARD_DATA_LANGUAGE_STRINGS  @"PboardDataLanguageStrings"
#define PBOARD_DATA_FILES_STRINGS     @"PboardDataFilesStrings"
#define PBOARD_DATA_STRINGS           @"PboardDataStrings"
#define PBOARD_OWNER_POINTER          @"PboardOwnerPoint"

#define PBOARD_DATA_ROW_INDEXES  @"Rows"

#define PBOARD_SOURCE_KEY  @"source"
#define PBOARD_TARGET_KEY  @"target"

#define RESOLVE_USE_NONE           0
#define RESOLVE_USE_PROJET_FILE    1
#define RESOLVE_USE_IMPORTED_FILE  2

#define NSStringEncodingUTF16BE  0x90000100
#define NSStringEncodingUTF16LE  0x94000100
#define NSStringEncodingUTF32BE  0x98000100
#define NSStringEncodingUTF32LE  0x9C000100

#define OPERATION_REBUILD  1

#define ILNotificationProjectControllerDidBecomeDirty  @"ILNotificationProjectControllerDidBecomeDirty"
#define ILNotificationProjectProviderWillClose         @"ILNotificationProjectProviderWillClose"
#define ILNotificationProjectProviderDidClose          @"ILNotificationProjectProviderDidClose"
#define ILNotificationProjectProviderDidOpen           @"ILNotificationProjectProviderDidOpen"
#define ILNotificationLanguageStatsDidChange           @"ILNotificationLanguageStatsDidChange"

#define ILNotificationExplorerItemDidRemove            @"ILNotificationExplorerItemDidRemove"

#define ILNotificationEngineDidReload                  @"ILNotificationEngineDidReload"

#define ILNotificationBeginOperation                   @"ILNotificationBeginOperation"
#define ILNotificationEndOperation                     @"ILNotificationEndOperation"

#define ILLanguageSelectionDidChange                   @"ILLanguageSelectionDidChange"
#define ILFileSelectionDidChange                       @"ILFileSelectionDidChange"
#define ILStringSelectionDidChange                     @"ILStringSelectionDidChange"

#define ILDisplayedStringsDidChange                    @"ILDisplayedStringsDidChange"
#define ILStringsFilterDidChange                       @"ILStringsFilterDidChange"
#define ILQuoteSubstitutionDidChange                   @"ILQuoteSubstitutionDidChange"
#define ILEditorFontDidChange                          @"ILEditorFontDidChange"
#define ILTableContentSizeDidChange                    @"ILTableContentSizeDidChange"
#define ILHistoryDidChange                             @"ILHistoryDidChange"
#define ILProjectLabelsDidChange                       @"ILProjectLabelsDidChange"
#define ILNotificationScreenDidChange                  @"ILNotificationScreenDidChange"

#define LogAssert1(cond, desc, arg1) if(!(cond)) NSLog(@"*** [%@ %@] => %@", [self class], NSStringFromSelector(_cmd), [NSString stringWithFormat:desc, arg1]);

// Returns true if there is an error returned by a method. Supports nil error.
#define IS_ERROR(e)  (e && *e)

#define ILErrorDomain  @"ILErrorDomain"

// #define REPAIR_DOCUMENT [[NSUserDefaults standardUserDefaults] boolForKey:@"repair"]
#define REPAIR_DOCUMENT  YES

// Re-enable concurrent operations in 4.1 when we have enough time to test it.
//#define CONCURRENT_OP_OPTIONS ([[NSUserDefaults standardUserDefaults] boolForKey:@"nonConcurrentOp"]?0:NSEnumerationConcurrent)
#define CONCURRENT_OP_OPTIONS  YES

static inline BOOL IsTestRunning()
{
    return (NSClassFromString(@"XCTestCase") != nil);
}

enum
{
    ILStringIgnoreCase              = 1,
    ILStringIgnoreControlCharacters = 2
};

// Block used for various callback
typedef void(^CallbackBlock)(void);

// Block used for various callback that can be interrupted
typedef BOOL(^CancellableCallbackBlock)(void);

// Block used for various error callback
typedef void(^CallbackErrorBlock)(NSError *error);
