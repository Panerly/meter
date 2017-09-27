//
//  HSTabBarController.m
//  first
//
//  Created by HS on 16/5/20.
//  Copyright © 2016年 HS. All rights reserved.
//

#import "HSTabBarController.h"
#import "SettingViewController.h"
#import "MeteringViewController.h"
#import "ServerViewController.h"
#import "MonitorViewController.h"
#import "SeniorlevelViewController.h"
#import "NewHomeViewController.h"


@interface HSTabBarController ()

@end

@implementation HSTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加子控制器
    NewHomeViewController *home = [[NewHomeViewController alloc] init];
    [self addOneChlildVc:home title:@"首页" imageName:@"home@3x" selectedImageName:@"home_selected@3x"];
    
    //判断是否是高级权限 选择呈现不同查看方式
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"purview"] isEqualToString:@"0"]) {//管理员（大小表，无抄表情况）
        MeteringViewController *meter = [[MeteringViewController alloc] init];
        [self addOneChlildVc:meter title:@"抄表" imageName:@"metering@3x" selectedImageName:@"metering_selected@3x"];
        
        MonitorViewController *monitor = [[MonitorViewController alloc] init];
        [self addOneChlildVc:monitor title:@"监测" imageName:@"monitor@3x" selectedImageName:@"monitor_selected@3x"];
        
    }else if([[[NSUserDefaults standardUserDefaults] objectForKey:@"purview"] isEqualToString:@"1"]){//现改为抄表员
        MeteringViewController *meter = [[MeteringViewController alloc] init];
        [self addOneChlildVc:meter title:@"抄表" imageName:@"metering@3x" selectedImageName:@"metering_selected@3x"];
        
        
    }else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"purview"] isEqualToString:@"2"]){//现改为维护人员
        MonitorViewController *monitor = [[MonitorViewController alloc] init];
        [self addOneChlildVc:monitor title:@"监测" imageName:@"monitor@3x" selectedImageName:@"monitor_selected@3x"];
    }else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"purview"] isEqualToString:@"3"]){//现改为厂家权限
        
        MonitorViewController *monitor = [[MonitorViewController alloc] init];
        [self addOneChlildVc:monitor title:@"监测" imageName:@"monitor@3x" selectedImageName:@"monitor_selected@3x"];
    }else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"purview"] isEqualToString:@"4"]){//查询权限
        SeniorlevelViewController *Senior = [[SeniorlevelViewController alloc] init];
        [self addOneChlildVc:Senior title:@"抄表情况" imageName:@"metering@3x" selectedImageName:@"metering_selected@3x"];
        MonitorViewController *monitor = [[MonitorViewController alloc] init];
        [self addOneChlildVc:monitor title:@"监测" imageName:@"monitor@3x" selectedImageName:@"monitor_selected@3x"];
    }
    
    ServerViewController *server = [[ServerViewController alloc] init];
    [self addOneChlildVc:server title:@"服务" imageName:@"server@3x" selectedImageName:@"server_selected@3x"];
    
    SettingViewController *setting = [[SettingViewController alloc] init];
    [self addOneChlildVc:setting title:@"设置" imageName:@"me@3x" selectedImageName:@"me_selected@3x"];
}

//登录缩放动画
- (void)animationWithView:(UIView *)view duration:(CFTimeInterval)duration{
    
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    
    NSMutableArray *values = [NSMutableArray array];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01, 0.01, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
    [self animationWithView:view duration:.3];
    [view.layer addAnimation:animation forKey:nil];
}

- (void)addOneChlildVc:(UIViewController *)childVc title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName
{
    //自定义tabbarItem的颜色
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor blackColor], NSForegroundColorAttributeName,
                                                       nil] forState:UIControlStateNormal];
    UIColor *titleHighlightedColor = navigateColor;
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       titleHighlightedColor, NSForegroundColorAttributeName,
                                                       nil] forState:UIControlStateSelected];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont fontWithName:@"JXK" size:13], NSFontAttributeName,
                                                       nil] forState:UIControlStateNormal];
    // 设置标题
    // 相当于同时设置了tabBarItem.title和navigationItem.title
    childVc.title               = title;
    
    // 设置图标
    childVc.tabBarItem.image = [UIImage imageNamed:imageName];
    // 设置选中的图标
    UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
    
    // 声明这张图片用原图(别渲染)
    selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVc.tabBarItem.selectedImage = selectedImage;
        
    // 添加为tabbar控制器的子控制器
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:childVc];
    [self addChildViewController:nav];
}


-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSInteger index = [self.tabBar.items indexOfObject:item];
    [self animationWithIndex:index];
}

- (void)animationWithIndex:(NSInteger) index {
    
    NSMutableArray * tabbarbuttonArray = [NSMutableArray array];
    for (UIView *tabBarButton in self.tabBar.subviews) {
        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [tabbarbuttonArray addObject:tabBarButton];
        }
    }
    CABasicAnimation*pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulse.duration = 0.1;
    pulse.repeatCount= 1;
    pulse.autoreverses= YES;
    pulse.fromValue= [NSNumber numberWithFloat:1.0];
    pulse.toValue= [NSNumber numberWithFloat:1.3];
    [[tabbarbuttonArray[index] layer]
     addAnimation:pulse forKey:nil]; 
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
