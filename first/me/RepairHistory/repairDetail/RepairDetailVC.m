//
//  RepairDetailVC.m
//  first
//
//  Created by panerly on 08/06/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import "RepairDetailVC.h"
#import "KZVideoSupport.h"
#import "KZVideoViewController.h"
#import "KZVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "DelayVC.h"

@interface RepairDetailVC ()
<
AVCaptureMetadataOutputObjectsDelegate,
UIImagePickerControllerDelegate,
CLLocationManagerDelegate,
KZVideoViewControllerDelegate
>
{
    UIImagePickerController *_imagePickerController;
    NSMutableString *videoNameCopy;
    KZVideoModel *_videoModel;
    UIView *playView;
    UILabel *progressLabel;
    UIImageView *imgView;
    NSString *x;
    NSString *y;
}
@property (nonatomic, strong) NSURL *videoURL;

@property (nonatomic, strong) NSURL *gifURL;

@property (nonatomic, strong) CLLocationManager* locationManager;

@property (nonatomic, strong) KZEyeView *showViews;
@end

@implementation RepairDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.user_id;
    
    [self setBG];
    [self setUI];
    [self addNoticeForKeyboard];
    
    //定位
    [self orientate];
    
    UIBarButtonItem *changeMeter = [[UIBarButtonItem alloc] initWithTitle:@"换表" style:UIBarButtonItemStylePlain target:self action:@selector(checkValue)];
    self.navigationItem.rightBarButtonItem = changeMeter;
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
    CGFloat offset = (_remarksTextView.frame.origin.y+_remarksTextView.frame.size.height+10) - (self.view.frame.size.height - kbHeight);
    
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //将视图上移计算好的偏移
    if(offset > 0) {
        [UIView animateWithDuration:duration animations:^{
            self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
        }];
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
    
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    
    [bgView setImage:[UIImage imageNamed:@"icon_home_bg"]];
    
    [self.view addSubview:bgView];
}

