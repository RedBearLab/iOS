//
//  BitmapContextRep.h
//  ImageManip
//
//  Created by Alex Nichol on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OSCommonImage.h"
#import "CGImageContainer.h"
#import "CGContextCreator.h"

/**
 * A structure that defines a point in bitmap space.
 * This is similar to the CGPoint structure, but it
 * does not use floating points, making it more accurate.
 */
typedef struct {
	long x;
	long y;
} BMPoint;

BMPoint BMPointMake (long x, long y);
BMPoint BMPointFromSize (CGSize size);
BMPoint BMPointFromPoint (CGPoint point);

/**
 * BitmapContextRep is a concrete subclass of NSObject that provides a basic
 * class for mutating image's bitmaps.  This class is very barebones,
 * and generally will not be enough for most image manipulation.
 */
@interface BitmapContextRep : NSObject {
    CGContextRef context;
	CGImageRef lastImage;
	unsigned char * bitmapData;
	BOOL needsUpdate;
}

/**
 * Creates a bitmap context with pixels and dimensions from an image.
 * @param image The image to wrap in a bitmap context.
 */
- (id)initWithImage:(ANImageObj *)image;

/**
 * Creates a blank bitmap context with specified dimensions.
 * @param sizePoint The size to use for the new bitmap.  The x value
 * of this is used for the width, and the y value is used for height.
 */
- (id)initWithSize:(BMPoint)sizePoint;

/**
 * Returns the bitmap context underlying the image.
 */
- (CGContextRef)context;

/**
 * Replaces the current context with a new one.
 * @param aContext The new bitmap context for the image which will be retained
 * and released automatically by the BitmapContextRep.
 */
- (void)setContext:(CGContextRef)aContext;

/**
 * Returns the current size of the bitmap.
 */
- (BMPoint)bitmapSize;

/**
 * Tells the BitmapContext that a new image should be generated when
 * one is requested because the internal context has been externally
 * modified.
 * @param needsUpdate This should almost always be YES.  If this is no,
 * a new CGImageRef will not be generated when one is requested.
 */
- (void)setNeedsUpdate:(BOOL)flag;

/**
 * Returns by reference a 4-byte RGBA pixel at a certain point.
 * @param rgba A pointer to a 4-byte or more pixel buffer. 
 * @param point The point from which a pixel will be read.  For all
 * points in a BitmapContextRep, the x and y values start at 0 and end
 * at width - 1 and height - 1 respectively.
 */
- (void)getRawPixel:(UInt8 *)rgba atPoint:(BMPoint)point;

/**
 * Sets a 4-byte ARGB pixel at a specified point.
 * @param rgba The pixel buffer containing at least 4 bytes.
 * @param point The point at which the pixel will be set.  For all
 * points in a BitmapContextRep, the x and y values start at 0 and end
 * at width - 1 and height - 1 respectively.
 * @discussion Since alpha is premultiplied, it is important to remember to multiply
 * the alpha as a percentage by the RGB values.  This means that a white pixel
 * with 50% alpha would become rgba(128, 128, 128, 128).
 */
- (void)setRawPixel:(const UInt8 *)rgba atPoint:(BMPoint)point;

/**
 * Returns an autoreleased CGImageRef of the current BitmapContext.
 */
- (CGImageRef)CGImage;

@end

@protocol BitmapContextRep

@optional
- (CGContextRef)context;
- (void)setContext:(CGContextRef)aContext;
- (BMPoint)bitmapSize;
- (void)setNeedsUpdate:(BOOL)flag;
- (void)getRawPixel:(UInt8 *)rgba atPoint:(BMPoint)point;
- (void)setRawPixel:(const UInt8 *)rgba atPoint:(BMPoint)point;
- (CGImageRef)CGImage;

@end
