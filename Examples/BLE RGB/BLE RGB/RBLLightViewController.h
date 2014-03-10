//
//  RBLLightViewController.h
//  BLE RGB
//
//  Created by redbear on 14-2-20.
//  Copyright (c) 2014年 redbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RBLViewController.h"
#import "ColorPickerClasses/RSColorPickerView.h"

@interface RBLLightViewController : UIViewController <RSColorPickerViewDelegate>
{
    UILabel *label;
}

@property (nonatomic, strong) RBLViewController *vc;
@property (nonatomic) RSColorPickerView *colorPicker;
@property (nonatomic) UIView *colorPatch;


@end
