//
//  ProjectExportMailScripts.h
//  iLocalize
//
//  Created by Jean on 12/17/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

@interface ProjectExportMailScripts : NSObject {
    NSMutableArray                *mMailPrograms;
}
+ (ProjectExportMailScripts*)shared;
- (void)update;
- (NSArray*)programs;
- (NSString*)scriptFileForPrograms:(NSString*)program;
@end
