//
//  ANImageBitmapRep.h
//  ImageManip
//
//  Created by Alex Nichol on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OSCommonImage.h"
#import "BitmapScaleManipulator.h"
#import "BitmapCropManipulator.h"
#import "BitmapRotationManipulator.h"
#import "BitmapDrawManipulator.h"
#import "UIImage+ANImageBitmapRep.h"

typedef struct {
	CGFloat red;
	CGFloat green;
	CGFloat blue;
	CGFloat alpha;
} BMPixel;

BMPixel BMPixelMake (CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha);
#if TARGET_OS_IPHONE
UIColor * UIColorFromBMPixel (BMPixel pixel);
#elif TARGET_OS_MAC
NSColor * NSColorFromBMPixel (BMPixel pixel);
#endif

@interface ANImageBitmapRep : BitmapContextRep <BitmapScaleManipulator, BitmapCropManipulator, BitmapRotationManipulator, BitmapDrawManipulator, NSCopying> {
#if __has_feature(objc_arc) == 1
	__strong NSArray * baseClasses;
#else
	NSArray * baseClasses;
#endif
}

#if __has_feature(objc_arc) == 1
+ (ANImageBitmapRep *)imageBitmapRepWithCGSize:(CGSize)avgSize __attribute__((ns_returns_autoreleased));
+ (ANImageBitmapRep *)imageBitmapRepWithImage:(ANImageObj *)anImage __attribute__((ns_returns_autoreleased));
#else
+ (ANImageBitmapRep *)imageBitmapRepWithCGSize:(CGSize)avgSize;
+ (ANImageBitmapRep *)imageBitmapRepWithImage:(ANImageObj *)anImage;
#endif

/**
 * Reverses the RGB values of all pixels in the bitmap.  This causes
 * an "inverted" effect.
 */
- (void)invertColors;

/**
 * Scales the image down, then back up again.  Use this to blur an image.
 * @param quality A percentage from 0 to 1, 0 being horrible quality, 1 being
 * perfect quality.
 */
- (void)setQuality:(CGFloat)quality;

/**
 * Darken or brighten the image.
 * @param brightness A percentage from 0 to 2.  In this case, 0 is the darkest
 * and 2 is the brightest.  If this is 1, no change will be made.
 */
- (void)setBrightness:(CGFloat)brightness;

/**
 * Returns a pixel at a given location.
 * @param point The point from which a pixel will be taken.  For all points
 * in a BitmapContextRep, the x and y values start at 0 and end at
 * width - 1 and height - 1 respectively.
 * @return The pixel with values taken from the specified point.
 */
- (BMPixel)getPixelAtPoint:(BMPoint)point;

/**
 * Sets a pixel at a specific location.
 * @param pixel An RGBA pixel represented by an array of four floats.
 * Each component is one float long, and goes from 0 to 1.  
 * In this case, 0 is black and 1 is white.
 * @param point The location of the pixel to change.  For all points
 * in a BitmapContextRep, the x and y values start at 0 and end at
 * width - 1 and height - 1 respectively.
 */
- (void)setPixel:(BMPixel)pixel atPoint:(BMPoint)point;

/**
 * Creates a new UIImage or NSImage from the bitmap context.
 */
#if __has_feature(objc_arc) == 1
- (ANImageObj *)image __attribute__((ns_returns_autoreleased));
#else
- (ANImageObj *)image;
#endif

@end
