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
    
    self.userAddr.text = self.checkModel.s_DiZhi;
}
- (IBAction)naviAction:(id)sender {
    
    [self.delegate didClickButton:sender X:self.checkModel.n_GPS_E Y:self.checkModel.n_GPS_N];
}
//- (UIViewController *)findVC
//{
//    UIResponder *next = self.nextResponder;
//    
//    while (1) {
//        
//        if ([next isKindOfClass:[UIViewController class]]) {
//            return  (UIViewController *)next;
//        }
//        next =  next.nextResponder;
//    }
//    return nil;
//}


//- (CLLocation *)AMapLocationFromBaiduLocation:(CLLocation *)BaiduLocation;
//{
//    const double x_pi = M_PI * 3000.0 / 180.0;
//    double x = BaiduLocation.coordinate.longitude - 0.0065, y = BaiduLocation.coordinate.latitude - 0.006;
//    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
//    double theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
//    double AMapLongitude = z * cos(theta);
//    double AMapLatitude = z * sin(theta);
//    CLLocation *AMapLocation = [[CLLocation alloc] initWithLatitude:AMapLatitude longitude:AMapLongitude];
//    
//    return AMapLocation;
//}
////打开百度地图导航
//- (void)openBaiDuMap{
//    
//    NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin=latlng:%f,%f|name:我的位置&destination=latlng:%f,%f|name:终点&mode=driving",currentLatitude, currentLongitude,_shopLat,_shopLon] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
//    
//    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
//    
//}
//
//
//
//
////打开高德地图导航
//
//- (void)openGaoDeMap{
//    
//    NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&poiname=%@&lat=%f&lon=%f&dev=1&style=2",@"app name", @"YGche", @"终点", _shopLat, _shopLon] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
//    
//}
//
//
//
////打开苹果自带地图导航
//
//- (void)openAppleMap{
//    
//    //起点
//    
//    CLLocationCoordinate2D coords1 = CLLocationCoordinate2DMake(currentLatitude,currentLongitude);
//    
//    MKMapItem *currentLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coords1 addressDictionary:nil]];
//    
//    //目的地的位置
//    
//    CLLocationCoordinate2D coords2 = CLLocationCoordinate2DMake(_shopLat,_shopLon);
//    
//    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coords2 addressDictionary:nil]];
//    
//    toLocation.name =address;
//    
//    NSArray *items = [NSArray arrayWithObjects:currentLocation, toLocation, nil];
//    
//    NSDictionary *options = @{ MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsMapTypeKey: [NSNumber numberWithInteger:MKMapTypeStandard], MKLaunchOptionsShowsTrafficKey:@YES };
//    
//    //打开苹果自身地图应用，并呈现特定的item
//    
//    [MKMapItem openMapsWithItems:items launchOptions:options];
//    
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
