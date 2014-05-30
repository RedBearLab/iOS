
/*
 
 Copyright (c) 2013-2014 RedBearLab
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "RBLControlViewController.h"
#import "CellPin.h"

uint8_t total_pin_count  = 0;
uint8_t pin_mode[128]    = {0};
uint8_t pin_cap[128]     = {0};
uint8_t pin_digital[128] = {0};
uint16_t pin_analog[128]  = {0};
uint8_t pin_pwm[128]     = {0};
uint8_t pin_servo[128]   = {0};

uint8_t init_done = 0;

@interface RBLControlViewController ()

@end

@implementation RBLControlViewController
@synthesize ble;
@synthesize protocol;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    UIImage *temp = [[UIImage imageNamed:@"title.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:temp style:UIBarButtonItemStyleBordered target:self action:@selector(action)];
    self.navigationItem.leftBarButtonItem = barButtonItem;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    protocol = [[RBLProtocol alloc] init];
    protocol.delegate = self;
    protocol.ble = ble;
    
    NSLog(@"ControlView: viewDidLoad");
}

NSTimer *syncTimer;

-(void) syncTimeout:(NSTimer *)timer
{
    NSLog(@"Timeout: no response");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"No response from the BLE Controller sketch."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    // disconnect it
    [ble.CM cancelPeripheralConnection:ble.activePeripheral];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"ControlView: viewDidAppear");
    
    syncTimer = [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(syncTimeout:) userInfo:nil repeats:NO];

    [protocol queryProtocolVersion];
}

-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"ControlView: viewDidDisappear");

    total_pin_count = 0;
    [tv reloadData];
    
    init_done = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnStopClicked:(id)sender
{
    NSLog(@"Button Stop Clicked");
    
    [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
}

-(void) processData:(uint8_t *) data length:(uint8_t) length
{
#if defined(CV_DEBUG)
    NSLog(@"ControlView: processData");
    NSLog(@"Length: %d", length);
#endif
    
    [protocol parseData:data length:length];
}

-(void) protocolDidReceiveProtocolVersion:(uint8_t)major Minor:(uint8_t)minor Bugfix:(uint8_t)bugfix
{
    NSLog(@"protocolDidReceiveProtocolVersion: %d.%d.%d", major, minor, bugfix);
    
    // get response, so stop timer
    [syncTimer invalidate];
    
    uint8_t buf[] = {'B', 'L', 'E'};
    [protocol sendCustomData:buf Length:3];
    
    [protocol queryTotalPinCount];
}

-(void) protocolDidReceiveTotalPinCount:(UInt8) count
{
    NSLog(@"protocolDidReceiveTotalPinCount: %d", count);
    
    total_pin_count = count;
    [protocol queryPinAll];
}

-(void) protocolDidReceivePinCapability:(uint8_t)pin Value:(uint8_t)value
{
    NSLog(@"protocolDidReceivePinCapability");
    NSLog(@" Pin %d Capability: 0x%02X", pin, value);
    
    if (value == 0)
        NSLog(@" - Nothing");
    else
    {
        if (value & PIN_CAPABILITY_DIGITAL)
            NSLog(@" - DIGITAL (I/O)");
        if (value & PIN_CAPABILITY_ANALOG)
            NSLog(@" - ANALOG");
        if (value & PIN_CAPABILITY_PWM)
            NSLog(@" - PWM");
        if (value & PIN_CAPABILITY_SERVO)
            NSLog(@" - SERVO");
    }
    
    pin_cap[pin] = value;
}

-(void) protocolDidReceivePinData:(uint8_t)pin Mode:(uint8_t)mode Value:(uint8_t)value
{
//    NSLog(@"protocolDidReceiveDigitalData");
//    NSLog(@" Pin: %d, mode: %d, value: %d", pin, mode, value);
    
    uint8_t _mode = mode & 0x0F;
    
    pin_mode[pin] = _mode;
    if ((_mode == INPUT) || (_mode == OUTPUT))
        pin_digital[pin] = value;
    else if (_mode == ANALOG)
        pin_analog[pin] = ((mode >> 4) << 8) + value;
    else if (_mode == PWM)
        pin_pwm[pin] = value;
    else if (_mode == SERVO)
        pin_servo[pin] = value;
    
    [tv reloadData];
}

-(void) protocolDidReceivePinMode:(uint8_t)pin Mode:(uint8_t)mode
{
    NSLog(@"protocolDidReceivePinMode");
    
    if (mode == INPUT)
        NSLog(@" Pin %d Mode: INPUT", pin);
    else if (mode == OUTPUT)
        NSLog(@" Pin %d Mode: OUTPUT", pin);
    else if (mode == PWM)
        NSLog(@" Pin %d Mode: PWM", pin);
    else if (mode == SERVO)
        NSLog(@" Pin %d Mode: SERVO", pin);
    
    pin_mode[pin] = mode;
    [tv reloadData];
}

-(void) protocolDidReceiveCustomData:(UInt8 *)data length:(UInt8)length
{
    // Handle your customer data here.
    for (int i = 0; i< length; i++)
        printf("0x%2X ", data[i]);
    printf("\n");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    uint8_t pin = indexPath.row;
    
    if (pin_cap[pin] == PIN_CAPABILITY_NONE)
        return 0;
    
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return total_pin_count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"cell_pin";
    uint8_t pin = indexPath.row;
    
    CellPin *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell.lblPin setText:[NSString stringWithFormat:@"%d", pin]];
    [cell.btnMode setTag:pin];
    [cell.sgmHL setTag:pin];
    [cell.sldPWM setTag:pin];
    
    // Pin availability
    if (pin_cap[pin] == 0x00)
        [cell setHidden:TRUE];
    
    // Pin mode
    if (pin_mode[pin] == INPUT)
    {
        [cell.btnMode setTitle:@"Input" forState:UIControlStateNormal];
        [cell.sgmHL setHidden:FALSE];
        [cell.sgmHL setEnabled:FALSE];
        [cell.sgmHL setSelectedSegmentIndex:pin_digital[pin]];
        [cell.lblAnalog setHidden:TRUE];
        [cell.sldPWM setHidden:TRUE];
    }
    else if (pin_mode[pin] == OUTPUT)
    {
        [cell.btnMode setTitle:@"Output" forState:UIControlStateNormal];
        [cell.sgmHL setHidden:FALSE];
        [cell.sgmHL setEnabled:TRUE];
        [cell.sgmHL setSelectedSegmentIndex:pin_digital[pin]];
        [cell.lblAnalog setHidden:TRUE];
        [cell.sgmHL setHidden:FALSE];
        [cell.sldPWM setHidden:TRUE];
    }
    else if (pin_mode[pin] == ANALOG)
    {
        [cell.btnMode setTitle:@"Analog" forState:UIControlStateNormal];
        [cell.lblAnalog setText:[NSString stringWithFormat:@"%d", pin_analog[pin]]];
        [cell.lblAnalog setHidden:FALSE];
        [cell.sgmHL setHidden:TRUE];
        [cell.sldPWM setHidden:TRUE];
    }
    else if (pin_mode[pin] == PWM)
    {
        [cell.btnMode setTitle:@"PWM" forState:UIControlStateNormal];
        [cell.lblAnalog setText:[NSString stringWithFormat:@"%d", pin_analog[pin]]];
        [cell.sldPWM setHidden:FALSE];
        [cell.lblAnalog setHidden:TRUE];
        [cell.sgmHL setHidden:TRUE];
        [cell.sldPWM setMinimumValue:0];
        [cell.sldPWM setMaximumValue:255];
        [cell.sldPWM setValue:pin_pwm[pin]];
    }
    else if (pin_mode[pin] == SERVO)
    {
        [cell.btnMode setTitle:@"Servo" forState:UIControlStateNormal];
        [cell.lblAnalog setText:[NSString stringWithFormat:@"%d", pin_analog[pin]]];
        [cell.sldPWM setHidden:FALSE];
        [cell.lblAnalog setHidden:TRUE];
        [cell.sgmHL setHidden:TRUE];
        [cell.sldPWM setMinimumValue:0];
        [cell.sldPWM setMaximumValue:180];
        [cell.sldPWM setValue:pin_servo[pin]];
    }
    
    return cell;
}

- (IBAction)toggleHL:(id)sender
{
    NSLog(@"High/Low clicked, pin id: %d", [sender tag]);
    
    uint8_t pin = [sender tag];
    UISegmentedControl *sgmControl = (UISegmentedControl *) sender;
    if ([sgmControl selectedSegmentIndex] == LOW)
    {
        [protocol digitalWrite:pin Value:LOW];
        pin_digital[pin] = LOW;
    }
    else
    {
        [protocol digitalWrite:pin Value:HIGH];
        pin_digital[pin] = HIGH;
    }
}

uint8_t current_pin = 0;

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet button clicked, pin id: %d", buttonIndex);
    NSLog(@"title: %@", [actionSheet buttonTitleAtIndex:buttonIndex]);
    
    NSString *mode_str = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([mode_str isEqualToString:@"Input"])
    {
        [protocol setPinMode:current_pin Mode:INPUT];
    }
    else if ([mode_str isEqualToString:@"Output"])
    {
        [protocol setPinMode:current_pin Mode:OUTPUT];
    }
    else if ([mode_str isEqualToString:@"Analog"])
    {
        [protocol setPinMode:current_pin Mode:ANALOG];
    }
    else if ([mode_str isEqualToString:@"PWM"])
    {
        [protocol setPinMode:current_pin Mode:PWM];
    }
    else if ([mode_str isEqualToString:@"Servo"])
    {
        [protocol setPinMode:current_pin Mode:SERVO];
    }
}

- (IBAction)modeChange:(id)sender
{
    uint8_t pin = [sender tag];
    NSLog(@"Mode button clicked, pin id: %d", pin);
    
    NSString *title = [NSString stringWithFormat:@"Select Pin %d Mode", pin];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    
    if (pin_cap[pin] & PIN_CAPABILITY_DIGITAL)
    {
        [sheet addButtonWithTitle:@"Input"];
        [sheet addButtonWithTitle:@"Output"];
    }
    
    if (pin_cap[pin] & PIN_CAPABILITY_PWM)
        [sheet addButtonWithTitle:@"PWM"];
    
    if (pin_cap[pin] & PIN_CAPABILITY_SERVO)
        [sheet addButtonWithTitle:@"Servo"];
    
    if (pin_cap[pin] & PIN_CAPABILITY_ANALOG)
        [sheet addButtonWithTitle:@"Analog"];
    
    sheet.cancelButtonIndex = [sheet addButtonWithTitle: @"Cancel"];
    
    current_pin = pin;
    
    // Show the sheet
    [sheet showInView:self.view];
}

- (IBAction)sliderChange:(id)sender
{
    uint8_t pin = [sender tag];
    UISlider *sld = (UISlider *) sender;
    uint8_t value = sld.value;
    
    if (pin_mode[pin] == PWM)
        pin_pwm[pin] = value; // for updating the GUI
    else
        pin_servo[pin] = value;
}

- (IBAction)sliderTouchUp:(id)sender
{
    uint8_t pin = [sender tag];
    UISlider *sld = (UISlider *) sender;
    uint8_t value = sld.value;
    NSLog(@"Slider, pin id: %d, value: %d", pin, value);
    
    if (pin_mode[pin] == PWM)
    {
        pin_pwm[pin] = value;
        [protocol analogWrite:pin Value:value];
    }
    else
    {
        pin_servo[pin] = value;
        [protocol servoWrite:pin Value:value];
    }
}

@end