- (void)setUI {
    
    
    _userName     = [[UILabel alloc] init];
    _repairReason = [[UILabel alloc] init];
    _repairStatus = [[UILabel alloc] init];
    _phoneNum     = [[UILabel alloc] init];
    _installAddr  = [[UILabel alloc] init];
    _remarkStr    = [[UILabel alloc] init];
    _repairedNumStr = [[UILabel alloc] init];
    _repairedReasonLabel = [[UILabel alloc] init];
    _spotConditionLabel = [[UILabel alloc] init];
    _user_addrLabel = [[UILabel alloc] init];
    
    _plusBtn    = [[UIButton alloc] init];
    _locaBtn    = [[UIButton alloc] init];
    _locaStr    = [[UILabel alloc] init];
    _resetBtn   = [[UIButton alloc] init];
    _delayBtn   = [[UIButton alloc] init];
    _uploadBtn  = [[UIButton alloc] init];

    _remarksTextView     = [[UITextView alloc] init];
    _repairedNumTextField = [[UITextField alloc] init];
    _repairedReasonTextField = [[UITextField alloc] init];
    _showViews = [[KZEyeView alloc] init];
    
    [self.view addSubview:_userName];
    [self.view addSubview:_repairReason];
    [self.view addSubview:_repairStatus];
    [self.view addSubview:_phoneNum];
    [self.view addSubview:_installAddr];
    [self.view addSubview:_plusBtn];
    [self.view addSubview:_locaBtn];
    [self.view addSubview:_locaStr];
    [self.view addSubview:_resetBtn];
    [self.view addSubview:_delayBtn];
    [self.view addSubview:_uploadBtn];

    [self.view addSubview:_remarksTextView];
    [self.view addSubview:_repairedNumTextField];
    [self.view addSubview:_repairedReasonTextField];
    
    [self.view addSubview:_remarkStr];
    [self.view addSubview:_repairedNumStr];
    [self.view addSubview:_repairedReasonLabel];
    [self.view addSubview:_spotConditionLabel];
    [self.view addSubview:_user_addrLabel];
    
    [self.view addSubview:_showViews];
    /*@property(nonatomic, copy) NSString *user_id;       //用户号
     @property(nonatomic, copy) NSString *bsh;           //表身号
     @property(nonatomic, copy) NSString *appearance;    //报警原因
     @property(nonatomic, copy) NSString *stage;         //维修状态
     @property(nonatomic, copy) NSString *repair_name;   //维修人员
     @property(nonatomic, copy) NSString *alert_time;    //报警时间*/
    //set reserveValue

    _userName.text = [NSString stringWithFormat:@"维修人员: %@", self.repair_name];
    _userName.font = [UIFont systemFontOfSize:15];
    
    _repairStatus.text = [NSString stringWithFormat:@"状        态: %@",self.stage];
    _repairStatus.font = [UIFont systemFontOfSize:15];
    
    _spotConditionLabel.text = [NSString stringWithFormat:@"现场状态: %@",self.spotCondition];
    _spotConditionLabel.font = [UIFont systemFontOfSize:15];
    
    _repairReason.text = [NSString stringWithFormat:@"%@",self.appearance];
    _repairReason.font = [UIFont systemFontOfSize:15];
    
    _repairReason.textColor = [UIColor redColor];
    _repairReason.textAlignment = NSTextAlignmentRight;
    
    _phoneNum.text = [NSString stringWithFormat:@"表  身  号: %@",self.bsh];
    _phoneNum.font = [UIFont systemFontOfSize:15];
    
    _installAddr.text = [NSString stringWithFormat:@"下单时间: %@",self.alert_time];
    _installAddr.font = [UIFont systemFontOfSize:15];
    
    _user_addrLabel.text = [NSString stringWithFormat:@"用户地址:%@",self.user_addr];
    _user_addrLabel.font = [UIFont systemFontOfSize:15];
    
    
    
    
    [_plusBtn setImage:[UIImage imageNamed:@"icon_plus"] forState:UIControlStateNormal];
    [_plusBtn addTarget:self action:@selector(addVideoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_locaBtn setImage:[UIImage imageNamed:@"orientate"] forState:UIControlStateNormal];
    _locaBtn.showsTouchWhenHighlighted = YES;
    [_locaBtn addTarget:self action:@selector(orientate) forControlEvents:UIControlEventTouchUpInside];
    _locaStr.text = @"请定位";
    _locaStr.textColor = [UIColor redColor];
    _locaStr.textAlignment = NSTextAlignmentRight;
    
    [_resetBtn setTitle:@"重置" forState:UIControlStateNormal];
    _resetBtn.backgroundColor = [UIColor colorWithRed:128/255.0f green:218/255.0f blue:249/255.0f alpha:1];
    _resetBtn.clipsToBounds = YES;
    _resetBtn.layer.cornerRadius = 10;
    _resetBtn.showsTouchWhenHighlighted = YES;
    [_resetBtn addTarget:self action:@selector(resetData) forControlEvents:UIControlEventTouchUpInside];
    
    [_delayBtn setTitle:@"延迟维修" forState:UIControlStateNormal];
    _delayBtn.backgroundColor = [UIColor redColor];
    _delayBtn.clipsToBounds = YES;
    _delayBtn.layer.cornerRadius = 10;
    _delayBtn.showsTouchWhenHighlighted = YES;
    [_delayBtn addTarget:self action:@selector(delayAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    _uploadBtn.backgroundColor = [UIColor colorWithRed:255/255.0f green:153/255.0f blue:0 alpha:1];
    _uploadBtn.layer.cornerRadius = 10;
    _uploadBtn.showsTouchWhenHighlighted = YES;
    [_uploadBtn addTarget:self action:@selector(uploadVideoData) forControlEvents:UIControlEventTouchUpInside];
    
    _remarksTextView.layer.cornerRadius = 4;
    _remarksTextView.layer.masksToBounds = YES;
    
    _repairedNumTextField.borderStyle = UITextBorderStyleRoundedRect;
    _repairedNumTextField.keyboardType = UIKeyboardTypeNumberPad;
    _repairedNumTextField.placeholder = @"请输入读数";
    
    _repairedReasonTextField.borderStyle = UITextBorderStyleRoundedRect;
    _repairedReasonTextField.placeholder = @"请输入维修原因";
    
    _repairedNumStr.text        = @"水 表  读 数:";
    _repairedNumStr.textColor   = [UIColor whiteColor];
    
    _repairedReasonLabel.text   = @"维 修  原 因:";
    _repairedReasonLabel.textColor = [UIColor whiteColor];
    
    _remarkStr.text             = @"备            注:";
    _remarkStr.textColor        = [UIColor whiteColor];
    
//    _previewImageView.backgroundColor = [UIColor lightGrayColor];
//    _previewImageView.alpha = .5f;
    _showViews.userInteractionEnabled = NO;
    _showViews.hidden = YES;
    

    // make constraints
    __weak typeof(self)weakSelf = self;
    NSUInteger labelHeight = 25;
    
    [_userName mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(weakSelf.view.mas_left).with.offset(10);
        make.top.equalTo(weakSelf.view.mas_top).with.offset(64 + 10);
        make.size.equalTo(CGSizeMake(PanScreenWidth - 10 * 2 - 150, labelHeight));
    }];
    
    [_repairReason mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(weakSelf.view.mas_right).with.offset(-5);
        make.top.equalTo(weakSelf.view.mas_top).with.offset(64 + 10);
        make.size.equalTo(CGSizeMake(150, labelHeight));
    }];
    
    [_repairStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(weakSelf.view.mas_left).with.offset(10);
        make.top.equalTo(weakSelf.userName.mas_bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(PanScreenWidth - 10 * 2, labelHeight));
    }];
    
    [_spotConditionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(weakSelf.view.left).with.offset(10);
        make.top.equalTo(weakSelf.repairStatus.bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(PanScreenWidth - 10 * 2, labelHeight));
    }];
    
    [_phoneNum mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(weakSelf.view.left).with.offset(10);
        make.top.equalTo(weakSelf.spotConditionLabel.bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(PanScreenWidth - 10 * 2, labelHeight));
    }];
    
    [_installAddr mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(weakSelf.view.left).with.offset(10);
        make.top.equalTo(weakSelf.phoneNum.bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(PanScreenWidth - 10 * 2, labelHeight));
    }];
    
    [_user_addrLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(weakSelf.view.left).with.offset(10);
        make.top.equalTo(weakSelf.installAddr.bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(PanScreenWidth - 10, labelHeight));
    }];
    
    [_plusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(weakSelf.view.left).with.offset(20);
        make.top.equalTo(weakSelf.user_addrLabel.bottom).with.offset(20);
        make.size.equalTo(CGSizeMake(PanScreenWidth/3.5, PanScreenWidth/3.5));
    }];
    
    [_showViews mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(weakSelf.view.left).with.offset(20);
        make.top.equalTo(weakSelf.user_addrLabel.bottom).with.offset(20);
        make.size.equalTo(CGSizeMake(PanScreenWidth/3.5, PanScreenWidth/3.5));
    }];
    
    [_locaBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(weakSelf.view.right).with.offset(-10);
        make.top.equalTo(weakSelf.user_addrLabel.bottom).with.offset(PanScreenWidth/3.5/2+15-5);
        make.size.equalTo(CGSizeMake(40, 40));
    }];
    
    [_locaStr mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(weakSelf.locaBtn.left).with.offset(-5);
        make.top.equalTo(weakSelf.user_addrLabel.bottom).with.offset(PanScreenWidth/3.5/2+15);
        make.size.equalTo(CGSizeMake(150, 30));
    }];
    
    [_resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(weakSelf.view.mas_left).with.offset(20);
        make.bottom.equalTo(weakSelf.view.mas_bottom).with.offset(-10);
        make.size.equalTo(CGSizeMake(PanScreenWidth/4, PanScreenWidth/8));
    }];
    
    [_delayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(weakSelf.view.centerX);
        make.bottom.equalTo(weakSelf.view.mas_bottom).with.offset(-10);
        make.size.equalTo(CGSizeMake(PanScreenWidth/4, PanScreenWidth/8));
    }];
    
    [_uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(weakSelf.view.mas_right).with.offset(-20);
        make.bottom.equalTo(weakSelf.view.mas_bottom).with.offset(-10);
        make.size.equalTo(CGSizeMake(PanScreenWidth/4, PanScreenWidth/8));
    }];
    
    [_repairedNumStr mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(weakSelf.view.mas_left).with.offset(10);
        make.top.equalTo(weakSelf.locaBtn.mas_bottom).with.offset(30);
        make.size.equalTo(CGSizeMake(PanScreenWidth/3, 30));
    }];
    [_repairedNumTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(weakSelf.remarkStr.mas_right).with.offset(-15);
        make.right.equalTo(weakSelf.view.mas_right).with.offset(-10);
        make.top.equalTo(weakSelf.locaBtn.mas_bottom).with.offset(30);
    }];
    
    [_repairedReasonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(weakSelf.view.mas_left).with.offset(10);
        make.top.equalTo(weakSelf.repairedNumStr.mas_bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(PanScreenWidth/3, 30));
    }];
    
    [_repairedReasonTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(weakSelf.remarkStr.mas_right).with.offset(-15);
        make.right.equalTo(weakSelf.view.mas_right).with.offset(-10);
        make.top.equalTo(weakSelf.repairedNumStr.mas_bottom).with.offset(5);
    }];
    
    
    [_remarkStr mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(weakSelf.view.mas_left).with.offset(10);
        make.top.equalTo(weakSelf.repairedReasonLabel.mas_bottom).with.offset(5);
        make.size.equalTo(CGSizeMake(PanScreenWidth/3, 30));
    }];
    [_remarksTextView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(weakSelf.remarkStr.mas_right).with.offset(-15);
        make.right.equalTo(weakSelf.view.mas_right).with.offset(-10);
        make.top.equalTo(weakSelf.repairedReasonLabel.mas_bottom).with.offset(5);
        make.height.equalTo(60);
    }];
}

