
/*
 
 Copyright (c) 2013-2014 RedBearLab
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "RBLProtocol.h"

@implementation RBLProtocol
@synthesize ble;

//#define PROT_DEBUG

-(void) parseData:(unsigned char *) data length:(int) length
{
#if defined(PROT_DEBUG)
    NSLog(@"RBLProtocol: paseData");
#endif
    
    uint8_t i = 0;
    
    while (i < length)
    {
        uint8_t type = data[i++];

        switch (type)
        {
            case 'V': // report protocol version
                [[self delegate] protocolDidReceiveProtocolVersion:data[i++] Minor:data[i++] Bugfix:data[i++]];
                break;
            
            case 'C': // report total pin count of the board
                [[self delegate] protocolDidReceiveTotalPinCount:data[i++]];
                break;
            
            case 'P': // report pin capability
                [[self delegate] protocolDidReceivePinCapability:data[i++] Value:data[i++]];
                break;
            
            case 'Z': // custom data
                [[self delegate] protocolDidReceiveCustomData:&data[i] length:length-i];
                i=length;
                break;
            
            case 'M': // report pin mode
                [[self delegate] protocolDidReceivePinMode:data[i++] Mode:data[i++]];
                break;
        
            case 'G': // report pin data
                [[self delegate] protocolDidReceivePinData:data[i++] Mode:data[i++] Value:data[i++]];
                break;
        }
    }
}

-(void) setPinMode:(uint8_t) pin Mode:(uint8_t) mode
{
#if defined(PROT_DEBUG)
    NSLog(@"RBLPRotocol: setPinMode");
#endif
    
    uint8_t buf[] = {'S', pin, mode};
    uint8_t len = 3;
    
    NSData *nsData = [[NSData alloc] initWithBytes:buf length:len];
    [ble write:nsData];
}

-(void) digitalRead:(uint8_t)pin
{
#if defined(PROT_DEBUG)
    NSLog(@"RBLProtocol: digitalRead");
#endif
    
    uint8_t buf[] = {'G', pin};
    uint8_t len = 2;
    
    NSData *nsData = [[NSData alloc] initWithBytes:buf length:len];
    [ble write:nsData];
}

-(void) digitalWrite:(uint8_t)pin Value:(uint8_t)value
{
#if defined(PROT_DEBUG)
    NSLog(@"RBLProtocol: digitalWrite");
#endif
    
    uint8_t buf[] = {'T', pin, value};
    uint8_t len = 3;
    
    NSData *nsData = [[NSData alloc] initWithBytes:buf length:len];
    [ble write:nsData];
}

-(void) queryPinAll
{
#if defined(PROT_DEBUG)
    NSLog(@"RBLProtocol: queryPinAll");
#endif
    
    uint8_t buf[] = {'A'};
    uint8_t len = 1;
    
    NSData *nsData = [[NSData alloc] initWithBytes:buf length:len];
    [ble write:nsData];
}

-(void) queryProtocolVersion
{
#if defined(PROT_DEBUG)
    NSLog(@"RBLProtocol: queryProtocolVersion");
#endif
    
    uint8_t buf[] = {'V'};
    uint8_t len = 1;

    NSData *nsData = [[NSData alloc] initWithBytes:buf length:len];
    [ble write:nsData];
}

-(void) queryTotalPinCount
{
#if defined(PROT_DEBUG)
    NSLog(@"RBLProtocol: queryTotalPinCount");
#endif
    
    uint8_t buf[] = {'C'};
    uint8_t len = 1;
    
    NSData *nsData = [[NSData alloc] initWithBytes:buf length:len];
    [ble write:nsData];
}

-(void) queryPinCapability:(uint8_t) pin
{
#if defined(PROT_DEBUG)
    NSLog(@"RBLProtocol: queryPinCapability");
#endif
    
    uint8_t buf[] = {'P', pin};
    uint8_t len = 2;
    
    NSData *nsData = [[NSData alloc] initWithBytes:buf length:len];
    [ble write:nsData];
}

-(void) queryPinMode:(uint8_t) pin
{
#if defined(PROT_DEBUG)
    NSLog(@"RBLPRotocol: queryPinMode");
#endif
    
    uint8_t buf[] = {'M', pin};
    uint8_t len = 2;
    
    NSData *nsData = [[NSData alloc] initWithBytes:buf length:len];
    [ble write:nsData];    
}

-(void) analogWrite:(uint8_t) pin Value:(uint8_t) value
{
#if defined(PROT_DEBUG)
    NSLog(@"RBLPRotocol: analogWrite");
#endif
    
    uint8_t buf[] = {'N', pin, value};
    uint8_t len = 3;
    
    NSData *nsData = [[NSData alloc] initWithBytes:buf length:len];
    [ble write:nsData];
}

-(void) servoWrite:(uint8_t) pin Value:(uint8_t) value
{
#if defined(PROT_DEBUG)
    NSLog(@"RBLPRotocol: servoWrite");
#endif
    
    uint8_t buf[] = {'O', pin, value};
    uint8_t len = 3;
    
    NSData *nsData = [[NSData alloc] initWithBytes:buf length:len];
    [ble write:nsData];
}

-(void) sendCustomData: (uint8_t *) data Length:(uint8_t) length
{
    uint8_t buf[1+1+length];
    buf[0] = 'Z';
    buf[1] = length;
    memcpy(&buf[2], data, length);
    uint8_t len = 1+1+length;

    NSData *nsData = [[NSData alloc] initWithBytes:buf length:len];
    [ble write:nsData];
}

@end
