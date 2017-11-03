//
//  RepairDetailVC.h
//  first
//
//  Created by panerly on 08/06/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepairDetailVC : UIViewController

//上个页面传过来的值
@property(nonatomic, copy) NSString *user_id;       //用户号 --》户号
@property(nonatomic, copy) NSString *bsh;           //表身号 --》水表钢印号
@property(nonatomic, copy) NSString *appearance;    //报警原因
@property(nonatomic, copy) NSString *stage;         //维修状态
@property(nonatomic, copy) NSString *repair_name;   //维修人员
@property(nonatomic, copy) NSString *alert_time;    //报警时间
//后来加的值
@property(nonatomic, copy) NSString *user_addr;     //用户地址 --》地址
@property(nonatomic, copy) NSString *spotCondition; //现场状况
@property(nonatomic, copy) NSString *type;          //0:人工报修 1:抄表报修 2:外复报修 9:没用的--》
@property(nonatomic, copy) NSString *bs;            //--》0:换表流程  1:开挖流程

//2017-11-1 为换表新加
@property(nonatomic, copy) NSString *kj;            //--》口径
@property(nonatomic, copy) NSString *user_name;     //--》户名
@property(nonatomic, copy) NSString *jiuBiaoCJ;     //--》厂家

@property (nonatomic, strong) UILabel *userName;            //
@property (nonatomic, strong) UILabel *repairReason;        //
@property (nonatomic, strong) UILabel *phoneNum;            //
@property (nonatomic, strong) UILabel *installAddr;         //
@property (nonatomic, strong) UILabel *meterNum;            //
@property (nonatomic, strong) UILabel *repairStatus;        //
@property (nonatomic, strong) UILabel *locaStr;             //地理位置
@property (nonatomic, strong) UILabel *repairedNumStr;      //修正后读数 --》旧表拆码
@property (nonatomic, strong) UILabel *repairedReasonLabel; //维修原因
@property (nonatomic, strong) UILabel *remarkStr;           //备注
@property (nonatomic, strong) UILabel *spotConditionLabel;  //现场状况
@property (nonatomic, strong) UILabel *user_addrLabel;      //用户地址



//@property (nonatomic, strong) UIImageView *previewImageView;//视频或照片预览图

@property (nonatomic, strong) UIButton *plusBtn;    //添加视频或照片
@property (nonatomic, strong) UIButton *locaBtn;    //定位
@property (nonatomic, strong) UIButton *resetBtn;   //重置btn
@property (nonatomic, strong) UIButton *uploadBtn;  //上传btn
@property (nonatomic, strong) UIButton *delayBtn;   //延迟维修btn

@property (nonatomic, strong) UITextView *remarksTextView;//备注view
@property (nonatomic, strong) UITextField *repairedNumTextField;//维修后读数
@property (nonatomic, strong) UITextField *repairedReasonTextField;//维修原因 --》原因

//@property (nonatomic, copy) NSDictionary *movieInfo;//存放的视频信息

@property (nonatomic, strong) NSMutableArray *passArr;

@end
