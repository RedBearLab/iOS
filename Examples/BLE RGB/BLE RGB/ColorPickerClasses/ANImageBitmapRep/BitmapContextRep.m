//
//  BitmapContextRep.m
//  ImageManip
//
//  Created by Alex Nichol on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BitmapContextRep.h"

BMPoint BMPointMake (long x, long y) {
	BMPoint p;
	p.x = x;
	p.y = y;
	return p;
}

BMPoint BMPointFromSize (CGSize size) {
	return BMPointMake(round(size.width), round(size.height));
}

BMPoint BMPointFromPoint (CGPoint point) {
	return BMPointMake(round(point.x), round(point.y));
}

@implementation BitmapContextRep

- (id)initWithImage:(ANImageObj *)image {
	if ((self = [super init])) {
		context = [CGContextCreator newARGBBitmapContextWithImage:CGImageFromANImage(image)];
		bitmapData = CGBitmapContextGetData(context);
		lastImage = CGBitmapContextCreateImage(context);
	}
	return self;
}

- (id)initWithSize:(BMPoint)sizePoint {
	if ((self = [super init])) {
		if (sizePoint.x == 0 || sizePoint.y == 0) {
#if __has_feature(objc_arc)
			return nil;
#else
			[super dealloc];
			return nil;
#endif
		}
		context = [CGContextCreator newARGBBitmapContextWithSize:CGSizeMake(sizePoint.x, sizePoint.y)];
		bitmapData = CGBitmapContextGetData(context);
		lastImage = CGBitmapContextCreateImage(context);
	}
	return self;
}

- (CGContextRef)context {
	return context;
}

- (void)setContext:(CGContextRef)aContext {
	if (context == aContext) return;
	// free previous.
	CGContextRelease(context);
	free(bitmapData);
	// create new.
	context = CGContextRetain(aContext);
	bitmapData = CGBitmapContextGetData(aContext);
	[self setNeedsUpdate:YES];
}

- (BMPoint)bitmapSize {
	BMPoint point;
	point.x = (long)CGBitmapContextGetWidth(context);
	point.y = (long)CGBitmapContextGetHeight(context);
	return point;
}

- (void)setNeedsUpdate:(BOOL)flag {
	needsUpdate = flag;
}

- (void)getRawPixel:(UInt8 *)rgba atPoint:(BMPoint)point {
	size_t width = CGBitmapContextGetWidth(context);
	size_t height = CGBitmapContextGetHeight(context);
	NSAssert(point.x >= 0 && point.x < width, @"Point must be within bitmap.");
	NSAssert(point.y >= 0 && point.y < height, @"Point must be within bitmap.");
	unsigned char * argbData = &bitmapData[((point.y * width) + point.x) * 4];
	rgba[0] = argbData[1]; // red
	rgba[1] = argbData[2]; // green
	rgba[2] = argbData[3]; // blue
	rgba[3] = argbData[0]; // alpha
	[self setNeedsUpdate:YES];
}

- (void)setRawPixel:(const UInt8 *)rgba atPoint:(BMPoint)point {
	size_t width = CGBitmapContextGetWidth(context);
	size_t height = CGBitmapContextGetHeight(context);
	NSAssert(point.x >= 0 && point.x < width, @"Point must be within bitmap.");
	NSAssert(point.y >= 0 && point.y < height, @"Point must be within bitmap.");
	unsigned char * argbData = &bitmapData[((point.y * width) + point.x) * 4];
	argbData[1] = rgba[0]; // red
	argbData[2] = rgba[1]; // green
	argbData[3] = rgba[2]; // blue
	argbData[0] = rgba[3]; // alpha
	[self setNeedsUpdate:YES];
}

- (CGImageRef)CGImage {
	if (needsUpdate) {
		CGImageRelease(lastImage);
		lastImage = CGBitmapContextCreateImage(context);
		needsUpdate = NO;
	}
#if __has_feature(objc_arc) == 1
	return (__bridge CGImageRef)CGImageReturnAutoreleased(lastImage);
#else
	return (CGImageRef)[[CGImageContainer imageContainerWithImage:lastImage] image];
#endif
}

- (void)dealloc {
	CGContextRelease(context);
	free(bitmapData);
	if (lastImage != NULL) {
		CGImageRelease(lastImage);
	}
#if __has_feature(objc_arc) != 1
	[super dealloc];
#endif
}

@end
