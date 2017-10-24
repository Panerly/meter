//
//  CompleteTableViewCell.m
//  first
//
//  Created by HS on 16/8/23.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "CompleteTableViewCell.h"
#import "CompleteViewController.h"


@implementation CompleteTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.completeModel.i_ChaoMa) {
        
        self.meter_id.text = [NSString stringWithFormat:@"本期抄收值： %@ m³",self.completeModel.i_ChaoMa];
    }
    if (self.completeModel.s_DiZhi) {
        
        self.user_id.text = [NSString stringWithFormat:@"%@",self.completeModel.s_DiZhi];
    }
    if (self.completeModel.d_ChaoBiao) {
        
        self.collect_time.text = [NSString stringWithFormat:@"抄表时间：%@",self.completeModel.d_ChaoBiao];
    }
    if (self.completeModel.s_PhotoFile) {
        
        self.compImage.image = self.completeModel.s_PhotoFile;
    }
    _click = self.completeModel.s_DiZhi;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    
        self.meter_id.textColor = [UIColor blackColor];
    
        self.meter_id.font = [UIFont systemFontOfSize:17];
    }];
}



- (UIViewController *)findVC
{
    UIResponder *next = self.nextResponder;
    
    while (1) {
        
        if ([next isKindOfClass:[UIViewController class]]) {
            return  (UIViewController *)next;
        }
        next =  next.nextResponder;
    }
    return nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

//上传数据
- (IBAction)upload:(id)sender {
    
    [self createDB];
    
}
- (void)createDB {
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];

    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    [db open];
    [db executeUpdate:[NSString stringWithFormat:@"delete from Reading_now where s_DiZhi = '%@'",_click]];
    
    FMResultSet *restultSet = [db executeQuery:@"SELECT * FROM Reading_now order by id"];
    [((CompleteViewController *)[self findVC]).dataArr removeAllObjects];
    
    while ([restultSet next]) {
        
        NSString *i_ChaoMa  = [restultSet stringForColumn:@"i_ChaoMa"];
        NSString *s_DiZhi   = [restultSet stringForColumn:@"s_DiZhi"];
        NSString *d_ChaoBiao = [restultSet stringForColumn:@"d_ChaoBiao"];

        CompleteModel *completeModel    = [[CompleteModel alloc] init];
        completeModel.i_ChaoMa          = [NSString stringWithFormat:@"%@", i_ChaoMa];
        completeModel.s_DiZhi           = [NSString stringWithFormat:@"%@", s_DiZhi];
        completeModel.d_ChaoBiao        = [NSString stringWithFormat:@"%@", d_ChaoBiao];
        [((CompleteViewController *)[self findVC]).dataArr addObject:completeModel];
    }
    [db close];
    
    [((CompleteViewController *)[self findVC]).tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [SCToastView showInView:((CompleteViewController *)[self findVC]).tableView text:@"上传成功" duration:.5 autoHide:YES];
}

@end
