//
//  TransAnonymous.m
//  GizDataAccessDemo-Debug
//
//  Created by GeHaitong on 15/2/10.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "TransAnonymous.h"

@interface TransAnonymous () <GizDataAccessLoginDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *textUserName;
@property (weak, nonatomic) IBOutlet UILabel *textPassName;

@property (weak, nonatomic) IBOutlet UITextField *textUser;
@property (weak, nonatomic) IBOutlet UITextField *textPassword;
@property (weak, nonatomic) IBOutlet UITextField *textVerifyCode;

@property (weak, nonatomic) IBOutlet UIView *viewVerifyCode;

@property (assign, nonatomic) TransAnonymousType type;

@property (strong, nonatomic) GizDataAccessLogin *gizLogin;

@property (weak, nonatomic) IBOutlet UIButton *btnChange;
@property (weak, nonatomic) IBOutlet UIButton *btnVerifyCode;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger timerCounter;

@end

@implementation TransAnonymous

- (id)initWithType:(TransAnonymousType)type
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
        case kTransAnonymousTypeNormal:
            self.navigationItem.title = @"匿名用户转换普通账号";
            [self.view sendSubviewToBack:self.viewVerifyCode];
            break;
        case kTransAnonymousTypePhone:
            self.navigationItem.title = @"匿名用户转换手机账号";
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
        case kTransAnonymousTypeNormal:
            accountType = kGizDataAccessAccountTypeNormal;
            break;
        case kTransAnonymousTypePhone:
            accountType = kGizDataAccessAccountTypePhone;
            break;
        default:
            return;
    }
    [self.gizLogin transAnonymousUser:_token username:self.textUser.text password:self.textPassword.text code:self.textVerifyCode.text accountType:accountType];
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
    {
        if(self.type == kTransAnonymousTypeNormal)
        {
            [self onChange:textField];
            return YES;
        }
        [self.textPassword becomeFirstResponder];
    }
    if(textField == self.textPassword)
    {
        if(self.type == kTransAnonymousTypePhone)
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

- (void)gizDataAccess:(GizDataAccessLogin *)login didTransAnonymousUser:(GizDataAccessErrorCode)result message:(NSString *)message
{
    if(result == kGizDataAccessErrorNone)
    {
        //转换成功后，这个用户就不再是匿名用户了
        _isAnonymousUser = NO;
        
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"转换成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        NSString *strMsg = [NSString stringWithFormat:@"转换失败\n%@", message];
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
