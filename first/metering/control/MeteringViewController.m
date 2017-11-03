//
//  MeteringViewController.m
//  first
//
//  Created by HS on 16/5/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "MeteringViewController.h"
#import "MeteringSingleViewController.h"
#import "SingleViewController.h"

#import "MeterInfoModel.h"
#import "MeterInfoTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
//自定义tableview
#import "ContextMenuCell.h"
#import "YALContextMenuTableView.h"

#import "LocaDBViewController.h"
#import "CompleteViewController.h"
#import "FTPopOverMenu.h"

#import "ScanImageViewController.h"
#import "SJViewController.h"


//static const char *kScanQRCodeQueueName = "ScanQRCodeQueue";
static NSString *const menuCellIdentifier = @"rotationCell";

@interface MeteringViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
AVCaptureMetadataOutputObjectsDelegate,
YALContextMenuTableViewDelegate,
UISearchResultsUpdating,
UISearchBarDelegate,
MetercellDelegate
>
{
    //判断是大表还是小表
    BOOL isBigMeter;
    UIImageView *loading;
    NSString *cellID;
    //扫描确认btn
    UIButton *scanBtn;
    //弹窗用的tableview，与界面重复，避免加载数据源混乱用BOOL区分
    BOOL isTap;
    NSURLSessionTask *task;
    AFNetworkReachabilityStatus netStatus;
    UISegmentedControl *segmentedCtl;
}
@property (nonatomic, assign) NSInteger num;

@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) BOOL lastResult;

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong) YALContextMenuTableView* contextMenuTableView;

@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) NSArray *menuIcons;

@property (nonatomic, strong) FMDatabase *db;


//创建搜索栏
@property (nonatomic, strong) UISearchController *searchController;

@property(nonatomic,retain)NSMutableArray *searchResults;//接收数据源结果


@end

//判断手电开启
static BOOL flashIsOn;

@implementation MeteringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavColor];
    
    flashIsOn   = YES;
    isBigMeter  = YES;
    isTap       = NO;
    _num        = 5;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [button addTarget:self action:@selector(QRcode) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"icon_qrcode@3x"] forState:UIControlStateNormal];
    UIBarButtonItem *scan                   = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem   = scan;
    
    
    UIBarButtonItem *more = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_more@2x"] style:UIBarButtonItemStylePlain target:self action:@selector(presentMenuButtonTapped)];
    self.navigationItem.rightBarButtonItem = more;
    
    [self initiateMenuOptions];
    
    
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_bg.png"]];
    
    [self _createTableView];
    
    [self loadInterNetData];
    
    [self setSegmentedCtl];
}
/**
 *  设置导航栏的颜色，返回按钮和标题为白色
 */
