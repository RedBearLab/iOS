//
//  ANImageBitmapRep.m
//  ImageManip
//
//  Created by Alex Nichol on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANImageBitmapRep.h"

BMPixel BMPixelMake (CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
	BMPixel pixel;
	pixel.red = red;
	pixel.green = green;
	pixel.blue = blue;
	pixel.alpha = alpha;
	return pixel;
}

#if TARGET_OS_IPHONE
UIColor * UIColorFromBMPixel (BMPixel pixel) {
	return [UIColor colorWithRed:pixel.red green:pixel.green blue:pixel.blue alpha:pixel.alpha];
}
#elif TARGET_OS_MAC
NSColor * NSColorFromBMPixel (BMPixel pixel) {
	return [NSColor colorWithCalibratedRed:pixel.red green:pixel.green blue:pixel.blue alpha:pixel.alpha];
}
#endif

@interface ANImageBitmapRep (BaseClasses)

- (void)generateBaseClasses;

@end

@implementation ANImageBitmapRep

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	if (!baseClasses) [self generateBaseClasses];
	for (int i = 0; i < [baseClasses count]; i++) {
		BitmapContextManipulator * manip = baseClasses[i];
		if ([manip respondsToSelector:[anInvocation selector]]) {
			[anInvocation invokeWithTarget:manip];
			return;
		}
	}
	[self doesNotRecognizeSelector:[anInvocation selector]];
}

#if __has_feature(objc_arc) == 1
+ (ANImageBitmapRep *)imageBitmapRepWithCGSize:(CGSize)avgSize {
	return [[ANImageBitmapRep alloc] initWithSize:BMPointMake(round(avgSize.width), round(avgSize.height))];
}

+ (ANImageBitmapRep *)imageBitmapRepWithImage:(ANImageObj *)anImage {
	return [[ANImageBitmapRep alloc] initWithImage:anImage];
}
#else
+ (ANImageBitmapRep *)imageBitmapRepWithCGSize:(CGSize)avgSize {
	return [[[ANImageBitmapRep alloc] initWithSize:BMPointMake(round(avgSize.width), round(avgSize.height))] autorelease];
}

+ (ANImageBitmapRep *)imageBitmapRepWithImage:(ANImageObj *)anImage {
	return [[[ANImageBitmapRep alloc] initWithImage:anImage] autorelease];
}
#endif

- (void)invertColors {
	UInt8 pixel[4];
	BMPoint size = [self bitmapSize];
	for (long y = 0; y < size.y; y++) {
		for (long x = 0; x < size.x; x++) {
			[self getRawPixel:pixel atPoint:BMPointMake(x, y)];
			pixel[0] = 255 - pixel[0];
			pixel[1] = 255 - pixel[1];
			pixel[2] = 255 - pixel[2];
			[self setRawPixel:pixel atPoint:BMPointMake(x, y)];
		}
	}
}

- (void)setQuality:(CGFloat)quality {
	NSAssert(quality >= 0 && quality <= 1, @"Quality must be between 0 and 1.");
	if (quality == 1.0) return;
	CGSize cSize = CGSizeMake((CGFloat)([self bitmapSize].x) * quality, (CGFloat)([self bitmapSize].y) * quality);
	BMPoint oldSize = [self bitmapSize];
	[self setSize:BMPointMake(round(cSize.width), round(cSize.height))];
	[self setSize:oldSize];
}

- (void)setBrightness:(CGFloat)brightness {
	NSAssert(brightness >= 0 && brightness <= 2, @"Brightness must be between 0 and 2.");
	BMPoint size = [self bitmapSize];
	for (long y = 0; y < size.y; y++) {
		for (long x = 0; x < size.x; x++) {
			BMPoint point = BMPointMake(x, y);
			BMPixel pixel = [self getPixelAtPoint:point];
			pixel.red *= brightness;
			pixel.green *= brightness;
			pixel.blue *= brightness;
			if (pixel.red > 1) pixel.red = 1;
			if (pixel.green > 1) pixel.green = 1;
			if (pixel.blue > 1) pixel.blue = 1;
			[self setPixel:pixel atPoint:point];
		}
	}
}

- (BMPixel)getPixelAtPoint:(BMPoint)point {
	UInt8 rawPixel[4];
	[self getRawPixel:rawPixel atPoint:point];
	BMPixel pixel;
	pixel.alpha = (CGFloat)(rawPixel[3]) / 255.0;
	pixel.red = ((CGFloat)(rawPixel[0]) / 255.0) / pixel.alpha;
	pixel.green = ((CGFloat)(rawPixel[1]) / 255.0) / pixel.alpha;
	pixel.blue = ((CGFloat)(rawPixel[2]) / 255.0) / pixel.alpha;
	return pixel;
}

- (void)setPixel:(BMPixel)pixel atPoint:(BMPoint)point {
	NSAssert(pixel.red >= 0 && pixel.red <= 1, @"Pixel color must range from 0 to 1.");
	NSAssert(pixel.green >= 0 && pixel.green <= 1, @"Pixel color must range from 0 to 1.");
	NSAssert(pixel.blue >= 0 && pixel.blue <= 1, @"Pixel color must range from 0 to 1.");
	NSAssert(pixel.alpha >= 0 && pixel.alpha <= 1, @"Pixel color must range from 0 to 1.");
	UInt8 rawPixel[4];
	rawPixel[0] = round(pixel.red * 255.0 * pixel.alpha);
	rawPixel[1] = round(pixel.green * 255.0 * pixel.alpha);
	rawPixel[2] = round(pixel.blue * 255.0 * pixel.alpha);
	rawPixel[3] = round(pixel.alpha * 255.0);
	[self setRawPixel:rawPixel atPoint:point];
}

- (ANImageObj *)image {
	return ANImageFromCGImage([self CGImage]);
}

#if __has_feature(objc_arc) != 1
- (void)dealloc {
	[baseClasses release];
	[super dealloc];
}
#endif

#pragma mark Base Classes

- (void)generateBaseClasses {
	BitmapCropManipulator * croppable = [[BitmapCropManipulator alloc] initWithContext:self];
	BitmapScaleManipulator * scalable = [[BitmapScaleManipulator alloc] initWithContext:self];
	BitmapRotationManipulator * rotatable = [[BitmapRotationManipulator alloc] initWithContext:self];
    BitmapDrawManipulator * drawable = [[BitmapDrawManipulator alloc] initWithContext:self];
	baseClasses = @[croppable, scalable, rotatable, drawable];
#if __has_feature(objc_arc) != 1
	[rotatable release];
	[scalable release];
	[croppable release];
    [drawable release];
#endif
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
	BMPoint size = [self bitmapSize];
	ANImageBitmapRep * rep = [[ANImageBitmapRep allocWithZone:zone] initWithSize:size];
	CGContextRef newContext = [rep context];
	CGContextDrawImage(newContext, CGRectMake(0, 0, size.x, size.y), [self CGImage]);
	[rep setNeedsUpdate:YES];
	return rep;
}

@end
