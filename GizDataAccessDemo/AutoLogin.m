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

@interface AutoLogin () <GizDataAccessLoginDelegate, UIAlertViewDelegate>
{
    GizDataAccessLogin *gdaLogin;
    GizDataAccessSource *gdaSource;
}

@end

@implementation AutoLogin

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self login];
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
    [gdaLogin loginAnonymous];
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
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"登录失败，请检查网络后重试。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self login];
}

@end
