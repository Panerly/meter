//
//  RepairHisVC.m
//  first
//
//  Created by panerly on 16/05/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import "RepairHisVC.h"
#import "RepairTableViewCell.h"
#import "RepairDetailVC.h"
#import "RecordVC.h"
#import "TZPopInputView.h"
#import "TableViewAnimationKitHeaders.h"


@interface RepairHisVC ()
<
UITableViewDataSource,
UITableViewDelegate,
UISearchResultsUpdating,
UISearchBarDelegate
>

@property (nonatomic, strong) UILabel *nomoreLabel;
//创建搜索栏
@property (nonatomic, strong) UISearchController *searchController;

@property(nonatomic,retain)NSMutableArray *searchResults;//接收数据源结果

@property(nonatomic,retain)NSMutableArray *dataArr;

@property (nonatomic, strong) TZPopInputView *inputView;    // 输入框

@end

@implementation RepairHisVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"维修列表";
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    
    [imgView setImage:[UIImage imageNamed:@"icon_home_bg"]];
    
    [self.view addSubview:imgView];
    
    _nomoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PanScreenWidth, 80)];
    
    _nomoreLabel.text       = @"暂无维修记录";
    
    _nomoreLabel.textColor  = [UIColor whiteColor];
    
    _nomoreLabel.textAlignment = NSTextAlignmentCenter;
    
    _nomoreLabel.alpha      = 0.5f;
    
    _nomoreLabel.center     = self.view.center;
    
    [self.view addSubview:_nomoreLabel];
    
    [self initTableView];
    
    //[self initRightBarItem];
    
    _dataArr = [NSMutableArray array];
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    
    [self _requestTask:userName];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    self.navigationController.navigationBar.barTintColor    = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_home_bg"]];
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    [self _requestTask:userName];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_inputView) {
        
        self.inputView = [[TZPopInputView alloc] init];
    }
}

//确认订单
- (void)initRightBarItem {
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    btn.showsTouchWhenHighlighted = YES;
    [btn setTitle:@"确认" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(setSelectBtn) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addItem               = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = addItem;
}

- (void)setSelectBtn {
    
    [SCToastView showInView:self.view text:@"已确认任务" duration:1 autoHide:YES];
}

//初始化tableview & searchController
- (void)initTableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, PanScreenWidth, PanScreenHeight - 64) style:UITableViewStylePlain];
        
        _tableView.backgroundColor  = [UIColor clearColor];
        _tableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
        _tableView.delegate     = self;
        _tableView.dataSource   = self;
        [_tableView registerNib:[UINib nibWithNibName:@"RepairTableViewCell" bundle:nil] forCellReuseIdentifier:@"repairCellID"];
        
        [self.view addSubview:_tableView];
    }
    
    _tableView.mj_header                            = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(_requestTask:)];
    _tableView.mj_header.automaticallyChangeAlpha   = YES;
    _tableView.keyboardDismissMode                  = UIScrollViewKeyboardDismissModeOnDrag;
    
    if (!_searchController) {
        //调用初始化searchController
        self.searchController                                       = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.searchController.searchBar.frame                       = CGRectMake(0, 0, 0, 44);
        self.searchController.dimsBackgroundDuringPresentation      = NO;
        self.searchController.hidesNavigationBarDuringPresentation  = YES;
        self.searchController.searchBar.barTintColor                = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_home_bg"]];
//        self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        self.searchController.searchBar.placeholder                 = @"输入用户号或表身号进行搜索";
        
        self.searchController.searchBar.delegate    = self;
        self.searchController.searchResultsUpdater  = self;
        //搜索栏表头视图
        self.tableView.tableHeaderView = self.searchController.searchBar;
        [self.searchController.searchBar sizeToFit];
        [self.view addSubview:_tableView];

    }
}

