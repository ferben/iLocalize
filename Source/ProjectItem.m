//
//  ProjectItem.m
//  iLocalize
//
//  Created by Jean Bovet on 5/24/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "ProjectItem.h"


@implementation ProjectItem

@synthesize path;
@synthesize name;
@synthesize date;
@synthesize dateFormatter;
@synthesize image;

- (NSString *)  imageRepresentationType
{
    return IKImageBrowserNSImageRepresentationType;
}

- (id)  imageRepresentation
{
    return self.image;
}

- (NSString *) imageUID
{
    return self.path;
}

- (NSString *) imageTitle
{
    return self.name;
}

- (NSString *) imageSubtitle
{
    return [dateFormatter stringFromDate:self.date];
}

@end
