//
//  RBLViewController.m
//  SimpleChat
//
//  Created by redbear on 14-4-8.
//  Copyright (c) 2014年 redbear. All rights reserved.
//

#import "RBLViewController.h"
#import "RBLCellTableViewCell.h"

#define TEXT_STR @"TEXT_STR"
#define FORM @"FORM"

@interface RBLViewController ()
{
    NSMutableArray *tableData;
}

@end

@implementation RBLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    tableData = [NSMutableArray array];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    bleShield = [[BLE alloc] init];
    [bleShield controlSetup];
    bleShield.delegate = self;
    
    self.navigationItem.hidesBackButton = NO;
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [self navigationItem].rightBarButtonItem = barButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

-(void) connectionTimer:(NSTimer *)timer
{
    if(bleShield.peripherals.count > 0)
    {
        [bleShield connectPeripheral:[bleShield.peripherals objectAtIndex:0]];
    }
    else
    {
        [activityIndicator stopAnimating];
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

- (IBAction)BLEShieldScan:(id)sender
{
    if (bleShield.activePeripheral)
        if(bleShield.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[bleShield CM] cancelPeripheralConnection:[bleShield activePeripheral]];
            return;
        }
    
    if (bleShield.peripherals)
        bleShield.peripherals = nil;
    
    [bleShield findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    [activityIndicator startAnimating];
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    NSLog(@"%@", s);
    NSNumber *form = [NSNumber numberWithBool:YES];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:s, TEXT_STR, form, FORM, nil];
    [tableData addObject:dict];
    
    [_tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    [_tableView reloadData];
}

NSTimer *rssiTimer;

-(void) readRSSITimer:(NSTimer *)timer
{
    [bleShield readRSSI];
}

- (void) bleDidDisconnect
{
    NSLog(@"bleDidDisconnect");
    
    [self.navigationItem.leftBarButtonItem setTitle:@"Connect"];
    [activityIndicator stopAnimating];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

-(void) bleDidConnect
{
    [activityIndicator stopAnimating];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    [self.navigationItem.leftBarButtonItem setTitle:@"Disconnect"];
    
    NSLog(@"bleDidConnect");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"chat_cell";
    
    RBLCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    NSDictionary *dict = [tableData objectAtIndex:indexPath.row];
    NSString *text = [dict objectForKey:TEXT_STR];
    NSNumber *form = [dict objectForKey:FORM];
    
    if ([form boolValue] == YES) {
        cell.receive.image = [UIImage imageNamed:@"arduino.png"];
        cell.text.text = text;
        cell.text.textAlignment = NSTextAlignmentLeft;
        cell.send.image = nil;
    } else {
        cell.send.image = [UIImage imageNamed:@"apple.png"];
        cell.text.text = text;
        cell.text.textAlignment = NSTextAlignmentRight;
        cell.receive.image = nil;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self.text resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *text = textField.text;
    NSNumber *form = [NSNumber numberWithBool:NO];
    
    NSString *s;
    NSData *d;
    
    if (text.length > 16)
        s = [text substringToIndex:16];
    else
        s = text;
    
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    if (bleShield.activePeripheral.state == CBPeripheralStateConnected) {
        [bleShield write:d];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:text, TEXT_STR, form, FORM, nil];
        [tableData addObject:dict];
        [_tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        NSLog(@"%f", _tableView.contentOffset.y);
        [self.tableView reloadData];
    }
    
    textField.text = @"";
    
    return YES;
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"%f", _tableView.contentOffset.y);
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y -=kbSize.height;
        frame.size.height +=kbSize.height;
        self.view.frame = frame;
    }];
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect frame = self.tableView.frame;
        frame.origin.y +=kbSize.height;
        frame.size.height -=(kbSize.height * 2);
        _tableView.frame = frame;
    }];
    
    NSNumber *form = [NSNumber numberWithBool:NO];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"", TEXT_STR, form, FORM, nil];
    [tableData addObject:dict];
    [_tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    [_tableView reloadData];
    
    [tableData removeLastObject];
    [_tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    [_tableView reloadData];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect frame = _tableView.frame;
        frame.origin.y -=kbSize.height;
        frame.size.height +=(kbSize.height * 2);
        _tableView.frame = frame;
    }];
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y +=kbSize.height;
        frame.size.height -=kbSize.height;
        self.view.frame = frame;
    }];
    
    NSNumber *form = [NSNumber numberWithBool:NO];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"", TEXT_STR, form, FORM, nil];
    [tableData addObject:dict];
    [_tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    [_tableView reloadData];
    
    [tableData removeLastObject];
    [_tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    [_tableView reloadData];
}

@end
