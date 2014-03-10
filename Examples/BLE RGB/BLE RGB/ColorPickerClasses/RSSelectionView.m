//
//  RSSelectionView.m
//  RSColorPicker
//
//  Created by Ryan Sullivan on 3/12/13.
//  Copyright (c) 2013 Freelance Web Developer. All rights reserved.
//

#import "RSSelectionView.h"

@interface RSSelectionView ()

@property (nonatomic) UIColor *outerRingColor;
@property (nonatomic) UIColor *innerRingColor;

@end

@implementation RSSelectionView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.opaque = NO;
		self.exclusiveTouch = YES;
		_outerRingColor = [UIColor colorWithWhite:1 alpha:0.4];
		_innerRingColor = [UIColor colorWithWhite:0 alpha:1];
	}
	return self;
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
	_selectedColor = selectedColor;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(ctx, _selectedColor.CGColor);
	CGContextFillEllipseInRect(ctx, CGRectInset(rect, 2, 2));
	CGContextSetLineWidth(ctx, 3);
	CGContextSetStrokeColorWithColor(ctx, _outerRingColor.CGColor);
	CGContextStrokeEllipseInRect(ctx, CGRectInset(rect, 1.5, 1.5));
	CGContextSetLineWidth(ctx, 2);
	CGContextSetStrokeColorWithColor(ctx, _innerRingColor.CGColor);
	CGContextStrokeEllipseInRect(ctx, CGRectInset(rect, 3, 3));
}

@end

