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

@interface DataManager () <GizDataAccessSourceDelegate, UITableViewDataSource, UITableViewDelegate, LoadDataDelegate>
{
    LoadData *loadDataCtrl;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DataManager

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *leftItem1 = [[UIBarButtonItem alloc] initWithTitle:@"添加数据" style:UIBarButtonItemStylePlain target:self action:@selector(onAddItem)];
    UIBarButtonItem *leftItem2 = [[UIBarButtonItem alloc] initWithTitle:@"注销" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout)];
    
    self.navigationItem.leftBarButtonItems = @[leftItem1, leftItem2];
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
- (void)onAddItem {
    AddData *addDataCtrl = [[AddData alloc] init];
    [self.navigationController pushViewController:addDataCtrl animated:YES];
}

- (void)onLoadData {
    loadDataCtrl = [[LoadData alloc] initWithDelegate:self];
//    [self.navigationController pushViewController:loadDataCtrl animated:YES];
    [loadDataCtrl show];
}

- (void)onLogout {
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    //清除登录信息
    _token = nil;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
