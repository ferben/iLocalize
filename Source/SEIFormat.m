//
//  SEIFormat.m
//  iLocalize
//
//  Created by Jean Bovet on 4/22/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "SEIFormat.h"


@implementation SEIFormat

@synthesize format;
@synthesize displayName;
@synthesize importerClassName;
@synthesize exporterClassName;
@synthesize readableExtensions;
@synthesize writableExtension;

- (XMLImporter*)createImporter
{
    Class c = NSClassFromString(self.importerClassName);
    XMLImporter *importer = [[c alloc] init];
    importer.format = format;
    return importer;
}

- (XMLExporter*)createExporter
{
    Class c = NSClassFromString(self.exporterClassName);
    return [[c alloc] init];
}

- (BOOL)writable
{
    return self.writableExtension != nil;
}

@end
