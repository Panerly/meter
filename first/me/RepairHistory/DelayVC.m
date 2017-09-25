//
//  DelayVC.m
//  first
//
//  Created by panerly on 17/08/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import "DelayVC.h"
#import "RepairHisVC.h"

@interface DelayVC ()<UITextViewDelegate>
{
    UITextView *textView;
    UILabel *textViewPlaceholderLabel;
}

@end

@implementation DelayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"延时填单";
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    //让顶部不留空白
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_home_bg"]];
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 84, PanScreenWidth - 20, 200)];
    textView.layer.cornerRadius = 8;
    textView.font = [UIFont systemFontOfSize:20];
    textView.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    textView.layer.borderWidth = 1;
    textView.layer.masksToBounds = YES;
    textView.tag = 100;
    textView.delegate = self;
    
    //1、在UITextView上加上一个UILabel
    textViewPlaceholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+2, 84+10, PanScreenWidth - 25*2, 25)];
    textViewPlaceholderLabel.text = @"请输入延时维修或请假理由";
    textViewPlaceholderLabel.textColor = [UIColor grayColor];
    
    [self.view addSubview:textView];
    [self.view addSubview: textViewPlaceholderLabel];
    
}
//设置textView的placeholder

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //[text isEqualToString:@""] 表示输入的是退格键
    if (![text isEqualToString:@""])
    {
        textViewPlaceholderLabel.hidden = YES;
    }
    
    //range.location == 0 && range.length == 1 表示输入的是第一个字符
    if ([text isEqualToString:@""] && range.location == 0 && range.length == 1)
        
    {
        textViewPlaceholderLabel.hidden = NO;
    }
    return YES;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [textView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)save {
    [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeGradient];
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ip"];
    NSString *url                  = [NSString stringWithFormat:@"http://%@/Meter_Reading/DelayedMaintenanceServlet",ip];
    
    NSURLSessionConfiguration *config   = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager       = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    manager.requestSerializer.timeoutInterval = 10;
    //获取系统当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *currentTime      = [formatter stringFromDate:[NSDate date]];
    NSDictionary *parameters = @{
                                 @"delay":textView.text,
                                 @"repair_name":[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],
                                 @"user_id":self.user_id,
                                 @"upload_time":currentTime
                                 };
    
    AFHTTPResponseSerializer *serializer    = manager.responseSerializer;
    
    serializer.acceptableContentTypes       = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf            = self;
    
    NSURLSessionTask *task =[manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [SVProgressHUD dismiss];
        if (responseObject) {
            
            if ([[responseObject objectForKey:@"type"] isEqualToString:@"成功"]) {
                
                [LSStatusBarHUD showMessage:@"提交成功,即将退出"];
                sleep(2.5);
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                
                [LSStatusBarHUD showMessage:@"提交失败!"];
            }
            
        }else {
            
            UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"提示" message:@"提交失败" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertVC addAction:action];
            [weakSelf presentViewController:alertVC animated:YES completion:^{
                
            }];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [SVProgressHUD showErrorWithStatus:@"加载失败"];
        UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"连接失败" message:[NSString stringWithFormat:@"%@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [weakSelf presentViewController:alertVC animated:YES completion:^{
            
        }];
        
    }];
    
    [task resume];
    
}
@end
