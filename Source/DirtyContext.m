//
//  DirtyContext.m
//  iLocalize
//
//  Created by Jean Bovet on 2/22/11.
//  Copyright 2011 Arizona Software. All rights reserved.
//

#import "DirtyContext.h"
#import "StringController.h"
#import "FileController.h"
#import "LanguageController.h"
#import "ProjectController.h"

@implementation DirtyContext

+ (DirtyContext*)contextWithStringController:(StringController*)sc
{
	DirtyContext *dc = [[DirtyContext alloc] init];
	dc.sc = sc;
	return dc;
}

+ (DirtyContext*)contextWithFileController:(FileController*)fc
{
	DirtyContext *dc = [[DirtyContext alloc] init];
	dc.fc = fc;
	return dc;
}

- (void)accumulate:(DirtyContext*)other
{
	if(other.sc) {
		self.sc = other.sc;		
	}
	if(other.fc) {
		self.fc = other.fc;		
	}
	if(other.lc) {
		self.lc = other.lc;		
	}
	if(other.pc) {
		self.pc = other.pc;		
	}
}

- (void)pushSource:(id)source
{
	if([source isKindOfClass:[StringController class]]) {
		self.sc = source;
	}
	if([source isKindOfClass:[FileController class]]) {
		self.fc = source;
	}
	if([source isKindOfClass:[LanguageController class]]) {
		self.lc = source;
	}
	if([source isKindOfClass:[ProjectController class]]) {
		self.pc = source;
	}
	if([source isKindOfClass:[DirtyContext class]]) {
		[self accumulate:source];
	}
}

- (void)reset
{
	self.sc = nil;
	self.fc = nil;
	self.lc = nil;
	self.pc = nil;
}

- (id)copyWithZone:(NSZone*)zone
{
	DirtyContext *c = [[DirtyContext alloc] init];
	[c accumulate:self];
	return c;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"sc=%@, fc=%@, lc=%@, pc=%@", self.sc, self.fc, self.lc, self.pc];
}

@end
