//
//  RSColorPickerView.h
//  RSColorPicker
//
//  Created by Ryan Sullivan on 8/12/11.
//  Copyright 2011 Freelance Web Developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
#import "ANImageBitmapRep.h"

@class RSColorPickerView, BGRSLoupeLayer;

@protocol RSColorPickerViewDelegate <NSObject>
-(void)colorPickerDidChangeSelection:(RSColorPickerView*)cp;
@end

@interface RSColorPickerView : UIView

@property (nonatomic) BOOL cropToCircle;
@property (nonatomic) CGFloat brightness;
@property (nonatomic) CGFloat opacity;
@property (nonatomic) UIColor *selectionColor;
@property (nonatomic, weak) id <RSColorPickerViewDelegate> delegate;
@property (nonatomic, readonly) CGPoint selection;

@property (nonatomic) int vRed;
@property (nonatomic) int vGreen;
@property (nonatomic) int vBlue;

-(UIColor*)colorAtPoint:(CGPoint)point; // Returns UIColor at a point in the RSColorPickerView

+(void)prepareForDiameter:(CGFloat)diameter;
+(void)prepareForDiameter:(CGFloat)diameter padding:(CGFloat)padding;
+(void)prepareForDiameter:(CGFloat)diameter scale:(CGFloat)scale;
+(void)prepareForDiameter:(CGFloat)diameter scale:(CGFloat)scale padding:(CGFloat)padding;
+(void)prepareForDiameter:(CGFloat)diameter scale:(CGFloat)scale padding:(CGFloat)padding inBackground:(BOOL)bg;
@end
