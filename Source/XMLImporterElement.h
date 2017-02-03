//
//  XMLImporterElement.h
//  iLocalize
//
//  Created by Jean Bovet on 4/20/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XMLImporterElement : NSObject {
    NSString *file;
    NSString *key;
    NSString *source;
    NSString *translation;
}
@property (strong) NSString *file;
@property (strong) NSString *key;
@property (strong) NSString *source;
@property (strong) NSString *translation;
@end
