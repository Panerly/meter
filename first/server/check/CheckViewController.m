//
//  CheckViewController.m
//  first
//
//  Created by panerly on 26/09/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import "CheckViewController.h"
#import "CheckModel.h"
#import "CheckTableViewCell.h"
#import "CheckDetailVC.h"
#import "TableViewAnimationKitHeaders.h"
#import <CoreLocation/CoreLocation.h>
@interface CheckViewController ()

<
UITableViewDelegate,
UITableViewDataSource,
UISearchResultsUpdating,
UISearchBarDelegate,
UINavigationControllerDelegate,
MycellDelegate
>
{
    UIImageView *loading;
}
//创建搜索栏
@property (nonatomic, strong) UISearchController *searchController;

@property(nonatomic,retain)NSMutableArray *searchResults;//接收数据源结果

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic,retain)NSMutableArray *dataArr;

@end

@implementation CheckViewController


- (void)setSearchResults:(NSMutableArray *)searchResults {
    
    _searchResults = searchResults;
    _searchResults = [NSMutableArray array];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setBG];
    
    [self initTableView];
    
    _dataArr = [NSMutableArray array];
}

//修改导航栏颜色
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor    = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_home_bg.png"]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self _requestTask];
}

- (void)setBG {
    
    self.title = @"复核数据";
//    NSArray *familyNames = [UIFont familyNames];
//    for( NSString *familyName in familyNames )
//    {
//        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
//        for( NSString *fontName in fontNames )
//        {
//            printf( "\tFont: %s \n", [fontName UTF8String] );
//        }
//    }
//    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"am" size:18],NSFontAttributeName, nil];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_home_bg.png"]];
}

- (void)initTableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, PanScreenHeight) style:UITableViewStylePlain];
    
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle  = NO;
    
    [_tableView setExclusiveTouch:YES];
    
    _tableView.delegate   = self;
    _tableView.dataSource = self;
    
    
    _tableView.mj_header                            = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(_requestTask)];
    _tableView.mj_header.automaticallyChangeAlpha   = YES;
    _tableView.keyboardDismissMode                  = UIScrollViewKeyboardDismissModeOnDrag;
    
    //调用初始化searchController
    self.searchController                                       = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.frame                       = CGRectMake(0, 0, 0, 44);
    self.searchController.dimsBackgroundDuringPresentation      = NO;
    self.searchController.hidesNavigationBarDuringPresentation  = YES;
//        self.searchController.searchBar.barTintColor                = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_home_bg.png"]];
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.searchController.searchBar.placeholder                 = @"搜索";
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    UITextField*searchField = [self.searchController.searchBar valueForKey:@"_searchField"];
    
    //改变searcher的textcolor
    
    searchField.textColor=[UIColor whiteColor];
    
    //改变placeholder的颜色
    
    [searchField setValue:[UIColor lightGrayColor]forKeyPath:@"_placeholderLabel.textColor"];
    
    self.searchController.searchBar.delegate    = self;
    self.searchController.searchResultsUpdater  = self;
    //搜索栏表头视图
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];
    
    [_tableView registerNib:[UINib nibWithNibName:@"CheckTableViewCell" bundle:nil] forCellReuseIdentifier:@"checkID"];
    [self.view addSubview:_tableView];
}