- (void)delayAction {
    
    DelayVC *delayVC = [[DelayVC alloc] init];
    delayVC.user_id = self.user_id;
    [self.navigationController showViewController:delayVC sender:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_remarksTextView resignFirstResponder];
    [_repairedNumTextField resignFirstResponder];
    [_repairedReasonTextField resignFirstResponder];
    [playView removeFromSuperview];
//    for (UIView *subview in self.view.window.subviews) {
//        if ([subview isKindOfClass:[playView class]]) {
//            [subview removeFromSuperview];
//        }
//    }
    playView = nil;
}

//拍照、录视频、预览
- (void)addVideoAction:(UIButton *)sender {
    
    __weak typeof(self)weakSelf = self;
    
    if (_videoModel) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择拍摄类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *playAction = [UIAlertAction actionWithTitle:@"播放" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf playAction];
        }];
        UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (_videoModel) {
                
                _videoModel = nil;
            }
            for (UIView *subview in weakSelf.showViews.subviews) {
                [subview removeFromSuperview];
            }
            [weakSelf takePhoto];
        }];
        UIAlertAction *makeVideoAction = [UIAlertAction actionWithTitle:@"录视频--小屏" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (_videoModel) {
                
                _videoModel = nil;
            }
            [weakSelf recordMovie];
        }];
        UIAlertAction *makeVideoFAction = [UIAlertAction actionWithTitle:@"录视频--全屏" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (_videoModel) {
                
                _videoModel = nil;
            }
            [weakSelf recordFullScreen];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alertVC addAction:playAction];
        [alertVC addAction:takePhotoAction];
        [alertVC addAction:makeVideoAction];
        [alertVC addAction:makeVideoFAction];
        [alertVC addAction:cancelAction];
        
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
    }else {
        
    }
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择拍摄类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (_videoModel) {
            
            _videoModel = nil;
        }
        for (UIView *subview in weakSelf.showViews.subviews) {
            [subview removeFromSuperview];
        }
        [weakSelf takePhoto];
    }];
    UIAlertAction *makeVideoAction = [UIAlertAction actionWithTitle:@"录视频--小屏" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (_videoModel) {
            
            _videoModel = nil;
        }
        [weakSelf recordMovie];
    }];
    UIAlertAction *makeVideoFAction = [UIAlertAction actionWithTitle:@"录视频--全屏" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (_videoModel) {
            
            _videoModel = nil;
        }
        [weakSelf recordFullScreen];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertVC addAction:takePhotoAction];
    [alertVC addAction:makeVideoAction];
    [alertVC addAction:makeVideoFAction];
    [alertVC addAction:cancelAction];
    
    [self presentViewController:alertVC animated:YES completion:^{
        
    }];
}

