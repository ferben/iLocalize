//
//  ILGlossaryEntry.h
//  iLocalize
//
//  Created by Jean Bovet on 4/25/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

/**
 Single entry of a glossary.
 */
@interface GlossaryEntry : NSObject
{
    NSString  *source;
    NSString  *translation;
}

@property (strong) NSString *source;
@property (strong) NSString *translation;

@end
