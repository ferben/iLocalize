//
//  AddLocationWC.h
//  iLocalize3
//
//  Created by Jean on 10.01.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractWC.h"

@interface AddLocationWC : AbstractWC
{
    IBOutlet NSPopUpButton  *mPopUpLocation;
}

- (NSString *)location;
- (IBAction)cancel:(id)sender;
- (IBAction)add:(id)sender;

@end