-(void)setNavColor{
    
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
//    self.navigationController.navigationBar.barTintColor = COLORRGB(226, 107, 16);
    self.navigationController.navigationBar.barTintColor = navigateColor;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

//大小表控制
- (void)setSegmentedCtl {
    segmentedCtl            = [[UISegmentedControl alloc] initWithItems:@[@"小表抄收",@"大表抄收"]];
    segmentedCtl.frame      = CGRectMake(0, 0, PanScreenWidth/3, 30);
    segmentedCtl.tintColor  = [UIColor whiteColor];
    segmentedCtl.selectedSegmentIndex = 0;
    [segmentedCtl addTarget:self action:@selector(meterTypecOntrol:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentedCtl;
    segmentedCtl.selectedSegmentIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!isBigMeter) {
        [self loadBigMeterLocalData];
    }
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    if ([db open]) {
        
        FMResultSet *restultSet = [db executeQuery:@"select * from Reading_now"];
        int litMeterCountNum = 0;
        int bigMeterCountNum = 0;
        while ([restultSet next]) {
            if (![[restultSet stringForColumn:@"s_bookNo"] isEqualToString:@"00"]) {
                litMeterCountNum++;
            }
            if ([[restultSet stringForColumn:@"s_bookNo"] isEqualToString:@"00"]) {
                bigMeterCountNum++;
            }
        }
        if (litMeterCountNum + bigMeterCountNum > 0) {
            
            //            self.tabBarItem.badgeColor = [UIColor redColor];
            self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",litMeterCountNum+bigMeterCountNum];
        }else{
            
            self.tabBarItem.badgeValue = nil;
        }
    }
    [db close];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self createDB];
    if ([self.db open]) {
        
        FMResultSet *restultSet = [self.db executeQuery:@"SELECT * FROM Area_data where s_bookNo is not '00' order by id"];
        if (_dataArr) {
            
            [_dataArr removeAllObjects];
        }else {
            
            _dataArr = [NSMutableArray array];
            [_dataArr removeAllObjects];
        }
        
        while ([restultSet next]) {
            
            NSString *install_addr     = [restultSet stringForColumn:@"s_bookName"];
            NSString *s_bookNo         = [restultSet stringForColumn:@"s_bookNo"];
            
            MeterInfoModel *meterinfoModel  = [[MeterInfoModel alloc] init];
            meterinfoModel.s_DiZhi     = install_addr;
            meterinfoModel.s_bookNo    = s_bookNo;
            [_dataArr addObject:meterinfoModel];
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.db close];
    [self.tableView.mj_header endRefreshing];
}

/**
 *  监测网络连接请求 网络 或 本地 数据
 */
- (void)loadInterNetData {
    
    __weak typeof(self) weakSelf = self;
    //检测网络
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        netStatus = status;
        if (status == AFNetworkReachabilityStatusNotReachable) {
            [SVProgressHUD showInfoWithStatus:@"似乎已断开与互联网的连接" maskType:SVProgressHUDMaskTypeGradient];
            [self createDB];
            if ([self.db open]) {
                FMResultSet *restultSet = [self.db executeQuery:@"SELECT * FROM Area_data where s_bookNo is not '00' order by id"];
                if (_dataArr) {
                    [_dataArr removeAllObjects];
                }else {
                    _dataArr = [NSMutableArray array];
                    [_dataArr removeAllObjects];
                }
                
                while ([restultSet next]) {
                    NSString *install_addr  = [restultSet stringForColumn:@"s_bookName"];
                    NSString *s_bookNo      = [restultSet stringForColumn:@"s_bookNo"];
                    
                    MeterInfoModel *meterinfoModel = [[MeterInfoModel alloc] init];
                    meterinfoModel.s_DiZhi    = install_addr;
                    meterinfoModel.s_bookNo   = s_bookNo;
                    [_dataArr addObject:meterinfoModel];
                }
                
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
            [weakSelf.db close];
            [weakSelf.tableView.mj_header endRefreshing];
            
        } else {
            
            //请求区域信息
            [weakSelf requestAreaData];
            //请求所有数据
            [weakSelf _requestData];
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}


///**
// *  加载小表列表数据(网络)
// */
//- (void)loadLitMeterData {
//    
//    //刷新控件
//    if (!loading) {
//        loading        = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
//        loading.center = self.view.center;
//        UIImage *image = [UIImage sd_animatedGIFNamed:@"刷新5"];
//        [loading setImage:image];
//        [self.view addSubview:loading];
//    }
//    
//    if (_tableView.mj_header.isRefreshing) {
//        [loading removeFromSuperview];
//    }
//    
//    NSString *ipStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"ip"]?[[NSUserDefaults standardUserDefaults] objectForKey:@"ip"]:@"58.211.253.180:8000";
//    
//    NSString *litMeterDataUrl                 = [NSString stringWithFormat:@"http://%@/Meter_Reading/Meter_areaServlet",ipStr];
//    
//    NSURLSessionConfiguration *config         = [NSURLSessionConfiguration defaultSessionConfiguration];
//    
//    AFHTTPSessionManager *manager             = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
//    
//    AFHTTPResponseSerializer *serializer      = manager.responseSerializer;
//    
//    manager.requestSerializer.timeoutInterval = 8;
//    
//    serializer.acceptableContentTypes         = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
//    
//    __weak typeof(self) weakSelf              = self;
//    
//    NSURLSessionTask *litMeterTask = [manager POST:litMeterDataUrl parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//        
//        _dataArr = [NSMutableArray array];
//        [_dataArr removeAllObjects];
//        
//        NSError *error;
//        
//        if (responseObject) {
//            
//            [loading removeFromSuperview];
//            
//            for (NSDictionary *dic in responseObject) {
//                if (![[dic objectForKey:@"area_Id"] isEqualToString:@"00"]) {
//                    
//                    MeterInfoModel *meterInfoModel = [[MeterInfoModel alloc] initWithDictionary:dic error:&error];
//                    [_dataArr addObject:meterInfoModel];
//                }
//                
//                if ([weakSelf.db open]) {
//                    
//                    [weakSelf.db executeUpdate:@"create table if not exists Meter_area (id integer primary key autoincrement,  area_Name text null);"];
//                    [weakSelf.db executeUpdate:@"replace into Meter_area (id, area_Name) values (?,?)",[dic objectForKey:@"s_bookNo"], [dic objectForKey:@"s_bookName"]];
//                    
//                }
//                [weakSelf.db close];
//            }
//            
//            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//        }
//        if (!isBigMeter) {
//            [self loadBigMeterLocalData];
//        }
//        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
//        NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
//        FMDatabase *db = [FMDatabase databaseWithPath:fileName];
//        if ([db open]) {
//            
//            FMResultSet *restultSet = [db executeQuery:@"select * from litMeter_info"];
//            int litMeterCountNum    = 0;
//            int bigMeterCountNum    = 0;
//            while ([restultSet next]) {
//                if (![[restultSet stringForColumn:@"collector_area"] isEqualToString:@"00"]) {
//                    litMeterCountNum++;
//                }
//                if ([[restultSet stringForColumn:@"collector_area"] isEqualToString:@"00"]) {
//                    bigMeterCountNum++;
//                }
//            }
//            if (litMeterCountNum + bigMeterCountNum > 0) {
//                
//                self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",litMeterCountNum+bigMeterCountNum];
//            }else{
//                
//                self.tabBarItem.badgeValue = nil;
//            }
//        }
//        [db close];
//        [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        
//        NSLog(@"小表数据查询失败：%@",error);
//        [loading removeFromSuperview];
//    }];
//    [litMeterTask resume];
//}



/**
 *  视图消失停止请求任务
 *
 */
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (task.state == MJRefreshStateRefreshing) {
        [task cancel];
    }
    if (self.searchController.active) {
        self.searchController.active = NO;
        [self.searchController.searchBar removeFromSuperview];
    }
}

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


//- (void)share{
//    UIImage *image = [UIImage imageNamed:@"bg_server.jpg"];
//    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
//    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//
//    id<ISSCAttachment> localAttachment = [ShareSDKCoreService attachmentWithPath:encodedImageStr];
//    //1.2、以下参数分别对应：内容、默认内容、图片、标题、链接、描述、分享类型
//    id<ISSContent> publishContent = [ShareSDK content:@"分享测试"
//                                       defaultContent:nil
//                                                image:localAttachment
//                                                title:@"测试标题"
//                                                  url:@"http://www.hzsb.com"
//                                          description:nil
//                                            mediaType:SSPublishContentMediaTypeImage];
//
//
//    //1+、创建弹出菜单容器（iPad应用必要，iPhone应用非必要）
//    id<ISSContainer> container = [ShareSDK container];
//    [container setIPadContainerWithView:nil
//                            arrowDirect:UIPopoverArrowDirectionUp];
//    //2、展现分享菜单
//    [ShareSDK showShareActionSheet:container
//                         shareList:nil
//                           content:publishContent
//                     statusBarTips:NO
//                       authOptions:nil
//                      shareOptions:nil
//                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
//
//                                NSLog(@"=== response state :%zi ",state);
//
//                                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
//                                //可以根据回调提示用户。
//                                if (state == SSResponseStateSuccess)
//                                {
//                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"分享成功!" preferredStyle:UIAlertControllerStyleAlert];
//                                    [alert addAction:action];
//                                    [self presentViewController:alert animated:YES completion:nil];
//
//                                }
//                                else if (state == SSResponseStateFail) {
//
//                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"失败" message:[NSString stringWithFormat:@"Error Description：%@",[error errorDescription]] preferredStyle:UIAlertControllerStyleAlert];
//                                    [alert addAction:action];
//                                    [self presentViewController:alert animated:YES completion:nil];
//                                }
//                            }];
//
//
//}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)_createTableView
{
    cellID = @"meterInfoID";
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, PanScreenHeight) style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        _tableView.backgroundColor      = [UIColor clearColor];
        self.tableView.delegate         = self;
        self.tableView.dataSource       = self;
        self.tableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor  = [UIColor clearColor];
        _tableView.keyboardDismissMode  = UIScrollViewKeyboardDismissModeOnDrag;
        
        [_tableView registerNib:[UINib nibWithNibName:@"MeterInfoTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
        
        [_tableView setExclusiveTouch:YES];
        
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadInterNetData)];
        _tableView.mj_header.automaticallyChangeAlpha = YES;
        
        //调用初始化searchController
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.searchController.searchBar.frame                       = CGRectMake(0, 0, 0, 44);
        self.searchController.dimsBackgroundDuringPresentation      = NO;
        self.searchController.hidesNavigationBarDuringPresentation  = NO;
//        self.searchController.searchBar.barTintColor                = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_bg.png"]];
        self.searchController.searchBar.placeholder                 = @"搜索";
        self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        
        self.searchController.searchBar.delegate    = self;
        self.searchController.searchResultsUpdater  = self;
        //搜索栏表头视图
        self.tableView.tableHeaderView = self.searchController.searchBar;
        [self.searchController.searchBar sizeToFit];
    }
    
    if (!self.contextMenuTableView) {
        
        self.contextMenuTableView                   = [[YALContextMenuTableView alloc]initWithTableViewDelegateDataSource:self];
        self.contextMenuTableView.scrollEnabled     = NO;
        self.contextMenuTableView.animationDuration = 0.1;
        self.contextMenuTableView.yalDelegate       = self;
        self.contextMenuTableView.menuItemsSide     = Right;
        self.contextMenuTableView.menuItemsAppearanceDirection = FromTopToBottom;
        
        //register nib
        [self.contextMenuTableView registerNib:[UINib nibWithNibName:@"ContextMenuCell" bundle:nil] forCellReuseIdentifier:menuCellIdentifier];
        
    }
}

//初始化加载storyboard
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self = [[UIStoryboard storyboardWithName:@"Metering" bundle:nil] instantiateViewControllerWithIdentifier:@"Metering"];
    }
    return self;
}