//获取复核任务列表
- (void)_requestTask {
    
    //刷新控件
    loading        = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    loading.center = self.view.center;
    UIImage *image = [UIImage sd_animatedGIFNamed:@"刷新5"];
    [loading setImage:image];
    [self.view addSubview:loading];
    
    NSString *ip;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] isEqualToString:@"001"]) {
        
        ip = @"58.211.253.180:8000";
    }else{
        
        ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ip"];
    }
    
    NSString *url                  = [NSString stringWithFormat:@"http://%@/Meter_Reading/MeterInfoServlet",ip];
    
    NSURLSessionConfiguration *config   = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager       = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    manager.requestSerializer.timeoutInterval = 10;
    
    NSDictionary *parameters = @{
                                 @"loginID":[[NSUserDefaults standardUserDefaults] objectForKey:@"loginID"],
                                 @"i_markingmode":@"3"
                                 };

    AFHTTPResponseSerializer *serializer    = manager.responseSerializer;
    
    serializer.acceptableContentTypes       = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf            = self;
    
    NSURLSessionTask *task =[manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [loading removeFromSuperview];
        if (responseObject) {
            
            [_tableView.mj_header endRefreshing];
            [_dataArr removeAllObjects];
            
            for (NSDictionary *dic in responseObject) {
                
                NSError *error = nil;
                
                CheckModel *model = [[CheckModel alloc] initWithDictionary:dic error:&error];
                
                [self.dataArr addObject:model];
                
            }
            
            [weakSelf.tableView reloadData];
            [weakSelf starAnimationWithTableView:weakSelf.tableView];
            
        }else {
            
            [_tableView.mj_header endRefreshing];
            UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"提示" message:@"暂无数据" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertVC addAction:action];
            [weakSelf presentViewController:alertVC animated:YES completion:^{
                
            }];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //        [SVProgressHUD showErrorWithStatus:@"加载失败"];
        [loading removeFromSuperview];
        [_tableView.mj_header endRefreshing];
        UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"连接失败" message:[NSString stringWithFormat:@"%@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
        
    }];
    
    [task resume];
}

#pragma mark - tableview delegate & datasource
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //scrollView已经有拖拽手势，直接拿到scrollView的拖拽手势
    UIPanGestureRecognizer *pan = scrollView.panGestureRecognizer;
    //获取到拖拽的速度 >0 向下拖动 <0 向上拖动
    CGFloat velocity = [pan velocityInView:scrollView].y;
    
    if (velocity <- 5) {
        //向上拖动，隐藏导航栏
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }else if (velocity > 5) {
        //向下拖动，显示导航栏
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }else if(velocity == 0){
        //停止拖拽
    }
    [self.searchController.searchBar resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return (!self.searchController.active)?self.dataArr.count : self.searchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CheckTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkID" forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CheckTableViewCell" owner:self options:nil] lastObject];
    }
    cell.checkModel = (!self.searchController.active)?_dataArr[indexPath.row] : self.searchResults[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessibilityNavigationStyle = UIAccessibilityNavigationStyleSeparate;
    cell.delegate = self; 
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    /*
     @property (nonatomic, strong) NSString *averageNumStr;
     @property (nonatomic, strong) NSString *previousNumStr;
     @property (nonatomic, strong) NSString *bshTextStr;
     @property (nonatomic, strong) NSString *userNumStr;
     @property (nonatomic, strong) NSString *meterInfoStr;
     @property (nonatomic, strong) NSString *userAddrStr;
     @property (nonatomic, strong) NSString *mterConditionStr;
     
     
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
     */
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    CheckDetailVC *checkDetail = [[CheckDetailVC alloc] init];
    checkDetail.averageNumStr = ((CheckModel *)_dataArr[indexPath.row]).i_ShuiLiang_pingjun;
    checkDetail.previousNumStr = ((CheckModel *)_dataArr[indexPath.row]).i_ChaoMa_SC;
    checkDetail.bshTextStr = ((CheckModel *)_dataArr[indexPath.row]).i_ChaoBiaoID;
    checkDetail.userNumStr = ((CheckModel *)_dataArr[indexPath.row]).s_CID;
    checkDetail.meterInfoStr = [NSString stringWithFormat:@"钢印号:%@ 表分类:%@",((CheckModel *)_dataArr[indexPath.row]).s_ShuiBiaoGYH, ((CheckModel *)_dataArr[indexPath.row]).i_BiaoFenLei];
    checkDetail.userAddrStr = ((CheckModel *)_dataArr[indexPath.row]).s_DiZhi;
    
    [self.navigationController showViewController:checkDetail sender:nil];
}

