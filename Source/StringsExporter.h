//
//  StringsExporter.h
//  iLocalize
//
//  Created by Jean Bovet on 4/29/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "XMLExporter.h"

@class StringsContentModel;

@interface StringsExporter : XMLExporter {
    StringsContentModel *stringsContentModel;
    NSUInteger row;
}

@end
