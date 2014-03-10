//
//  BitmapContextManip.h
//  ImageBitmapRep
//
//  Created by Alex Nichol on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BitmapContextRep.h"

@interface BitmapContextManipulator : NSObject <BitmapContextRep> {
#if __has_feature(objc_arc) == 1
	__unsafe_unretained BitmapContextRep * bitmapContext;
#else
	BitmapContextRep * bitmapContext;
#endif
}

#if __has_feature(objc_arc) == 1
@property (nonatomic, assign) BitmapContextRep * bitmapContext;
#else
@property (nonatomic, assign) BitmapContextRep * bitmapContext;
#endif

- (id)initWithContext:(BitmapContextRep *)aContext;

@end
