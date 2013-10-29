//
//  AppDelegate.m
//  SimpleControls
//
//  Created by Cheong on 27/10/12.
//  Copyright (c) 2012 RedBearLab. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize ble;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ble = [[BLE alloc] init];
    [ble controlSetup:1];
    ble.delegate = self;
}

-(void) bleDidConnect
{
    NSLog(@"->Connected");
    
    btnConnect.title = @"Disconnect";
    [indConnect stopAnimation:self];
    
    lblAnalogIn.enabled = true;
    swDigitalOut.enabled = true;
    lblDigitalIn.enabled = true;
    btnAnalogIn.enabled = true;
    sldPWM.enabled = true;
    sldServo.enabled = true;
    
    swDigitalOut.selectedSegment = 1;
    lblDigitalIn.stringValue = @"LOW";
    lblAnalogIn.stringValue = @"----";
    sldPWM.integerValue = 0;
    sldServo.integerValue = 0;
    btnAnalogIn.state = 0;
}

- (void)bleDidDisconnect
{
    NSLog(@"->Disconnected");
    
    btnConnect.title = @"Connect";
    
    lblAnalogIn.enabled = false;
    swDigitalOut.enabled = false;
    lblDigitalIn.enabled = false;
    btnAnalogIn.enabled = false;
    sldPWM.enabled = false;
    sldServo.enabled = false;
    
    lblRSSI.stringValue = @"---";
//    lblAnalogIn.stringValue = @"----";
}

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSLog(@"Length: %d", length);
    
    // parse data, all commands are in 3-byte
    for (int i = 0; i < length; i+=3)
    {
        NSLog(@"0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2]);
        
        if (data[i] == 0x0A)
        {
            if (data[i+1] == 0x01)
                lblDigitalIn.stringValue = @"HIGH";
            else
                lblDigitalIn.stringValue = @"LOW";
        }
        else if (data[i] == 0x0B)
        {
            UInt16 Value;
            
            Value = data[i+2] | data[i+1] << 8;
            lblAnalogIn.stringValue = [NSString stringWithFormat:@"%d", Value];
        }
    }
}

-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
    lblRSSI.stringValue = rssi.stringValue;
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

-(IBAction)sendDigitalOut:(id)sender
{
    UInt8 buf[3] = {0x01, 0x00, 0x00};
    
    if (swDigitalOut.selectedSegment == 0)
        buf[1] = 0x01;
    else
        buf[1] = 0x00;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

/* Send command to Arduino to enable analog reading */
-(IBAction)sendAnalogIn:(id)sender
{
    UInt8 buf[3] = {0xA0, 0x00, 0x00};
    
    if (btnAnalogIn.state == 1)
        buf[1] = 0x01;
    else
        buf[1] = 0x00;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

// PWM slide will call this to send its value to Arduino
-(IBAction)sendPWM:(id)sender
{
    UInt8 buf[3] = {0x02, 0x00, 0x00};
    
    buf[1] = sldPWM.integerValue;
    buf[2] = (int)sldPWM.integerValue >> 8;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

// Servo slider will call this to send its value to Arduino
-(IBAction)sendServo:(id)sender
{
    UInt8 buf[3] = {0x03, 0x00, 0x00};
    
    buf[1] = sldServo.integerValue;
    buf[2] = (int)sldServo.integerValue >> 8;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

@end
