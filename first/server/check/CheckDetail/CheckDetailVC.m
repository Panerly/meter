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
#import "TZPopInputView.h"

// 拼接字符串
static NSString *boundaryStr = @"--";   // 分隔字符串
static NSString *randomIDStr;           // 本次上传标示字符串
static NSString *uploadID;              // 上传(php)脚本中，接收文件字段

@interface CheckDetailVC ()
<
AVCaptureMetadataOutputObjectsDelegate,
UITextFieldDelegate
//UITextViewDelegate
>
{
    UIImagePickerController *_imagePickerController;
    //确定传的是哪个照片
    NSInteger num;
    UIImageView *loading;
}
@property (nonatomic, strong) TZPopInputView *inputView;    // 输入框

@end

@implementation CheckDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self _makeImageTouchLess];
    
    [self setBG];
    
    [self addNoticeForKeyboard];
    
    [self setDelegate];
    
    [self setValue];
}

- (void)setValue {
    
    self.averageNum.text = self.averageNumStr;
    self.previousNum.text = self.previousNumStr;
    self.bshTextField.text = self.bshTextStr;
    self.userNum.text = self.userNumStr;
    self.meterInfo.text = self.meterInfoStr;
    self.userAddrTextfield.text = self.userAddrStr;
}

- (void)setDelegate {
    
    self.averageNum.delegate = self;
    self.previousNum.delegate = self;
    self.bshTextField.delegate = self;
    self.userNum.delegate = self;
    self.meterInfo.delegate = self;
    self.userAddrTextfield.delegate = self;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return  NO;
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
    self.inputView.titleLable.text = @"报修信息";
    [self.inputView setItems:@[@"报修原因"]];
    
    [self.inputView show];
    
    self.inputView.textFiled1.placeholder = @"请输入";
    
    __weak typeof(self) weakSelf = self;
    
    self.inputView.okButtonClickBolck = ^(NSMutableArray *arr){
        [weakSelf.inputView hide];
        [weakSelf reportUpload:arr[0]];
    };
    
}

- (void)reportUpload :(NSString *)reason{
    NSLog(@"上报原因%@",reason);
    
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
    NSString *url = [NSString stringWithFormat:@"http://%@/Meter_Reading/ReportServlet",ip];
    
    NSURLSessionConfiguration *config   = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager       = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    manager.requestSerializer.timeoutInterval = 10;
    //获取系统当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *currentTime      = [formatter stringFromDate:[NSDate date]];
    NSDictionary *parameters = @{
                                 @"report_name":[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],
                                 @"user_addr":self.userAddrTextfield.text,
                                 @"user_id":self.userNum.text,
                                 @"report_time":currentTime,
                                 @"alarm_reason":reason,
                                 @"type":@"2",
                                 @"i_markingmode":@"3"
                                 };
    //
    AFHTTPResponseSerializer *serializer    = manager.responseSerializer;
    
    serializer.acceptableContentTypes       = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak typeof(self) weakSelf            = self;
    
    NSURLSessionTask *task =[manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [loading removeFromSuperview];
        
        if ([[responseObject objectForKey:@"type"] isEqualToString:@"成功"]) {
            
            //成功后退出
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else {
            UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"上传失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertVC addAction:action];
            [weakSelf presentViewController:alertVC animated:YES completion:^{
                
            }];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [loading removeFromSuperview];
       
        UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"上传失败" message:[NSString stringWithFormat:@"%@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [weakSelf presentViewController:alertVC animated:YES completion:^{
            
        }];
        
    }];
    
    [task resume];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_inputView) {
        
        self.inputView = [[TZPopInputView alloc] init];
    }
}

