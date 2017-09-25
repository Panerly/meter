//
//  RepairHistModel.h
//  first
//
//  Created by panerly on 20/08/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import "JSONModel.h"

@interface RepairHistModel : JSONModel

//@property(nonatomic, copy) NSString *user_id;       //用户号
//@property(nonatomic, copy) NSString *bsh;           //表身号
//@property(nonatomic, copy) NSString *appearance;    //报警原因
//@property(nonatomic, copy) NSString *stage;         //维修状态
//@property(nonatomic, copy) NSString *repair_name;   //维修人员
//@property(nonatomic, copy) NSString *alert_time;    //报警时间


@property(nonatomic, copy) NSString<Optional> *give_date;     //下单时间*
@property(nonatomic, copy) NSString<Optional> *user_id;       //用户号*
@property(nonatomic, copy) NSString<Optional> *bsh;           //表身号*
@property(nonatomic, copy) NSString<Optional> *appearance;    //报警原因*
@property(nonatomic, copy) NSString<Optional> *stage;         //维修状态*
@property(nonatomic, copy) NSString<Optional> *repair_name;   //维修人*
//修改后加的参数
@property(nonatomic, copy) NSString<Optional> *give_name;     //下单人
@property(nonatomic, copy) NSString<Optional> *user_addr;     //用户地址
@property(nonatomic, copy) NSString<Optional> *big_fac;       //大表厂商代码
@property(nonatomic, copy) NSString<Optional> *small_fac;     //小表厂商代码
@property(nonatomic, copy) NSString<Optional> *spotCondition; //现场状况*/

@end
