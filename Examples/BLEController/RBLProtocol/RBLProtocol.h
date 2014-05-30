
/*
 
 Copyright (c) 2013-2014 RedBearLab
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <Foundation/Foundation.h>
#import "BLE.h"

#define MESSAGE_TYPE_CUSTOM_DATA        'Z'
#define MESSAGE_TYPE_PROTOCOL_VERSION   'V'
#define MESSAGE_TYPE_PIN_COUNT          'C'
#define MESSAGE_TYPE_PIN_CAPABILITY     'P'

#define COMMAND_ANALOG_WRITE            'N'

// Pin modes.
// except from UNAVAILABLE taken from Firmata.h
#define UNAVAILABLE             0xFF
#define INPUT                   0x00
#define OUTPUT                  0x01
#define ANALOG                  0x02
#define PWM                     0x03
#define SERVO                   0x04

// Pin types
#define DIGITAL = OUTPUT   // same as OUTPUT below
// ANALOG is already defined above

#define HIGH                    0x01
#define LOW                     0x00

#define PIN_CAPABILITY_NONE     0x00
#define PIN_CAPABILITY_DIGITAL  0x01
#define PIN_CAPABILITY_ANALOG   0x02
#define PIN_CAPABILITY_PWM      0x04
#define PIN_CAPABILITY_SERVO    0x08
#define PIN_CAPABILITY_I2C      0x10

#define PIN_ERROR_INVALID_PIN   0x01
#define PIN_ERROR_INVALID_MODE  0x02

@protocol ProtocolDelegate
@optional
@required
-(void) protocolDidReceiveCustomData:(uint8_t *) data length:(uint8_t) length;

-(void) protocolDidReceiveProtocolVersion:(uint8_t) major Minor:(uint8_t) minor Bugfix:(uint8_t) bugfix;
-(void) protocolDidReceiveTotalPinCount:(uint8_t) count;
-(void) protocolDidReceivePinCapability:(uint8_t) pin Value:(uint8_t) value;
-(void) protocolDidReceivePinMode:(uint8_t) pin Mode:(uint8_t) mode; /* mode: I/O/Analog/PWM/Servo */

-(void) protocolDidReceivePinData:(uint8_t) pin Mode:(uint8_t) mode Value:(uint8_t) value;
@end

@interface RBLProtocol : NSObject
@property (strong, nonatomic) BLE *ble;
@property (nonatomic,assign) id <ProtocolDelegate> delegate;
-(void) parseData:(unsigned char *) data length:(int) length;

/* APIs for query and read/write pins */
-(void) queryProtocolVersion;
-(void) queryTotalPinCount;
-(void) queryPinCapability:(uint8_t) pin;

-(void) queryPinAll;
-(void) queryPinMode:(uint8_t) pin;
-(void) setPinMode:(uint8_t) pin Mode:(uint8_t) mode;

-(void) sendCustomData: (uint8_t *) data Length:(uint8_t) length;

-(void) digitalWrite:(uint8_t) pin Value:(uint8_t) value; /* write digital pin, HIGH or LOW */
//-(void) digitalRead:(uint8_t) pin;

-(void) analogWrite:(uint8_t) pin Value:(uint8_t) value;
//-(void) analogRead:(uint8_t) pin;

-(void) servoWrite:(uint8_t) pin Value:(uint8_t) value; /* write servo pin, value = angle */
//-(void) servoRead:(uint8_t) pin;
@end