//提交
- (IBAction)submitButton:(id)sender {
    
    [AnimationView showInView:self.view];
    
    NSString *ip;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] isEqualToString:@"001"]) {
        
        ip = @"58.211.253.180:8000";
    }else{
        
        ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ip"];
    }
    
    NSString *uploadUrl = [NSString stringWithFormat:@"http://%@/Meter_Reading/Reading_nowServlet1",ip];
    
    AFSecurityPolicy *securityPolicy  = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager     = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    [manager setSecurityPolicy:securityPolicy];
    
    NSData *data = UIImageJPEGRepresentation(_firstImg.image, .1f);
    NSData *data2 = UIImageJPEGRepresentation(_secondImg.image, .1f);
    
    NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
    if (data) {
        
        [imageDic setObject:data forKey:[NSString stringWithFormat:@"first%@.jpg",self.userNumStr]];
    }
    if (data2) {
        
        [imageDic setObject:data2 forKey:[NSString stringWithFormat:@"second%@.jpg",self.userNumStr]];
    }
    
    //获取系统当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *currentTime      = [formatter stringFromDate:[NSDate date]];
    
    NSDictionary *para = [NSDictionary dictionary];
    /*@interface CheckDetailVC : UIViewController
     @property (weak, nonatomic) IBOutlet UITextField *averageNum;
     @property (weak, nonatomic) IBOutlet UITextField *previousNum;
     @property (weak, nonatomic) IBOutlet UITextField *bshTextField;
     @property (weak, nonatomic) IBOutlet UITextField *userNum;
     @property (weak, nonatomic) IBOutlet UITextField *meterInfo;
     @property (weak, nonatomic) IBOutlet UITextField *userAddrTextfield;
     @property (weak, nonatomic) IBOutlet UITextField *mterConditionTextField;
     @property (weak, nonatomic) IBOutlet UITextView *remarkTextView;
     @property (weak, nonatomic) IBOutlet UILabel *remarkLabel;*/
    NSDictionary *parameters = @{
                                 @"bs"      : @"1",
                                 @"i_MarkingMode"    : @"3",
                                 @"i_ChaoMa"   : _meterNumTextField.text,
                                 @"i_ShuiLiang_ChaoJian"   : [NSString stringWithFormat:@"%ld",[_meterNumTextField.text integerValue]- [_previousNum.text integerValue]],
                                 @"D_ChaoBiao": currentTime,
                                 @"s_BeiZhu" : self.remarkTextView.text,
                                 @"s_CID" : self.userNum.text
                                 };
    
    NSError *error;
    NSData *dataPara = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:dataPara encoding:NSUTF8StringEncoding];
    
    NSDictionary *jsonpara = @{
                               @"meter_key":jsonString
                               };
    para = jsonpara;
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    
    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    
    [self uploadFileWithURL:[NSURL URLWithString:uploadUrl] imageDic:imageDic pramDic:para manager:manager];
