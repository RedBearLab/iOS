//
//  RotatableBitmapRep.m
//  ImageManip
//
//  Created by Alex Nichol on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BitmapRotationManipulator.h"

#define DEGTORAD(x) (x * (M_PI / 180.0f))

static CGPoint locationForAngle (CGFloat angle, CGFloat hypotenuse) {
	CGPoint p;
	p.x = (CGFloat)cos((double)DEGTORAD(angle)) * hypotenuse;
	p.y = (CGFloat)sin((double)DEGTORAD(angle)) * hypotenuse;
	return p;
}

@implementation BitmapRotationManipulator

- (void)rotate:(CGFloat)degrees {
	if (degrees == 0) return;
	
	CGSize size = CGSizeMake([bitmapContext bitmapSize].x, [bitmapContext bitmapSize].y);
	CGSize newSize = CGSizeZero;
	
	/* Since the corners go off to the sides, we have to use the existing hypotenuse to calculate the new size
	   for the image.  This is done using some basic trigonometry. 
	 */
	CGFloat hypotenuse;
	hypotenuse = (CGFloat)sqrt(pow((double)size.width / 2.0, 2.0) + pow((double)size.height / 2.0, 2.0));
	
	CGPoint minP = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
	CGPoint maxP = CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);
	
	/* Find the angle for the corners. */
	float firstAngle = (float)atan2((double)size.height / 2.0, (double)size.width / 2.0);
	float secondAngle = (float)atan2((double)size.height / 2.0, (double)size.width / -2.0);
	float thirdAngle = (float)atan2((double)size.height / -2.0, (double)size.width / -2.0);
	float fourthAngle = (float)atan2((double)size.height / -2.0, (double)size.width / 2.0);
	float angles[4] = {firstAngle, secondAngle, thirdAngle, fourthAngle};
	
	/* Rotate the corners by the new degrees, finding out how outgoing
	   the corners will be.  This will allow us to easily calculate
	   the new size of the image.
	 */
	for (int i = 0; i < 4; i++) {
		// conver the angle to radians.
		float deg = angles[i] * (float)(180.0f / M_PI);
		CGPoint p1 = locationForAngle(deg + degrees, hypotenuse);
		if (p1.x < minP.x) minP.x = p1.x;
		if (p1.x > maxP.x) maxP.x = p1.x;
		if (p1.y < minP.y) minP.y = p1.y;
		if (p1.y > maxP.y) maxP.y = p1.y;
	}
	
	newSize.width = maxP.x - minP.x;
	newSize.height = maxP.y - minP.y;
	
	/* Figure out where the thing is going to go when rotated by the bottom left
	   corner.  Use that information to translate it so that it rotates from the center.
	 */
	hypotenuse = (CGFloat)sqrt((pow(newSize.width / 2.0, 2) + pow(newSize.height / 2.0, 2)));
	
	CGPoint newCenter;
	float addAngle = (float)atan2((double)newSize.height / 2, (double)newSize.width / 2) * (float)(180.0f / M_PI);
	newCenter.x = cos((float)DEGTORAD((degrees + addAngle))) * hypotenuse;
	newCenter.y = sin((float)DEGTORAD((degrees + addAngle))) * hypotenuse;
	
	CGPoint offsetCenter;
	offsetCenter.x = (float)((float)newSize.width / 2.0f) - (float)newCenter.x;
	offsetCenter.y = (float)((float)newSize.height / 2.0f) - (float)newCenter.y;
	
	CGContextRef newContext = [CGContextCreator newARGBBitmapContextWithSize:newSize];
	CGContextSaveGState(newContext);
	CGContextTranslateCTM(newContext, (float)round((float)offsetCenter.x), (float)round((float)offsetCenter.y));
	
	CGContextRotateCTM(newContext, (CGFloat)DEGTORAD(degrees));
	CGRect drawRect;
	drawRect.size = size;
	drawRect.origin.x = (CGFloat)round((newSize.width / 2) - (size.width / 2));
	drawRect.origin.y = (CGFloat)round((newSize.height / 2) - (size.height / 2));
	
	CGContextDrawImage(newContext, drawRect, [bitmapContext CGImage]);
	CGContextRestoreGState(newContext);
	[bitmapContext setContext:newContext];
	CGContextRelease(newContext);
}

