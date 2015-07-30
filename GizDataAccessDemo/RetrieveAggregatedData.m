//
//  RetrieveAggregatedData.m
//  GizDataAccessDemo-Debug
//
//  Created by GeHaitong on 15/7/28.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "RetrieveAggregatedData.h"

@interface RetrieveAggregatedData () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, GizDataAccessSourceDelegate>
{
    GizDataAccessSource *gdaSource;
}

@property (assign, nonatomic) id <RetrieveAggregatedDataDelegate>delegate;

@property (weak, nonatomic) UITextField *textStarted;

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

//其他
@property (weak, nonatomic) IBOutlet UITextField *textAttrs;
@property (weak, nonatomic) IBOutlet UITextField *textAggregate;;
@property (weak, nonatomic) IBOutlet UITextField *textUnit;

//选择器
@property (strong, nonatomic) UIPickerView *pickerSelection;
@property (strong, nonatomic) NSArray *arrayAggregate;
@property (strong, nonatomic) NSArray *arrayUnit;
@property (strong, nonatomic) NSArray *arrayPicker;

@end

@implementation RetrieveAggregatedData

- (id)initWithDelegate:(id)delegate
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
    self.view.frame = [UIScreen mainScreen].bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    [self.pickerSelection removeFromSuperview];
}

- (void)showPickerView
{
    if(nil == self.pickerSelection)
    {
        //初始化
        CGRect frame = CGRectMake(0, self.view.frame.size.height-216, self.view.frame.size.width, 0);
        self.pickerSelection = [[UIPickerView alloc] initWithFrame:frame];
        self.pickerSelection.hidden = YES;
        self.pickerSelection.delegate = self;
        self.pickerSelection.dataSource = self;
        self.pickerSelection.backgroundColor = [UIColor whiteColor];
        [[UIApplication sharedApplication].keyWindow addSubview:self.pickerSelection];
    }
    
    //加载数据
    NSUInteger selectedRow = [self.arrayPicker indexOfObject:self.textStarted.text];
    if(selectedRow >= self.arrayPicker.count)
        selectedRow = self.arrayPicker.count-1;
    
    [self.pickerSelection selectRow:selectedRow inComponent:0 animated:YES];
    [self.pickerSelection reloadAllComponents];
    
    //显示
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationsEnabled:YES];
    self.pickerSelection.hidden = NO;
    [UIView commitAnimations];
}

- (void)hidePickerView
{
    //隐藏
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationsEnabled:YES];
    self.pickerSelection.hidden = YES;
    [UIView commitAnimations];
    
    [self textFieldDidEndEditing:self.textStarted];
}

- (IBAction)onTap:(id)sender
{
    [self.textStarted resignFirstResponder];
    [self hidePickerView];
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

- (IBAction)onStart:(id)sender {
    if(nil == gdaSource)
        gdaSource = [[GizDataAccessSource alloc] initWithDelegate:self];
    
    NSTimeInterval timeStart = [self loadTimeInterval:YES];
    NSTimeInterval timeEnd = [self loadTimeInterval:NO];
    
    NSArray *attrs = [self.textAttrs.text componentsSeparatedByString:@","];
    GizDataAccessAggregatorType type = [self.arrayAggregate indexOfObject:self.textAggregate.text];;
    GizDataAccessDateTimeUnit unit = [self.arrayUnit indexOfObject:self.textUnit.text];
    
    if(0 == self.textAttrs.text.length)
    {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入属性名" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        return;
    }
    
    if(nil == self.arrayAggregate ||
       nil == self.arrayUnit ||
       type >= (self.arrayAggregate.count - 1) ||
       unit >= (self.arrayUnit.count - 1))
    {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择“聚合器类型”或者“日期格式”" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        return;
    }
    
    GIZAppDelegate.hud.labelText = @"加载数据中，请等待...";
    [GIZAppDelegate.hud show:YES];
    
    [gdaSource retrieveAggregatedData:_token productKey:PRODUCT_KEY deviceSN:PRODUCT_SN startTime:timeStart*1000 endTime:timeEnd*1000 specifyAttrs:attrs withAggregatorType:type byDateTimeUnit:unit];
}

#pragma mark - delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == self.textAggregate ||
       textField == self.textUnit)
    {
        [self.textStarted resignFirstResponder];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationsEnabled:YES];
        if(textField == self.textAggregate)
        {
            CGRect frame = self.view.frame;
            frame.origin.y = -140;
            self.view.frame = frame;
            
            if(nil == self.arrayAggregate)
                self.arrayAggregate = @[@"求和", @"平均值", @"最大值", @"最小值", @""];
            self.arrayPicker = self.arrayAggregate;
        }
        if(textField == self.textUnit)
        {
            CGRect frame = self.view.frame;
            frame.origin.y = -180;
            self.view.frame = frame;
            if(nil == self.arrayUnit)
                self.arrayUnit = @[@"精确到一小时", @"精确到一天", @"精确到一周", @"精确到一个月", @""];
            self.arrayPicker = self.arrayUnit;
        }
        [UIView commitAnimations];
        
        //启动选择器
        self.textStarted = textField;
        [self showPickerView];
        
        return NO;
    }
    return YES;
}

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
    
    if(textField == self.textAttrs)
    {
        CGRect frame = self.view.frame;
        frame.origin.y = -90;
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.arrayPicker.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.arrayPicker[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.textStarted.text = self.arrayPicker[row];
}

- (void)gizDataAccess:(GizDataAccessSource *)source didRetrieveAggregatedData:(NSArray *)data byQueryRequest:(NSDictionary *)queryRequest result:(GizDataAccessErrorCode)result errorMessage:(NSString *)message
{
    [GIZAppDelegate.hud hide:YES];
    
    NSLog(@"Receive data: %@, result: %@ message: %@", data, @(result), message);
    
    NSMutableArray *mData = [NSMutableArray array];
    for(NSDictionary *dict in data)
    {
#warning 带测试
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
    
    if([self.delegate respondsToSelector:@selector(retrieveAggregatedData:didLoaded:result:)])
        [self.delegate retrieveAggregatedData:self didLoaded:[mData copy] result:result];
    
    if(result != kGizDataAccessErrorNone)
    {
        NSString *msg = [NSString stringWithFormat:@"读取数据失败\n\n错误码：%@\n错误信息：%@", @(result), message];
        [[[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }
    
    [self hide];
}

@end
