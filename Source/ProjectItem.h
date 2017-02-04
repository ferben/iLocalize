//
//  ProjectItem.h
//  iLocalize
//
//  Created by Jean Bovet on 5/24/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface ProjectItem : NSObject
{
    NSString         *path;
    NSString         *name;
    NSDate           *date;
    NSDateFormatter  *dateFormatter;
    NSImage          *image;
}

@property (strong) NSString *path;
@property (strong) NSString *name;
@property (strong) NSDate *date;
@property (strong) NSDateFormatter *dateFormatter;
@property (strong) NSImage *image;

- (NSString *)imageSubtitle;

@end
