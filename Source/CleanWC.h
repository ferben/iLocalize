//
//  CleanWC.h
//  iLocalize3
//
//  Created by Jean on 30.05.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractWC.h"

@interface CleanWC : AbstractWC {

}
- (NSDictionary*)attributes;
- (IBAction)cancel:(id)sender;
- (IBAction)clean:(id)sender;
@end
