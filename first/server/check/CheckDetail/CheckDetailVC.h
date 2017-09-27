//
//  CheckDetailVC.h
//  first
//
//  Created by panerly on 26/09/2017.
//  Copyright © 2017 HS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckDetailVC : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *averageNum;
@property (weak, nonatomic) IBOutlet UITextField *previousNum;
@property (weak, nonatomic) IBOutlet UITextField *bshTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNum;
@property (weak, nonatomic) IBOutlet UITextField *meterInfo;
@property (weak, nonatomic) IBOutlet UITextField *userAddrTextfield;
@property (weak, nonatomic) IBOutlet UITextField *mterConditionTextField;
@property (weak, nonatomic) IBOutlet UITextView *remarkTextView;
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;

- (IBAction)reportButton:(id)sender;
- (IBAction)submitButton:(id)sender;

- (IBAction)camera:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIImageView *firstImg;
@property (weak, nonatomic) IBOutlet UIImageView *secondImg;
@property (weak, nonatomic) IBOutlet UIImageView *thirdImg;

@end
