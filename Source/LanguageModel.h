//
//  LanguageModel.h
//  iLocalize3
//
//  Created by Jean on 30.12.04.
//  Copyright 2004 Arizona Software. All rights reserved.
//

@class FileModel;

@interface LanguageModel : NSObject <NSCoding> {
    NSString            *mLanguage;
    NSMutableArray        *mFileModelArray;
    
    // volatile
    NSMutableDictionary *mPath2Model;
}

@property (nonatomic, strong) NSArray *translateUsingGlossariesSelectedStates;
@property (nonatomic, strong) NSArray *updateOrAddInGlossariesSelectedStates;

+ (LanguageModel*)model;

- (void)setLanguage:(NSString*)language;
- (NSString*)language;

- (void)addFileModel:(FileModel*)fileModel;
- (void)deleteFileModel:(FileModel*)fileModel;
- (NSMutableArray*)fileModels;
- (void)removeFromCache:(FileModel*)fileModel;

- (FileModel*)fileModelForBaseFileModel:(FileModel*)baseFileModel;

- (void)addToCache:(FileModel*)fm;
- (void)removeFromCache:(FileModel*)fm;

@end
