//
//  RBLViewController.h
//  SimpleChat
//
//  Created by redbear on 14-4-8.
//  Copyright (c) 2014年 redbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"

@interface RBLViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, BLEDelegate>
{
    BLE *bleShield;
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UITextField *text;

@end
