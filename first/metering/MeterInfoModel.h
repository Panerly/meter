//
//  MeterInfoModel.h
//  first
//
//  Created by HS on 16/8/10.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "JSONModel.h"

@interface MeterInfoModel : JSONModel
////小区名
//@property (nonatomic, strong) NSString<Optional> *install_Addr;
////照片名称1
//@property (nonatomic, strong) NSString<Optional> *collect_Img_Name1;
////照片名称2
//@property (nonatomic, strong) NSString<Optional> *collect_Img_Name2;
////照片名称3
//@property (nonatomic, strong) NSString<Optional> *collect_Img_Name3;
////所属小区或区域
//@property (nonatomic, strong) NSString<Optional> *collector_Area;
////通讯联络号
//@property (nonatomic, strong) NSString<Optional> *comm_Id;
////安装时间
//@property (nonatomic, strong) NSString<Optional> *install_Time;
////水表口径
//@property (nonatomic, strong) NSString<Optional> *meter_Cali;  //*
//@property (nonatomic, strong) NSString<Optional> *meter_Id;     //*
//@property (nonatomic, strong) NSString<Optional> *meter_Name;
//@property (nonatomic, strong) NSString<Optional> *meter_Txm;
//@property (nonatomic, strong) NSString<Optional> *meter_Wid;
//@property (nonatomic, strong) NSString<Optional> *remark;
//@property (nonatomic, strong) NSString<Optional> *user_Id;
//@property (nonatomic, strong) NSString<Optional> *water_Kind;


//标示 0未抄收 1已上传 2已抄收
@property (nonatomic, strong) NSString<Optional> *bs;

//小区 之前的install_addr
@property (nonatomic, strong) NSString<Optional> *s_bookName;

//登陆ID
@property (nonatomic, strong) NSString<Optional> *loginID;
//区域编码改为 --》抄表簿号
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
@property (nonatomic, strong) NSString<Optional> *n_GPS_E;//x
@property (nonatomic, strong) NSString<Optional> *n_GPS_N;//y
//上次抄表日期
@property (nonatomic, strong) NSString<Optional> *d_ChaoBiao_SC;
//上次抄码
@property (nonatomic, strong) NSString<Optional> *i_ChaoMa_SC;
//水量平均
@property (nonatomic, strong) NSString<Optional> *i_ShuiLiang_pingjun;



@end
