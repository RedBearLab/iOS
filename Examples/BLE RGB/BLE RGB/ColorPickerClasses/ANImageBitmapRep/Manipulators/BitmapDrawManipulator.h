//
//  BitmapDrawManipulator.h
//  FaceBlur
//
//  Created by Alex Nichol on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BitmapContextManipulator.h"

@protocol BitmapDrawManipulator

@optional
- (void)drawImage:(CGImageRef)image inRect:(CGRect)rect;
- (void)drawEllipseInFrame:(CGRect)frame color:(CGColorRef)color;

@end

@interface BitmapDrawManipulator : BitmapContextManipulator

/**
 * Overlays an image on the existing bitmap.
 * @param image The image to be overlayed.
 * @param rect The frame in which the image will be drawn.
 * The coordinates for this begin at the top-left hand
 * corner of the view.
 */
- (void)drawImage:(CGImageRef)image inRect:(CGRect)rect;

/**
 * Draws a colored ellipse in a given rectangle.
 * @param frame The rectangle in which to draw the ellipse
 * @param color The fill color for the ellipse.  The coordinates
 * for this begin at the top-left hand corner of the view.
 */
- (void)drawEllipseInFrame:(CGRect)frame color:(CGColorRef)color;

@end
