//
//  ServerViewController.m
//  first
//
//  Created by HS on 16/5/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "ServerViewController.h"
#import "CheckViewController.h"
#import "HelpViewController.h"
#import "RepairHisVC.h"

@interface ServerViewController ()<CLLocationManagerDelegate>

{
    UIButton *button;
    NSMutableArray *arr;
}

@end

@implementation ServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_bg.png"]];
    
    [self _createBtn];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!button) {
        [self _createBtn];
    }
    for (int i = 100; i < 106; i++) {
        
//        ((UIButton *)arr[i-100]).transform = CGAffineTransformTranslate(button.transform, 0, -PanScreenHeight/2);
        //((UIButton *)arr[i-100]).transform = CGAffineTransformRotate(button.transform, M_PI);
//        ((UIButton *)arr[i-100]).transform = CGAffineTransformMakeScale(1.5, 1.5);
//        [self animationWithView:(UIButton *)arr[i-100] duration:(i-99)/3];
        
        
        [self withanimationWithView:(UIButton *)arr[i-100] duration:.5];
    }
    
    for (int i = 100; i < 106; i++) {
        
//        CGFloat duration = (i - 99) * 0.15;
//        
//        [UIView animateWithDuration:duration animations:^{
//            
//            ((UIButton *)arr[i-100]).transform = CGAffineTransformIdentity;
//            
//        } completion:^(BOOL finished) {
//            
//        }];
        
        __weak typeof(self) weakSelf = self;
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)((i-100)/2));
        
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [weakSelf animationWithView:(UIButton *)arr[i-100] duration:(i-100)/2];
        });
    }
    
    [self setNavColor];
}
- (void)withanimationWithView:(UIView *)view duration:(CFTimeInterval)duration{
    
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0;
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    
    NSMutableArray *values = [NSMutableArray array];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(1.0, -PanScreenHeight/2, 1.0)]];
    
    animation.values = values;
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionDefault];
    
    [view.layer addAnimation:animation forKey:nil];
}

- (void)animationWithView:(UIView *)view duration:(CFTimeInterval)duration{
    
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    
    NSMutableArray *values = [NSMutableArray array];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(1.0, -PanScreenHeight/2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(1.0, 10, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(1.0, -10, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(1.0, 1.0, 1.0)]];
    
    animation.values = values;
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionDefault];
    
    [view.layer addAnimation:animation forKey:nil];
}