/**
 *  大小表切换
 *
 */
- (IBAction)meterTypecOntrol:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0://小表
            isBigMeter = YES;
            [self loadLitMeterLocalData];
            
            break;
        case 1://大表
            isBigMeter = NO;
            [self.dataArr removeAllObjects];
            [self loadBigMeterLocalData];
        default:
            break;
    }
    
}

//请求小表本地数据
- (void)loadLitMeterLocalData {
    
    [self createDB];
    if ([self.db open]) {
        
        FMResultSet *restultSet = [self.db executeQuery:@"SELECT * FROM Area_data where s_bookNo is not '00' order by id"];
        if (_dataArr) {
            
            [_dataArr removeAllObjects];
        }else {
            
            _dataArr = [NSMutableArray array];
            [_dataArr removeAllObjects];
        }
        
        while ([restultSet next]) {
            
            NSString *install_addr          = [restultSet stringForColumn:@"s_bookName"];
            NSString *s_bookNo         = [restultSet stringForColumn:@"s_bookNo"];
            
            MeterInfoModel *meterinfoModel  = [[MeterInfoModel alloc] init];
            meterinfoModel.s_DiZhi     = install_addr;
            meterinfoModel.s_bookNo    = s_bookNo;
            [_dataArr addObject:meterinfoModel];
        }
        if (_dataArr.count>0) {
            
        }else{
           
            [self _requestData];
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.db close];
    [self.tableView.mj_header endRefreshing];
}

//加载大表本地数据
- (void)loadBigMeterLocalData {
    
    [self createDB];
    if ([self.db open]) {
        
        FMResultSet *restultSet = [self.db executeQuery:@"SELECT * FROM Reading_now where s_bookNo = '00' order by id"];
        if (_dataArr) {
            
            [_dataArr removeAllObjects];
        }else {
            
            _dataArr = [NSMutableArray array];
            [_dataArr removeAllObjects];
        }
        
        while ([restultSet next]) {
            
            NSString *install_addr     = [restultSet stringForColumn:@"s_DiZhi"];
            NSString *s_bookNo         = [restultSet stringForColumn:@"s_bookNo"];
            
            MeterInfoModel *meterinfoModel = [[MeterInfoModel alloc] init];
            meterinfoModel.s_DiZhi    = install_addr;
            meterinfoModel.s_bookNo   = s_bookNo;
            [_dataArr addObject:meterinfoModel];
        }
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.db close];
    [self.tableView.mj_header endRefreshing];
}

#pragma mark-请求所有数据（大小表）
//请求列表信息
- (void)_requestData {
    //刷新控件
    if (!loading) {
        
        loading         = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        loading.center  = self.view.center;
        UIImage *image  = [UIImage sd_animatedGIFNamed:@"刷新5"];
        [loading setImage:image];
        [self.view addSubview:loading];
    }
    
    if (_tableView.mj_header.isRefreshing) {
        [loading removeFromSuperview];
    }

    NSString *ip;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] isEqualToString:@"001"]) {
        
        ip = @"58.211.253.180:8000";
    }else{
        
        ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ip"];
    }
    
    NSString *url = [NSString stringWithFormat:@"http://%@/Meter_Reading/MeterInfoServlet",ip];
    
    
    NSURLSessionConfiguration *config    = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager        = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    manager.requestSerializer.timeoutInterval = 8;
    
    serializer.acceptableContentTypes         = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf              = self;
    
    
    NSDictionary *parameters = @{
                                 @"loginID":[[NSUserDefaults standardUserDefaults] objectForKey:@"loginID"],
                                 @"i_markingmode":@"1"
                                 };
    
    task =[manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
            [weakSelf.tableView.mj_header endRefreshing];
            
            [weakSelf createDB];
            
            UIAlertAction *conformBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                if ([weakSelf.db open]) {
                    
                    [weakSelf.db executeUpdate:@"delete from Reading_now"];
                }
                
                int litMeterCount = 0;
                int bigMeterCount = 0;
                for (NSDictionary *dic in responseObject) {
                    
                    if (![[dic objectForKey:@"s_bookNo"] isEqualToString:@"00"]) {
                        litMeterCount++;
                    }
                    if ([[dic objectForKey:@"s_bookNo"] isEqualToString:@"00"]) {
                        bigMeterCount++;
                    }
                    
                    if ([weakSelf.db open]) {
                        
                        [weakSelf.db executeUpdate:@"insert into Reading_now (bs, s_bookName, i_caliber, s_bookNo, i_no, i_ChaoBiaoID, s_CID, i_BiaoZhuangTai, i_priceTag, i_SFFS, I_KeHuLeiBie, i_BiaoFenLei, i_RenKouShu, N_GPS_E, N_GPS_N, s_HuMing, s_DiZhi, s_BiaoWei, s_ShuiBiaoGYH, d_ChaoBiao_SC, i_ChaoMa_SC, i_ShuiLiang_pingjun) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",[dic objectForKey:@"bs"], [dic objectForKey:@"s_bookName"], [dic objectForKey:@"i_caliber"], [dic objectForKey:@"s_bookNo"], [dic objectForKey:@"i_no"], [dic objectForKey:@"i_ChaoBiaoID"], [dic objectForKey:@"s_CID"], [dic objectForKey:@"i_BiaoZhuangTai"], [dic objectForKey:@"i_priceTag"], [dic objectForKey:@"i_SFFS"], [dic objectForKey:@"I_KeHuLeiBie"], [dic objectForKey:@"i_BiaoFenLei"], [dic objectForKey:@"i_RenKouShu"], [dic objectForKey:@"N_GPS_E"], [dic objectForKey:@"N_GPS_N"], [dic objectForKey:@"s_HuMing"], [dic objectForKey:@"s_DiZhi"], [dic objectForKey:@"s_BiaoWei"], [dic objectForKey:@"s_ShuiBiaoGYH"], [dic objectForKey:@"d_ChaoBiao_SC"], [dic objectForKey:@"i_ChaoMa_SC"], [dic objectForKey:@"i_ShuiLiang_pingjun"]];
                    }
                }
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[NSString stringWithFormat:@"%d",litMeterCount] forKey:@"litMeterCount"];
                [defaults setObject:[NSString stringWithFormat:@"%d",bigMeterCount] forKey:@"bigMeterCount"];
                [defaults synchronize];
                if (litMeterCount + bigMeterCount > 0) {
                    
                    weakSelf.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",litMeterCount+bigMeterCount];
                }else{
                    
                    weakSelf.tabBarItem.badgeValue = nil;
                }
                
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.db close];
                
                [loading removeFromSuperview];
            }];
            UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [loading removeFromSuperview];
            }];
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否网络覆盖本地数据？" preferredStyle:UIAlertControllerStyleAlert];
            [alertVC addAction:cancelBtn];
            [alertVC addAction:conformBtn];
            [weakSelf presentViewController:alertVC animated:YES completion:^{
                
            }];
            
        }
        
        [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [weakSelf.tableView.mj_header endRefreshing];
        [loading removeFromSuperview];
        
        NSLog(@"错误信息：%@",error);
        
        UIAlertAction *confir = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        if (error.code == -1001) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请求超时!" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertVC addAction:confir];
            [weakSelf presentViewController:alertVC animated:YES completion:^{
                
            }];
        }
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Tips" message:[NSString stringWithFormat:@"%@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [weakSelf presentViewController:alertVC animated:YES completion:^{
            
        }];
        
    }];
    
    [task resume];
    
}

