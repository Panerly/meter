//
//  PresureViewController.m
//  first
//
//  Created by panerly on 13/09/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import "PressureViewController.h"
#import "AAChartKit.h"
#import "KSDatePicker.h"

@interface PressureViewController ()

@property (nonatomic, strong) NSMutableArray *collect_date_Arr;
@property (nonatomic, strong) NSMutableArray *pressure_data_Arr;

@property (nonatomic, strong) AAChartModel *chartModel;
@property (nonatomic, strong) AAChartView *chartView;

@end

@implementation PressureViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configThesegmentedControl];
    
    [self configTheSwitch];
    
   
    
    self.title = [NSString stringWithFormat:@"压力图"];
    
//    [self configTheChartView:chartType];

    NSDateFormatter *formatter_hour = [[NSDateFormatter alloc] init];
    [formatter_hour setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *currentTime = [formatter_hour stringFromDate:[NSDate date]];
    
    NSString *type = @"0";
    
    
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    NSDateComponents *comps = nil;
//    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
//    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
//    
//    [adcomps setYear:0];
//    [adcomps setMonth:0];
//    [adcomps setDay:-2];
//    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd"];
//    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:[NSDate date] options:0];
//    NSString *newdateStr = [formatter stringFromDate:newdate];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"日期" style:UIBarButtonItemStylePlain target:self action:@selector(selectDate)];
    
    [self _requestDataType:type Date1:currentTime Date2:currentTime];
}

//选取时间段进行检索
- (void)selectDate {
    
    KSDatePicker* picker = [[KSDatePicker alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 300)];
    
    picker.appearance.radius = 5;
    
    //设置回调
    picker.appearance.resultCallBack = ^void(KSDatePicker* datePicker,NSDate* currentDate,KSDatePickerButtonType buttonType){
        
        if (buttonType == KSDatePickerButtonCommit) {
            
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            [self _requestDataType:@"2" Date1:[formatter stringFromDate:currentDate] Date2:[formatter stringFromDate:currentDate]];
        }
    };
    // 显示
    [picker show];
}

- (void)configTheChartView:(AAChartType)chartType Date:(NSString *)date{
    
    self.chartView = [[AAChartView alloc]init];
    self.chartView.delegate = (id)self;
    self.view.backgroundColor = [UIColor whiteColor];
    self.chartView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-220);
    self.chartView.contentHeight = self.view.frame.size.height-250;
    [self.view addSubview:self.chartView];
    
    //    JSContext *context = [self.chartView  valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //
    //    context[@"打印"] = ^() {
    //        NSArray *args = [JSContext currentArguments];
    //        for (JSValue *jsVal in args) {
    //            NSLog(@"%@", jsVal);
    //        }
    //
    //
    //    };
    /*,
     
     AAObject(AASeriesElement)
     .nameSet(@"2018")
     .dataSet(@[@31,@22,@33,@54,@35,@36,@27,@38,@39,@54,@41,@29]),
     
     AAObject(AASeriesElement)
     .nameSet(@"2019")
     .dataSet(@[@11,@12,@13,@14,@15,@16,@17,@18,@19,@33,@56,@39]),
     
     AAObject(AASeriesElement)
     .nameSet(@"2020")
     .dataSet(@[@21,@22,@24,@27,@25,@26,@37,@28,@49,@56,@31,@11]),
     */
    NSMutableArray *pressureDataArr = [NSMutableArray array];
    for (int i = 0; i < _pressure_data_Arr.count; i++) {
        CGFloat pressure = [_pressure_data_Arr[i] floatValue];
        NSNumber *num = [NSNumber numberWithFloat:pressure];
        [pressureDataArr addObject:num];
    }
    
    NSMutableArray *collectDateArr = [NSMutableArray array];
    ;
    for (int i = 0; i < _collect_date_Arr.count; i++) {
        NSString *str = [_collect_date_Arr[i] stringByReplacingOccurrencesOfString:@" " withString:@""];
        [collectDateArr addObject:[str substringWithRange:NSMakeRange(10, 8)]];
    }
    
    self.chartModel= AAObject(AAChartModel)
    .chartTypeSet(chartType)
    .titleSet(@"水表压力图")
    .subtitleSet(@"压力数据")
    .pointHollowSet(true)
    .categoriesSet(collectDateArr)
    .yAxisTitleSet(@"kPa")
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(date)
                 .dataSet(pressureDataArr)
               ])
    /**
     *   标示线的设置
     *   标示线设置作为图表一项基础功能,用于对图表的基本数据水平均线进行标注
     *   虽然不太常被使用,但我们仍然提供了此功能的完整接口,以便于有特殊需求的用户使用
     *   解除以下代码注释,,运行程序,即可查看实际工程效果以酌情选择
     *
     **/
    //    .yPlotLinesSet(@[AAObject(AAPlotLinesElement)
    //                     .colorSet(@"#F05353")//颜色值(16进制)
    //                     .dashStyleSet(@"Dash")//样式：Dash,Dot,Solid等,默认Solid
    //                     .widthSet(@(1)) //标示线粗细
    //                     .valueSet(@(20)) //所在位置
    //                     .zIndexSet(@(1)) //层叠,标示线在图表中显示的层叠级别，值越大，显示越向前
    //                     .labelSet(@{@"text":@"标示线1",@"x":@(0),@"style":@{@"color":@"#33bdfd"}})/*这里其实也可以像AAPlotLinesElement这样定义个对象来赋值（偷点懒直接用了字典，最会终转为js代码，可参考https://www.hcharts.cn/docs/basic-plotLines来写字典）*/
    //                     ,AAObject(AAPlotLinesElement)
    //                     .colorSet(@"#33BDFD")
    //                     .dashStyleSet(@"Dash")
    //                     .widthSet(@(1))
    //                     .valueSet(@(40))
    //                     .labelSet(@{@"text":@"标示线2",@"x":@(0),@"style":@{@"color":@"#33bdfd"}})
    //                     ,AAObject(AAPlotLinesElement)
    //                     .colorSet(@"#ADFF2F")
    //                     .dashStyleSet(@"Dash")
    //                     .widthSet(@(1))
    //                     .valueSet(@(60))
    //                     .labelSet(@{@"text":@"标示线3",@"x":@(0),@"style":@{@"color":@"#33bdfd"}})
    //                     ]
    //                   )