- (CGImageRef)imageByRotating:(CGFloat)degrees {
	if (degrees == 0) return [bitmapContext CGImage];
	
	CGSize size = CGSizeMake([bitmapContext bitmapSize].x, [bitmapContext bitmapSize].y);
	CGSize newSize = CGSizeZero;
	
	/* Since the corners go off to the sides, we have to use the existing hypotenuse to calculate the new size
	   for the image.  This is done using some basic trigonometry. 
	 */
	CGFloat hypotenuse;
	hypotenuse = (CGFloat)sqrt(pow((double)size.width / 2.0, 2.0) + pow((double)size.height / 2.0, 2.0));
	
	CGPoint minP = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
	CGPoint maxP = CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);
	
	/* Find the angle for the corners. */
	float firstAngle = (float)atan2((double)size.height / 2.0, (double)size.width / 2.0);
	float secondAngle = (float)atan2((double)size.height / 2.0, (double)size.width / -2.0);
	float thirdAngle = (float)atan2((double)size.height / -2.0, (double)size.width / -2.0);
	float fourthAngle = (float)atan2((double)size.height / -2.0, (double)size.width / 2.0);
	float angles[4] = {firstAngle, secondAngle, thirdAngle, fourthAngle};
	
	/* Rotate the corners by the new degrees, finding out how outgoing
	   the corners will be.  This will allow us to easily calculate
	   the new size of the image.
	 */
	for (int i = 0; i < 4; i++) {
		// conver the angle to radians.
		float deg = angles[i] * (float)(180.0f / M_PI);
		CGPoint p1 = locationForAngle(deg + degrees, hypotenuse);
		if (p1.x < minP.x) minP.x = p1.x;
		if (p1.x > maxP.x) maxP.x = p1.x;
		if (p1.y < minP.y) minP.y = p1.y;
		if (p1.y > maxP.y) maxP.y = p1.y;
	}
	
	newSize.width = ceil(maxP.x - minP.x);
	newSize.height = ceil(maxP.y - minP.y);
	
	/* Figure out where the thing is going to go when rotated by the bottom left
	   corner.  Use that information to translate it so that it rotates from the center.
	 */
	hypotenuse = (CGFloat)sqrt((pow(newSize.width / 2.0, 2) + pow(newSize.height / 2.0, 2)));
	
	CGPoint newCenter;
	float addAngle = (float)atan2((double)newSize.height / 2, (double)newSize.width / 2) * (float)(180.0f / M_PI);
	newCenter.x = cos((float)DEGTORAD((degrees + addAngle))) * hypotenuse;
	newCenter.y = sin((float)DEGTORAD((degrees + addAngle))) * hypotenuse;
	
	CGPoint offsetCenter;
	offsetCenter.x = (float)((float)newSize.width / 2.0f) - (float)newCenter.x;
	offsetCenter.y = (float)((float)newSize.height / 2.0f) - (float)newCenter.y;
	
	CGContextRef newContext = [CGContextCreator newARGBBitmapContextWithSize:newSize];
	CGContextSaveGState(newContext);
	CGContextTranslateCTM(newContext, (float)round((float)offsetCenter.x), (float)round((float)offsetCenter.y));
	
	CGContextRotateCTM(newContext, (CGFloat)DEGTORAD(degrees));
	CGRect drawRect;
	drawRect.size = size;
	drawRect.origin.x = (CGFloat)round((newSize.width / 2) - (size.width / 2));
	drawRect.origin.y = (CGFloat)round((newSize.height / 2) - (size.height / 2));
	
	CGContextDrawImage(newContext, drawRect, [bitmapContext CGImage]);
	CGContextRestoreGState(newContext);
	CGImageRef image = CGBitmapContextCreateImage(newContext);
	void * buff = CGBitmapContextGetData(newContext);
	CGContextRelease(newContext);
	free(buff);
#if __has_feature(objc_arc) == 1
	id retainedImage = CGImageReturnAutoreleased(image);
	CGImageRelease(image);
	return (__bridge CGImageRef)retainedImage;
#else
	CGImageContainer * container = [CGImageContainer imageContainerWithImage:image];
	CGImageRelease(image);
	return [container image];
#endif
}

@end