#pragma mark-请求区域数据

- (void)requestAreaData {
    
    NSString *ip;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] isEqualToString:@"001"]) {
        
        ip = @"58.211.253.180:8000";
    }else{
        
        ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ip"];
    }
    
    NSString *url = [NSString stringWithFormat:@"http://%@/Meter_Reading/Meter_areaServlet",ip];
    
    
    NSURLSessionConfiguration *config    = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager        = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    manager.requestSerializer.timeoutInterval = 8;
    
    serializer.acceptableContentTypes         = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf              = self;
    
    
//    NSDictionary *parameters = @{
//                                 @"loginID":[[NSUserDefaults standardUserDefaults] objectForKey:@"loginID"],
//                                 @"i_markingmode":@"1"
//                                 };
    
    NSURLSessionTask *areaTask =[manager POST:url parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
            [weakSelf.tableView.mj_header endRefreshing];
            self.dataArr = [NSMutableArray array];
            [self.dataArr removeAllObjects];
            [weakSelf createDB];
            
            if ([weakSelf.db open]) {
                
                [weakSelf.db executeUpdate:@"delete from Area_data"];
            }
            
            for (NSDictionary *dic in responseObject) {
                
                
                if ([weakSelf.db open]) {
                    
                    [weakSelf.db executeUpdate:@"insert into Area_data (s_bookNo, s_bookName) values (?,?)",[dic objectForKey:@"s_bookNo"], [dic objectForKey:@"s_bookName"]];
                }
                
                MeterInfoModel *meterinfoModel = [[MeterInfoModel alloc] init];
                meterinfoModel.s_DiZhi  = [dic objectForKey:@"s_bookName"];
                meterinfoModel.s_bookNo = [dic objectForKey:@"s_bookNo"];
                [self.dataArr addObject:meterinfoModel];
            }
            
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [weakSelf.db close];
        }
        
        [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [weakSelf.tableView.mj_header endRefreshing];
        
        NSLog(@"错误信息：%@",error);
        
        UIAlertAction *confir = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        if (error.code == -1001) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请求超时!" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertVC addAction:confir];
            [weakSelf presentViewController:alertVC animated:YES completion:^{
                
            }];
        }
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Tips" message:[NSString stringWithFormat:@"%@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [weakSelf presentViewController:alertVC animated:YES completion:^{
            
        }];
        
    }];
    
    [areaTask resume];
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
}

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

