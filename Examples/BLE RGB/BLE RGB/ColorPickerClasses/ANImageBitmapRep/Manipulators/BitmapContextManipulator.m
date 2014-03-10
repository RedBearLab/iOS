//
//  BitmapContextManip.m
//  ImageBitmapRep
//
//  Created by Alex Nichol on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BitmapContextManipulator.h"

@implementation BitmapContextManipulator

@synthesize bitmapContext;

- (id)initWithContext:(BitmapContextRep *)aContext {
	if ((self = [super init])) {
		self.bitmapContext = aContext;
	}
	return self;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	[anInvocation invokeWithTarget:bitmapContext];
}

#if __has_feature(objc_arc) != 1

- (void)dealloc {
	self.bitmapContext = nil;
	[super dealloc];
}

#endif

@end
