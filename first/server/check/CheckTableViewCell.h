//
//  CheckTableViewCell.h
//  first
//
//  Created by panerly on 26/09/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckModel.h"

@protocol MycellDelegate <NSObject>

@optional

-(void)didClickButton:(UIButton *)button X:(NSString *)x Y:(NSString *)y;

@end

@interface CheckTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userAddr;

@property (nonatomic, strong) CheckModel *checkModel;

@property(nonatomic,weak) id<MycellDelegate> delegate;

@end