#pragma mark - openQrcode
//开启扫描
- (void)QRcode {
    
    SJViewController *viewController = [[SJViewController alloc] init];
    __weak typeof(self)weakSelf = self;
    /** 扫描成功返回来的数据 */
    viewController.successBlock = ^(NSString *successString) {
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"successBlock=%@",successString);
        
        SingleViewController *singleVC      = [[SingleViewController alloc] init];
        singleVC.meter_id_string            = [weakSelf getInfo:successString];
        singleVC.hidesBottomBarWhenPushed   = YES;
        if ([weakSelf getInfo:successString] == nil) {
            
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"本地库中不存在此户信息！\n请更新本地库或检查条码信息！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertVC addAction:action];
            [weakSelf presentViewController:alertVC animated:YES completion:^{
                
            }];
        }else{
            
            [weakSelf.navigationController showViewController:singleVC sender:nil];
        }
    };
    
    [self presentViewController:viewController animated:YES completion:nil];
    /*
     [SVProgressHUD show];
     
     if (!_scanView) {
     _scanView                   = [[UIView alloc] initWithFrame:self.view.bounds];
     _scanView.center            = self.view.center;
     _scanView.backgroundColor   = [UIColor blackColor];
     _scanView.alpha             = .8;
     [self.navigationController.view addSubview:_scanView];
     }
     
     if (!scanBtn) {
     
     scanBtn = [[UIButton alloc] init];
     }
     [scanBtn setTitle:@"关闭" forState:UIControlStateNormal];
     scanBtn.backgroundColor     = [UIColor redColor];
     scanBtn.clipsToBounds       = YES;
     scanBtn.layer.cornerRadius  = 5;
     [scanBtn addTarget:self action:@selector(conformBtn) forControlEvents:UIControlEventTouchUpInside];
     [_scanView addSubview:scanBtn];
     [scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
     make.size.equalTo(CGSizeMake(80, 30));
     make.centerX.equalTo(_scanView.centerX);
     make.bottom.equalTo(_scanView.bottom).with.offset(-120);
     }];
     
     [self startReading];
     */
    
}

