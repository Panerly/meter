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

@interface CheckViewController ()

<
UITableViewDelegate,
UITableViewDataSource,
UISearchResultsUpdating,
UISearchBarDelegate,
UINavigationControllerDelegate
>
//创建搜索栏
@property (nonatomic, strong) UISearchController *searchController;

@property(nonatomic,retain)NSMutableArray *searchResults;//接收数据源结果

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic,retain)NSMutableArray *dataArr;

@end

@implementation CheckViewController

- (void)setDataArr:(NSMutableArray *)dataArr {
    
    _dataArr = dataArr;
    _dataArr = [NSMutableArray array];
}

- (void)setSearchResults:(NSMutableArray *)searchResults {
    
    _searchResults = searchResults;
    _searchResults = [NSMutableArray array];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setBG];
    
    [self initTableView];
    
    [self _requestData];
}

//修改导航栏颜色
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor    = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_home_bg.png"]];
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
    
    
    _tableView.mj_header                            = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(_requestData)];
    _tableView.mj_header.automaticallyChangeAlpha   = YES;
    _tableView.keyboardDismissMode                  = UIScrollViewKeyboardDismissModeOnDrag;
    
    //调用初始化searchController
    self.searchController                                       = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.frame                       = CGRectMake(0, 0, 0, 44);
    self.searchController.dimsBackgroundDuringPresentation      = NO;
    self.searchController.hidesNavigationBarDuringPresentation  = YES;
        self.searchController.searchBar.barTintColor                = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_home_bg.png"]];
    self.searchController.searchBar.placeholder                 = @"搜索";
    
    self.searchController.searchBar.delegate    = self;
    self.searchController.searchResultsUpdater  = self;
    //搜索栏表头视图
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];
    
    [_tableView registerNib:[UINib nibWithNibName:@"CheckTableViewCell" bundle:nil] forCellReuseIdentifier:@"checkID"];
    [self.view addSubview:_tableView];
}

//获取外复数据
- (void)_requestData{
    
    for (int i = 0; i < 20; i++) {
        
        [_dataArr addObject:[NSString stringWithFormat:@"下沙经济开发区xx小区xx单元%d幢",i+1]];
    }
    [_tableView.mj_header endRefreshing];
//    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
    [self starAnimationWithTableView:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 20;
//    return (!self.searchController.active)?self.dataArr.count : self.searchResults.count;
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
//    cell.checkModel = = (!self.searchController.active)?_dataArr[indexPath.row] : self.searchResults[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.backgroundColor = [UIColor clearColor];
    cell.accessibilityNavigationStyle = UIAccessibilityNavigationStyleSeparate;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CheckDetailVC *checkDetail = [[CheckDetailVC alloc] init];
    [self.navigationController showViewController:checkDetail sender:nil];
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
        
        [arr addObject:checkModel.userAddr];
    }
    arr2 = [[arr filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    
    for (CheckModel *checkModel in self.dataArr) {
        
        if ([arr2 containsObject:checkModel.userAddr]) {
            
            [self.searchResults addObject:checkModel];
        }
    }
    //刷新表格
    [self.tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self.searchController.searchBar resignFirstResponder];
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
