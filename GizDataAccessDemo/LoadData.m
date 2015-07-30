/**
 * LoadData.m
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

#import "LoadData.h"

@interface LoadData () <UITextFieldDelegate, GizDataAccessSourceDelegate>
{
    GizDataAccessSource *gdaSource;
}

@property (weak, nonatomic) UITextField *textStarted;

@property (weak, nonatomic) id <LoadDataDelegate>delegate;

//开始时间戳
@property (weak, nonatomic) IBOutlet UITextField *textStartY;
@property (weak, nonatomic) IBOutlet UITextField *textStartM;
@property (weak, nonatomic) IBOutlet UITextField *textStartD;
@property (weak, nonatomic) IBOutlet UITextField *textStartH;
@property (weak, nonatomic) IBOutlet UITextField *textStartMM;
@property (weak, nonatomic) IBOutlet UITextField *textStartS;

//停止时间戳
@property (weak, nonatomic) IBOutlet UITextField *textEndY;
@property (weak, nonatomic) IBOutlet UITextField *textEndM;
@property (weak, nonatomic) IBOutlet UITextField *textEndD;
@property (weak, nonatomic) IBOutlet UITextField *textEndH;
@property (weak, nonatomic) IBOutlet UITextField *textEndMM;
@property (weak, nonatomic) IBOutlet UITextField *textEndS;

//个数限定
@property (weak, nonatomic) IBOutlet UITextField *textLimit;
@property (weak, nonatomic) IBOutlet UITextField *textSkip;

@property (weak, nonatomic) IBOutlet UITextField *textAttrs;

@end

@implementation LoadData

- (id)initWithDelegate:(id<LoadDataDelegate>)delegate
{
    self = [super init];
    if(self)
    {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.frame = [UIScreen mainScreen].bounds;
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

#pragma mark - actions
- (void)show
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationsEnabled:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    [UIView commitAnimations];
}

- (IBAction)hide
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationsEnabled:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [self.view removeFromSuperview];
    [UIView commitAnimations];
}

- (NSTimeInterval)loadTimeInterval:(BOOL)isStartTime
{
    NSString *strTime = nil;
    
    if(isStartTime)
        strTime = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", self.textStartY.text, self.textStartM.text, self.textStartD.text, self.textStartH.text, self.textStartMM.text, self.textStartS.text];
    else
        strTime = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", self.textEndY.text, self.textEndM.text, self.textEndD.text, self.textEndH.text, self.textEndMM.text, self.textEndS.text];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:strTime];
    return [date timeIntervalSince1970];
}

- (IBAction)onLoad:(id)sender {
    if(nil == gdaSource)
        gdaSource = [[GizDataAccessSource alloc] initWithDelegate:self];
    
    NSTimeInterval timeStart = [self loadTimeInterval:YES];
    NSTimeInterval timeEnd = [self loadTimeInterval:NO];
    
    GIZAppDelegate.hud.labelText = @"加载数据中，请等待...";
    [GIZAppDelegate.hud show:YES];
    
    NSArray *attrs = [self.textAttrs.text componentsSeparatedByString:@","];
    
    [gdaSource loadData:_token productKey:PRODUCT_KEY deviceSN:PRODUCT_SN startTime:timeStart*1000 endTime:timeEnd*1000 specifyAttrs:attrs limit:[self.textLimit.text integerValue] skip:[self.textSkip.text integerValue]];
}

- (IBAction)onTap:(id)sender {
    [self.textStarted resignFirstResponder];
}

#pragma mark - delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.textStarted = textField;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationsEnabled:YES];
    if(textField == self.textEndH ||
       textField == self.textEndMM ||
       textField == self.textEndS)
    {
        CGRect frame = self.view.frame;
        frame.origin.y = -40;
        self.view.frame = frame;
    }
    
    if(textField == self.textLimit)
    {
        CGRect frame = self.view.frame;
        frame.origin.y = -70;
        self.view.frame = frame;
    }
    
    if(textField == self.textSkip)
    {
        CGRect frame = self.view.frame;
        frame.origin.y = -120;
        self.view.frame = frame;
    }
    if(textField == self.textAttrs)
    {
        CGRect frame = self.view.frame;
        frame.origin.y = -180;
        self.view.frame = frame;
    }
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationsEnabled:YES];
    
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    self.view.frame = frame;
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.textAttrs)
    {
        [self onTap:nil];
    }
    return YES;
}

- (void)gizDataAccess:(GizDataAccessSource *)source didLoadData:(NSArray *)data result:(GizDataAccessErrorCode)result errorMessage:(NSString *)message
{
    [GIZAppDelegate.hud hide:YES];
    
    NSLog(@"Receive data: %@, result: %@ message: %@", data, @(result), message);
    
    NSMutableArray *mData = [NSMutableArray array];
    for(NSDictionary *dict in data)
    {
        NSMutableDictionary *mdict = [dict mutableCopy];
        [mdict setValue:nil forKey:@"device_sn"];
        [mdict setValue:nil forKey:@"product_key"];
        [mdict setValue:nil forKey:@"uid"];
        
        //转换时间戳
        NSNumber *nTS = [mdict valueForKey:@"ts"];
        if([nTS isKindOfClass:[NSNumber class]])
        {
            NSTimeInterval timeInterval = ((NSTimeInterval)[nTS unsignedLongLongValue])/1000;
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss SSS"];
            NSString *str = [dateFormatter stringFromDate:date];
            [mdict setValue:str forKey:@"ts"];
        }
        
        [mData addObject:[NSDictionary dictionaryWithDictionary:mdict]];
    }
    
    if([self.delegate respondsToSelector:@selector(loadData:didLoaded:result:)])
        [self.delegate loadData:self didLoaded:[NSArray arrayWithArray:mData] result:result];
    
    if(result != kGizDataAccessErrorNone)
    {
        NSString *msg = [NSString stringWithFormat:@"读取数据失败\n\n错误码：%@\n错误信息：%@", @(result), message];
        [[[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }
    
    [self hide];
}

@end
