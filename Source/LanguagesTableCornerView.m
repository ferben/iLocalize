//
//  LanguagesTableCornerView.m
//  iLocalize3
//
//  Created by Jean on 12.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "LanguagesTableCornerView.h"

@implementation LanguagesTableCornerView

- (void)drawRect:(NSRect)r
{
    [[NSImage imageNamed:@"TableViewGreyHeader"] drawInRect:r 
                                                  operation:NSCompositingOperationSourceOver 
                                                   fraction:1];
    
    [super drawRect:r];
}

@end
