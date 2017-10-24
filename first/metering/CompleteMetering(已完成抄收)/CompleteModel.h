//
//  CompleteModel.h
//  first
//
//  Created by HS on 16/8/23.
//  Copyright © 2016年 HS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompleteModel : NSObject

//标示 0未抄收 1已上传 2已抄收
@property (nonatomic, strong) NSString *bs;

//小区 之前的install_addr
@property (nonatomic, strong) NSString *s_bookName;

//区域编码改为 --》抄表簿号
@property (nonatomic, strong) NSString *s_bookNo;
//册内序号
@property (nonatomic, strong) NSString *i_no;
//抄表ID
@property (nonatomic, strong) NSString *i_ChaoBiaoID;
//客户编号
@property (nonatomic, strong) NSString *s_CID;
//录入标示 1：正常录入 3:外复回
@property (nonatomic, strong) NSString *i_MarkingMode;
//表状态
@property (nonatomic, strong) NSString *i_BiaoZhuangTai;
//用水性质ID
@property (nonatomic, strong) NSString *i_priceTag;
//收费方式ID
@property (nonatomic, strong) NSString *i_SFFS;
//客户类别
@property (nonatomic, strong) NSString *i_KeHuLeiBie;
//表分类
@property (nonatomic, strong) NSString *i_BiaoFenLei;
//人口数
@property (nonatomic, strong) NSString *i_RenKouShu;
//户名
@property (nonatomic, strong) NSString *s_HuMing;
//地址
@property (nonatomic, strong) NSString *s_DiZhi;
//表位
@property (nonatomic, strong) NSString *s_BiaoWei;
//水表钢印号
@property (nonatomic, strong) NSString *s_ShuiBiaoGYH;
//位置
@property (nonatomic, strong) NSString *n_GPS_E;//x
@property (nonatomic, strong) NSString *n_GPS_N;//y
//上次抄表日期
@property (nonatomic, strong) NSString *d_ChaoBiao_SC;
//上次抄码
@property (nonatomic, strong) NSString *i_ChaoMa_SC;
//水量平均
@property (nonatomic, strong) NSString *i_ShuiLiang_pingjun;
//本次用量
@property (nonatomic, strong) NSString *i_ShuiLiang_ChaoJian;
//本次抄码值
@property (nonatomic, strong) NSString *i_ChaoMa;
//备注
@property (nonatomic, strong) NSString *s_BeiZhu;
//本次抄表时间
@property (nonatomic, strong) NSString *d_ChaoBiao;
//pic
@property (nonatomic, strong) UIImage *s_PhotoFile;
@property (nonatomic, strong) UIImage *s_PhotoFile2;
@property (nonatomic, strong) UIImage *s_PhotoFile3;


@end