#pragma mark 从摄像头获取图片
- (void)takePhoto{

    _videoModel = nil;
    //[_showViews reloadInputViews];
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
    
    //_uploadBtn.imageView.image = image;
    
    imgView = [[UIImageView alloc] initWithFrame:_showViews.bounds];
    imgView.image = image;
    
    [_showViews addSubview:imgView];
    _showViews.hidden = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - recordMovie 录制视频 
//小屏录制
- (void)recordMovie {
    
    _uploadBtn.imageView.image = nil;
    KZVideoViewController *videoVC = [[KZVideoViewController alloc] init];
    videoVC.delegate = self;
    videoVC.savePhotoAlbum = YES;
    [videoVC startAnimationWithType:KZVideoViewShowTypeSmall];
}
//全屏录制
- (void)recordFullScreen {
    
    KZVideoViewController *videoVC = [[KZVideoViewController alloc] init];
    videoVC.delegate = self;
    videoVC.savePhotoAlbum = YES;
    [videoVC startAnimationWithType:KZVideoViewShowTypeSingle];
}

#pragma mark - KZVideoViewControllerDelegate
- (void)videoViewController:(KZVideoViewController *)videoController didRecordVideo:(KZVideoModel *)videoModel {
    
    _videoModel = videoModel;
    
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *attri = [fm attributesOfItemAtPath:_videoModel.videoAbsolutePath error:&error];
    if (error) {
        NSLog(@"error:%@",error);
    }else {
//        self.videoSizeLable.text = [NSString stringWithFormat:@"视频总大小:%.0fKB",attri.fileSize/1024.0];
        NSLog(@"视频总大小:%.0fKB",attri.fileSize/1024.0);
    }
    
    for (UIView *subview in _showViews.subviews) {
        [subview removeFromSuperview];
    }
    if (_videoModel.videoAbsolutePath) {
        
        _showViews.hidden = NO;
        
        NSURL *videoUrl = [NSURL fileURLWithPath:_videoModel.videoAbsolutePath];
        KZVideoPlayer *player = [[KZVideoPlayer alloc] initWithFrame:_showViews.bounds videoUrl:videoUrl];
        [_showViews addSubview:player];
    }
}
- (void)playAction {
    
    playView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:playView];
    playView.backgroundColor = [UIColor blackColor];
    //playView.alpha = .5f;
    if (_videoModel.videoAbsolutePath) {
        
        NSURL *videoUrl = [NSURL fileURLWithPath:_videoModel.videoAbsolutePath];
        KZVideoPlayer *player = [[KZVideoPlayer alloc] initWithFrame:CGRectMake(0, PanScreenHeight/3, PanScreenWidth, PanScreenHeight/5*2) videoUrl:videoUrl];
        [_showViews addSubview:player];
        [playView addSubview:player];
    }else {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"无法获取视频，请拍摄" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:cancel];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}
