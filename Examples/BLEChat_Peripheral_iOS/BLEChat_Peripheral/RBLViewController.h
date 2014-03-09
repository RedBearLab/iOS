//
//  RBLViewController.h
//  BLE peripheral mode
//
//  Created by redbear on 14-2-20.
//  Copyright (c) 2014年 redbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface RBLViewController : UIViewController <CBPeripheralManagerDelegate, UITextFieldDelegate>
{
    CBMutableCharacteristic *rx;
    NSMutableString *str;
}

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) IBOutlet UITextField *textField;

@end
