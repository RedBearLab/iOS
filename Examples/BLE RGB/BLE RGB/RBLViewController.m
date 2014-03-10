//
//  RBLViewController.m
//  BLE RGB
//
//  Created by redbear on 14-2-20.
//  Copyright (c) 2014年 redbear. All rights reserved.
//

#import "RBLViewController.h"
#import "RBLLightViewController.h"

#define RBL_SERVICE_UUID                    @"713d0000-503e-4c75-ba94-3148f18d941e"
#define RBL_TX_UUID                         @"713d0003-503e-4c75-ba94-3148f18d941e"

@interface RBLViewController ()

@end

@implementation RBLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doConnBtn:(id)sender
{
    if (self.peripheral.state == CBPeripheralStateConnected) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    } else {
        [self.centralManager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:RBL_SERVICE_UUID]] options:nil];
        [self.connBtn setTitle:@"Connecting" forState:UIControlStateNormal];
        [self.connBtn setEnabled:NO];
        [self.spinner startAnimating];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoLight"]) {
        NSLog(@"gotoLight");
        RBLLightViewController *lightView = [segue destinationViewController];
        lightView.vc = self;
    }
}

#pragma mark - delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"discover peripheral");
    
    [self.centralManager stopScan];
    
    if (self.peripheral != peripheral) {
        self.peripheral = peripheral;
        
        [self.centralManager connectPeripheral:self.peripheral options:nil];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"connect peripheral");
    
    self.peripheral.delegate = self;
    
    [self.peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"disconnect");
    
    self.peripheral = nil;
    self.txCharacteristic = nil;
    
    [self.connBtn setTitle:@"Connect" forState:UIControlStateNormal];
    [self.connBtn setEnabled:YES];
    [self.spinner stopAnimating];
    
    [[self navigationController] popToRootViewControllerAnimated:(TRUE)];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"discover service");
    
    for (int i = 0; i < peripheral.services.count; i++) {
        [self.peripheral discoverCharacteristics:nil forService:[peripheral.services objectAtIndex:i]];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"discover characteristic");
    
    for (CBCharacteristic *c in service.characteristics) {
        if ([c.UUID isEqual:[CBUUID UUIDWithString:RBL_TX_UUID]]) {
            [self.connBtn setTitle:@"Disconnect" forState:UIControlStateNormal];
            [self.connBtn setEnabled:YES];
            [self.spinner stopAnimating];
            
            self.txCharacteristic = c;
            
            [self performSegueWithIdentifier:@"gotoLight" sender:self];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}

@end
