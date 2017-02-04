//
//  FileController.h
//  iLocalize3
//
//  Created by Jean on 30.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

#import "AbstractController.h"
#import "ProjectLabelsProtocol.h"
#import "FileControllerProtocol.h"

@class FileModel;
@class StringModel;
@class StringsContentModel;
@class StringController;
@class StringEncoding;

@class FMModule;

@interface FileController : AbstractController <ProjectLabelPersistent, FileControllerProtocol>
{
    FileModel       *mBaseFileModel;
    FileModel       *mFileModel;
    
    // Variables (used for performance)
    FMModule        *mFileModule;           // associated file module (if any exists for this type of file)
    NSString        *mSmartPath;
    
    // Temporary (display only)
    NSMutableArray  *mStatusDescription;    // description of each status icon used by the tooltips
    NSRect           mStatusImageRect;       // last rect used to display the status icons (currently only in project window)
    BOOL             mMarkUsed;              // used to indicate the file controller owning the selected string controller(s)
    NSMutableSet    *mStringsLabelIndexes;  // set of all labels used by the strings owned by this file controller
}

- (void)clearCache; // for subclass only

- (void)setBaseFileModel:(FileModel *)model;
- (FileModel *)baseFileModel;

- (void)setFileModel:(FileModel *)model;
- (FileModel *)fileModel;

- (void)markUsed;
- (void)unmarkUsed;
- (BOOL)isUsed;

- (void)setAuxiliaryData:(id)data forKey:(NSString *)key;
- (id)auxiliaryDataForKey:(NSString *)key;

- (void)setStatusSynchDone;
- (BOOL)statusSynchDone;

- (void)setStatusSynchToDisk;
- (BOOL)statusSynchToDisk;

- (void)setStatusSynchFromDisk;
- (BOOL)statusSynchFromDisk;

- (void)setStatusWarning:(BOOL)flag;
- (BOOL)statusWarning;

- (void)setStatusCheckLayout:(BOOL)flag;
- (BOOL)statusCheckLayout;

- (void)setStatusNotFound:(BOOL)flag;
- (BOOL)statusNotFound;

- (void)setStatusUpdateAdded:(BOOL)flag;
- (BOOL)statusUpdateAdded;

- (void)setStatusUpdateUpdated:(BOOL)flag;
- (BOOL)statusUpdateUpdated;

- (BOOL)statusDone;

- (void)setStatus:(int)status;
- (int)status;
- (void)setStatusImageRect:(NSRect)r;
- (NSImage *)statusImage;
- (NSString *)statusDescriptionAtPosition:(NSPoint)p;
- (NSString *)statusDescription;

- (void)approve;
- (void)clearUpdatedStatus;
- (BOOL)needsToUpdateStatus;
- (void)updateStatus;

- (void)setDirty;
- (void)setModified:(int)what;

- (BOOL)displayNumberOfStrings;
- (BOOL)displayStatus;
- (BOOL)displayProgress;

- (BOOL)isBaseFileController;
- (FileController *)baseFileController;

- (NSString *)baseLanguage;
- (NSString *)language;

- (void)setModificationDate:(NSDate *)date;

- (NSString *)filename;
- (NSString *)sortableFilename;
- (NSString *)smartPathName;
- (NSString *)smartPath;

- (void)setRelativeFilePath:(NSString *)path;
- (NSString *)relativeFilePath;

- (NSString *)relativeBaseFilePath;
- (NSString *)absoluteFilePath;

- (NSString *)absoluteBaseFilePath;

//- (int)type;
- (NSImage *)typeImage;

- (void)setIgnore:(BOOL)flag;
- (BOOL)ignore;

- (void)setLocal:(BOOL)flag;
- (BOOL)isLocal;

- (void)setHasEncoding:(BOOL)flag;
- (BOOL)hasEncoding;

- (void)setEncoding:(StringEncoding *)encoding;
- (StringEncoding *)encoding;
- (NSString *)encodingName;
- (BOOL)supportsEncoding;

- (NSSet *)stringsLabelIndexes;
- (void)stringLabelsDidChange;

- (float)percentCompleted;
- (float)percentTranslated;
- (float)percentAutoTranslated;
- (float)percentToTranslate;

- (NSUInteger)numberOfStrings;
- (NSUInteger)numberOfTranslatedStrings;
- (NSUInteger)numberOfNonTranslatedStrings;
- (NSUInteger)numberOfToCheckStrings;
- (NSUInteger)numberOfInvariantStrings;
- (NSUInteger)numberOfBaseModifiedStrings;
- (NSUInteger)numberOfLockedStrings;
- (NSUInteger)numberOfAutoTranslatedStrings;
- (NSUInteger)numberOfAutoInvariantStrings;

- (NSUInteger)totalContentCount;
- (NSUInteger)filteredContentCount;
- (NSString *)contentInfo;

- (void)setBaseModelContent:(id)content;
- (id)baseModelContent;
- (StringsContentModel *)baseModelStringsContent;
- (BOOL)hasBaseModelContent;

- (void)setModelContent:(id)content;
- (id)modelContent;
- (StringsContentModel *)modelStringsContent;
- (BOOL)hasModelContent;

- (void)stringControllersDidChange;
- (void)filteredStringControllersDidChange;
- (void)baseStringModelDidChange:(StringModel *)model;

- (id)stringControllers;
- (id)stringControllerForKey:(NSString *)key;
- (id)baseStringController:(StringController *)sc;
- (id)stringControllerMatchingBaseStringController:(StringController *)bsc;

- (id)visibleStringControllers;
- (id)filteredStringControllers;

- (NSString *)pFileLabel;
- (id)pString;
- (NSString *)pFileName;

@end
