//
//  ProjectDiskOperations.h
//  iLocalize
//
//  Created by Jean Bovet on 1/19/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@class ProjectModel;
@class ProjectPrefs;

#define CURRENT_DOCUMENT_VERSION  430

#define PROJECT_VERSION_KEY     @"PROJECT_VERSION_KEY"
#define PROJECT_MODEL_KEY       @"PROJECT_MODEL_KEY"
#define PROJECT_PREFS_KEY       @"PROJECT_PREFS_KEY"
#define PROJECT_OS_VERSION      @"PROJECT_OS_VERSION"
#define PROJECT_NIBENGINE_TYPE  @"PROJECT_NIBENGINE_TYPE"

@interface ProjectDiskOperations : NSObject
{
}

+ (NSData *)dataForModel:(ProjectModel *)model prefs:(ProjectPrefs *)prefs;
+ (NSDictionary *)readProjectUsingData:(NSData *)data;
+ (ProjectModel *)readModelFromPath:(NSString *)path;

@end
