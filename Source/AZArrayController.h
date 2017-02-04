//
//  AZArrayController.h
//  iLocalize3
//
//  Created by Jean on 10.04.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

@interface AZArrayController : NSArrayController
{
    NSMutableArray  *mFilterDescriptors;
    id               mDelegate;
    id               mNewObject;
}

- (void)setFilterDescriptor:(id)filter;
- (void)setFilterDescriptors:(NSArray *)filters;
- (void)setDelegate:(id)delegate;

@end
