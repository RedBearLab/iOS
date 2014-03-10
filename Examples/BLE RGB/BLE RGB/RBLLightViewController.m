//
//  RBLLightViewController.m
//  BLE RGB
//
//  Created by redbear on 14-2-20.
//  Copyright (c) 2014年 redbear. All rights reserved.
//

#import "RBLLightViewController.h"

@interface RBLLightViewController ()

@end

@implementation RBLLightViewController

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
    
    _colorPicker = [[RSColorPickerView alloc] initWithFrame:CGRectMake(30.0, 80.0, 280.0, 260.0)];
    [_colorPicker setCropToCircle:YES]; // Defaults to YES (and you can set BG color)
    [_colorPicker setDelegate:self];
    [self.view addSubview:_colorPicker];
    
    _colorPatch = [[UIView alloc] initWithFrame:CGRectMake(100, 355.0, 120, 40.0)];
	[self.view addSubview:_colorPatch];
    
    int labelY = 400;
    
    // Buttons for testing
    UIButton *selectRed = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    selectRed.frame = CGRectMake(20.0, labelY, 50.0, 30.0);
    [selectRed setTitle:@"Red" forState:UIControlStateNormal];
    [selectRed addTarget:self action:@selector(selectRed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectRed];
    
    UIButton *selectGreen = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    selectGreen.frame = CGRectMake(CGRectGetMaxX(selectRed.frame) + 10, labelY, 50.0, 30.0);
    [selectGreen setTitle:@"Green" forState:UIControlStateNormal];
    [selectGreen addTarget:self action:@selector(selectGreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectGreen];
    
    UIButton *selectBlue = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    selectBlue.frame = CGRectMake(CGRectGetMaxX(selectGreen.frame) + 10, labelY, 50.0, 30.0);
    [selectBlue setTitle:@"Blue" forState:UIControlStateNormal];
    [selectBlue addTarget:self action:@selector(selectBlue:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectBlue];
    
    UIButton *selectWhite = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    selectWhite.frame = CGRectMake(CGRectGetMaxX(selectBlue.frame) + 10, labelY, 50.0, 30.0);
    [selectWhite setTitle:@"White" forState:UIControlStateNormal];
    [selectWhite addTarget:self action:@selector(selectWhite:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectWhite];
    
    UIButton *selectBlack = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    selectBlack.frame = CGRectMake(CGRectGetMaxX(selectWhite.frame) + 10, labelY, 50.0, 30.0);
    [selectBlack setTitle:@"Off" forState:UIControlStateNormal];
    [selectBlack addTarget:self action:@selector(selectOff:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectBlack];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 440, 320, 30.0)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Arial" size:15.0f];
    label.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)colorPickerDidChangeSelection:(RSColorPickerView *)cp {
	_colorPatch.backgroundColor = [cp selectionColor];
    //    _brightnessSlider.value = [cp brightness];
    //    _opacitySlider.value = [cp opacity];
    
    NSLog(@"*my %d, %d, %d", [cp vRed], [cp vGreen], [cp vBlue]);
    label.text = [NSString stringWithFormat:@"R : %d\tG : %d\tB : %d", [cp vRed], [cp vGreen], [cp vBlue]];
    
    uint8_t command[] = {0x00,0x00,0x00};
    
    command[0] = [cp vRed];
    command[1] = [cp vGreen];
    command[2] = [cp vBlue];
    
    NSData *nsData = [[NSData alloc] initWithBytes:command length:3];
    [self.vc.peripheral writeValue:nsData forCharacteristic:self.vc.txCharacteristic type:CBCharacteristicWriteWithoutResponse];
    
}

#pragma mark - User action

- (void)selectRed:(id)sender {
    [_colorPicker setSelectionColor:[UIColor redColor]];
}
- (void)selectGreen:(id)sender {
    [_colorPicker setSelectionColor:[UIColor greenColor]];
}
- (void)selectBlue:(id)sender {
    [_colorPicker setSelectionColor:[UIColor blueColor]];
}
- (void)selectBlack:(id)sender {
    [_colorPicker setSelectionColor:[UIColor blackColor]];
}
- (void)selectWhite:(id)sender {
    [_colorPicker setSelectionColor:[UIColor whiteColor]];
}
- (void)selectPurple:(id)sender {
    [_colorPicker setSelectionColor:[UIColor purpleColor]];
}
- (void)selectCyan:(id)sender {
    [_colorPicker setSelectionColor:[UIColor cyanColor]];
}

- (void)selectOff:(id)sender {
    uint8_t command[] = {0x00,0x00,0x00};
    
    NSData *nsData = [[NSData alloc] initWithBytes:command length:3];
    [self.vc.peripheral writeValue:nsData forCharacteristic:self.vc.txCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)circleSwitchAction:(UISwitch *)s {
	_colorPicker.cropToCircle = s.isOn;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    
    uint8_t command[] = {0x00,0x00,0x00};
    
    NSData *nsData = [[NSData alloc] initWithBytes:command length:3];
    [self.vc.peripheral writeValue:nsData forCharacteristic:self.vc.txCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

@end
