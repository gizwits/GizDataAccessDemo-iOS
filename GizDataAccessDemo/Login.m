//
//  Login.m
//  GizDataAccessDemo-Debug
//
//  Created by GeHaitong on 15/2/10.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "Login.h"

#import "AutoLogin.h"
#import "RegisterUser.h"

@interface Login () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textUser;
@property (weak, nonatomic) IBOutlet UITextField *textPass;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segThirdAccountType;
@property (weak, nonatomic) IBOutlet UITextField *textUid;
@property (weak, nonatomic) IBOutlet UITextField *textToken;

@end

@implementation Login

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"注册" style:UIBarButtonItemStylePlain target:self action:@selector(onRegister)];
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
- (IBAction)onLoginAnonymous:(id)sender {
    AutoLogin *autoLoginCtrl = [[AutoLogin alloc] initWithAnonymous];
    [self.navigationController pushViewController:autoLoginCtrl animated:YES];
}

- (IBAction)onLoginNormal:(id)sender {
    AutoLogin *autoLoginCtrl = [[AutoLogin alloc] initWithNormalUser:self.textUser.text password:self.textPass.text];
    [self.navigationController pushViewController:autoLoginCtrl animated:YES];
}

- (IBAction)onLoginThirdAccount:(id)sender {
    GizDataAccessThirdAccountType thirdType = kGizDataAccessThirdAccountTypeSINA;
    switch(self.segThirdAccountType.selectedSegmentIndex)
    {
        case 0:
            thirdType = kGizDataAccessThirdAccountTypeSINA;
            break;
        case 1:
            thirdType = kGizDataAccessThirdAccountTypeBAIDU;
            break;
        default:
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择类型" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            return;
    }
    AutoLogin *autoLoginCtrl = [[AutoLogin alloc] initWithThirdAccountType:thirdType uid:self.textUid.text token:self.textToken.text];
    [self.navigationController pushViewController:autoLoginCtrl animated:YES];
}

- (void)onRegister {
#warning 第三方账号测试通过，还有手机、邮箱用户注册和登录未测试。Remaining：2 interfaces.
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"注册方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"普通用户" otherButtonTitles:@"手机用户", @"邮箱用户", nil];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    RegisterUserType registerType;
    switch (buttonIndex) {
        case 0://普通用户
            registerType = kRegisterUserTypeNormal;
            break;
        case 1://手机用户
            registerType = kRegisterUserTypePhone;
            break;
        case 2://邮箱用户
            registerType = kRegisterUserTypeEmail;
            break;
            
        default:
            return;
    }
    
    RegisterUser *registerUserCtrl = [[RegisterUser alloc] initWithType:registerType];
    [self.navigationController pushViewController:registerUserCtrl animated:YES];
}

@end