//        //Y轴最大值
//        .yMaxSet(@(100))
        //Y轴最小值
        .yMinSet(@(0))
        //是否允许Y轴坐标值小数
        .yAllowDecimalsSet(YES)
    //    //指定y轴坐标
    //    .yTickPositionsSet(@[@(0),@(25),@(50),@(75),@(100)])
    

    ;
    
    //是否起用渐变色功能
    _chartModel.gradientColorEnable = YES;
    
    _chartModel.dataLabelEnabled = YES;
    
    [self.chartView aa_drawChartWithChartModel:_chartModel];
    
}

#pragma mark -- AAChartView delegate
-(void)AAChartViewDidFinishLoad {
    NSLog(@"😊😊😊图表视图已完成加载");
}

- (void)configThesegmentedControl{
    NSArray *segmentedArray = @[@[@"常规",@"堆叠",@"百分比堆叠"],
                                @[@"波点",@"方块",@"钻石",@"正三角",@"倒三角"]
                                ];
    
    NSArray *typeLabelNameArr = @[@"堆叠类型选择",@"折线连接点形状选择"];
    
    for (int i=0; i<segmentedArray.count; i++) {
        
        UISegmentedControl * segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray[i]];
        segmentedControl.frame = CGRectMake(20, 40*i+(self.view.frame.size.height-145), self.view.frame.size.width-40, 20);
        segmentedControl.selectedSegmentIndex = 0;
        segmentedControl.tintColor = navigateColor;
        segmentedControl.tag = i;
        [segmentedControl addTarget:self action:@selector(customsegmentedControlCellValueBeChanged:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:segmentedControl];
        
        UILabel *typeLabel = [[UILabel alloc]init];
        typeLabel.frame =CGRectMake(20, 40*i+(self.view.frame.size.height-165), self.view.frame.size.width-40, 20);
        typeLabel.text = typeLabelNameArr[i];
        typeLabel.font = [UIFont systemFontOfSize:11.0f];
        [self.view addSubview:typeLabel];
        
    }
}

- (void)customsegmentedControlCellValueBeChanged:(UISegmentedControl *)segmentedControl {
    switch (segmentedControl.tag) {
        case 0: {
            NSArray *stackingArr = @[AAChartStackingTypeFalse,
                                     AAChartStackingTypeNormal,
                                     AAChartStackingTypePercent];
            self.chartModel.stacking = stackingArr[segmentedControl.selectedSegmentIndex];
        }
            break;
            
        case 1: {
            NSArray *symbolArr = @[AAChartSymbolTypeCircle,
                                   AAChartSymbolTypeSquare,
                                   AAChartSymbolTypeDiamond,
                                   AAChartSymbolTypeTriangle,
                                   AAChartSymbolTypeTriangle_down];
            self.chartModel.symbol = symbolArr[segmentedControl.selectedSegmentIndex];
        }
            break;
            
        default:
            break;
    }
    
    [self refreshTheChartView];
}

