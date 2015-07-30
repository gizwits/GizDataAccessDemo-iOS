/**
 * AddData.m
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

#import "AddData.h"

@interface AddData () <UITextViewDelegate, GizDataAccessSourceDelegate>
{
    GizDataAccessSource *gdaSource;
}

//时间戳
@property (weak, nonatomic) IBOutlet UITextField *textYear;
@property (weak, nonatomic) IBOutlet UITextField *textMonth;
@property (weak, nonatomic) IBOutlet UITextField *textDay;
@property (weak, nonatomic) IBOutlet UITextField *textHour;
@property (weak, nonatomic) IBOutlet UITextField *textMinute;
@property (weak, nonatomic) IBOutlet UITextField *textSecond;
@property (weak, nonatomic) IBOutlet UITextField *textMillsecond;

//一次发送数据的数量
@property (weak, nonatomic) IBOutlet UITextField *textCount;

//数据点
@property (weak, nonatomic) IBOutlet UITextView *textDataPoint;

@end

@implementation AddData

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onSend)];
    self.navigationItem.title = @"添加数据";
    
#if QA_ENVIRONMENT
    //QA1
    self.textDataPoint.text = @"{\n\
    \"a1\": true,\n\
    \"a2\": \"1\",\n\
    \"a3\": 123,\n\
    \"a4\": \"test\"\n\
}";
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions
- (IBAction)onTap:(id)sender
{
    [self.textDataPoint resignFirstResponder];
}

- (void)onSend
{
    NSString *strDate = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@ %03i", self.textYear.text, self.textMonth.text, self.textDay.text, self.textHour.text, self.textMinute.text, self.textSecond.text, [self.textMillsecond.text intValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss SSS"];
    NSDate *date = [dateFormatter dateFromString:strDate];
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    
    if(nil == date)
    {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"日期或时间错误，请重新输入。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        return;
    }
    
    if([self.textCount.text integerValue] <= 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"同时发送数据的数量必须大于0。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        return;
    }
    
    if(nil == gdaSource)
        gdaSource = [[GizDataAccessSource alloc] initWithDelegate:self];
    
    GIZAppDelegate.hud.labelText = @"添加中...";
    [GIZAppDelegate.hud show:YES];
    
    NSData *dataContent = [self.textDataPoint.text dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:dataContent options:0 error:nil];
    if(nil == dict)
        dict = [NSDictionary dictionary];

    NSMutableArray *mArray = [NSMutableArray array];
    for(int i=0; i<[self.textCount.text integerValue]; i++)
    {
        NSDictionary *tmpDict = @{@"ts": @(timestamp*1000),
                                  @"attrs": dict};
        [mArray addObject:tmpDict];
    }
//    NSArray *data = @[@{@"attrs":@{@"device_mac":@"1C:48:F9:54:6E:D6",@"device_name":@"Jabra BOOST WeChat v0.17.9"},@"ts":@1434600799692}];
    NSArray *data = [NSArray arrayWithArray:mArray];
    [gdaSource saveData:_token productKey:PRODUCT_KEY deviceSN:PRODUCT_SN data:data];
}

#pragma mark - delegates
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationsEnabled:YES];
    CGRect frame = self.view.frame;
    frame.origin.y = -145;
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationsEnabled:YES];
    CGRect frame = self.view.frame;
    frame.origin.y = 44;
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (void)gizDataAccess:(GizDataAccessSource *)source didSaveData:(GizDataAccessErrorCode)result message:(NSString *)message
{
    [GIZAppDelegate.hud hide:YES];
    NSLog(@"Save data result: %@ message: %@", @(result), message);
    NSString *msg = @"保存数据成功";
    if(result != kGizDataAccessErrorNone)
        msg = [NSString stringWithFormat:@"保存数据失败\n\n错误码：%@\n错误信息：%@", @(result), message];

    [[[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
}

@end
