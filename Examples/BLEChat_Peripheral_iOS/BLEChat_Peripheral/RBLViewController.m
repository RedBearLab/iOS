//
//  RBLViewController.m
//  BLE peripheral mode
//
//  Created by redbear on 14-2-20.
//  Copyright (c) 2014年 redbear. All rights reserved.
//

#import "RBLViewController.h"

@interface RBLViewController ()

#define RBL_SERVICE_UUID                    @"713d0000-503e-4c75-ba94-3148f18d941e"
#define RBL_TX_UUID                         @"713d0003-503e-4c75-ba94-3148f18d941e"
#define RBL_RX_UUID                         @"713d0002-503e-4c75-ba94-3148f18d941e"

@end

@implementation RBLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    self.textField.delegate = self;
    [self.textField becomeFirstResponder];
    
    NSString *reqSysVer = @"7.0";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer  options:NSNumericSearch] != NSOrderedAscending);

    if (osVersionSupported) {
        NSTextStorage* textStorage = [[NSTextStorage alloc] init];
        NSLayoutManager* layoutManager = [NSLayoutManager new];
        [textStorage addLayoutManager:layoutManager];
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.view.bounds.size];
        [layoutManager addTextContainer:textContainer];
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 20, 320, 203) textContainer:textContainer];
    }
    else
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 20, 320, 203)];

    self.textView.editable = NO;
    self.textView.selectable = NO;
    self.textView.font = [UIFont fontWithName:@"Arial" size:20.0f];
    [self.view addSubview:self.textView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    NSLog(@"self.peripheralManager powered on.");
    
    CBMutableCharacteristic *tx = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:RBL_TX_UUID] properties:CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsWriteable];
    rx = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:RBL_RX_UUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    CBMutableService *s = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:RBL_SERVICE_UUID] primary:YES];
    s.characteristics = @[tx, rx];
    
    [self.peripheralManager addService:s];
    
    NSDictionary *advertisingData = @{CBAdvertisementDataLocalNameKey : @"BLE Shield", CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:RBL_SERVICE_UUID]]};
    [self.peripheralManager startAdvertising:advertisingData];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    NSLog(@"didReceiveWriteRequests");
    
    CBATTRequest*       request = [requests  objectAtIndex: 0];
    NSData*             request_data = request.value;
    CBCharacteristic*   write_char = request.characteristic;
    
    uint8_t buf[request_data.length];
    [request_data getBytes:buf length:request_data.length];

    NSMutableString *temp = [[NSMutableString alloc] init];
    for (int i = 0; i < request_data.length; i++) {
        [temp appendFormat:@"%c", buf[i]];
    }
    
    if (str == nil) {
        str = [NSMutableString stringWithFormat:@"%@\n", temp];
    } else {
        [str appendFormat:@"%@\n", temp];
    }
    
    self.textView.text = str;
    [self scrollOutputToBottom];
    
    //[peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *text = self.textField.text;
    
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.peripheralManager updateValue:data forCharacteristic:rx onSubscribedCentrals:nil];
    
    return YES;
}

- (void)scrollOutputToBottom {
    CGPoint p = [self.textView contentOffset];
    [self.textView setContentOffset:p animated:NO];
    [self.textView scrollRangeToVisible:NSMakeRange([self.textView.text length], 0)];
}

@end