/*
 //关闭窗口
 - (void)conformBtn
 {
 [SVProgressHUD dismiss];
 
 [UIView animateWithDuration:.5 animations:^{
 
 _scanView.transform          = CGAffineTransformMakeScale(.001, .001);
 _videoPreviewLayer.transform = CATransform3DMakeScale(.001, .001, .001);
 
 } completion:^(BOOL finished) {
 
 [_scanView removeFromSuperview];
 [_videoPreviewLayer removeFromSuperlayer];
 
 _videoPreviewLayer  = nil;
 _scanView           = nil;
 
 }];
 }
 
 //开始读取
 - (BOOL)startReading
 {
 // 获取 AVCaptureDevice 实例
 NSError * error;
 AVCaptureDevice *captureDevice  = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
 // 初始化输入流
 AVCaptureDeviceInput *input     = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
 if (!input) {
 
 UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"警告！" message:@"设备不支持！请检查" preferredStyle:UIAlertControllerStyleAlert];
 UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
 [self conformBtn];
 }];
 [alertVC addAction:action];
 [self presentViewController:alertVC animated:YES completion:nil];
 
 return NO;
 }
 
 //先上锁 设置完属性再解锁
 if ([captureDevice lockForConfiguration:nil]) {
 
 //自动闪光灯
 if ([captureDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
 [captureDevice setFlashMode:AVCaptureFlashModeAuto];
 }
 //自动白平衡
 if ([captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
 [captureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
 }
 //自动对焦
 if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
 [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
 }
 //自动曝光
 if ([captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
 [captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
 }
 [captureDevice unlockForConfiguration];
 }
 
 
 // 创建会话
 _captureSession = [[AVCaptureSession alloc] init];
 // 添加输入流
 [_captureSession addInput:input];
 // 初始化输出流
 AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
 // 添加输出流
 [_captureSession addOutput:captureMetadataOutput];
 
 // 创建dispatch queue.
 dispatch_queue_t dispatchQueue;
 dispatchQueue = dispatch_queue_create(kScanQRCodeQueueName, NULL);
 [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
 // 设置元数据类型 AVMetadataObjectTypeQRCode
 [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];
 
 // 创建输出对象
 if (!_videoPreviewLayer) {
 
 _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
 _videoPreviewLayer.cornerRadius = 10;
 [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
 [_videoPreviewLayer setFrame:CGRectMake(20, _scanView.center.y-PanScreenHeight/4, PanScreenWidth - 40, PanScreenHeight/3)];
 [self.navigationController.view.layer addSublayer:_videoPreviewLayer];
 // 开始会话
 [_captureSession startRunning];
 }
 [SVProgressHUD dismiss];
 
 return YES;
 }
 
 //停止读取
 - (void)stopReading
 {
 // 停止会话
 [_captureSession stopRunning];
 _captureSession = nil;
 }
 
 //获取捕获数据
 -(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
 fromConnection:(AVCaptureConnection *)connection
 {
 if (metadataObjects != nil && [metadataObjects count] > 0) {
 AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
 NSString *result = metadataObj.stringValue;
 //        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
 //            result = metadataObj.stringValue;
 //        } else {
 //            NSLog(@"不是二维码");
 //        }
 [self performSelectorOnMainThread:@selector(reportScanResult:) withObject:result waitUntilDone:NO];
 }
 }
 //处理结果
 - (void)reportScanResult:(NSString *)result {
 
 [self stopReading];
 NSLog(@"扫描结果：%@",result);
 
 UILabel *resultLabel        = [[UILabel alloc] init];
 resultLabel.text            = result;
 resultLabel.textColor       = [UIColor whiteColor];
 resultLabel.textAlignment   = NSTextAlignmentCenter;
 [_scanView addSubview:resultLabel];
 
 [resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
 make.size.equalTo(CGSizeMake(200, 25));
 make.centerX.equalTo(_scanView.centerX);
 make.top.equalTo(_scanView.mas_top).with.offset(84);
 }];
 
 [self conformBtn];
 
 SingleViewController *singleVC      = [[SingleViewController alloc] init];
 singleVC.meter_id_string            = [self getInfo:result];
 singleVC.hidesBottomBarWhenPushed   = YES;
 if ([self getInfo:result] == nil) {
 GUAAlertView *alertView = [GUAAlertView alertViewWithTitle:@"确定" message:@"本地库中不存在此户信息！\n请更新本地库或检查条码信息！" buttonTitle:@"确定" buttonTouchedAction:^{
 
 } dismissAction:^{
 
 }];
 [alertView show];
 }else{
 
 [self.navigationController showViewController:singleVC sender:nil];
 }
 
 if (!_lastResult) {
 return;
 }
 _lastResult = NO;
 
 UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"条形码扫描" message:result preferredStyle:UIAlertControllerStyleAlert];
 UIAlertAction *action       = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
 
 }];
 [alertVC addAction:action];
 [self presentViewController:alertVC animated:YES completion:^{
 
 }];
 
 // 以下处理了结果，继续下次扫描
 _lastResult = YES;
 }
 */

