//
//  CommandLineProcessing.h
//  iLocalize
//
//  Created by Jean Bovet on 1/19/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

@class CmdLineProjectProvider;

@interface CmdLineProcessing : NSObject {
	CmdLineProjectProvider *provider;
}
+ (BOOL)process;
@end
