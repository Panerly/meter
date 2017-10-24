//
//  CheckModel.h
//  first
//
//  Created by panerly on 26/09/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import "JSONModel.h"

@interface CheckModel : JSONModel


//登陆ID
@property (nonatomic, strong) NSString<Optional> *loginID;
//抄表簿号
@property (nonatomic, strong) NSString<Optional> *s_bookNo;
//册内序号
@property (nonatomic, strong) NSString<Optional> *i_no;
//抄表ID
@property (nonatomic, strong) NSString<Optional> *i_ChaoBiaoID;
//客户编号
@property (nonatomic, strong) NSString<Optional> *s_CID;
//表状态
@property (nonatomic, strong) NSString<Optional> *i_BiaoZhuangTai;
//用水性质ID
@property (nonatomic, strong) NSString<Optional> *i_priceTag;
//收费方式ID
@property (nonatomic, strong) NSString<Optional> *i_SFFS;
//客户类别
@property (nonatomic, strong) NSString<Optional> *i_KeHuLeiBie;
//表分类
@property (nonatomic, strong) NSString<Optional> *i_BiaoFenLei;
//人口数
@property (nonatomic, strong) NSString<Optional> *i_RenKouShu;
//户名
@property (nonatomic, strong) NSString<Optional> *s_HuMing;
//地址
@property (nonatomic, strong) NSString<Optional> *s_DiZhi;
//表位
@property (nonatomic, strong) NSString<Optional> *s_BiaoWei;
//水表钢印号
@property (nonatomic, strong) NSString<Optional> *s_ShuiBiaoGYH;
//位置
@property (nonatomic, strong) NSString<Optional> *n_GPS_E;
@property (nonatomic, strong) NSString<Optional> *n_GPS_N;
//上次抄表日期
@property (nonatomic, strong) NSString<Optional> *d_ChaoBiao_SC;
//上次抄码
@property (nonatomic, strong) NSString<Optional> *i_ChaoMa_SC;
//水量平均
@property (nonatomic, strong) NSString<Optional> *i_ShuiLiang_pingjun;


@end