//查找本地库信息是否存在此扫描结果数据
- (NSString*)getInfo :(NSString *)meter_id {
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    NSLog(@"文件路径：%@  条码号(meter_id)：%@", fileName, meter_id);
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    
    if ([db open]) {
        
        FMResultSet *restultSet = [db executeQuery:[NSString stringWithFormat:@"select * from Reading_now where s_bookNo = '%@'",meter_id]];
        NSString *install_addr;
        while ([restultSet next]) {
            install_addr = [restultSet stringForColumn:@"s_bookNo"];
        }
        if (install_addr) {
            
            return install_addr;
        }else{
            
            
            return nil;
        }
    }
    return nil;
}

#pragma mark - Local methods

- (void)initiateMenuOptions {
    
    self.menuTitles = @[
                        @"",
                        @"开  启  手  电  筒",
                        @"查看本地数据库",
                        @"已完成抄收列表"
                        ];
    
    self.menuIcons = @[
                       [UIImage imageNamed:@"icon_close@3x"],
                       [UIImage imageNamed:@"light@3x"],
                       [UIImage imageNamed:@"icon_db@3x"],
                       [UIImage imageNamed:@"icon_complete@2x"]
                       ];
}


#pragma mark - YALContextMenuTableViewDelegate

- (void)contextMenuTableView:(YALContextMenuTableView *)contextMenuTableView didDismissWithIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"Menu dismissed with indexpath.row = %ld", (long)indexPath.row);
    isTap = !isTap;
    if (!isTap) {
        [self.view addSubview:_tableView];
        [self.view insertSubview:_tableView belowSubview:_ctrlBtn];
    }
    if (indexPath.row == 1) {
        [self systemLightSwitch:flashIsOn];
    }
    if (indexPath.row == 2) {
        LocaDBViewController *locaDB = [[LocaDBViewController alloc] init];
        locaDB.hidesBottomBarWhenPushed = YES;
        [self.navigationController showViewController:locaDB sender:nil];
    }
    if (indexPath.row == 3) {
        CompleteViewController *completeVC = [[CompleteViewController alloc] init];
        completeVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController showViewController:completeVC sender:nil];
    }
    
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (void)tableView:(YALContextMenuTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isTap) {
        [tableView dismisWithIndexPath:indexPath];
        
    }else {
        if (isBigMeter) {
            
            MeteringSingleViewController *meteringVC = [[MeteringSingleViewController alloc] init];
            if (self.searchController.active) {
                
                meteringVC.s_bookNo = ((MeterInfoModel *)_searchResults[indexPath.row]).s_bookNo;
            }else {
                
                meteringVC.s_bookNo = ((MeterInfoModel *)_dataArr[indexPath.row]).s_bookNo;
            }
            meteringVC.hidesBottomBarWhenPushed = YES;
            meteringVC.title = @"任务详情";
            [self.navigationController showViewController:meteringVC sender:nil];
        }else {
            
            SingleViewController *singleVC      = [[SingleViewController alloc] init];
            
            singleVC.meter_id_string            = self.searchController.active?((MeterInfoModel *)_searchResults[indexPath.row]).s_DiZhi:((MeterInfoModel *)_dataArr[indexPath.row]).s_DiZhi;
            
            singleVC.hidesBottomBarWhenPushed   = YES;
            singleVC.isBigMeter                 = YES;
            
            [self.navigationController showViewController:singleVC sender:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isTap) {
        
        return 50;
    }
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isTap) {
        
        return self.menuTitles.count;
    }
    return  self.searchController.active?_searchResults.count:_dataArr.count;
}

