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

//数据点
@property (weak, nonatomic) IBOutlet UITextView *textDataPoint;

@end

@implementation AddData

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onSend)];
    self.navigationItem.title = @"添加数据";
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
    
    if(nil == gdaSource)
        gdaSource = [[GizDataAccessSource alloc] initWithDelegate:self];
    
    GIZAppDelegate.hud.labelText = @"添加中...";
    [GIZAppDelegate.hud show:YES];
    
    [gdaSource saveData:_token productKey:PRODUCT_KEY deviceSN:PRODUCT_SN timestamp:timestamp*1000 attributes:self.textDataPoint.text];
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
