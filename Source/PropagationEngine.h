//
//  PropagationEngine.h
//  iLocalize
//
//  Created by Jean Bovet on 3/30/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

/*
 Discussion around the propagation (· is a white space):
 
 1) Each string is decomposed using the following schema:
 
 "This is a string           : something"
 "<-  root ------><- space -><- punctuation -><- remaining ->"
 
 where:
 - root : string until the punctuation or until the first space before the punctuation
 - space : any space betwen the root string and the punctuation
 - punctuation : the punctuation
 - remaining : any character after the punctuation
 
 2) The idea is to translate all the strings that have the same root but different punctuation.
 The only exception is when a translation has space(s) between the root and the punctuation, then
 the space(s) are propagated only to the string having the same punctuation (see examples below):
 
 a) Example
 House
 House:
 House...
 House…
 House in the lake
 House: in the lake.
 
 If "House" => "Dog" then
 
 Dog
 Dog:
 Dog...
 Dog…
 House in the lake
 House: in the lake.
 
 If "Dog:" becomes "Dog·:" then
  
 Dog
 Dog:
 Dog...
 Dog·…
 House in the lake
 House: in the lake.
*/

#import "StringController.h"

@class Extraction;

typedef void(^PropagationEngineWillChangeStringController)(id<StringControllerProtocol>string);

@interface PropagationEngine : NSObject
{
    NSMutableArray  *punctuationList;
}

+ (PropagationEngine *)engine;

/**
 Return the extraction for the given string.
 */
- (Extraction *)extract:(NSString *)s;

/**
 Propagate the "root" content of a string controller protocol to an array of string controller protocol.
 @param string The string whose root content needs to be propagated.
 @param scs Array of string controller protocol objects where the root content is going to be propagated
 @param ignoreCase Flag that indicates if the case should be taken into account when comparing the root
 @param block Block that will be invoked just before the string controller is being modified
 */
- (void)propagateString:(id<StringControllerProtocol>)string toStrings:(NSArray *)scs ignoreCase:(BOOL)ignoreCase block:(PropagationEngineWillChangeStringController)block;

@end
