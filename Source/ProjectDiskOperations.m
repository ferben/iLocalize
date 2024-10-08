//
//  ProjectDiskOperations.m
//  iLocalize
//
//  Created by Jean Bovet on 1/19/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ProjectDiskOperations.h"

@implementation ProjectDiskOperations

+ (NSData*)dataForModel:(ProjectModel*)model prefs:(ProjectPrefs*)prefs
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:@CURRENT_DOCUMENT_VERSION forKey:PROJECT_VERSION_KEY];
    [archiver encodeObject:[NSNumber numberWithLong:[Utils getOSVersion]] forKey:PROJECT_OS_VERSION];
    [archiver encodeObject:@2L forKey:PROJECT_NIBENGINE_TYPE];
    [archiver encodeObject:[NSKeyedArchiver archivedDataWithRootObject:model] forKey:PROJECT_MODEL_KEY];
    [archiver encodeObject:[NSKeyedArchiver archivedDataWithRootObject:prefs] forKey:PROJECT_PREFS_KEY];
    [archiver finishEncoding];
    return data;
    
    /* How we did before version 3.6:
     NSMutableDictionary *dic = [NSMutableDictionary dictionary];
     [dic setObject:[NSNumber numberWithInt:CURRENT_DOCUMENT_VERSION] forKey:PROJECT_VERSION_KEY];
     [dic setObject:[NSNumber numberWithLong:[Utils getOSVersion]] forKey:PROJECT_OS_VERSION];
     [dic setObject:mProjectModel forKey:PROJECT_MODEL_KEY];
     [dic setObject:mProjectPrefs forKey:PROJECT_PREFS_KEY];
     return [NSArchiver archivedDataWithRootObject:dic];    */    
}

+ (NSDictionary*)readProjectUsingData:(NSData *)data
{
    NSDictionary *dic;
    
    if ([data length] == 0)
        return dic;
    
    @try
    {
        // Try to open as a keyed archive (since version 3.6)
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        tempDic[PROJECT_VERSION_KEY] = [unarchiver decodeObjectForKey:PROJECT_VERSION_KEY];
        tempDic[PROJECT_OS_VERSION] = [unarchiver decodeObjectForKey:PROJECT_OS_VERSION];
        id nibEngineType = [unarchiver decodeObjectForKey:PROJECT_NIBENGINE_TYPE];
        
        if (nibEngineType)
        {
            tempDic[PROJECT_NIBENGINE_TYPE] = nibEngineType;            
        }
        
        tempDic[PROJECT_MODEL_KEY] = [NSKeyedUnarchiver unarchiveObjectWithData:[unarchiver decodeObjectForKey:PROJECT_MODEL_KEY]];
        
        @try
        {
            // Since version 4
            tempDic[PROJECT_PREFS_KEY] = [NSKeyedUnarchiver unarchiveObjectWithData:[unarchiver decodeObjectForKey:PROJECT_PREFS_KEY]];
        }
        @catch (NSException * e)
        {
            // Before version 4
            tempDic[PROJECT_PREFS_KEY] = [NSKeyedUnarchiver unarchiveObjectWithData:[unarchiver decodeObjectForKey:PROJECT_PREFS_KEY]];                
        }
        
        [unarchiver finishDecoding];
        
        dic = tempDic;
    }
    @catch (NSException *e)
    {
        // Invalid archive. Perhaps an old one. Try the standard unarchiver.
        dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }

    return dic;
}

+ (ProjectModel*)readModelFromPath:(NSString*)path
{
    NSDictionary *dic = [ProjectDiskOperations readProjectUsingData:[NSData dataWithContentsOfFile:path]];
    return dic[PROJECT_MODEL_KEY];
}

@end
