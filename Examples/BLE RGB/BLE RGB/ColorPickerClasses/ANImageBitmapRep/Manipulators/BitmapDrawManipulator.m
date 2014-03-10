//
//  BitmapDrawManipulator.m
//  FaceBlur
//
//  Created by Alex Nichol on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BitmapDrawManipulator.h"

@implementation BitmapDrawManipulator

- (void)drawImage:(CGImageRef)image inRect:(CGRect)rect {
    BMPoint size = [bitmapContext bitmapSize];
	// It's kind of rude to prevent them from doing something kind of cool, so let's not.
	// NSAssert(frame.origin.x >= 0 && frame.origin.x + frame.size.width <= size.x, @"Cropping frame must be within the bitmap.");
	// NSAssert(frame.origin.y >= 0 && frame.origin.y + frame.size.height <= size.y, @"Cropping frame must be within the bitmap.");
	
	CGPoint offset = CGPointMake(rect.origin.x, (size.y - (rect.origin.y + rect.size.height)));
    
    CGContextRef context = [[self bitmapContext] context];
    CGContextSaveGState(context);
    CGContextDrawImage(context, CGRectMake(offset.x, offset.y, rect.size.width, rect.size.height), image);
    CGContextRestoreGState(context);
    [self.bitmapContext setNeedsUpdate:YES];
}

- (void)drawEllipseInFrame:(CGRect)frame color:(CGColorRef)color {
    CGContextRef context = [[self bitmapContext] context];
    CGContextSaveGState(context);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -[bitmapContext bitmapSize].y);
    CGContextSetFillColorWithColor(context, color);
    CGContextFillEllipseInRect(context, frame);
    CGContextRestoreGState(context);
    [self.bitmapContext setNeedsUpdate:YES];
}

@end
