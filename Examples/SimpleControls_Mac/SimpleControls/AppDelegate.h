//
//  AppDelegate.h
//  SimpleControls
//
//  Created by Cheong on 27/10/12.
//  Copyright (c) 2012 RedBearLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BLE.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, BLEDelegate>
{
    IBOutlet NSTextField *lblRSSI;
    IBOutlet NSTextField *lblAnalogIn;
    IBOutlet NSSegmentedControl *swDigitalOut;
    IBOutlet NSTextField *lblDigitalIn;
    IBOutlet NSButton *btnConnect;
    IBOutlet NSProgressIndicator *indConnect;
    IBOutlet NSSlider *sldPWM;
    IBOutlet NSSlider *sldServo;
    IBOutlet NSButton *btnAnalogIn;
}

@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) BLE *ble;

@end
