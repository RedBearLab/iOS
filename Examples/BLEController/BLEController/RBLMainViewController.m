
/*
 
 Copyright (c) 2013-2014 RedBearLab
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

//#define MV_DEBUG

#import "RBLMainViewController.h"
#import "RBLControlViewController.h"

NSString * const  UUIDPrefKey = @"UUIDPrefKey";

@implementation RBLMainViewController
@synthesize ble;
RBLControlViewController *cv;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;
    
    self.mDevices = [[NSMutableArray alloc] init];
    self.mDevicesName = [[NSMutableArray alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:UUIDPrefKey];
    }
    
    //Retrieve saved UUID from system
    self.lastUUID = [[NSUserDefaults standardUserDefaults] objectForKey:UUIDPrefKey];
    if ([self.lastUUID isEqualToString:@""])
    {
        [btnConnectLast setEnabled:NO];
    }
    else
    {
        [btnConnectLast setEnabled:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDevice"])
    {
        RBLDetailViewController *vc = [segue destinationViewController];
        vc.BLEDevices = self.mDevices;
        vc.BLEDevicesName = self.mDevicesName;
        vc.ble = ble;
    }
    else if ([[segue identifier] isEqualToString:@"gotoControlVC"])
    {
        cv = [segue destinationViewController];
        cv.ble = ble;
    }
}

-(void) connectionTimer:(NSTimer *)timer
{
    showAlert = YES;
    [btnConnect setEnabled:YES];
    
    self.lastUUID = [[NSUserDefaults standardUserDefaults] objectForKey:UUIDPrefKey];
    
    if ([self.lastUUID isEqualToString:@""])
    {
        [btnConnectLast setEnabled:NO];
    }
    else
    {
        [btnConnectLast setEnabled:YES];
    }
    
    if (ble.peripherals.count > 0)
    {
        if(isFindingLast)
        {
            int i;
            for (i = 0; i < ble.peripherals.count; i++)
            {
                CBPeripheral *p = [ble.peripherals objectAtIndex:i];
                        
                if (p.UUID != NULL)
                {
                    //Comparing UUIDs and call connectPeripheral is matched
                    if([self.lastUUID isEqualToString:[self getUUIDString:p.UUID]])
                    {
                        showAlert = NO;
                        [ble connectPeripheral:p];
                    }
                }
            }
        }
        else
        {
            [self.mDevices removeAllObjects];
            [self.mDevicesName removeAllObjects];
            
            int i;
            for (i = 0; i < ble.peripherals.count; i++)
            {
                CBPeripheral *p = [ble.peripherals objectAtIndex:i];
                
                if (p.UUID != NULL)
                {
                    [self.mDevices insertObject:[self getUUIDString:p.UUID] atIndex:i];
                    if (p.name != nil) {
                        [self.mDevicesName insertObject:p.name atIndex:i];
                    } else {
                        [self.mDevicesName insertObject:@"RedBear Device" atIndex:i];
                    }
                }
                else
                {
                    [self.mDevices insertObject:@"NULL" atIndex:i];
                    [self.mDevicesName insertObject:@"RedBear Device" atIndex:i];
                }
            }
            showAlert = NO;
            [self performSegueWithIdentifier:@"showDevice" sender:self];
        }
    }
  
    if (showAlert == YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"No BLE Device(s) found."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [activityScanning stopAnimating];
}

- (IBAction)btnConnectClicked:(id)sender
{
    if (ble.activePeripheral)
        if(ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            return;
        }
    
    if (ble.peripherals)
        ble.peripherals = nil;
    
    [btnConnect setEnabled:false];
    [btnConnectLast setEnabled:NO];
    [ble findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    isFindingLast = false;
    [activityScanning startAnimating];
}

- (IBAction)lastClick:(id)sender {
    if (ble.peripherals) {
        ble.peripherals = nil;
    }
    
    [btnConnect setEnabled:false];
    [btnConnectLast setEnabled:NO];
    [ble findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    isFindingLast = true;
    [activityScanning startAnimating];
}

-(void) bleDidConnect
{
    NSLog(@"->DidConnect");
    
    self.lastUUID = [self getUUIDString:ble.activePeripheral.UUID];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastUUID forKey:UUIDPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.lastUUID = [[NSUserDefaults standardUserDefaults] objectForKey:UUIDPrefKey];
    if ([self.lastUUID isEqualToString:@""]) {
        [btnConnectLast setEnabled:NO];
    } else {
        [btnConnectLast setEnabled:YES];
    }
    
    [activityScanning stopAnimating];
    [self performSegueWithIdentifier:@"gotoControlVC" sender:self];
}

- (void)bleDidDisconnect
{
    NSLog(@"->DidDisconnect");
    
    [activityScanning stopAnimating];
    [self.navigationController popToRootViewControllerAnimated:true];
}

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
#if defined(MV_DEBUG)
    NSLog(@"->DidReceiveData");
#endif
    
    if (cv != nil)
    {
        [cv processData:data length:length];
    }
}

-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
}

-(NSString *)getUUIDString:(CFUUIDRef)ref {
    NSString *str = [NSString stringWithFormat:@"%@", ref];
    return [[NSString stringWithFormat:@"%@", str] substringWithRange:NSMakeRange(str.length - 36, 36)];
}

@end
