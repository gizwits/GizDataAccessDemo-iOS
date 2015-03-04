/**
 * DataManager.m
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

#import "DataManager.h"
#import "AddData.h"
#import "LoadData.h"
#import "ChangePass.h"
#import "ChangeUser.h"
#import "TransAnonymous.h"

@interface DataManager () <GizDataAccessSourceDelegate, UITableViewDataSource, UITableViewDelegate, LoadDataDelegate, UIActionSheetDelegate>
{
    LoadData *loadDataCtrl;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DataManager

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:@"菜单" style:UIBarButtonItemStylePlain target:self action:@selector(onMenu)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设定查询条件" style:UIBarButtonItemStylePlain target:self action:@selector(onLoadData)];
    self.navigationItem.title = @"查询结果";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions
- (void)onMenu {
    NSString *titlePhone = @"匿名用户转换手机账号";
    NSString *titleNormal = @"匿名用户转换普通账号";
    
    if(!_isAnonymousUser) {
        titlePhone = @"普通用户修改手机";
        titleNormal = @"普通用户修改邮箱";
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"菜单" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"添加数据" otherButtonTitles:@"注销", @"修改密码", titlePhone, titleNormal, nil];
    [actionSheet showInView:self.view];
}

- (void)onLoadData {
    loadDataCtrl = [[LoadData alloc] initWithDelegate:self];
//    [self.navigationController pushViewController:loadDataCtrl animated:YES];
    [loadDataCtrl show];
}

#pragma mark - table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datas.count;
}

#pragma mark - tableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strIdentifier = @"dataIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    if(nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier];
    }
    
    NSDictionary *dict = _datas[indexPath.row];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    cell.textLabel.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.numberOfLines = 0;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = _datas[indexPath.row];
    NSString *text = [NSString stringWithFormat:@"%@\n", dict];
    CGRect rc = [text boundingRectWithSize:CGSizeMake(280, 4096) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]} context:nil];
    return rc.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - load data view
- (void)loadData:(LoadData *)loadData didLoaded:(NSArray *)data result:(GizDataAccessErrorCode)result
{
    if(result == kGizDataAccessErrorNone)
    {
        _datas = data;
        [self.tableView reloadData];
    }
}

#pragma mark = Action sheet
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0://添加数据
        {
            AddData *addDataCtrl = [[AddData alloc] init];
            [self.navigationController pushViewController:addDataCtrl animated:YES];
            return;
        }
        case 1://注销
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            //清除登录信息
            _token = nil;
            _datas = nil;
            break;
        }
        case 2://修改密码
        {
            if(!_isAnonymousUser && !_isThirdUser) {
                ChangePassType changeType = kChangePassTypeModify;
                ChangePass *changePassCtrl = [[ChangePass alloc] initWithType:changeType];
                [self.navigationController pushViewController:changePassCtrl animated:YES];
            }
            else {
                [[[UIAlertView alloc] initWithTitle:@"提示" message:@"匿名用户或者第三方用户不能通过 SDK 的 API 修改密码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            }
            break;
        }
        case 3://普通用户修改手机
        {
            if(!_isAnonymousUser) {
                ChangeUserType changeType = kChangeUserTypePhone;
                ChangeUser *changeUserCtrl = [[ChangeUser alloc] initWithType:changeType];
                [self.navigationController pushViewController:changeUserCtrl animated:YES];
            }
            else {
                TransAnonymousType TransType = kTransAnonymousTypePhone;
                TransAnonymous *TransCtrl = [[TransAnonymous alloc] initWithType:TransType];
                [self.navigationController pushViewController:TransCtrl animated:YES];
            }
            break;
        }
        case 4://普通用户修改邮箱
        {
            if(!_isAnonymousUser) {
                ChangeUserType changeType = kChangeUserTypeEmail;
                ChangeUser *changeUserCtrl = [[ChangeUser alloc] initWithType:changeType];
                [self.navigationController pushViewController:changeUserCtrl animated:YES];
            }
            else {
                TransAnonymousType TransType = kTransAnonymousTypeNormal;
                TransAnonymous *TransCtrl = [[TransAnonymous alloc] initWithType:TransType];
                [self.navigationController pushViewController:TransCtrl animated:YES];
            }
            break;
        }
        default:
            return;
    }
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
