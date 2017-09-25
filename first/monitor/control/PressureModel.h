//
//  PressureModel.h
//  first
//
//  Created by panerly on 14/09/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import "JSONModel.h"

@interface PressureModel : JSONModel

@property (nonatomic, strong) NSString *collect_date;
@property (nonatomic, strong) NSString *pressure_data;

@end
