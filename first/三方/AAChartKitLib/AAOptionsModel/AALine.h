//
//  AALine.h
//  AAChartKit
//
//  Created by An An on 17/1/6.
//  Copyright © 2017年 An An. All rights reserved.
//  source code ----*** https://github.com/AAChartModel/AAChartKit ***--- source code
//

#import <Foundation/Foundation.h>

@class AADataLabels;

@interface AALine : NSObject

AAPropStatementAndFuncStatement(strong, AALine, NSNumber *, lineWidth);//设置折线的宽度
AAPropStatementAndFuncStatement(strong, AALine, AADataLabels *, dataLabels);
//AAPropStatementAndFuncStatement(assign, AALine, BOOL, enableMouseTracking);
//AAPropStatementAndFuncStatement(copy,   AALine, NSString *, dashStyle);//折线的样式类型(字符串枚举)

@end