//获取任务列表
- (void)_requestTask :(NSString *)repairName{
    
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ip"];
    NSString *url                  = [NSString stringWithFormat:@"http://%@/Meter_Reading/MaintenanceTaskServlet",ip];
    
    NSURLSessionConfiguration *config   = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager       = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    manager.requestSerializer.timeoutInterval = 10;
    
    NSDictionary *parameters = @{
                                 @"repair_name":[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],
                                 @"purview":[[NSUserDefaults standardUserDefaults] objectForKey:@"purview"],
                                 @"big_fac":[[NSUserDefaults standardUserDefaults] objectForKey:@"bigmeter_factory"]?[[NSUserDefaults standardUserDefaults] objectForKey:@"bigmeter_factory"]:@"",
                                 @"small_fac":[[NSUserDefaults standardUserDefaults] objectForKey:@"smallmeter_factory"]?[[NSUserDefaults standardUserDefaults] objectForKey:@"smallmeter_factory"]:@""
                                 };
    
    AFHTTPResponseSerializer *serializer    = manager.responseSerializer;
    
    serializer.acceptableContentTypes       = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf            = self;
    
    NSURLSessionTask *task =[manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            
            [_tableView.mj_header endRefreshing];
            
            [self.dataArr removeAllObjects];
            
            for (NSDictionary *dic in responseObject) {
                
                NSError *error = nil;
                
                RepairHistModel *model = [[RepairHistModel alloc] initWithDictionary:dic error:&error];
                
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
            [self presentViewController:alertVC animated:YES completion:^{
                
            }];
        }

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
//        [SVProgressHUD showErrorWithStatus:@"加载失败"];
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
- (void)starAnimationWithTableView:(UITableView *)tableView {
    
    [TableViewAnimationKit showWithAnimationType:7 tableView:tableView];
}

#pragma mark - UITableViewDelegate & UITableViewDataSourse
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return (!self.searchController.active)?self.dataArr.count : self.searchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 120;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RepairTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"repairCellID" forIndexPath:indexPath];
    
    if (!cell) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RepairTableViewCell" owner:self options:nil] lastObject];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    cell.bgView.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bgView.bounds].CGPath;
    
    cell.bgView.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    cell.bgView.layer.shadowOffset = CGSizeMake(1, 1.5);
    cell.bgView.layer.shadowOpacity = .90f;
    
//    cell.statusView.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.statusView.bounds].CGPath;
//    cell.statusView.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
//    cell.statusView.layer.shadowOffset = CGSizeMake(1, 1.3);
//    cell.statusView.layer.shadowOpacity = .90f;
    
     cell.repairHisModel = (!self.searchController.active)?_dataArr[indexPath.row] : self.searchResults[indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *purview = [[NSUserDefaults standardUserDefaults] objectForKey:@"purview"];
    if ([((RepairHistModel *)_dataArr[indexPath.row]).stage isEqualToString:@"未处理"] && ![purview isEqualToString:@"3"]) {
        
        return YES;
    }else{
        return NO;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"厂家协助";
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self.searchController.searchBar resignFirstResponder];
}

#pragma mark - 提交厂家操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.inputView.titleLable.text = @"厂家协助";
    [self.inputView setItems:@[@"现场状况"]];
    
    [self.inputView show];
    
    self.inputView.textFiled1.placeholder = @"请输入";
    
    __weak typeof(self) weakSelf = self;
    //获取系统当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *currentTime      = [formatter stringFromDate:[NSDate date]];
    
    self.inputView.okButtonClickBolck = ^(NSMutableArray *arr){
        
        [LSStatusBarHUD showLoading:@"请稍等..."];
        NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ip"];
        NSString *url                  = [NSString stringWithFormat:@"http://%@/Meter_Reading/MaintenanceAssistanceServlet",ip];
        
        NSURLSessionConfiguration *config   = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        AFHTTPSessionManager *manager       = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
        
        manager.requestSerializer.timeoutInterval = 10;
        NSString *user_id_str = ((RepairHistModel *)weakSelf.dataArr[indexPath.row]).user_id;
        NSDictionary *parameters = @{
                                     @"spot":arr[0],
                                     @"repair_name":[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],
                                     @"user_id":user_id_str,
                                     @"upload_time":currentTime
                                     };
        
        AFHTTPResponseSerializer *serializer    = manager.responseSerializer;
        
        serializer.acceptableContentTypes       = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
        
        NSURLSessionTask *task =[manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (responseObject) {
                if ([[responseObject objectForKey:@"type"] isEqualToString:@"成功"]) {
                    [weakSelf.inputView hide];
//                    // 从数据源中删除
//                    [weakSelf.dataArr removeObjectAtIndex:indexPath.row];
//                    
//                    // 从列表中删除
//                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
                    [weakSelf _requestTask:userName];
                    [LSStatusBarHUD hideLoading];
                    [LSStatusBarHUD showMessage:@"提交成功！"];
                    
                }else{
                    [LSStatusBarHUD hideLoading];
                    [LSStatusBarHUD showMessage:@"提交失败！"];
                }
                
            }else {
                
                UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"提示" message:@"暂无数据" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                
                [alertVC addAction:action];
                [weakSelf presentViewController:alertVC animated:YES completion:^{
                    
                }];
            }
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [SVProgressHUD showErrorWithStatus:@"加载失败"];
            UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"连接失败" message:[NSString stringWithFormat:@"%@", error] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertVC addAction:action];
            [weakSelf presentViewController:alertVC animated:YES completion:^{
                
            }];
            
        }];
        
        [task resume];
        
    };
    
    
