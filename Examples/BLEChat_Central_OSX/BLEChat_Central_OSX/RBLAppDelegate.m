//
//  RBLAppDelegate.m
//  BLEChat_Central_OSX
//
//  Created by Cheong on 14-3-9.
//  Copyright (c) 2014年 RedBear. All rights reserved.
//

#import "RBLAppDelegate.h"

@implementation RBLAppDelegate

@synthesize  ble;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self.textView setEditable:NO];
    
    ble = [[BLE alloc] init];
    [ble controlSetup:1];
    ble.delegate = self;
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application
{
    return YES;
}

-(void) bleDidConnect
{
    NSLog(@"->Connected");
    
    btnConnect.title = @"Disconnect";
    [indConnect stopAnimation:self];
}

- (void)bleDidDisconnect
{
    NSLog(@"->Disconnected");
    
    btnConnect.title = @"Connect";
    
    lblRSSI.stringValue = @"RSSI: -127";
}

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSLog(@"Length: %d", length);

    NSString *str = [NSString stringWithCString:data encoding:NSUTF8StringEncoding];
    
    static NSMutableString *message;
    
    if (message == nil)
        message = [[NSMutableString alloc] initWithString:@""];

    [message appendString:str];
    [message appendString:@"\n"];
    
    self.textView.string = message;
    [self.textView scrollRangeToVisible: NSMakeRange(self.textView.string.length, 0)];
}

-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
    lblRSSI.stringValue = [NSString stringWithFormat:@"RSSI: %@", rssi.stringValue];
}

- (IBAction)btnConnect:(id)sender
{
    if (ble.activePeripheral)
        if(ble.activePeripheral.isConnected)
        {
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            return;
        }
    
    if (ble.peripherals)
        ble.peripherals = nil;
    
    [ble findBLEPeripherals:2];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    [indConnect startAnimation:self];
}

-(void) connectionTimer:(NSTimer *)timer
{
    if (ble.peripherals.count > 0)
    {
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
    }
    else
    {
        [indConnect stopAnimation:self];
    }
}

-(IBAction)sendTextOut:(id)sender
{
    UInt8 buf[20];
    [text.stringValue getCString:buf maxLength:20 encoding:NSUTF8StringEncoding];
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:text.stringValue.length];
    [ble write:data];
}

@end