- (void)videoViewControllerDidCancel:(KZVideoViewController *)videoController {
    NSLog(@"没有录到视频");
}

#pragma mark - orientate 定位
//定位
- (void)orientate {
    [SCToastView showInView:[UIApplication sharedApplication].keyWindow text:@"正在定位..." duration:1 autoHide:YES];
    //检测定位功能是否开启
    if([CLLocationManager locationServicesEnabled]){
        if(!_locationManager){
            self.locationManager = [[CLLocationManager alloc] init];
            if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
                
                [self.locationManager requestWhenInUseAuthorization];
                [self.locationManager requestAlwaysAuthorization];
            }
        }
        //设置代理
        self.locationManager.delegate = self;
        //设置定位精度
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        //设置距离筛选
        [self.locationManager setDistanceFilter:5.0];
        //开始定位
        [self.locationManager startUpdatingLocation];
        //设置开始识别方向
        [self.locationManager startUpdatingHeading];
        
    }else{
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"定位信息" message:@"您没有开启定位功能" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
    }
    
}
#pragma mark - CLLocationManagerDelegate 代理方法实现
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    NSLog(@"经度：%f,纬度：%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
    [SCToastView showInView:[UIApplication sharedApplication].keyWindow text:@"定位成功" duration:1 autoHide:YES];
    
    [_locationManager stopUpdatingLocation];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"使用当前坐标 ？" message:[NSString stringWithFormat:@"\n经度：%f\n\n纬度：%f",newLocation.coordinate.longitude,newLocation.coordinate.latitude] preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        x = [NSString  stringWithFormat:@"%f", newLocation.coordinate.longitude];
        y = [NSString  stringWithFormat:@"%f", newLocation.coordinate.latitude];
        
        weakSelf.locaStr.text = [NSString stringWithFormat:@"[%.3f,%.3f]",newLocation.coordinate.longitude,newLocation.coordinate.latitude];
        weakSelf.locaStr.textColor = [UIColor blackColor];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertVC addAction:cancel];
    [alertVC addAction:action];
    
    [self presentViewController:alertVC animated:YES completion:^{
        
    }];
    
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
    [SVProgressHUD showErrorWithStatus:@"定位失败"];
}

