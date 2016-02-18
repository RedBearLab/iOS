
/*
 
 Copyright (c) 2013-2014 RedBearLab
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize ble;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application
{
    if (ble.activePeripheral)
        if(ble.activePeripheral.isConnected)
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
    
    return YES;
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
        
        if (data[i] == 0x0A) // Digital In data
        {
            if (data[i+1] == 0x01)
                lblDigitalIn.stringValue = @"HIGH";
            else
                lblDigitalIn.stringValue = @"LOW";
        }
        else if (data[i] == 0x0B) // Analog In data
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
    NSLog(@"Clicked");
    
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
