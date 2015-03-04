//
//  ChangeUser.m
//  GizDataAccessDemo-Debug
//
//  Created by GeHaitong on 15/2/10.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "ChangeUser.h"

@interface ChangeUser () <GizDataAccessLoginDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *textUserName;

@property (weak, nonatomic) IBOutlet UITextField *textUser;
@property (weak, nonatomic) IBOutlet UITextField *textVerifyCode;

@property (weak, nonatomic) IBOutlet UIView *viewVerifyCode;

@property (assign, nonatomic) ChangeUserType type;

@property (strong, nonatomic) GizDataAccessLogin *gizLogin;

@property (weak, nonatomic) IBOutlet UIButton *btnChange;
@property (weak, nonatomic) IBOutlet UIButton *btnVerifyCode;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger timerCounter;

@end

@implementation ChangeUser

- (id)initWithType:(ChangeUserType)type
{
    self = [super init];
    if(self)
    {
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    switch (self.type) {
        case kChangeUserTypeEmail:
            self.navigationItem.title = @"普通用户修改邮箱";
            self.textUserName.text = @"邮箱";
            [self.view sendSubviewToBack:self.viewVerifyCode];
            self.textUser.returnKeyType = UIReturnKeyDone;
            break;
        case kChangeUserTypePhone:
            self.navigationItem.title = @"普通用户修改手机";
            self.textUserName.text = @"手机号";
            break;
        default:
            break;
    }
    
    self.gizLogin = [[GizDataAccessLogin alloc] initWithDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.timer invalidate];
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

- (IBAction)onChange:(id)sender {
    GizDataAccessAccountType accountType;
    
    switch (self.type) {
        case kChangeUserTypeEmail:
            accountType = kGizDataAccessAccountTypeEmail;
            break;
        case kChangeUserTypePhone:
            accountType = kGizDataAccessAccountTypePhone;
            break;
        default:
            return;
    }
    [self.gizLogin changeUser:_token username:self.textUser.text code:self.textVerifyCode.text accountType:accountType];
}

- (IBAction)onQueryVerifyCode:(id)sender {
    GIZAppDelegate.hud.labelText = @"正在获取验证码...";
    [GIZAppDelegate.hud show:YES];
    [self.gizLogin requestSendVerifyCode:self.textUser.text];
}

- (void)onTimer:(NSTimer *)timer {
    if(self.timerCounter == 0)
    {
        [self.btnVerifyCode setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.btnVerifyCode.enabled = YES;
        [timer invalidate];
        return;
    }

    NSString *title = [NSString stringWithFormat:@"下次获取 %@ 秒", @(self.timerCounter)];
    [self.btnVerifyCode setTitle:title forState:UIControlStateNormal];
    self.timerCounter--;
}

- (IBAction)onTap:(id)sender {
    [self.textUser resignFirstResponder];
    [self.textVerifyCode resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.textUser)
    {
        if(self.type == kChangeUserTypeEmail)
        {
            [self onChange:textField];
            return YES;
        }
        [self.textVerifyCode becomeFirstResponder];
    }
    if(textField == self.textVerifyCode)
    {
        [self onChange:textField];
    }
    return YES;
}

- (void)gizDataAccess:(GizDataAccessLogin *)login didChangeUser:(GizDataAccessErrorCode)result message:(NSString *)message
{
    if(result == kGizDataAccessErrorNone)
    {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"修改成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSString *strMsg = [NSString stringWithFormat:@"修改失败\n%@", message];
        [[[UIAlertView alloc] initWithTitle:@"提示" message:strMsg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
}

- (void)gizDataAccess:(GizDataAccessLogin *)login didRequestSendVerifyCode:(GizDataAccessErrorCode)result message:(NSString *)message
{
    [GIZAppDelegate.hud hide:YES];
    
    //验证码获取成功，则不让改手机号、1分钟内不让重新获取验证码
    if(result == kGizDataAccessErrorNone)
    {
        self.textUser.enabled = NO;
        self.btnVerifyCode.enabled = NO;
        
        //计时器60秒
        self.timerCounter = 60;
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
        [self onTimer:self.timer];
        
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"服务器已成功发送验证码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"发送验证码失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
}

@end
