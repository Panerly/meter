//
//  CheckTableViewCell.m
//  first
//
//  Created by panerly on 26/09/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import "CheckTableViewCell.h"

@implementation CheckTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    self.userAddr.text = _checkModel.userAddr;
    self.userAddr.text = [NSString stringWithFormat:@"下沙经济开发区15号大街22号"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
