//
//  GenerateOperation.h
//  RSColorPicker
//
//  Created by Ryan on 7/22/13.
//  Copyright (c) 2013 Freelance Web Developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@class ANImageBitmapRep;

@interface RSGenerateOperation : NSOperation

-(id)initWithDiameter:(CGFloat)diameter andPadding:(CGFloat)padding;

@property (readonly) CGFloat diameter;
@property (readonly) CGFloat padding;

@property ANImageBitmapRep *bitmap;

@end
