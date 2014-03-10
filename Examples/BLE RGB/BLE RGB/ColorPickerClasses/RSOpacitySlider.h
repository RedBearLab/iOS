//
//  RSOpacitySlider.h
//  RSColorPicker
//
//  Created by Jared Allen on 5/16/13.
//  Copyright (c) 2013 Red Cactus LLC. All rights reserved.
//

#import "RSColorPickerView.h"

extern UIImage* RSOpacityBackgroundImage(CGFloat length, UIColor *color);

@interface RSOpacitySlider : UISlider

@property (nonatomic) RSColorPickerView *colorPicker;

@end
