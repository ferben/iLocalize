//
//  StringControllerProtocol.h
//  iLocalize
//
//  Created by Jean Bovet on 4/19/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@protocol StringControllerProtocol

- (NSString *)key;

- (NSString *)base;
- (NSString *)baseComment;
- (NSString *)translation;
- (NSString *)translationComment;

- (void)setAutomaticTranslation:(NSString *)translation;
- (void)setStatus:(unsigned char)status;
- (unsigned char)status;

@end

