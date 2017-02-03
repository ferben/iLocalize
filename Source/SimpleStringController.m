//
//  SimpleStringController.m
//  iLocalize
//
//  Created by Jean Bovet on 3/30/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "SimpleStringController.h"


@implementation SimpleStringController

@synthesize key;
@synthesize base;
@synthesize translation;

+ (SimpleStringController*)stringWithBase:(NSString*)base translation:(NSString*)translation
{
    SimpleStringController *sc = [[SimpleStringController alloc] init];
    sc.key = @"";
    sc.base = base;
    sc.translation = translation;
    return sc;
}

- (void)setStatus:(unsigned char)status {
    
}

- (unsigned char)status {
    return 0;
}

- (NSString*)baseComment {
    return nil;
}

- (NSString*)translationComment {
    return nil;
}

- (void)setAutomaticTranslation:(NSString *)_translation
{
    self.translation = _translation;
}

- (BOOL)isEqual:(id)object
{
    return [self.key isEqual:[object key]] && [self.base isEqual:[object base]] && [self.translation isEqual:[object translation]];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"key=%@, base=%@, translation=%@", self.key, self.base, self.translation];
}

@end
