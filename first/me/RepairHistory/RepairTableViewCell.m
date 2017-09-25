//
//  RepairTableViewCell.m
//  first
//
//  Created by panerly on 08/06/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import "RepairTableViewCell.h"

@implementation RepairTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    _bgView.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
//    _bgView.layer.shadowOffset = CGSizeMake(1, 1.5);
//    _bgView.layer.shadowOpacity = .90f;
//    
//    _statusView.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
//    _statusView.layer.shadowOffset = CGSizeMake(1, 1.3);
//    _statusView.layer.shadowOpacity = .90f;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    //设置开始和结束位置(设置渐变的方向)
    gradient.startPoint = CGPointMake(1, 0);
    gradient.endPoint = CGPointMake(0, 0);
    gradient.frame = CGRectMake(0, 0, _bgView.frame.size.width, _bgView.frame.size.height - 13);
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:0 green:166/255.0f blue:171/255.0f alpha:1].CGColor,(id)[UIColor colorWithRed:0 green:104/255.0f blue:107/255.0f alpha:1].CGColor,nil];
    gradient.cornerRadius = 15;
    [_bgView.layer insertSublayer:gradient atIndex:0];
    
    _user_id.text = [NSString stringWithFormat:@"用户号：%@", self.repairHisModel.user_id];
    _bsh.text = [NSString stringWithFormat:@"表  身  号：%@",self.repairHisModel.bsh];
    _appearance.text = [NSString stringWithFormat:@"报警原因：%@",self.repairHisModel.appearance];
    _repair_name.text = [NSString stringWithFormat:@"用户地址：%@", self.repairHisModel.user_addr];
    _alertTime.text = [NSString stringWithFormat:@"%@", self.repairHisModel.give_date];
    
    if ([self.repairHisModel.stage isEqualToString:@"未处理"]) {
        
        _statueView.image = [UIImage imageNamed:@"icon_uncomplete"];
    }else if ([self.repairHisModel.stage isEqualToString:@"协助中"]){
        
        _statueView.image = [UIImage imageNamed:@"icon_fac_help"];
    }else{
        
        _statueView.image = [UIImage imageNamed:@"icon_complete"];
    }
//    _statueView.image = [self.repairHisModel.stage isEqualToString:@"未处理"]?[UIImage imageNamed:@"icon_uncomplete"]:[UIImage imageNamed:@"icon_complete"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
