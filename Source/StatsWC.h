//
//  StatsWC.h
//  iLocalize3
//
//  Created by Jean on 30.05.05.
//  Copyright 2005 Arizona Software. All rights reserved.
//

#import "AbstractWC.h"

@interface StatsWC : AbstractWC
{
    IBOutlet NSPopUpButton        *mSourcePopUp;
    IBOutlet NSProgressIndicator  *mProgressIndicator;
    IBOutlet NSTextField          *mProgressInfoField;
        
    IBOutlet NSTextField          *mPriceBaseField;
    IBOutlet NSPopUpButton        *mPriceUnitPopUp;
    
    IBOutlet NSArrayController    *mStatsController;
    
    NSMutableDictionary           *mStatsDic;
    float                          mPriceTotal;
    float                          mPriceToTranslateTotal;
}

- (IBAction)changeSource:(id)sender;
- (IBAction)changePriceBase:(id)sender;
- (IBAction)changePriceUnit:(id)sender;
- (IBAction)copyToClipboard:(id)sender;
- (IBAction)close:(id)sender;

@end
