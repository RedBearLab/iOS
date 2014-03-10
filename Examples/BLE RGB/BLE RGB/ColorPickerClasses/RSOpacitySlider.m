//
//  RSOpacitySlider.m
//  RSColorPicker
//
//  Created by Jared Allen on 5/16/13.
//  Copyright (c) 2013 Red Cactus LLC. All rights reserved.
//

#import "RSOpacitySlider.h"

/**
 * Returns image that looks like a checkered background.
 */
UIImage* RSOpacityBackgroundImage(CGFloat length, UIColor *color) {
	UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, length*0.5, length*0.5)];
	UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(length*0.5, length*0.5, length*0.5, length*0.5)];
	UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(0, length*0.5, length*0.5, length*0.5)];
	UIBezierPath* rectangle4Path = [UIBezierPath bezierPathWithRect: CGRectMake(length*0.5, 0, length*0.5, length*0.5)];
	
	UIGraphicsBeginImageContext(CGSizeMake(length, length));
	
	[color setFill];
	[rectanglePath fill];
	[rectangle2Path fill];
	
	[[UIColor whiteColor] setFill];
	[rectangle3Path fill];
	[rectangle4Path fill];
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

@implementation RSOpacitySlider

-(id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self initRoutine];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initRoutine];
	}
	return self;
}

-(void)initRoutine {
	self.minimumValue = 0.0;
	self.maximumValue = 1.0;
	self.continuous = YES;
	
	self.enabled = YES;
	self.userInteractionEnabled = YES;
	
	UIImage *backgroundImage = RSOpacityBackgroundImage(16.f, [UIColor colorWithWhite:0.5 alpha:1.0]);
	self.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
	[self addTarget:self action:@selector(myValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (CGRect)trackRectForBounds:(CGRect)bounds
{
	//to hide the track view
	return CGRectMake(0, ceilf(bounds.size.height / 2), bounds.size.width, 0);
}

-(void)myValueChanged:(id)notif {
	_colorPicker.opacity = self.value;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGColorSpaceRef space = CGColorSpaceCreateDeviceGray();
	NSArray* colors = [[NSArray alloc] initWithObjects:
										 (id)[UIColor colorWithWhite:0 alpha:0].CGColor,
										 (id)[UIColor colorWithWhite:1 alpha:1].CGColor,nil];
	
	CGGradientRef myGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, NULL);
	
	CGContextDrawLinearGradient(ctx, myGradient, CGPointZero, CGPointMake(rect.size.width, 0), 0);
	CGGradientRelease(myGradient);
	CGColorSpaceRelease(space);
}

-(void)setColorPicker:(RSColorPickerView*)cp {
	_colorPicker = cp;
	if (!_colorPicker) { return; }
	self.value = [_colorPicker brightness];
}

@end
