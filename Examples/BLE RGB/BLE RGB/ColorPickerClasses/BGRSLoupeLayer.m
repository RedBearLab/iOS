/**
 * BGRSLoupeLayer.m
 * Copyright (c) 2011, Benjamin Guest.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * -Redistributions of source code must retain the above copyright
 *  notice, this list of conditions and the following disclaimer.
 * -Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in the
 *  documentation and/or other materials provided with the distribution.
 * -Neither the name of Benjamin Guest nor the names of its
 *  contributors may be used to endorse or promote products derived from
 *  this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import "BGRSLoupeLayer.h"
#import "RSColorPickerView.h"
#import "RSOpacitySlider.h"

@interface BGRSLoupeLayer ()

@property (nonatomic) struct CGPath *gridCirclePath;

- (void)drawGlintInContext:(CGContextRef)ctx;
- (UIImage *)loupeImage;

@end


@implementation BGRSLoupeLayer

@synthesize loupeCenter, colorPicker;

const CGFloat LOUPE_SIZE = 85, SHADOW_SIZE = 6, RIM_THICKNESS = 3.0;
const int NUM_PIXELS = 5, NUM_SKIP = 15;

- (id)init
{
	self = [super init];
	if (self) {
		CGFloat size = LOUPE_SIZE+2*SHADOW_SIZE;
		self.bounds = CGRectMake(-size/2,-size/2,size,size);
		self.anchorPoint = CGPointMake(0.5, 1);
		self.contentsScale = [UIScreen mainScreen].scale;
		
		UIImage *loupeImage = [self loupeImage];
		CALayer *loupeLayer = [CALayer layer];
		loupeLayer.bounds = self.bounds;
		loupeLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
		loupeLayer.contents = (id)loupeImage.CGImage;
		
		[self addSublayer:loupeLayer];
	}
	return self;
}

- (void)dealloc
{
	self.colorPicker = nil;
	if (_gridCirclePath) CGPathRelease(_gridCirclePath);
}

- (struct CGPath *)gridCirclePath
{
	if (_gridCirclePath == NULL) {
		CGMutablePathRef circlePath = CGPathCreateMutable();
		const CGFloat radius = LOUPE_SIZE/2;
		CGPathAddArc(circlePath, nil, 0, 0, radius-RIM_THICKNESS/2, 0, 2*M_PI, YES);
		_gridCirclePath = circlePath;
	}
	return _gridCirclePath;
}

- (UIImage *)loupeImage
{
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGFloat size = LOUPE_SIZE+2*SHADOW_SIZE;
	CGContextTranslateCTM(ctx, size/2, size/2);
	
	// Draw Shadow
	CGContextSaveGState(ctx);     // Save before shadow
	
	UIBezierPath *inner = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, SHADOW_SIZE + 1, SHADOW_SIZE + 1)];
	UIBezierPath *outer = [UIBezierPath bezierPathWithRect:self.bounds];
	[outer appendPath:inner];
	outer.usesEvenOddFillRule = YES;
	[outer addClip];
	
	CGSize shadowOffset = CGSizeMake(0,SHADOW_SIZE/2);
	CGContextSetShadowWithColor(ctx, shadowOffset, SHADOW_SIZE/2, [UIColor blackColor].CGColor);
	CGContextAddEllipseInRect(ctx, CGRectMake(-LOUPE_SIZE/2, -LOUPE_SIZE/2, LOUPE_SIZE, LOUPE_SIZE));
	
	CGContextSetFillColorWithColor(ctx, [colorPicker selectionColor].CGColor);
	CGContextFillPath(ctx);
	
	CGContextRestoreGState(ctx);  // Restore context after shadow
		
	// Create Cliping Area
	CGContextSaveGState(ctx);     // Save context for cliping
	
	CGContextAddPath(ctx, self.gridCirclePath);  // Clip gird drawing to inside of loupe
	CGContextClip(ctx);
	
	[self drawGlintInContext:ctx];
	
	CGContextRestoreGState(ctx);  // Restor from clip drawing
	
	// Stroke Rim of Loupe
	CGContextSetLineWidth(ctx, RIM_THICKNESS);
	CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
	CGContextAddPath(ctx, self.gridCirclePath);
	CGContextStrokePath(ctx);
	
	// Draw center of rim loupe
	CGContextSetLineWidth(ctx, RIM_THICKNESS-1);
	CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
	CGContextAddPath(ctx, self.gridCirclePath);
	CGContextStrokePath(ctx);
			
	const CGFloat w = ceilf(LOUPE_SIZE/NUM_PIXELS);

	// Draw Selection Square
	CGFloat xyOffset = -(w+1)/2;
	CGRect selectedRect = CGRectMake(xyOffset, xyOffset, w, w);
	CGContextAddRect(ctx, selectedRect);
	
	CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
	CGContextSetLineWidth(ctx, 1.0);
	CGContextStrokePath(ctx);

	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

- (void)drawInContext:(CGContextRef)ctx
{
	CGContextAddPath(ctx, self.gridCirclePath);  // Clip gird drawing to inside of loupe
	CGContextClip(ctx);
	
	// Draw Opacity Background
	NSInteger numCols = 6;
	CGFloat loupeLength = LOUPE_SIZE;
	CGFloat pixelLength = loupeLength / numCols;

    UIColor *colorWhite = [UIColor whiteColor];
    UIColor *colorGray = [UIColor grayColor];

    UIColor *color1;
	UIColor *color2;
    UIColor *pixelColor;
	for (int j = 0; j < numCols; j++){
		color1 = (j % 2) ? colorWhite : colorGray;
		color2 = (j % 2) ? colorGray : colorWhite;

		for (int i = 0; i  < numCols; i++){
			CGRect pixelRect = CGRectMake((pixelLength * i) - (loupeLength / 2),
                                          (pixelLength * j) - (loupeLength / 2),
                                          pixelLength,
                                          pixelLength);

			pixelColor = (i % 2) ? color1 : color2;
			CGContextSetFillColorWithColor(ctx, pixelColor.CGColor);
			CGContextFillRect(ctx, pixelRect);
		}
	}
	
	[self drawGridInContext:ctx];
}

- (void)drawGridInContext:(CGContextRef)ctx
{
	const CGFloat w = ceilf(LOUPE_SIZE/NUM_PIXELS);
	
	CGPoint currentPoint = [colorPicker selection];
	currentPoint.x -= NUM_PIXELS*NUM_SKIP/2;
	currentPoint.y -= NUM_PIXELS*NUM_SKIP/2;
	int i,j;
	
	// Draw Pixelated Loupe
	for (j=0; j<NUM_PIXELS; j++){
		for (i=0; i<NUM_PIXELS; i++){
			
			CGRect pixelRect = CGRectMake(w*i-LOUPE_SIZE/2, w*j-LOUPE_SIZE/2, w, w);
			UIColor* pixelColor = [self.colorPicker colorAtPoint:currentPoint];
			CGContextSetFillColorWithColor(ctx, pixelColor.CGColor);
			CGContextFillRect(ctx, pixelRect);
			
			currentPoint.x += NUM_SKIP;
		}
		currentPoint.x -= NUM_PIXELS*NUM_SKIP;
		currentPoint.y += NUM_SKIP;
	}
}

- (void)drawGlintInContext:(CGContextRef)ctx{
	// Draw Top Glint
	CGFloat radius =      LOUPE_SIZE/2;
	CGFloat glintRadius = 1.50*LOUPE_SIZE;
	CGFloat drop =        0.25*LOUPE_SIZE;
	CGFloat yOff = drop + glintRadius - radius;
	
	// Calculations
	CGFloat glintAngle1 = acosf((yOff*yOff + glintRadius*glintRadius - radius*radius)
								/(2*yOff*glintRadius));
	CGFloat glintAngle2 = asinf(glintRadius/radius * sinf(glintAngle1));
	CGFloat glintEdgeHeight = -radius*sinf(glintAngle2-M_PI_2);
	
	// Add bottom arc
	CGContextAddArc(ctx, 0, yOff, glintRadius, -M_PI_2+glintAngle1, -M_PI_2-glintAngle1, YES);
	
	// Add top arc
	CGContextAddArc(ctx, 0, 0, radius, -M_PI_2-glintAngle2, -M_PI_2+glintAngle2, NO);
	
	CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
	//CGContextStrokePath(ctx);
	//return;
	
	CGContextClosePath(ctx);
	CGContextSaveGState(ctx);     // Save context for cliping
	CGContextClip(ctx);
	
	CGColorSpaceRef space = CGColorSpaceCreateDeviceGray();
	NSArray* colors = @[(id)[UIColor colorWithWhite:1.0 alpha:0.65].CGColor,
					    (id)[UIColor colorWithWhite:1.0 alpha:0.15].CGColor];
	
	CGGradientRef myGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, NULL);
	
	CGContextDrawLinearGradient(ctx, myGradient ,CGPointMake(0,-radius), CGPointMake(0,-glintEdgeHeight), 0);
	CGGradientRelease(myGradient);
	CGContextRestoreGState(ctx);
	
	
	// Draw bottom glint
	yOff   = 0.40*LOUPE_SIZE;
	radius = 0.40*LOUPE_SIZE;
	CGPoint glintCenter = CGPointMake(0, yOff);
	
	CGContextAddArc(ctx, 0, yOff, radius, 0, M_2_PI, YES);
	CGContextSaveGState(ctx);     // Save context for cliping
	CGContextClip(ctx);
	
	colors = @[(id)[UIColor colorWithWhite:1.0 alpha:0.5].CGColor,
			   (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor];
	
	myGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, NULL);
	
	CGContextDrawRadialGradient(ctx, myGradient, glintCenter, 0.0, glintCenter, radius, 0.0);
	CGGradientRelease(myGradient);
	CGContextRestoreGState(ctx);
	
	// Release objects
	CGColorSpaceRelease(space);
}

#pragma mark - Animation

static NSString* const kAppearKey = @"cp_l_appear";

- (void)appearInColorPicker:(RSColorPickerView*)aColorPicker{
	if (self.colorPicker != aColorPicker) {
		self.colorPicker = aColorPicker;
	}
    
    [self removeAllAnimations];
    self.transform = CATransform3DIdentity;
    isReadyToDismiss = NO;
    
	// Add Layer to color picker
	[CATransaction setDisableActions:YES];
	[self.colorPicker.layer addSublayer:self];
	
	// Animate Arival
    isRunningInitialAnimation = YES;
	CAKeyframeAnimation *springEffect = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	springEffect.values = @[@(0.1), @(1.4), @(0.95), @(1)];
	springEffect.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	springEffect.removedOnCompletion = NO;
	springEffect.duration = 0.35f;
    springEffect.delegate = self;
    
	// Animate
	[self addAnimation:springEffect forKey:kAppearKey];
}

/**
 * Disapear removes the loupe view from the color picker by shrinking it down to zero
 */
static NSString* const kDisappearKey = @"cp_l_disappear";

- (void)disappear
{
    [self disappearAnimated:YES];
}

- (void)disappearAnimated:(BOOL)anim
{
    isReadyToDismiss = YES;
    if (isRunningInitialAnimation) return;

    if (!anim) {
        [self removeFromSuperlayer];
        return;
    }
    
    self.transform = CATransform3DMakeScale(0.01, 0.01, 1);
	
	CABasicAnimation* disapear = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	disapear.fromValue = @(1);
	disapear.duration  = 0.1f;
	disapear.delegate  = self;
	disapear.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	disapear.removedOnCompletion = NO;
	[self addAnimation:disapear forKey:kDisappearKey];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	if (anim == [self animationForKey:kDisappearKey]){
        if (!flag) return;
        
		[self removeFromSuperlayer];
		self.transform = CATransform3DIdentity;
	} else if (anim == [self animationForKey:kAppearKey]) {
        isRunningInitialAnimation = NO;
        if (isReadyToDismiss) {
            [self disappear];
        }
    }
}

@end
