//
//  CroppableBitmapRep.m
//  ImageManip
//
//  Created by Alex Nichol on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BitmapCropManipulator.h"


@implementation BitmapCropManipulator

- (void)cropFrame:(CGRect)frame {
	BMPoint size = [bitmapContext bitmapSize];
	// It's kind of rude to prevent them from doing something kind of cool, so let's not.
	// NSAssert(frame.origin.x >= 0 && frame.origin.x + frame.size.width <= size.x, @"Cropping frame must be within the bitmap.");
	// NSAssert(frame.origin.y >= 0 && frame.origin.y + frame.size.height <= size.y, @"Cropping frame must be within the bitmap.");
	
	CGContextRef newBitmap = [CGContextCreator newARGBBitmapContextWithSize:frame.size];
	CGPoint offset = CGPointMake(-frame.origin.x, -frame.origin.y);
	CGContextDrawImage(newBitmap, CGRectMake(offset.x, offset.y, size.x, size.y), [bitmapContext CGImage]);
	[bitmapContext setContext:newBitmap];
	CGContextRelease(newBitmap);
}

- (void)cropTopFrame:(CGRect)frame {
	BMPoint size = [bitmapContext bitmapSize];
	// It's kind of rude to prevent them from doing something kind of cool, so let's not.
	// NSAssert(frame.origin.x >= 0 && frame.origin.x + frame.size.width <= size.x, @"Cropping frame must be within the bitmap.");
	// NSAssert(frame.origin.y >= 0 && frame.origin.y + frame.size.height <= size.y, @"Cropping frame must be within the bitmap.");
	
	CGContextRef newBitmap = [CGContextCreator newARGBBitmapContextWithSize:frame.size];
	CGPoint offset = CGPointMake(-frame.origin.x, -(size.y - (frame.origin.y + frame.size.height)));
	CGContextDrawImage(newBitmap, CGRectMake(offset.x, offset.y, size.x, size.y), [bitmapContext CGImage]);
	[bitmapContext setContext:newBitmap];
	CGContextRelease(newBitmap);
}

- (void)cropTopEllipse:(CGRect)frame {
    frame.origin.x = round(frame.origin.x);
    frame.origin.y = round(frame.origin.y);
    frame.size.width = round(frame.size.width);
    frame.size.height = round(frame.size.height);
    
    BMPoint size = [bitmapContext bitmapSize];
	// It's kind of rude to prevent them from doing something kind of cool, so let's not.
	// NSAssert(frame.origin.x >= 0 && frame.origin.x + frame.size.width <= size.x, @"Cropping frame must be within the bitmap.");
	// NSAssert(frame.origin.y >= 0 && frame.origin.y + frame.size.height <= size.y, @"Cropping frame must be within the bitmap.");
	
	CGContextRef newBitmap = [CGContextCreator newARGBBitmapContextWithSize:frame.size];
	CGPoint offset = CGPointMake(-frame.origin.x, -(size.y - (frame.origin.y + frame.size.height)));
    
    CGContextSaveGState(newBitmap);
    CGContextBeginPath(newBitmap);
    CGContextAddEllipseInRect(newBitmap, CGRectMake(0, 0, frame.size.width, frame.size.height));
    CGContextClip(newBitmap);
	CGContextDrawImage(newBitmap, CGRectMake(offset.x, offset.y, size.x, size.y), [bitmapContext CGImage]);
    CGContextRestoreGState(newBitmap);
    
	[bitmapContext setContext:newBitmap];
	CGContextRelease(newBitmap);
}

- (CGImageRef)croppedImageWithFrame:(CGRect)frame {
	BMPoint size = [bitmapContext bitmapSize];
	// It's kind of rude to prevent them from doing something kind of cool, so let's not.
	// NSAssert(frame.origin.x >= 0 && frame.origin.x + frame.size.width <= size.x, @"Cropping frame must be within the bitmap.");
	// NSAssert(frame.origin.y >= 0 && frame.origin.y + frame.size.height <= size.y, @"Cropping frame must be within the bitmap.");
	
	CGContextRef newBitmap = [CGContextCreator newARGBBitmapContextWithSize:frame.size];
	CGPoint offset = CGPointMake(-frame.origin.x, -frame.origin.y);
	CGContextDrawImage(newBitmap, CGRectMake(offset.x, offset.y, size.x, size.y), [bitmapContext CGImage]);
	CGImageRef image = CGBitmapContextCreateImage(newBitmap);
	CGContextRelease(newBitmap);
#if __has_feature(objc_arc) == 1
	CGImageRef retainedAutorelease = (__bridge CGImageRef)CGImageReturnAutoreleased(image);
	CGImageRelease(image);
	return retainedAutorelease;
#else
	CGImageContainer * container = [CGImageContainer imageContainerWithImage:image];
	CGImageRelease(image);
	return [container image];
#endif
}

@end