#pragma mark - 上传维修数据

- (void)uploadVideoData {
    
    progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, PanScreenHeight/2, PanScreenWidth, 40)];
    progressLabel.text = @"正在上传，请稍后...";
    progressLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:progressLabel];
    
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ip"];
    
    NSString *uploadVideoUrl                  = [NSString stringWithFormat:@"http://%@/Meter_Reading/MaintenanceTaskUploadServlet",ip];
    
    NSURLSessionConfiguration *config   = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager       = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    manager.requestSerializer.timeoutInterval = 10;
    
    AFHTTPResponseSerializer *serializer    = manager.responseSerializer;
    
    serializer.acceptableContentTypes       = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    
    __weak typeof(self) weakSelf            = self;
    if (_videoModel.videoAbsolutePath) {
        
        self.videoURL = [NSURL fileURLWithPath:_videoModel.videoAbsolutePath];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *currentTime      = [formatter stringFromDate:[NSDate date]];
    
    
    NSDictionary *paraDic = @{
                              @"user_name":self.user_id,
                              @"reason":_repairedReasonTextField.text?_repairedReasonTextField.text:_repairReason.text,
                              @"repairStatus":@"已维修",
                              @"phoneNum":self.bsh,
                              @"user_addr":self.alert_time,
                              @"x":x?x:@"",
                              @"y":y?y:@"",
                              @"remarks":_remarksTextView.text?_remarksTextView.text:@"",
                              @"fix_number":_repairedNumTextField.text?_repairedNumTextField.text:@"",
                              @"repairMan":[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],
                              @"uploadTime":currentTime,
                              @"type":self.type
                              };
    NSError *error;
    NSData *dataPara     = [NSJSONSerialization dataWithJSONObject:paraDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:dataPara encoding:NSUTF8StringEncoding];
    
    NSDictionary *para = @{
                           @"para_key":jsonString
                           };
    
    [manager POST:uploadVideoUrl parameters:para constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        if (!_videoModel && imgView.image) {
            
            NSData *imgData = UIImageJPEGRepresentation(imgView.image, 1);
            [formData appendPartWithFileData:imgData name:@"video" fileName:[NSString stringWithFormat:@"123.jpg"] mimeType:@"jpg"];
        }else if(_videoModel){
            
            [formData appendPartWithFileURL:weakSelf.videoURL name:@"video" fileName:[NSString stringWithFormat:@"123.mp4"] mimeType:@"mp4" error:nil];
        }else{
            
            UIImage *img = [UIImage imageNamed:@"pic"];
            NSData *imgData = UIImageJPEGRepresentation(img, 1);
            [formData appendPartWithFileData:imgData name:@"video" fileName:[NSString stringWithFormat:@"123.png"] mimeType:@"png"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
//        if (uploadProgress.totalUnitCount == uploadProgress.completedUnitCount) {
//            [SCToastView hideInView:weakSelf.view];
//        }else {
//            
//            [SCToastView showInView:weakSelf.view text:[NSString stringWithFormat:@"已上传：%lld",uploadProgress.completedUnitCount] duration:0 autoHide:NO];
//        }
        progressLabel.text = [NSString stringWithFormat:@"正在上传：%lld％", uploadProgress.completedUnitCount/uploadProgress.totalUnitCount];
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

//        if ([SCToastView isShowingInView:weakSelf.view]) {
//            
//            [SCToastView hideInView:weakSelf.view];
//        }
        progressLabel.hidden = YES;
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
        progressLabel.hidden = YES;
        [SCToastView showInView:weakSelf.view text:[NSString stringWithFormat:@"上传失败：%@",error] duration:5 autoHide:YES];
    }];
    
}
- (void)showProgressStatus :(CGFloat)progressValue{
    [SVProgressHUD showProgress:5 status:[NSString stringWithFormat:@"上传中:"] maskType:SVProgressHUDMaskTypeGradient];
}

#pragma mark - reset重置
- (void)resetData {
    
    _locaStr.text       = @"请定位";
    _locaStr.textColor  = [UIColor redColor];
    _repairedNumTextField.text  = @"";
    _remarksTextView.text       = @"";
    for (UIView *subview in _showViews.subviews) {
        [subview removeFromSuperview];
    }
    _showViews.hidden = YES;
}

#pragma mark - 换表流程
//换表流程
- (void)changeMeterAction {
    
    UIAlertController *alertSheet = [UIAlertController alertControllerWithTitle:@"请选择换表方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *changeMeter = [UIAlertAction actionWithTitle:@"换表流程" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf changeMeter:@"0"];
    }];
    UIAlertAction *dig = [UIAlertAction actionWithTitle:@"开挖流程" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf changeMeter:@"1"];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertSheet addAction:changeMeter];
    [alertSheet addAction:dig];
    [alertSheet addAction:cancel];
    [self presentViewController:alertSheet animated:YES completion:^{
        
    }];
}