#pragma mark - 代理事件
//跳转到下一界面并传值
-(void)didClickButton:(UIButton *)button X:(NSString *)x Y:(NSString *)y;
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择导航方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *baidu = [UIAlertAction actionWithTitle:@"高德导航" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self openGaoDeMapX:x Y:y];
    }];
    UIAlertAction *apple = [UIAlertAction actionWithTitle:@"苹果自带导航" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self openAppleMapX:x Y:y];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:baidu];
    [alert addAction:apple];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}


#pragma mark - open navigator
////打开百度地图导航
//- (void)openBaiDuMapX:(NSString *)x Y:(NSString *)y{
//
//    NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin=latlng:%f,%f|name:我的位置&destination=latlng:%f,%f|name:终点&mode=driving",currentLatitude, currentLongitude,[x floatValue],[y floatValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
//
//    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
//
//}

//打开高德地图导航
- (void)openGaoDeMapX:(NSString *)x Y:(NSString *)y{
    
    //将百度坐标转换成高德坐标
    CLLocationCoordinate2D location;
    location.longitude = [x floatValue];
    location.latitude = [y floatValue];
    CLLocationCoordinate2D convertLocation = [self bd09ToWgs84:location];
    
    NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&poiname=%@&lat=%f&lon=%f&dev=1&style=2",@"app name", @"YGche", @"终点", convertLocation.latitude,convertLocation.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];

}
//打开苹果自带地图导航

- (void)openAppleMapX:(NSString *)x Y:(NSString *)y{
    //将百度坐标转换成高德坐标
    CLLocationCoordinate2D location;
    location.longitude = [x floatValue];
    location.latitude = [y floatValue];
    CLLocationCoordinate2D convertLocation = [self bd09ToWgs84:location];
    
    //检测定位功能是否开启
            if([CLLocationManager locationServicesEnabled]){
//                CLLocationCoordinate2D loc = CLLocationCoordinate2DMake([self.checkModel.n_GPS_N integerValue], [self.checkModel.n_GPS_E integerValue]);
                MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
                MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:convertLocation addressDictionary:nil]];
                [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                               launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                               MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    
            }else{
    
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"定位信息" message:@"您没有开启定位功能" preferredStyle:UIAlertControllerStyleAlert];
    
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    
                }];
    
                [alertVC addAction:action];
                [self presentViewController:alertVC animated:YES completion:^{
                    
                }];
            }
//    //起点
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

}

