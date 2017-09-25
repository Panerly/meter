//
//  RepairTableViewCell.h
//  first
//
//  Created by panerly on 08/06/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RepairHistModel.h"

@interface RepairTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *statueView;

@property (weak, nonatomic) IBOutlet UILabel *user_id;
@property (weak, nonatomic) IBOutlet UILabel *bsh;
@property (weak, nonatomic) IBOutlet UILabel *appearance;
@property (weak, nonatomic) IBOutlet UILabel *repair_name;

@property (nonatomic, strong) RepairHistModel *repairHisModel;
@property (weak, nonatomic) IBOutlet UILabel *alertTime;

@end
