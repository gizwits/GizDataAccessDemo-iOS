//
//  ChangePass.m
//  GizDataAccessDemo-Debug
//
//  Created by GeHaitong on 15/2/10.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "ChangePass.h"

@interface ChangePass () <GizDataAccessLoginDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *textUserName;
@property (weak, nonatomic) IBOutlet UILabel *textPassName;

@property (weak, nonatomic) IBOutlet UITextField *textUser;
@property (weak, nonatomic) IBOutlet UITextField *textPassword;
@property (weak, nonatomic) IBOutlet UITextField *textVerifyCode;

@property (weak, nonatomic) IBOutlet UIView *viewVerifyCode;

@property (assign, nonatomic) ChangePassType type;

@property (strong, nonatomic) GizDataAccessLogin *gizLogin;

@property (weak, nonatomic) IBOutlet UIButton *btnChange;
@property (weak, nonatomic) IBOutlet UIButton *btnVerifyCode;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger timerCounter;

@end

@implementation ChangePass

- (id)initWithType:(ChangePassType)type
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
        case kChangePassTypeModify:
            self.navigationItem.title = @"修改密码";
            self.textUserName.text = @"旧密码";
            [self.btnChange setTitle:@"修改" forState:UIControlStateNormal];
            [self.view sendSubviewToBack:self.viewVerifyCode];
            break;
        case kChangePassTypeResetEmail:
            self.navigationItem.title = @"通过邮箱重置密码";
            self.textUserName.text = @"邮箱";
            [self.view sendSubviewToBack:self.viewVerifyCode];
            self.textPassName.alpha = 0;
            self.textPassword.alpha = 0;
            self.textUser.returnKeyType = UIReturnKeyDone;
            break;
        case kChangePassTypeResetPhone:
            self.navigationItem.title = @"通过手机重置密码";
            self.textUserName.text = @"手机号";
            self.textPassword.returnKeyType = UIReturnKeyNext;
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
        case kChangePassTypeModify:
            [self.gizLogin changeUserPassword:_token oldPassword:self.textUser.text newPassword:self.textPassword.text];
            return;
        case kChangePassTypeResetEmail:
            accountType = kGizDataAccessAccountTypeEmail;
            break;
        case kChangePassTypeResetPhone:
            accountType = kGizDataAccessAccountTypePhone;
            break;
        default:
            return;
    }
    [self.gizLogin resetPassword:self.textUser.text code:self.textVerifyCode.text newPassword:self.textPassword.text accountType:accountType];
}

- (IBAction)onQueryVerifyCode:(id)sender {
    GIZAppDelegate.hud.labelText = @"正在获取验证码...";
    [GIZAppDelegate.hud show:YES];
    [self.gizLogin requestSendVerifyCode:self.textUser.text];
}

- (void)onTimer:(NSTimer *)timer {
    NSString *title = [NSString stringWithFormat:@"下次获取 %@ 秒", @(self.timerCounter)];
    [self.btnVerifyCode setTitle:title forState:UIControlStateNormal];
    self.timerCounter--;
    
    if(self.timerCounter == 0)
    {
        self.btnVerifyCode.enabled = YES;
        [timer invalidate];
    }
}

- (IBAction)onTap:(id)sender {
    [self.textUser resignFirstResponder];
    [self.textPassword resignFirstResponder];
    [self.textVerifyCode resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationsEnabled:YES];
    
    CGRect frame = self.view.frame;
    if(textField == self.textUser)
        frame.origin.y = 64;
    if(textField == self.textPassword)
        frame.origin.y = 0;
    if(textField == self.textVerifyCode)
        frame.origin.y = 0;
    self.view.frame = frame;
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationsEnabled:YES];
    
    CGRect frame = self.view.frame;
    frame.origin.y = 64;
    self.view.frame = frame;
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.textUser)
    {
        if(self.type == kChangePassTypeResetEmail)
        {
            [self onChange:textField];
            return YES;
        }
        [self.textPassword becomeFirstResponder];
    }
    if(textField == self.textPassword)
    {
        if(self.type == kChangePassTypeResetPhone)
            [self.textVerifyCode becomeFirstResponder];
        else
            [self onChange:textField];
    }
    if(textField == self.textVerifyCode)
    {
        [self onChange:textField];
    }
    return YES;
}

- (void)gizDataAccess:(GizDataAccessLogin *)login didChangeUserPassword:(GizDataAccessErrorCode)result message:(NSString *)message
{
    if(result == kGizDataAccessErrorNone)
    {
        NSString *strMsg = @"重置成功";
        switch (self.type) {
            case kChangePassTypeModify:
                strMsg = @"修改密码成功";
                break;
            case kChangePassTypeResetEmail:
                strMsg = @"已成功向邮箱发送重置邮件";
                break;
            default:
                break;
        }

        [[[UIAlertView alloc] initWithTitle:@"提示" message:strMsg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSString *strMsg = [NSString stringWithFormat:@"重置失败\n%@", message];
        if(self.type == kChangePassTypeModify)
        {
            strMsg = [NSString stringWithFormat:@"修改密码失败\n%@", message];
        }
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
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timer) userInfo:nil repeats:YES];
        [self onTimer:self.timer];
        
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"服务器已成功发送验证码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"发送验证码失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
}

@end
