//
//  RBLViewController.h
//  BLE RGB
//
//  Created by redbear on 14-2-20.
//  Copyright (c) 2014年 redbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface RBLViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *txCharacteristic;

@property (strong, nonatomic) IBOutlet UIButton *connBtn;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)doConnBtn:(id)sender;
@end
