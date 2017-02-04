//
//  ASProject.h
//  iLocalize
//
//  Created by Jean on 12/1/07.
//  Copyright 2007 Arizona Software. All rights reserved.
//

#import "ASManager.h"

@class ProjectDocument;
@interface ASProject : NSObject <ASManagerDelegate>
{
    ProjectDocument  *mDocument;
}

+ (ASProject *)projectWithDocument:(ProjectDocument *)doc;
- (void)setDocument:(ProjectDocument *)doc;
- (NSString *)name;

@end
