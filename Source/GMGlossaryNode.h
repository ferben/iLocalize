//
//  GMGlossaryNode.h
//  iLocalize
//
//  Created by Jean on 4/2/09.
//  Copyright 2009 Arizona Software. All rights reserved.
//

@class Glossary;

@interface GMGlossaryNode : NSObject
{
    Glossary        *_glossary;
    NSString        *_path;
    NSMutableArray  *children;
    NSString        *searchString;
}

@property (strong) NSString *path;
@property (strong) Glossary *glossary;
@property (strong) NSString *searchString;

+ (GMGlossaryNode *)nodeWithPath:(NSString *)title;
+ (GMGlossaryNode *)nodeWithGlossary:(Glossary *)glossary;

- (void)insert:(Glossary *)glossary;
- (void)applySearchString:(NSString *)string;

- (NSArray *)children;
- (NSString *)name;
- (NSString *)file;
- (NSString *)sourceLanguage;
- (NSString *)targetLanguage;
- (NSInteger)items;

@end
