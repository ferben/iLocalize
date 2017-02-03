//
//  FileConflictDecision.h
//  iLocalize
//
//  Created by Jean Bovet on 2/14/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//


@interface FileConflictDecision : NSObject {
    int decision;
    NSString *file;
}
@property int decision;
@property (strong) NSString *file;
@end
