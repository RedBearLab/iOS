//
//  RBLCellTableViewCell.h
//  SimpleChat
//
//  Created by redbear on 14-4-8.
//  Copyright (c) 2014年 redbear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBLCellTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *send;
@property (weak, nonatomic) IBOutlet UIImageView *receive;
@property (weak, nonatomic) IBOutlet UILabel *text;

@end