- (UITableViewCell *)tableView:(YALContextMenuTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isTap) {
        
        ContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:menuCellIdentifier forIndexPath:indexPath];
        
        if (cell) {
            
            cell.backgroundColor     = [UIColor clearColor];
            cell.menuTitleLabel.text = [self.menuTitles objectAtIndex:indexPath.row];
            cell.menuImageView.image = [self.menuIcons objectAtIndex:indexPath.row];
            return cell;
        }
    }
    MeterInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    cell.backgroundColor         = [UIColor clearColor];
    
    if (!cell) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MeterInfoTableViewCell" owner:self options:nil] lastObject];
    }
    cell.meterInfoModel= self.searchController.active?_searchResults[indexPath.row]:_dataArr[indexPath.row];
    cell.delegate = self;
    return cell;
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    //should be called after rotation animation completed
    if (isTap) {
        
        [self.contextMenuTableView reloadData];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (isTap) {
        
        [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        
        [self.contextMenuTableView updateAlongsideRotation];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (isTap) {
        
        [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
        
        
        [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            //should be called after rotation animation completed
            [self.contextMenuTableView reloadData];
        }];
        [self.contextMenuTableView updateAlongsideRotation];
    }
    
}
/**
 *  隐藏状态栏
 *
 */
- (BOOL)prefersStatusBarHidden {
    return NO;
}

/**
 *  当点击更多时隐藏本页tableview（防止两个tableview冲突）
 */
- (void)presentMenuButtonTapped {
    [self.contextMenuTableView showInView:self.navigationController.view withEdgeInsets:UIEdgeInsetsZero animated:YES];
    
    isTap = !isTap;
    if (isTap) {
        [self.tableView removeFromSuperview];
    } else {
        
        [self _createTableView];
    }
    
}

#pragma mark - 打开手电筒
//打开闪光灯
- (void)systemLightSwitch:(BOOL)open {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if (open) {
            [device setTorchMode:AVCaptureTorchModeOn];
            flashIsOn = !flashIsOn;
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
            flashIsOn = !flashIsOn;
        }
        [device unlockForConfiguration];
    }
}
#pragma mark - 创建数据库
- (void)createDB {
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];;
    NSString *fileName = [doc stringByAppendingPathComponent:@"meter.sqlite"];
    
    NSLog(@"数据库路径(创建时)：%@",fileName);
    
    FMDatabase *db = [FMDatabase databaseWithPath:fileName];
    
    if ([db open]) {
        
        BOOL createLitMeter = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS Reading_now (id integer PRIMARY KEY AUTOINCREMENT, bs text null, s_bookName text null, i_caliber text null, s_bookNo text null, i_no text null, i_ChaoBiaoID text null, s_CID text null, i_BiaoZhuangTai text null, i_priceTag text null, i_SFFS text null, I_KeHuLeiBie text null, i_BiaoFenLei text null, i_RenKouShu text null, N_GPS_E decimal(18, 5) null, N_GPS_N decimal(18, 5) null, s_HuMing  text null, s_DiZhi text null, s_BiaoWei text null, s_ShuiBiaoGYH text null, d_ChaoBiao_SC text null, i_ChaoMa_SC text null, i_ShuiLiang_pingjun text null, s_PhotoFile text null, s_PhotoFile2 text null, s_PhotoFile3 blob text, s_BeiZhu text null, i_ChaoMa text null, i_ShuiLiang_ChaoJian text null, d_ChaoBiao text null, i_MarkingMode text null);"];
        
        if (createLitMeter) {
            
            NSLog(@"创建抄收表成功");
        } else {
            
            NSLog(@"创建抄收表失败！");
            [SCToastView showInView:_tableView text:@"创建抄收表失败" duration:.5 autoHide:YES];
        }

        BOOL createLitMeterHisAll = [db executeUpdate:@"create table if not exists Area_data (id integer primary key autoincrement, s_bookNo text not null, s_bookName text not null)"];
        if (createLitMeterHisAll) {
            NSLog(@"创建区域表成功");
        }else {
            NSLog(@"创建区域表失败");
            [SCToastView showInView:_tableView text:@"创建区域表失败" duration:.5 autoHide:YES];
        }
        
    }
    
    self.db = db;
}

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    if (self.view.window == nil && [self isViewLoaded]) {
//        self.view = nil;
//    }
//}

#pragma mark - searchController delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    self.searchResults = [NSMutableArray array];
    [self.searchResults removeAllObjects];
    
    //NSPredicate 谓词
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@",searchController.searchBar.text];
    
    NSMutableArray *arr     = [NSMutableArray array];
    NSMutableArray *arr2    = [NSMutableArray array];
    [arr2 removeAllObjects];
    if (isBigMeter) {
        
        for (MeterInfoModel *model in self.dataArr) {
            [arr addObject:model.s_DiZhi];
        }
        arr2 = [[arr filteredArrayUsingPredicate:searchPredicate] mutableCopy];
        for (MeterInfoModel *model in self.dataArr) {
            if ([arr2 containsObject:model.s_DiZhi]) {
                [self.searchResults addObject:model];
            }
        }
    } else {
        for (MeterInfoModel *model in self.dataArr) {
            [arr addObject:model.s_DiZhi];
        }
        arr2 = [[arr filteredArrayUsingPredicate:searchPredicate] mutableCopy];
        for (MeterInfoModel *model in self.dataArr) {
            if ([arr2 containsObject:model.s_DiZhi]) {
                [self.searchResults addObject:model];
            }
        }
    }
    //刷新表格
    [self.tableView reloadData];
}

#pragma mark - searchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    UIButton *btn = [searchBar valueForKey:@"_cancelButton"];
    [btn setTitle:cancelTitle forState:UIControlStateNormal];
}


@end

