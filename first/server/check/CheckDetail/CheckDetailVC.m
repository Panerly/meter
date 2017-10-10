//
//  CheckDetailVC.m
//  first
//
//  Created by panerly on 26/09/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import "CheckDetailVC.h"
#import <AVFoundation/AVFoundation.h>
#import "ZJUsefulPickerView.h"

@interface CheckDetailVC ()
<
AVCaptureMetadataOutputObjectsDelegate
//UITextFieldDelegate,
//UITextViewDelegate
>
{
    UIImagePickerController *_imagePickerController;
    //确定传的是哪个照片
    NSInteger num;
}
@end

@implementation CheckDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self _makeImageTouchLess];
    
    [self setBG];
    
    [self addNoticeForKeyboard];
}

- (void)_makeImageTouchLess
{
    self.firstImg.multipleTouchEnabled  = NO;
    self.secondImg.multipleTouchEnabled = NO;
    self.thirdImg.multipleTouchEnabled  = NO;
}

#pragma mark - 键盘通知
- (void)addNoticeForKeyboard {
    
    //注册键盘出现的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    //注册键盘消失的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
///键盘显示事件
- (void) keyboardWillShow:(NSNotification *)notification {
    //获取键盘高度，在不同设备上，以及中英文下是不同的
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    //计算出键盘顶端到inputTextView panel底端的距离(加上自定义的缓冲距离INTERVAL_KEYBOARD)
    CGFloat offset = 0.0;
    if ([_mterConditionTextField isFirstResponder]) {
        
        offset = (_mterConditionTextField.frame.origin.y+_mterConditionTextField.frame.size.height+10) - (self.view.frame.size.height - kbHeight);
    }else if([_meterNumTextField isFirstResponder]){
        
        offset = (_meterNumTextField.frame.origin.y+_meterNumTextField.frame.size.height+10) - (self.view.frame.size.height - kbHeight);
    }else{
        
        offset = (_remarkTextView.frame.origin.y+_remarkTextView.frame.size.height+10) - (self.view.frame.size.height - kbHeight);
    }
    
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    if ([_mterConditionTextField isFirstResponder] || [_remarkTextView isFirstResponder] || [_meterNumTextField isFirstResponder]) {
        
        //将视图上移计算好的偏移
        if(offset > 0) {
            [UIView animateWithDuration:duration animations:^{
                self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
            }];
        }
    }
}

///键盘消失事件
- (void) keyboardWillHide:(NSNotification *)notify {
    // 键盘动画时间
    double duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //视图下沉恢复原状
    [UIView animateWithDuration:duration animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (void)setBG {
    
    self.title = @"复核";
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_home_bg.png"]];
    
//    _mterConditionTextField.delegate = self;
//    _remarkTextView.delegate         = self;
//    
//    _mterConditionTextField.returnKeyType = UIReturnKeyDone;
//    _remarkTextView.returnKeyType         = UIReturnKeyDone;
    _meterNumTextField.keyboardType = UIKeyboardTypeNumberPad;
}

//- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    if ((textField.returnKeyType = UIReturnKeyDone)) {
//        
//        [_mterConditionTextField resignFirstResponder];
//    }
//}

//报修
- (IBAction)reportButton:(id)sender {
    
    
}

//提交
- (IBAction)submitButton:(id)sender {
    
    
}

- (IBAction)camera:(UIButton *)sender {
    
    switch (sender.tag) {
        case 500:
            
            break;
        case 501:
            
            break;
        case 502:
            
            break;
            
        default:
            break;
    }
    [self _camera:sender.tag];
}

- (void)_camera:(NSInteger )imageValue{
    num = imageValue;
    BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    if (!isCamera) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备不支持摄像头" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:NULL];
    }else
    {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = (id)self;
        _imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        _imagePickerController.allowsEditing = YES;
        [self selectImageFromCamera];
    }
}
#pragma mark 从摄像头获取图片或视频
- (void)selectImageFromCamera
{
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    //录制视频时长，默认10s
    _imagePickerController.videoMaximumDuration = 15;
    
    //相机类型（拍照、录像...）字符串需要做相应的类型转换
    _imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeJPEG];
    //设置摄像头模式（拍照，录制视频）为拍照模式
    _imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    [self presentViewController:_imagePickerController animated:YES completion:^{
        
    }];
}

//获取成功后赋值
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    if (num == 500) {
        
        self.firstImg.image = image;
    }
    if (num == 501) {
        self.secondImg.image = image;
        
    }
    if (num == 502) {
        self.thirdImg.image = image;
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectCondition:(id)sender {
    
    NSArray *multipleAssociatedData = @[// 数组
                                        @[@"正常", @"异常"], //这是第一列  --- 数组
                                        
                                        @{   /*key- 第一列中的   value(数组) --> 对应的第二类的数据 */
                                            @"正常": @[@"正常"],//字典
                                            @"异常": @[@"估表", @"故障", @"无量", @"异常处理", @"延迟抄表"],
                                            },
                                        
                                        @{ /*key- 第二列中的   value(数组) --> 对应的第三类的数据 */
                                            @"正常": @[@"正常"],
                                            @"估表": @[@"估值：120", @"估值：130", @"估值：140"],
                                            @"故障": @[@"水表破损", @"电缆损坏"],
                                            @"无量": @[@"无用量"]
                                            
                                            }
                                        
                                        ];
    [ZJUsefulPickerView showMultipleAssociatedColPickerWithToolBarText:@"请选择水表状况" withDefaultValues:@[@"正常", @"正常"] withData:multipleAssociatedData withCancelHandler:^{
        NSLog(@"quxiaole -----");
        
    } withDoneHandler:^(NSArray *selectedValues) {
        NSLog(@"%@---", selectedValues);
        _mterConditionTextField.text = [NSString stringWithFormat:@"%@",selectedValues[selectedValues.count-1]];
        
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [_averageNum resignFirstResponder];
    [_previousNum resignFirstResponder];
    [_bshTextField resignFirstResponder];
    [_userNum resignFirstResponder];
    [_meterInfo resignFirstResponder];
    [_userAddrTextfield resignFirstResponder];
    [_mterConditionTextField resignFirstResponder];
    [_remarkTextView resignFirstResponder];
    [_meterNumTextField resignFirstResponder];
}

@end
