//
//  PresureViewController.h
//  first
//
//  Created by panerly on 13/09/2017.
//  Copyright © 2017 HS. All rights reserved.
//
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,SecondeViewControllerChartType) {
    SecondeViewControllerChartTypeColumn =0,
    SecondeViewControllerChartTypeBar,
    SecondeViewControllerChartTypeArea,
    SecondeViewControllerChartTypeAreaspline,
    SecondeViewControllerChartTypeLine,
    SecondeViewControllerChartTypeSpline,
    SecondeViewControllerChartTypeScatter,
};


@interface PressureViewController : UIViewController


@property (nonatomic, assign) SecondeViewControllerChartType chartType;
@property (nonatomic, copy  ) NSString  *receivedChartType;
@property (nonatomic, copy  ) NSString  *meter_id;

@end
