//
//  RegisterUser.m
//  GizDataAccessDemo-Debug
//
//  Created by GeHaitong on 15/2/10.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "RegisterUser.h"

@interface RegisterUser () <GizDataAccessLoginDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *textUserName;

@property (weak, nonatomic) IBOutlet UITextField *textUser;
@property (weak, nonatomic) IBOutlet UITextField *textPassword;
@property (weak, nonatomic) IBOutlet UITextField *textVerifyCode;

@property (weak, nonatomic) IBOutlet UIView *viewVerifyCode;

@property (assign, nonatomic) RegisterUserType type;

@property (strong, nonatomic) GizDataAccessLogin *gizLogin;

@property (weak, nonatomic) IBOutlet UIButton *btnVerifyCode;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger timerCounter;

@end

@implementation RegisterUser

- (id)initWithType:(RegisterUserType)type
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
        case kRegisterUserTypeNormal:
            self.navigationItem.title = @"注册普通用户";
            self.textUserName.text = @"用户名";
            [self.view sendSubviewToBack:self.viewVerifyCode];
            break;
        case kRegisterUserTypePhone:
            self.navigationItem.title = @"注册手机用户";
            self.textUserName.text = @"手机号";
            self.textPassword.returnKeyType = UIReturnKeyNext;
            break;
        case kRegisterUserTypeEmail:
            self.navigationItem.title = @"注册邮箱用户";
            self.textUserName.text = @"邮箱";
            [self.view sendSubviewToBack:self.viewVerifyCode];
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

- (IBAction)onRegister:(id)sender {
    GizDataAccessAccountType accountType;
    
    switch (self.type) {
        case kRegisterUserTypeNormal:
            accountType = kGizDataAccessAccountTypeNormal;
            break;
        case kRegisterUserTypePhone:
            accountType = kGizDataAccessAccountTypePhone;
            break;
        case kRegisterUserTypeEmail:
            accountType = kGizDataAccessAccountTypeEmail;
            break;
        default:
            return;
    }
    
    [self.gizLogin registerUser:self.textUser.text password:self.textPassword.text code:self.textVerifyCode.text accountType:accountType];
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
        [self.textPassword becomeFirstResponder];
    if(textField == self.textPassword)
    {
        if(self.type == kRegisterUserTypePhone)
            [self.textVerifyCode becomeFirstResponder];
        else
            [self onRegister:textField];
    }
    if(textField == self.textVerifyCode)
    {
        [self onRegister:textField];
    }
    return YES;
}

- (void)gizDataAccess:(GizDataAccessLogin *)login didRegisterUser:(NSString *)uid token:(NSString *)token result:(GizDataAccessErrorCode)result message:(NSString *)message
{
    if(result == kGizDataAccessErrorNone)
    {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"注册成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSString *msg = [NSString stringWithFormat:@"注册失败\n%@", message];
        [[[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
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