//    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
}
- (void)alertMessage {
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    RepairDetailVC *repairDetailVC = [[RepairDetailVC alloc] init];
    RecordVC *recordVC = [[RecordVC alloc] init];
    
    //      已维修 已协助 未维修
    //厂家   YES    NO     NO
    //抄表员  YES   YES     NO
    
    BOOL flag = NO;
    NSString *purview = [[NSUserDefaults standardUserDefaults] objectForKey:@"purview"];
    if ([purview isEqualToString:@"3"]) {//厂家
        
        flag = [((RepairHistModel *)_dataArr[indexPath.row]).stage isEqualToString:@"已维修"]?NO:YES;
        
    }else{//维修人员
        
        flag = [((RepairHistModel *)_dataArr[indexPath.row]).stage isEqualToString:@"未处理"]?NO:YES;
    }
    recordVC.flag = flag;
    
    repairDetailVC.user_id = ((RepairHistModel *)_dataArr[indexPath.row]).user_id;
    repairDetailVC.appearance = ((RepairHistModel *)_dataArr[indexPath.row]).appearance;
    repairDetailVC.stage = ((RepairHistModel *)_dataArr[indexPath.row]).stage;
    repairDetailVC.alert_time = ((RepairHistModel *)_dataArr[indexPath.row]).give_date;
    repairDetailVC.bsh = ((RepairHistModel *)_dataArr[indexPath.row]).bsh;
    repairDetailVC.repair_name = ((RepairHistModel *)_dataArr[indexPath.row]).repair_name;
    repairDetailVC.user_addr = ((RepairHistModel *)_dataArr[indexPath.row]).user_addr;
    repairDetailVC.spotCondition = ((RepairHistModel *)_dataArr[indexPath.row]).spotCondition;
    
    recordVC.user_id = ((RepairHistModel *)_dataArr[indexPath.row]).user_id;
    
    [self.navigationController showViewController:(flag ? recordVC:repairDetailVC) sender:nil];
    
//    [self.navigationController showViewController:recordVC sender:nil];
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
    
    for (RepairHistModel *model in self.dataArr) {
        
        [arr addObject:model.user_id];
        [arr addObject:model.bsh];
    }
    arr2 = [[arr filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    for (RepairHistModel *model in self.dataArr) {
        
        if ([arr2 containsObject:model.user_id]||[arr2 containsObject:model.bsh]) {
            
            [self.searchResults addObject:model];
        }
    }
    //刷新表格
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}


//移除搜索栏
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.searchController.active) {
        
        self.searchController.active = NO;
        [self.searchController.searchBar removeFromSuperview];
    }
}

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
