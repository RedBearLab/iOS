//
//  RBLMainViewController.h
//  BLE Select
//
//  Created by Chi-Hung Ma on 4/24/13.
//  Copyright (c) 2013 RedBearlab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"
#import "RBLDetailViewController.h"

@interface RBLMainViewController : UIViewController <BLEDelegate, RBLDetailViewControllerDelegate>
{
    BLE *bleShield;
    bool isFindingLast;
}

@property (strong,nonatomic) NSMutableArray *mDevices;
@property (strong,nonatomic) NSString *lastUUID;


@end
