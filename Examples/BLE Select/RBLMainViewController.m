//
//  RBLMainViewController.m
//  BLE Select
//
//  Created by Chi-Hung Ma on 4/24/13.
//  Copyright (c) 2013 RedBearlab. All rights reserved.
//

#import "RBLMainViewController.h"
#import "RBLDetailViewController.h"

@interface RBLMainViewController ()
 
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
- (IBAction)scanClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *lastButton;
- (IBAction)lastClick:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

NSString * const  UUIDPrefKey = @"UUIDPrefKey";

@implementation RBLMainViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    bleShield = [[BLE alloc] init];
    [bleShield controlSetup];
    bleShield.delegate = self;
    
    //Retrieve saved UUID from system
    self.lastUUID = [[NSUserDefaults standardUserDefaults] objectForKey:UUIDPrefKey];
    
    if (self.lastUUID.length > 0)
    {
        self.uuidLabel.text = self.lastUUID;
    }
    else
    {
        self.lastButton.hidden = true;
    }
    
    self.mDevices = [[NSMutableArray alloc] init];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)scanClick:(id)sender {

    if (bleShield.activePeripheral)
    {
   //     if(bleShield.activePeripheral.isConnected)
        if(bleShield.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[bleShield CM] cancelPeripheralConnection:[bleShield activePeripheral]];
            return;
        }
    }
    
    if (bleShield.peripherals)
        bleShield.peripherals = nil;
    
    [bleShield findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];

    
    isFindingLast = false;
    self.lastButton.hidden = true;
    self.scanButton.hidden = true;
    [self.spinner startAnimating];
    
}


- (IBAction)lastClick:(id)sender {
    
    [bleShield findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
   
    
    isFindingLast = true;
    self.lastButton.hidden = true;
    self.scanButton.hidden = true;
    [self.spinner startAnimating];
}


// Called when scan period is over 
-(void) connectionTimer:(NSTimer *)timer
{
    if(bleShield.peripherals.count > 0)
    {
        //to connect to the peripheral with a particular UUID
        if(isFindingLast)
        {
            int i;
            for (i = 0; i < bleShield.peripherals.count; i++)
            {
                CBPeripheral *p = [bleShield.peripherals objectAtIndex:i];
                
                //if (p.UUID != NULL)
                if (p.identifier.UUIDString != NULL)
                {
                    //Comparing UUIDs and call connectPeripheral is matched
                    //if([self.lastUUID isEqualToString:[self getUUIDString:p.UUID]])
                    if([self.lastUUID isEqualToString:p.identifier.UUIDString])
                    {
                        [bleShield connectPeripheral:p];
                    }
                }
            }
        }
        //Scan for all BLE in range and prepare a list
        else
        {
            [self.mDevices removeAllObjects];
            
            int i;
            for (i = 0; i < bleShield.peripherals.count; i++)
            {
                CBPeripheral *p = [bleShield.peripherals objectAtIndex:i];
                
                //if (p.UUID != NULL)
                if (p.identifier.UUIDString != NULL)
                {
                    //[self.mDevices insertObject:[self getUUIDString:p.UUID] atIndex:i];
                    [self.mDevices insertObject:p.identifier.UUIDString atIndex:i];

                }
                else
                {
                    [self.mDevices insertObject:@"NULL" atIndex:i];
                }
            }
            
            //Show the list for user selection
            [self performSegueWithIdentifier:@"showDevice" sender:self];
        }
    }
    else
    {
        [self.spinner stopAnimating];
        
        if (self.lastUUID.length == 0)
        {
            self.lastButton.hidden = true;
        }
        else
        {
            self.lastButton.hidden = false;
        }
        
        self.scanButton.hidden = false;
    }

}

//Show device list for user selection
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDevice"])
    {
        RBLDetailViewController *vc =[segue destinationViewController] ;
        vc.BLEDevices = self.mDevices;
        vc.delegate = self;
    }
}

- (void)didSelected:(NSInteger)index
{
    self.scanButton.hidden = true;
    [bleShield connectPeripheral:[bleShield.peripherals objectAtIndex:index]];
}


-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{

}

- (void) bleDidDisconnect
{
    self.lastButton.hidden = false;
    self.rssiLabel.hidden = true;
    [self.scanButton setTitle:@"Scan All" forState:UIControlStateNormal];
}

-(void) bleDidConnect
{
    //Save UUID into system
    //self.lastUUID = [self getUUIDString:bleShield.activePeripheral.UUID];
    self.lastUUID = bleShield.activePeripheral.identifier.UUIDString;
    [[NSUserDefaults standardUserDefaults] setObject:self.lastUUID forKey:UUIDPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.spinner stopAnimating];
    self.lastButton.hidden = true;
    self.scanButton.hidden = false;
    self.uuidLabel.text = self.lastUUID;
    self.rssiLabel.text = @"RSSI: ?";
    self.rssiLabel.hidden = false;
    [self.scanButton setTitle:@"Disconnect" forState:UIControlStateNormal];
}

-(void) bleDidUpdateRSSI:(NSNumber *)rssi
{
    self.rssiLabel.text = [NSString stringWithFormat:@"RSSI: %@", rssi.stringValue];
}


-(NSString*)getUUIDString:(CFUUIDRef)ref {
    NSString *str = [NSString stringWithFormat:@"%@",ref];
    return [[NSString stringWithFormat:@"%@",str] substringWithRange:NSMakeRange(str.length - 36, 36)];
}


@end