//    if (increaseAlarm>0) {//判断是否有预设值
//        
//        if (increase > increaseAlarm) {
//            
//            [AnimationView dismiss];
//            UIAlertAction *action       = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
//            UIAlertController *alertVC  = [UIAlertController alertControllerWithTitle:@"提示" message:@"本期抄表增幅值大于警报增幅值！\n请核实后重新填入，或者进入设置修改预设增幅警报值" preferredStyle:UIAlertControllerStyleAlert];
//            [alertVC addAction:action];
//            [self presentViewController:alertVC animated:YES completion:^{
//            }];
//        }else{//通过增幅监测
//            
//            
//        }
//        
//    }else{
//        [AnimationView dismiss];
//        UIAlertAction *action      = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
//        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"未设置增幅警报" message:@"预设增幅警报值不能为0，\n进入设置修改预设增幅警报值" preferredStyle:UIAlertControllerStyleAlert];
//        [alertVC addAction:action];
//        [self presentViewController:alertVC animated:YES completion:^{
//            
//        }];
//    }
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
    
    //获取系统当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *currentTime      = [formatter stringFromDate:[NSDate date]];
    NSString *attachingString = [NSString stringWithFormat:@"%@\n%@",currentTime,self.userNum.text];
    
    if (num == 500) {
        
        self.firstImg.image = [self addWatemarkTextAfteriOS7_WithLogoImage:image watemarkText:attachingString];
    }
    if (num == 501) {
        
        self.secondImg.image = [self addWatemarkTextAfteriOS7_WithLogoImage:image watemarkText:attachingString];
    }
    if (num == 502) {
        
        self.thirdImg.image = [self addWatemarkTextAfteriOS7_WithLogoImage:image watemarkText:attachingString];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

//添加水印信息
- (UIImage *)addWatemarkTextAfteriOS7_WithLogoImage:(UIImage *)logoImage watemarkText:(NSString *)watemarkText{
    int w = logoImage.size.width;
    int h = logoImage.size.height;
    UIGraphicsBeginImageContext(logoImage.size);
    [[UIColor redColor] set];
    [logoImage drawInRect:CGRectMake(0, 0, w, h)];
    UIFont * font = [UIFont systemFontOfSize:50];
    [watemarkText drawInRect:CGRectMake(10, 55, PanScreenWidth-20, 80*3) withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:[UIColor redColor]}];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (IBAction)selectCondition:(id)sender {

    
    NSArray *multipleAssociatedData = @[// 数组
                                        @[@"正常", @"异常"], //这是第一列  --- 数组
                                        
                                        @{   /*key- 第一列中的   value(数组) --> 对应的第二类的数据 */
                                            @"正常": @[@"正常"],//字典
                                            @"异常": @[@"估表", @"故障", @"无量"],
                                            },
                                        
                                        @{ /*key- 第二列中的   value(数组) --> 对应的第三类的数据 */
                                            @"正常": @[@"过圈",@"正常换表"],
                                            @"估表": @[@"堆设", @"门闭", @"水没",@"市政处理",@"暂估"],
                                            @"故障": @[@"水表破损", @"电缆损坏",@"申请换表",@"停走",@"失灵",@"黑面",@"壳漏",@"玻璃碎",@"倒装",@"针偏"],
                                            @"无量": @[@"无用量"]
                                            
                                            }
                                        
                                        ];
    [ZJUsefulPickerView showMultipleAssociatedColPickerWithToolBarText:@"请选择水表状况" withDefaultValues:@[@"正常", @"正常",@"正常换表"] withData:multipleAssociatedData withCancelHandler:^{
        NSLog(@"cancel -----");
        
    } withDoneHandler:^(NSArray *selectedValues) {
        NSLog(@"%@---", selectedValues);
        _mterConditionTextField.text = [NSString stringWithFormat:@"%@",selectedValues[selectedValues.count-1]];
        NSString *str = [NSString stringWithFormat:@"%@",selectedValues[1]];
        if ([str containsString:@"估表"]) {
            _meterNumTextField.text = [NSString stringWithFormat:@"%ld",[self.averageNumStr integerValue]+[self.previousNumStr integerValue]];
            
        }
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

#pragma mark - 私有方法
- (NSString *)topStringWithMimeType:(NSString *)mimeType uploadFile:(NSString *)uploadFile
{
    NSMutableString *strM = [NSMutableString string];
    
    [strM appendFormat:@"\r\n%@%@\r\n", boundaryStr, randomIDStr];
    [strM appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", uploadID,uploadFile];
    [strM appendFormat:@"Content-Type: %@\r\n\r\n", mimeType];
    
    NSLog(@"%@", strM);
    return [strM copy];
}

- (NSString *)bottomString:(NSString *)key value:(NSString *)value
{
    NSMutableString *strM = [NSMutableString string];
    
    [strM appendFormat:@"\r\n%@%@\r\n", boundaryStr, randomIDStr];
    [strM appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
    [strM appendFormat:@"%@\r\n",value];
    
    
    NSLog(@"%@", strM);
    return [strM copy];
}

#pragma mark - 上传文件
- (void)uploadFileWithURL:(NSURL *)url imageDic:(NSDictionary *)imgDic pramDic:(NSDictionary *)pramDic manager:(AFHTTPSessionManager *)manager
{
    // 1> 数据体
    
    
    NSMutableData *dataM = [NSMutableData data];
    
    //    [dataM appendData:[boundaryStr dataUsingEncoding:NSUTF8StringEncoding]];
    for (NSString *name  in [imgDic allKeys]) {
        NSString *topStr = [self topStringWithMimeType:@"image/png" uploadFile:name];
        [dataM appendData:[topStr dataUsingEncoding:NSUTF8StringEncoding]];
        [dataM appendData:[imgDic valueForKey:name]];
    }
    
    for (NSString *name  in [pramDic allKeys]) {
        NSString *bottomStr = [self bottomString:name value:[pramDic valueForKey:name]];
        [dataM appendData:[bottomStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [dataM appendData:[[NSString stringWithFormat:@"%@%@--\r\n", boundaryStr, randomIDStr] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    // 1. Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:20];
    
    // dataM出了作用域就会被释放,因此不用copy
    request.HTTPBody = dataM;
    //    NSLog(@"%@",dataM);
    
    // 2> 设置Request的头属性
    request.HTTPMethod = @"POST";
    
    // 3> 设置Content-Length
    NSString *strLength = [NSString stringWithFormat:@"%ld", (long)dataM.length];
    [request setValue:strLength forHTTPHeaderField:@"Content-Length"];
    
    // 4> 设置Content-Type
    NSString *strContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", randomIDStr];
    [request setValue:strContentType forHTTPHeaderField:@"Content-Type"];
    
    
    __weak typeof(self) weakSelf = self;
    
    // 3> 连接服务器发送请求
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        [AnimationView dismiss];
        NSLog(@"上传成功：%@",responseObject);
        if ([[responseObject objectForKey:@"type"] isEqualToString:@"成功"]) {
            
            [SCToastView showInView:self.view text:@"上传成功" duration:1 autoHide:YES];
            
            //成功后退出
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [SCToastView showInView:self.view text:[NSString stringWithFormat:@"上传失败%@",error] duration:1 autoHide:YES];
        }
        if (error) {
            NSLog(@"上传失败：%@",error);
            [AnimationView dismiss];
            [SCToastView showInView:self.view text:[NSString stringWithFormat:@"上传失败！\n原因:%@",error.code== -1004?@"服务器连接失败":error.localizedDescription] duration:5 autoHide:YES];
        }
    }];
    
    [task resume];
    
}

@end
