/**
 * AutoLogin.m
 *
 * Copyright (c) 2014~2015 Xtreme Programming Group, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "AutoLogin.h"
#import "DataManager.h"

typedef enum
{
    kAutoLoginTypeAnonymous,
    kAutoLoginTypeNormal,
    kAutoLoginTypeThirdAccountType
}AutoLoginType;

@interface AutoLogin () <GizDataAccessLoginDelegate, UIAlertViewDelegate>
{
    GizDataAccessLogin *gdaLogin;
    GizDataAccessSource *gdaSource;
}

@property (nonatomic, assign) AutoLoginType loginType;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, assign) GizDataAccessThirdAccountType thirdType;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *token;

@end

@implementation AutoLogin

- (id)initWithAnonymous
{
    self = [super init];
    if(self)
    {
        self.loginType = kAutoLoginTypeAnonymous;
    }
    return self;
}

- (id)initWithNormalUser:(NSString *)username password:(NSString *)password
{
    self = [super init];
    if(self)
    {
        self.loginType = kAutoLoginTypeNormal;
        self.username = username;
        self.password = password;
    }
    return self;
}

- (id)initWithThirdAccountType:(GizDataAccessThirdAccountType)thirdType uid:(NSString *)uid token:(NSString *)token
{
    self = [super init];
    if(self)
    {
        self.loginType = kAutoLoginTypeThirdAccountType;
        self.thirdType = thirdType;
        self.uid = uid;
        self.token = token;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.hidesBackButton = YES;
    [self performSelector:@selector(login) withObject:nil afterDelay:0.5];
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
- (void)login {
    if(nil == gdaLogin)
        gdaLogin = [[GizDataAccessLogin alloc] initWithDelegate:self];
    
    switch (self.loginType) {
        case kAutoLoginTypeAnonymous:
            [gdaLogin loginAnonymous];
            break;
        case kAutoLoginTypeNormal:
            [gdaLogin login:self.username password:self.password];
            break;
        case kAutoLoginTypeThirdAccountType:
            [gdaLogin loginWithThirdAccountType:self.thirdType uid:self.uid token:self.token];
            break;
        default:
            break;
    }
}

#pragma mark - delegates
- (void)gizDataAccessDidLogin:(GizDataAccessLogin *)login uid:(NSString *)uid token:(NSString *)token result:(GizDataAccessErrorCode)result message:(NSString *)message
{
    NSLog(@"token:%@", token);
    _token = token;
    
    if(result == kGizDataAccessErrorNone)
    {
        //跳转
        DataManager *dataManagerCtrl = [[DataManager alloc] init];
        [self.navigationController pushViewController:dataManagerCtrl animated:YES];
    }
    else
    {
        switch (result) {
            case kGizDataAccessErrorUserNotExists:
                [[[UIAlertView alloc] initWithTitle:@"提示" message:@"用户不存在" delegate:self cancelButtonTitle:@"重试" otherButtonTitles:@"返回", nil] show];
                break;
            case kGizDataAccessErrorConnectionFailed:
            case kGizDataAccessErrorConnectionTimeout:
                [[[UIAlertView alloc] initWithTitle:@"提示" message:@"登录失败，请检查网络后重试" delegate:self cancelButtonTitle:@"重试" otherButtonTitles:nil] show];
                break;
            default:
            {
                //一般情况下发生的概率小些
                NSString *msg = [NSString stringWithFormat:@"登录失败，发生错误：“%@”", message];
                [[[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"重试" otherButtonTitles:@"返回",nil] show];
                break;
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self login];
            break;
        case 1:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
            break;
    }
}

@end
