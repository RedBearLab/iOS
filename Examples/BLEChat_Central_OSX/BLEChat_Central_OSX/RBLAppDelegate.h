//
//  RBLAppDelegate.h
//  BLEChat_Central_OSX
//
//  Created by Cheong on 14-3-9.
//  Copyright (c) 2014年 RedBear. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BLE.h"

@interface RBLAppDelegate : NSObject <NSApplicationDelegate, BLEDelegate>
{
    IBOutlet NSButton *btnConnect;
    IBOutlet NSProgressIndicator *indConnect;
    IBOutlet NSTextField *lblRSSI;
    IBOutlet NSTextField *text;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextView *textView;
@property (assign) IBOutlet NSButton *buttonSend;
@property (strong, nonatomic) BLE *ble;

@end