- (void)starAnimationWithTableView:(UITableView *)tableView {
    
    [TableViewAnimationKit showWithAnimationType:0 tableView:tableView];
}
#pragma mark - searchController delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    self.searchResults= [NSMutableArray array];
    [self.searchResults removeAllObjects];
    
    //NSPredicate 谓词
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@",searchController.searchBar.text];
    
    NSMutableArray *arr     = [NSMutableArray array];
    NSMutableArray *arr2    = [NSMutableArray array];
    [arr2 removeAllObjects];
    
    for (CheckModel *checkModel in self.dataArr) {
        
        [arr addObject:checkModel.s_DiZhi];
    }
    arr2 = [[arr filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    
    for (CheckModel *checkModel in self.dataArr) {
        
        if ([arr2 containsObject:checkModel.s_DiZhi]) {
            
            [self.searchResults addObject:checkModel];
        }
    }
    //刷新表格
    [self.tableView reloadData];
}


//移除搜索栏
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.searchController.active) {
        
        self.searchController.active = NO;
        [self.searchController.searchBar removeFromSuperview];
    }
}

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    if (self.view.window == nil && [self isViewLoaded]) {
//        self.view = nil;
//    }
//}

#pragma mark - LocationConvert baidu to gaode
- (CLLocationCoordinate2D)bd09ToWgs84:(CLLocationCoordinate2D)location
{
    CLLocationCoordinate2D gcj02 = [self bd09ToGcj02:location];
    return [self gcj02Decrypt:gcj02.latitude gjLon:gcj02.longitude];
}
- (CLLocationCoordinate2D)bd09ToGcj02:(CLLocationCoordinate2D)location
{
    return [self bd09Decrypt:location.latitude bdLon:location.longitude];
}

- (CLLocationCoordinate2D)gcj02Decrypt:(double)gjLat gjLon:(double)gjLon {
    CLLocationCoordinate2D  gPt = [self gcj02Encrypt:gjLat bdLon:gjLon];
    double dLon = gPt.longitude - gjLon;
    double dLat = gPt.latitude - gjLat;
    CLLocationCoordinate2D pt;
    pt.latitude = gjLat - dLat;
    pt.longitude = gjLon - dLon;
    return pt;
}
- (CLLocationCoordinate2D)bd09Decrypt:(double)bdLat bdLon:(double)bdLon
{
    CLLocationCoordinate2D gcjPt;
    double x = bdLon - 0.0065, y = bdLat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * M_PI);
    double theta = atan2(y, x) - 0.000003 * cos(x * M_PI);
    gcjPt.longitude = z * cos(theta);
    gcjPt.latitude = z * sin(theta);
    return gcjPt;
}

- (CLLocationCoordinate2D)gcj02Encrypt:(double)ggLat bdLon:(double)ggLon
{
    CLLocationCoordinate2D resPoint;
    double mgLat;
    double mgLon;
    if ([self outOfChina:ggLat bdLon:ggLon]) {
         resPoint.latitude = ggLat;
        resPoint.longitude = ggLon;
        return resPoint;
    }
    double dLat = [self transformLat:(ggLon - 105.0)bdLon:(ggLat - 35.0)];
    double dLon = [self transformLon:(ggLon - 105.0) bdLon:(ggLat - 35.0)];
    double radLat = ggLat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - jzEE * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((jzA * (1 - jzEE)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (jzA / sqrtMagic * cos(radLat) * M_PI);
    mgLat = ggLat + dLat;
    mgLon = ggLon + dLon;
    resPoint.latitude = mgLat;
    resPoint.longitude = mgLon;
    return resPoint;
}
- (BOOL)outOfChina:(double)lat bdLon:(double)lon
{
    if (lon < RANGE_LON_MIN || lon > RANGE_LON_MAX)
        return true;
    if (lat < RANGE_LAT_MIN || lat > RANGE_LAT_MAX)
          return true;
    return false;
}
- (double)transformLat:(double)x bdLon:(double)y
{
    double ret = LAT_OFFSET_0(x, y);
    ret += LAT_OFFSET_1;
    ret += LAT_OFFSET_2;
    ret += LAT_OFFSET_3;
    return ret;
}

- (double)transformLon:(double)x bdLon:(double)y
{
    double ret = LON_OFFSET_0(x, y);
    ret += LON_OFFSET_1;
    ret += LON_OFFSET_2;
    ret += LON_OFFSET_3;
    return ret;
}
//-(CLLocationCoordinate2D)bd09Encrypt:(double)ggLat bdLon:(double)ggLon
//{
//    CLLocationCoordinate2D bdPt;
//    double x = ggLon, y = ggLat;
//    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * M_PI);
//    double theta = atan2(y, x) + 0.000003 * cos(x * M_PI);
//    bdPt.longitude = z * cos(theta) + 0.0065;
//    bdPt.latitude = z * sin(theta) + 0.006;
//    return bdPt;
//}

#pragma mark - searchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    UIButton *btn=[searchBar valueForKey:@"_cancelButton"];
    [btn setTitle:cancelTitle forState:UIControlStateNormal];
}


- (void)dealloc
{
    [self.navigationController setDelegate:nil];
}


@end