- (void)refreshTheChartView {
    
    [self.chartView aa_refreshChartWithChartModel:self.chartModel];
}

- (void)configTheSwitch {
    NSArray *nameArr = @[@"x轴翻转",@"y轴翻转",@"x 轴直立",@"辐射化图形",@"隐藏连接点",@"显示数字"];
    CGFloat switchWidth = (self.view.frame.size.width-40)/6;
    
    for (int i=0; i<nameArr.count; i++) {
        
        UISwitch * switchView = [[UISwitch alloc]init];
        switchView.frame = CGRectMake(switchWidth*i+20, self.view.frame.size.height-70, switchWidth, 20);
        if (i>4) {
            
            switchView.on = YES;
        }else{
            
            switchView.on = NO;
        }
        switchView.tag = i;
        [switchView addTarget:self action:@selector(switchViewClicked:) forControlEvents:UIControlEventValueChanged];
        switchView.tintColor = navigateColor;
        [self.view addSubview:switchView];
        
        UILabel *label = [[UILabel alloc]init];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.frame = CGRectMake(switchWidth*i+20,  self.view.frame.size.height-40, switchWidth, 40);
        label.text = nameArr[i];
        label.font = [UIFont systemFontOfSize:10.0f];
        [self.view addSubview:label];
    }
}

- (void)switchViewClicked:(UISwitch *)switchView {
    switch (switchView.tag) {
        case 0:
            self.chartModel.xAxisReversed = switchView.on;
            break;
        case 1:
            self.chartModel.yAxisReversed = switchView.on;
            break;
        case 2:
            self.chartModel.inverted = switchView.on;
            break;
        case 3:
            self.chartModel.polar = switchView.on;
            break;
        case 4:
            self.chartModel.markerRadius = switchView.on?@0:@5;
            break;
        case 5:
            self.chartModel.dataLabelEnabled = switchView.on;
            break;
        default:
            break;
    }
    
    [self refreshTheChartView];
}

- (void)_requestDataType:(NSString *)type Date1:(NSString *)date1 Date2:(NSString *)date2
{
    
    [LSStatusBarHUD showLoading:@"请稍等..."];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *ipLabel = [defaults objectForKey:@"ip"];
    NSString *dbLabel = [defaults objectForKey:@"db"];
    
    NSString *logInUrl = [NSString stringWithFormat:@"http://%@/waterweb/PressureServlet",ipLabel];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    NSDictionary *parameters = @{
                                 @"type":type,
                                 @"meter_id":self.meter_id,
                                 @"db":dbLabel,
                                 @"date1":date1,
                                 @"date2":date2
                                 };
    
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task =[manager POST:logInUrl parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [LSStatusBarHUD hideLoading];
        if (responseObject) {
            [LSStatusBarHUD showMessage:@"加载成功"];
            
            weakSelf.collect_date_Arr = [NSMutableArray array];
            weakSelf.pressure_data_Arr = [NSMutableArray array];
            
            for (NSDictionary *dic in responseObject) {
                
                [weakSelf.collect_date_Arr addObject:[dic objectForKey:@"collect_date"]];
                [weakSelf.pressure_data_Arr addObject:[dic objectForKey:@"pressure_data"]];
            }
            AAChartType chartType;
            
            weakSelf.chartType = 5;
            
            switch (weakSelf.chartType) {
                case 0:
                    chartType = AAChartTypeColumn;
                    break;
                case 1:
                    chartType = AAChartTypeBar;
                    break;
                case 2:
                    chartType = AAChartTypeArea;
                    break;
                case 3:
                    chartType = AAChartTypeAreaspline;
                    break;
                case 4:
                    chartType = AAChartTypeLine;
                    break;
                case 5:
                    chartType = AAChartTypeSpline;
                    break;
                case 6:
                    chartType = AAChartTypeScatter;
                    break;
                default:
                    break;
            }
            NSString *date = [NSString stringWithFormat:@"%@",[date1 substringWithRange:NSMakeRange(0, 10)]];
            [weakSelf configTheChartView:chartType Date:date];
        }else{

            [LSStatusBarHUD showMessage:@"暂无数据"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"暂无数据" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:cancel];
            [weakSelf presentViewController:alert animated:YES completion:^{
                
            }];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [LSStatusBarHUD hideLoading];
        [LSStatusBarHUD showMessage:@"加载失败"];
        NSLog(@"%@",error);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"链接失败" message:[NSString stringWithFormat:@"%@",error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancel];
        [weakSelf presentViewController:alert animated:YES completion:^{
            
        }];
        
    }];
    
    [task resume];
}


@end