-(void)setNavColor{
    
    self.navigationController.navigationBar.barStyle        = UIStatusBarStyleDefault;
//    self.navigationController.navigationBar.barTintColor    = COLORRGB(226, 107, 16);
    self.navigationController.navigationBar.barTintColor = navigateColor;
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
}
- (void)_createBtn
{
    CGFloat width = self.view.frame.size.width/5+10;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];//button的类型;
    arr = [[NSMutableArray alloc] init];
    [arr removeAllObjects];
    
    NSArray *titleArr = @[@"维修",@"意见建议",@"帮助说明",@"故障报修",@"服务热线",@"外复"];
    NSArray *imageArr = @[@"help",@"suggestions",@"explain",@"故障报修",@"call_icon",@"check"];
    
    for (int i = 0; i < 2; i++) {
        
        for (int j = 0; j < titleArr.count-i-j; j++) {
            
//            if (j == 0) {
//                
//                button = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth/2 * i + PanScreenWidth/8, 80, width, width)];
//            }else
            button = [[UIButton alloc] initWithFrame:CGRectMake(PanScreenWidth/2 * i + PanScreenWidth/8, width *(j+1) + (j*40)+10, width, width)];

            [button setBackgroundImage:[UIImage imageNamed:imageArr[i+j+j]] forState:UIControlStateNormal];
            
            //    在UIButton中有三个对EdgeInsets的设置：ContentEdgeInsets、titleEdgeInsets、imageEdgeInsets
            //    [button setImage:[UIImage imageNamed:@"his"] forState:UIControlStateNormal];//给button添加image
            button.imageEdgeInsets = UIEdgeInsetsMake(5,13,21,button.titleLabel.bounds.size.width);//设置image在button上的位置（上top，左left，下bottom，右right）这里可以写负值，对上写－5，那么image就象上移动5个像素
            
            [button setTitle:titleArr[i+j+j] forState:UIControlStateNormal];//设置button的title
//            button.titleLabel.font = [UIFont systemFontOfSize:16];//title字体大小
            button.titleLabel.font = [UIFont fontWithName:@"JXK" size:20];
            button.titleLabel.adjustsFontSizeToFitWidth = YES;
            button.titleLabel.textAlignment = NSTextAlignmentCenter;//设置title的字体居中
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];//设置title在一般情况下为白色字体
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];//设置title在button被选中情况下为灰色字体
            button.titleEdgeInsets = UIEdgeInsetsMake(110, -button.titleLabel.bounds.size.width, 0, 0);//设置title在button上的位置（上top，左left，下bottom，右right）
            
            button.tag = 200+i+j+j;
            
            [arr addObject:button];
            
            [button addTarget:self action:@selector(waterCharge:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.view addSubview:button];
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (IBAction)waterCharge:(UIButton *)sender {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"该功能暂未推出，敬请期待^_^!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *email = [UIAlertAction actionWithTitle:@"发送邮件" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://76843918@qq.com"]];
    }];
    
    UIAlertAction *sms = [UIAlertAction actionWithTitle:@"发送短信" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"sms://15356167113"]];
    }];
    UIAlertAction *tel = [UIAlertAction actionWithTitle:@"拨打" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://4001081616"]];
    }];
    
    UIAlertController *jurisdiction = [UIAlertController alertControllerWithTitle:@"提示" message:@"此功能仅限维护人员使用!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertController *checkAlert = [UIAlertController alertControllerWithTitle:@"提示" message:@"此功能仅限外复人员使用!" preferredStyle:UIAlertControllerStyleAlert];
    
    HelpViewController *helpView = [[HelpViewController alloc] init];
    
//    PayViewController *pay = [[PayViewController alloc] init];
    
    RepairHisVC *repairHisVC = [[RepairHisVC alloc] init];
    
//    repairHisVC.title = @"维修记录";
    
//    repairHisVC.view.backgroundColor = [UIColor whiteColor];
    
    repairHisVC.hidesBottomBarWhenPushed = YES;
    
    CheckViewController *checkVC = [[CheckViewController alloc] init];
    
    checkVC.hidesBottomBarWhenPushed = YES;
    
    switch (sender.tag) {
            
        case 200:
            if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"purview"] isEqualToString:@"1"]){//此功能仅限维修员或管理员使用
                
                [self.navigationController showViewController:repairHisVC sender:nil];
            }else{
                
                [jurisdiction addAction:action];
                [self presentViewController:jurisdiction animated:YES completion:^{
                    
                }];
            }
        break;
            
        case 201:
            [alert addAction:cancel];
            [alert addAction:email];
            [self presentViewController:alert animated:YES completion:nil];
        break;
            
        case 202:
            [self.navigationController showViewController:helpView sender:nil];
        break;
            
        case 203:
            [alert addAction:cancel];
            [alert addAction:sms];
            [self presentViewController:alert animated:YES completion:nil];
        break;
            
        case 204:
            [alert addAction:cancel];
            [alert addAction:tel];
            [self presentViewController:alert animated:YES completion:nil];
            break;
            
        case 205:
//            [alertVC addAction:action];
//            [self presentViewController:alertVC animated:YES completion:^{
//            }];
            
            //            [self.navigationController showViewController:pay sender:nil];
//            if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"purview"] isEqualToString:@"5"]){//此功能仅限外复人员使用
//                
////                [self.navigationController showViewController:repairHisVC sender:nil];
//            }else{
//                
//                [checkAlert addAction:action];
//                [self presentViewController:checkAlert animated:YES completion:^{
//                    
//                }];
//            }
            [self.navigationController showViewController:checkVC sender:nil];
            break;
            
        default:
            break;
    }
}
@end