//检查
- (void)checkValue {
    
    //check item is null
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    NSString *message = @"请检查，部分参数为空！";
    
    
    if ([_repairedReasonTextField.text isEqualToString:@""]) {
        
        message = @"请输入维修原因";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"参数不能为空" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:confirm];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }else if ([_repairedNumTextField.text isEqualToString:@""]){
        
        message = @"请输入读数";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"参数不能为空" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:confirm];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }else{
        
        [self changeMeterAction];
    }
}

- (void)changeMeter :(NSString *)bs{
    
    [AnimationView showInView:self.view];
    
    progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, PanScreenHeight/2 + 10, PanScreenWidth, 40)];
    progressLabel.text = @"正在上传，请稍后...";
    progressLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:progressLabel];
    
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ip"];
    
    NSString *uploadVideoUrl                  = [NSString stringWithFormat:@"http://%@/Meter_Reading/HuanBiaoServlet",ip];
    
    NSURLSessionConfiguration *config   = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager       = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    
    manager.requestSerializer.timeoutInterval = 10;
    
    AFHTTPResponseSerializer *serializer    = manager.responseSerializer;
    
    serializer.acceptableContentTypes       = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    
    __weak typeof(self) weakSelf            = self;
    if (_videoModel.videoAbsolutePath) {
        
        self.videoURL = [NSURL fileURLWithPath:_videoModel.videoAbsolutePath];
    }
    
    NSDictionary *parameters = @{
                                 @"bs"          :bs,
                                 @"kj"          :self.kj,
                                 @"type"        :self.type,
                                 @"diZhi"       :self.user_addr,
                                 @"huHao"       :self.user_id,
                                 @"huMing"      :self.user_name,
                                 @"biaoHao"     :self.bsh,
                                 @"yuanYin"     :self.repairedReasonTextField.text,
                                 @"jiuBiaoCJ"   :self.jiuBiaoCJ,
                                 @"jiuBiaoChaiMa":self.repairedNumTextField.text
                                 };
    NSError *error;
    NSData *dataPara     = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:dataPara encoding:NSUTF8StringEncoding];
    
    NSDictionary *para = @{
                           @"a":jsonString
                           };
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddhhmmss"];
    NSString *currentTime      = [formatter stringFromDate:[NSDate date]];
    
    [manager POST:uploadVideoUrl parameters:para constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        if (!_videoModel && imgView.image) {
            
            NSData *imgData = UIImageJPEGRepresentation(imgView.image, 1);
            [formData appendPartWithFileData:imgData name:@"msg" fileName:[NSString stringWithFormat:@"%@.jpg", currentTime] mimeType:@"jpg"];
        }else if(_videoModel){
            
            [formData appendPartWithFileURL:weakSelf.videoURL name:@"video" fileName:[NSString stringWithFormat:@"%@.mp4", currentTime] mimeType:@"mp4" error:nil];
        }else{
            
            UIImage *img = [UIImage imageNamed:@"pic"];
            NSData *imgData = UIImageJPEGRepresentation(img, 1);
            [formData appendPartWithFileData:imgData name:@"video" fileName:[NSString stringWithFormat:@"123.png"] mimeType:@"png"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //        if (uploadProgress.totalUnitCount == uploadProgress.completedUnitCount) {
        //            [SCToastView hideInView:weakSelf.view];
        //        }else {
        //
        //            [SCToastView showInView:weakSelf.view text:[NSString stringWithFormat:@"已上传：%lld",uploadProgress.completedUnitCount] duration:0 autoHide:NO];
        //        }
        progressLabel.text = [NSString stringWithFormat:@"正在上传：%lld％", uploadProgress.completedUnitCount/uploadProgress.totalUnitCount*100];
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [AnimationView dismiss];
        progressLabel.hidden = YES;
        [SCToastView showInView:weakSelf.view text:[NSString stringWithFormat:@"换表成功，即将退出"] duration:1 autoHide:YES];
        sleep(1);
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
        [AnimationView dismiss];
        progressLabel.hidden = YES;
        [SCToastView showInView:weakSelf.view text:[NSString stringWithFormat:@"上传失败：%@",error] duration:5 autoHide:YES];
    }];
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
