//
//  RecordVC.m
//  first
//
//  Created by panerly on 20/06/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import "RecordVC.h"
#import "TimeLineViewControl.h"
#import "RepairDetailVC.h"
#import "DelayVC.h"


@interface RecordVC ()
{
    NSMutableArray *timesArr;
    NSMutableArray *descriptionsArr;
    int currentCount;
}

@end
#define TableViewCellID @"TableViewCellID"

@implementation RecordVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"维修记录";
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    
    [imgView setImage:[UIImage imageNamed:@"icon_home_bg"]];
    [self.view addSubview:imgView];
    
    
    UIBarButtonItem *more = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(_requestTimeLimeTask)];
    self.navigationItem.rightBarButtonItem = more;
    
    
    [self _requestTimeLimeTask];
}

//获取时间轴信息
- (void)_requestTimeLimeTask {
    
    [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeGradient];
    
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ip"];
    
    NSString *url                  = [NSString stringWithFormat:@"http://%@/Meter_Reading/TimeLineServlet",ip];
    
    NSURLSessionConfiguration *config   = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager       = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    manager.requestSerializer.timeoutInterval = 10;
    
    NSDictionary *parameters = @{
                                 @"user_id":self.user_id
                                 };
    
    AFHTTPResponseSerializer *serializer    = manager.responseSerializer;
    
    serializer.acceptableContentTypes       = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf            = self;
    
    NSURLSessionTask *task =[manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
            timesArr = [NSMutableArray array];
            descriptionsArr = [NSMutableArray array];
            
            [SVProgressHUD showInfoWithStatus:@"加载成功"];
            
            for (NSDictionary *dic in responseObject) {
                
                [timesArr addObject:[dic objectForKey:@"time"]];
                [descriptionsArr addObject:[dic objectForKey:@"describe"]];
            }
            currentCount = 0;
            currentCount = (int)timesArr.count;
            if (![descriptionsArr.lastObject containsString:@"维修完成"]) {
                
                [timesArr addObject:@"预计一天后"];
                [descriptionsArr addObject:@"审核通过，维修完成"];
            }
            [weakSelf _loadTimeLine];
            
        }else{
            
            [SVProgressHUD showInfoWithStatus:@"暂无数据" maskType:SVProgressHUDMaskTypeGradient];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", error]];
        
        
    }];
    
    [task resume];
     
}

- (void)_loadTimeLine {
    
        TimeLineViewControl *timeline = [[TimeLineViewControl alloc] initWithTimeArray:timesArr
                                                               andTimeDescriptionArray:descriptionsArr
                                                                      andCurrentStatus:currentCount
                                                                              andFrame:CGRectMake(30, 120, self.view.frame.size.width - 30, 400)];
    
    
        [self.view addSubview:timeline];
}

//- (void)initUI {
//    
//    UIButton *delayBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, PanScreenHeight - 20 - PanScreenWidth/9, PanScreenWidth/4, PanScreenWidth/9)];
//    [delayBtn setTitle:@"延时维修" forState:UIControlStateNormal];
//    delayBtn.layer.cornerRadius = 7;
//    [self.view addSubview:delayBtn];
//    delayBtn.backgroundColor = COLORRGB(0, 164, 221);
//    [delayBtn addTarget:self action:@selector(delayAction) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIButton *repairBtn = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth - 20 - PanScreenWidth/4, PanScreenHeight - 20 - PanScreenWidth/9, PanScreenWidth/4, PanScreenWidth/9)];
//    [repairBtn setTitle:@"立即维修" forState:UIControlStateNormal];
//    repairBtn.layer.cornerRadius = 7;
//    [self.view addSubview:repairBtn];
//    repairBtn.backgroundColor = COLORRGB(0, 164, 221);
//    [repairBtn addTarget:self action:@selector(repairAction) forControlEvents:UIControlEventTouchUpInside];
//}
//
//- (void)delayAction {
//    
//    DelayVC *delayVC = [[DelayVC alloc] init];
//    [self.navigationController showViewController:delayVC sender:nil];
//}

//- (void)repairAction {
//    
//    RepairDetailVC *repairVC = [[RepairDetailVC alloc] init];
//    
//    [self.navigationController showViewController:repairVC sender:nil];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
