//
//  RBLDetailViewController.h
//  BLE Select
//
//  Created by Chi-Hung Ma on 4/24/13.
//  Copyright (c) 2013 RedBearlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RBLDetailViewControllerDelegate <NSObject>

// recipe == nil on cancel
- (void) didSelected:(NSInteger)selected;

@end

@interface RBLDetailViewController : UITableViewController
{
    int selected;
}

@property (strong,nonatomic) NSArray *BLEDevices;

@property (nonatomic, weak) id <RBLDetailViewControllerDelegate> delegate;


@end


