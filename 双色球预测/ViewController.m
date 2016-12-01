//
//  ViewController.m
//  双色球预测
//
//  Created by CPF on 16/10/21.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import "ViewController.h"
#import "OperationManager.h"
#import "UITextField+Delete.h"
#import "SaveModel.h"
#import "FMDatabaseTool.h"
#import "OpenAwardView.h"
#import "WiningDetail.h"
#import "LastExpectView.h"
#import "SegmentPageHead.h"

@interface ViewController ()<UITextFieldDelegate, WJTextFieldDelegate, MLMSegmentPageDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *numArray;
//@property (nonatomic, strong) UIView *textFieldBg;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextView *lastExpect;//上期预测
@property (nonatomic, strong) UITextView *nextExpect;//下期预测
@property (nonatomic, strong) SaveModel *model;
@property (nonatomic, strong) OpenAwardView *openAwardView;
@property (nonatomic, strong) WiningDetail *winingDetailView;//中奖信息
@property (nonatomic, strong) LastExpectView *nextExpectView;//下期预测号码
@property (nonatomic, strong) LastExpectView *lastExpectView;//上期开奖号码
@property (nonatomic, strong) MLMSegmentPage *pageView;

@end

@implementation ViewController

- (NSMutableArray *)numArray
{
    if (!_numArray) {
        _numArray = [NSMutableArray new];
    }
    return _numArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xf4f6f5);
    // 控制是否显示键盘上的工具条。
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [self createUI];
    [self requestData];
}

- (void)createUI
{
//    self.textFieldBg = [UIView new];
//    [self.view addSubview:self.textFieldBg];
//    [self.textFieldBg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view).offset(viewAdapter(35));
//        make.left.equalTo(self.view).offset(viewAdapter(20));
//        make.right.equalTo(self.view).offset(viewAdapter(-20));
//        make.height.mas_equalTo(viewAdapter(150)).priorityLow();
//    }];
//    self.textFieldBg.backgroundColor = DEBUGCOLOR(redColor);

//    UIView *tempView = nil;
//    for (int i = 0; i < 6; i++) {
//        UITextField *textField = [UITextField new];
//        textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        textField.layer.borderWidth = viewAdapter(2.5);
//        textField.layer.cornerRadius = viewAdapter(3);
//        textField.tag = 1000 + i;
//        textField.backgroundColor = [UIColor whiteColor];
//        textField.tintColor = [UIColor blackColor];
//        textField.textAlignment = NSTextAlignmentCenter;
//        textField.font = [UIFont systemFontOfSize:viewAdapter(25)];
//        textField.keyboardType = UIKeyboardTypePhonePad;
//        textField.delegate = self;
//        textField.enabled = NO;
//        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//        [self.textFieldBg addSubview:textField];
//        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.textFieldBg).offset(viewAdapter(5));
////            make.centerX.equalTo(textFieldBg.mas_right).multipliedBy(((CGFloat)i + 1) / ((CGFloat)6 + 1));
//            make.width.mas_equalTo((WIDTH - viewAdapter(40) - SPACING*5)/6);
//            make.height.equalTo(textField.mas_width).offset(viewAdapter(5));
//            if (!tempView) {
//                make.left.equalTo(self.textFieldBg);
//            }else{
//                make.left.equalTo(tempView.mas_right).offset(SPACING);
//            }
//            if (i == 5) {
//                make.right.equalTo(self.textFieldBg);
//                make.bottom.equalTo(self.textFieldBg.mas_bottom).offset(viewAdapter(-5));
//            }
//        }];
//        tempView = textField;
//    }
//    
//    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    [self.view addSubview:clearBtn];
//    [clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.textFieldBg).offset(viewAdapter(-5));
//        make.top.equalTo(self.textFieldBg.mas_bottom).offset(viewAdapter(5));
//    }];
//    [clearBtn setTitle:@"清除" forState:UIControlStateNormal];
//    clearBtn.titleLabel.font = [UIFont systemFontOfSize:viewAdapter(18)];
//    [clearBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
//    [clearBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    clearBtn.layer.borderColor = [UIColor blackColor].CGColor;
//    clearBtn.layer.borderWidth = viewAdapter(1);
//    clearBtn.layer.cornerRadius = viewAdapter(3);
//    clearBtn.contentEdgeInsets = UIEdgeInsetsMake(2, 4, 2, 4);
//    [clearBtn addTarget:self action:@selector(clearBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.openAwardView = [OpenAwardView new];
    [self.view addSubview:self.openAwardView];
    [self.openAwardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(viewAdapter(35));
        make.left.equalTo(self.view).offset(viewAdapter(20));
        make.right.equalTo(self.view).offset(viewAdapter(-20));
//        make.height.mas_equalTo(viewAdapter(150)).priorityLow();
    }];
    
    //中奖信息
    self.winingDetailView = [WiningDetail new];
    [self.view addSubview:self.winingDetailView];
    [self.winingDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.openAwardView.mas_bottom).offset(viewAdapter(5));
        make.left.equalTo(self.view).offset(viewAdapter(15));
        make.right.equalTo(self.view).offset(viewAdapter(-15));
    }];
    self.winingDetailView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.winingDetailView.layer.borderWidth = viewAdapter(1);
    self.winingDetailView.layer.cornerRadius = viewAdapter(5);
    
    //下期预测号码
    self.nextExpectView = [LastExpectView new];
    [self.view addSubview:self.nextExpectView];
    [self.nextExpectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.winingDetailView.mas_bottom).offset(viewAdapter(5));
        make.left.equalTo(self.view).offset(viewAdapter(15));
        make.right.equalTo(self.view).offset(viewAdapter(-15));
    }];
    self.nextExpectView.titleLable.text = @"下期预测号码:";
    
    //上期开奖号码
    self.lastExpectView = [LastExpectView new];
    [self.view addSubview:self.lastExpectView];
    [self.lastExpectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nextExpectView.mas_bottom).offset(viewAdapter(5));
        make.left.equalTo(self.view).offset(viewAdapter(15));
        make.right.equalTo(self.view).offset(viewAdapter(-15));
    }];
    
    UIView *lastExpectBg = [UIView new];
    UIView *nextExpectBg = [UIView new];
    //预测信息
    self.pageView = [[MLMSegmentPage alloc] initSegmentWithFrame:CGRectZero titlesArray:@[@"本期预测情况", @"下期预测情况"] vcOrviews:@[lastExpectBg, nextExpectBg] headStyle:SegmentHeadStyleLine];
    self.pageView.delegate = self;
    self.pageView.headHeight = viewAdapter(50);
    self.pageView.headColor = [UIColor whiteColor];//UIColorFromRGB(0xf4f6f5);
    self.pageView.fontScale = 0.95;//.85;
    self.pageView.fontSize = viewAdapter(18);
    self.pageView.lineScale = .9;
    self.pageView.deselectColor = [UIColor grayColor];
    self.pageView.selectColor = [UIColor redColor];
    self.pageView.bottomLineHeight = viewAdapter(1.5);
    self.pageView.bottomLineColor = UIColorFromRGB(0xf4f6f5);
    self.pageView.backgroundColor = [UIColor whiteColor];
    self.pageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.pageView.layer.borderWidth = viewAdapter(1);
    [self.view addSubview:self.pageView];
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.lastExpectView.mas_bottom).offset(viewAdapter(5));
        make.bottom.equalTo(self.view).offset(-50);
    }];
    
//    self.scrollView = [UIScrollView new];
//    [self.view addSubview:self.scrollView];
//    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.lastExpectView.mas_bottom);
//        make.left.right.equalTo(self.view);
//        make.bottom.equalTo(self.view).offset(-50);
//    }];
//    self.scrollView.backgroundColor = DEBUGCOLOR(cyanColor);
//    
//    UIView *container = [UIView new];
//    [self.scrollView addSubview:container];
//    [container mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.scrollView);
//        make.width.equalTo(self.scrollView);
//    }];
    //上一期
    self.lastExpect = [UITextView new];
    [lastExpectBg addSubview:self.lastExpect];
    [self.lastExpect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lastExpectBg).offset(viewAdapter(15));
        make.right.equalTo(lastExpectBg).offset(viewAdapter(-15));
        make.top.equalTo(lastExpectBg);
        make.bottom.equalTo(lastExpectBg);
    }];
    self.lastExpect.font = [UIFont fontWithName:@"Menlo-Bold" size:viewAdapter(17)];
//    self.lastExpect.numberOfLines = 0;
    self.lastExpect.editable = NO;
    self.lastExpect.backgroundColor = [UIColor whiteColor];//UIColorFromRGB(0xf4f6f5);
    //下一期
    self.nextExpect = [UITextView new];
    [nextExpectBg addSubview:self.nextExpect];
    [self.nextExpect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nextExpectBg).offset(viewAdapter(15));
        make.right.equalTo(nextExpectBg).offset(viewAdapter(-15));
        make.top.equalTo(nextExpectBg);
        make.bottom.equalTo(nextExpectBg);
    }];
    self.nextExpect.font = [UIFont fontWithName:@"Menlo-Bold" size:viewAdapter(17)];
//    self.nextExpect.numberOfLines = 0;
    self.nextExpect.editable = NO;
    self.nextExpect.backgroundColor = [UIColor whiteColor];//UIColorFromRGB(0xf4f6f5);

    UISwipeGestureRecognizer *lastExpectSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upAndDownButtonClick:)];
    lastExpectSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    lastExpectSwipe.delegate = self;
    UISwipeGestureRecognizer *nextExpectSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upAndDownButtonClick:)];
    nextExpectSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    nextExpectSwipe.delegate = self;
    [self.pageView addGestureRecognizer:lastExpectSwipe];
    [self.pageView addGestureRecognizer:nextExpectSwipe];
    
    UIButton *upButton = [UIButton new];
    [self.view addSubview:upButton];
    UIButton *downButton = [UIButton new];
    [self.view addSubview:downButton];
    [upButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(viewAdapter(-10));
        make.centerX.equalTo(self.view.mas_centerX).offset(-WIDTH/5);
    }];
    [downButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(viewAdapter(-10));
        make.centerX.equalTo(self.view.mas_centerX).offset(WIDTH/5);
    }];
    [upButton setTitle:@"<上一期" forState:UIControlStateNormal];
    [downButton setTitle:@"下一期>" forState:UIControlStateNormal];
    upButton.titleLabel.font = [UIFont systemFontOfSize:viewAdapter(18)];
    downButton.titleLabel.font = [UIFont systemFontOfSize:viewAdapter(18)];
    [upButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [downButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    upButton.tag = 2000;
    downButton.tag = 2001;
    [upButton addTarget:self action:@selector(upAndDownButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [downButton addTarget:self action:@selector(upAndDownButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *currentBtn = [UIButton new];
    [self.view addSubview:currentBtn];
    [currentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(viewAdapter(-10));
    }];
    [currentBtn setTitle:@"刷新" forState:UIControlStateNormal];
    currentBtn.titleLabel.font = [UIFont systemFontOfSize:viewAdapter(18)];
    [currentBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [currentBtn addTarget:self action:@selector(requestData) forControlEvents:UIControlEventTouchUpInside];

}

- (void)requestData
{
    [ToolClass showMBConnectTitle:@"" toView:self.view afterDelay:0 isNeedUserInteraction:NO];
    [ToolClass requestPOSTWithURL:@"http://f.apiplus.cn/ssq-1.json" parameters:nil isCache:NO success:^(id responseObject, NSString *msg) {
        NSArray *data = responseObject[@"data"];
        NSDictionary *dataDict = data.firstObject;
        NSString *dateStr = [NSString stringWithFormat:@"%@(%@)", [dataDict[@"opentime"] componentsSeparatedByString:@" "].firstObject, [ToolClass getWeekDayFordate:[ToolClass dateFromTimeInterval:[dataDict[@"opentimestamp"] doubleValue]]]];
        SaveModel *model = (SaveModel *)[FMDatabaseTool findByFirstProperty:dateStr withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
        if (model) {
            self.model = model;
        }else{
            model = [SaveModel new];
            model.time = dateStr;
            model.number = dataDict[@"opencode"];
            model.expect = dataDict[@"expect"];
            [FMDatabaseTool saveObjectToDB:model withTableName:NSStringFromClass([SaveModel class])];
            self.model = model;
        }
        [self reloadUI];
        [ToolClass hideMBConnect];
    } failure:^(NSString *errorInfo, NSError *error) {
        SaveModel *model = (SaveModel *)[FMDatabaseTool findByFirstProperty:[self getCurrentPeriodsString] withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
        if (model) {
            self.model = model;
            [self reloadUI];
        }
        [ToolClass hideMBConnect];
    }];
}

//- (void)clearBtnClick:(UIButton *)button
//{
//    for (int i = 0; i < 6; i++) {
//        UITextField *textField = [self.textFieldBg viewWithTag:1000 + i];
//        textField.text = @"";
//        if (i == 0) {
//            textField.enabled = YES;
//            [textField becomeFirstResponder];
//            textField.layer.borderColor = [UIColor blackColor].CGColor;
//        }else{
//            textField.enabled = NO;
//            textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        }
//    }
//}

- (void)upAndDownButtonClick:(id)object
{
    CATransition *animation = [CATransition animation];
//    animation.delegate = self;
    animation.duration = 0.7;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"cube";

    SaveModel *model = nil;
    NSString *mbMessage = @"";
    if ([object isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)object;
        if (button.tag == 2000) {//上一期
            model = (SaveModel *)[FMDatabaseTool findByFirstProperty:[self getUpOrDownPeriodsString:YES withPeriodString:self.model.time] withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
            mbMessage = @"未找到上期数据";
            animation.subtype = kCATransitionFromLeft;
        }else{//下一期
            model = (SaveModel *)[FMDatabaseTool findByFirstProperty:[self getUpOrDownPeriodsString:NO withPeriodString:self.model.time] withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
            mbMessage = @"最后一期";
            animation.subtype = kCATransitionFromRight;
        }
    }else{
        UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer *)object;
        if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {//上一期
            model = (SaveModel *)[FMDatabaseTool findByFirstProperty:[self getUpOrDownPeriodsString:YES withPeriodString:self.model.time] withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
            mbMessage = @"未找到上期数据";
            animation.subtype = kCATransitionFromLeft;
        }else{//下一期
            model = (SaveModel *)[FMDatabaseTool findByFirstProperty:[self getUpOrDownPeriodsString:NO withPeriodString:self.model.time] withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
            mbMessage = @"最后一期";
            animation.subtype = kCATransitionFromRight;
        }
        self.pageView.viewsScroll.scrollEnabled = YES;
    }
    if (model) {
        self.model = model;
        [self reloadUI];
//        [[self.winingDetailView layer] addAnimation:animation forKey:@"animation"];
//        [[self.lastExpectView layer] addAnimation:animation forKey:@"animation"];
//        [[self.nextExpectView layer] addAnimation:animation forKey:@"animation"];
        [[self.pageView layer] addAnimation:animation forKey:@"animation"];
    }else{
        [ToolClass showMBMessageTitle:mbMessage toView:self.view];
    }
}

- (void)reloadNumbers
{
//    for (int i = 0; i < 6; i++) {
//        UITextField *textField = self.textFieldBg.subviews[i];
//        if (self.numArray.count == 6) {
//            textField.text = self.numArray[i];
//            textField.layer.borderColor = [UIColor blackColor].CGColor;
//            if (i == 5) {
//                textField.enabled = YES;
//            }
//        }else{
//            if (i == 0) {
//                textField.enabled = YES;
//                [textField becomeFirstResponder];
//                textField.layer.borderColor = [UIColor blackColor].CGColor;
//            }
//        }
//    }
}

//设置显示数据
- (void)reloadUI
{
    [self.openAwardView setOpenAwardViewWithModel:self.model];
    NSString *lastTimeStr = [self getUpOrDownPeriodsString:YES withPeriodString:self.model.time];
    SaveModel *lastTimeModel = (SaveModel *)[FMDatabaseTool findByFirstProperty:lastTimeStr withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
    
    if (lastTimeModel) {
        //获取上期预测结果
        NSDictionary *dict = [OperationManager getResultWithArray:[lastTimeModel.number componentsSeparatedByString:@","]];
        //本期中奖号码
        NSArray *okNums = [[self.model.number componentsSeparatedByString:@"+"].firstObject componentsSeparatedByString:@","];
        //7个号码中买中的号码
        NSArray *sevenArray = [self findIsWinningWithArray1:okNums array2:dict[@"sevenArray"]];
        //所有个号码中测中的号码
        NSArray *allArray = [self findIsWinningWithArray1:okNums array2:dict[@"allArray"]];
        //中奖信息拼参
        NSDictionary *winingDetailDict = @{@"sevenArray":sevenArray, @"allArray":allArray};
        //设置中奖信息
        [self.winingDetailView setWiningDetailWithDictionary:winingDetailDict];
        //设置上期开奖号码
        [self.lastExpectView setLastExpectViewWithText:lastTimeModel.number];
        
        //上期预测情况
        NSString *string = [self getFormatStringWithDict:dict];
        NSMutableAttributedString *attuibutedString = [[NSMutableAttributedString alloc] initWithString:string];
        [attuibutedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Menlo-Bold" size:viewAdapter(17)] range:NSMakeRange(0, attuibutedString.length)];
        for (long i = 0; i < string.length-2; i++) {
            NSString *str = [string substringWithRange:NSMakeRange(i, 2)];
            if ([allArray containsObject:str]) {
                [attuibutedString addAttributes:@{NSForegroundColorAttributeName : [UIColor redColor]} range:NSMakeRange(i, 2)];
            }
        }
        self.lastExpect.attributedText = attuibutedString;
        self.pageView.showIndex = 0;
    }else{
        [self.winingDetailView setWiningDetailWithDictionary:nil];
        [self.lastExpectView setLastExpectViewWithText:nil];
        self.lastExpect.text = @"未查询到上期开奖号码";
        self.pageView.showIndex = 1;
    }
    
    //下期预测情况
    NSDictionary *dict = [OperationManager getResultWithArray:[[self.model.number componentsSeparatedByString:@"+"].firstObject componentsSeparatedByString:@","]];
    [self.nextExpectView setLastExpectViewWithText:[dict[@"sevenArray"] componentsJoinedByString:@","]];
    NSString *string = [self getFormatStringWithDict:dict];
    self.nextExpect.text = string;
}

/** 两个数组的交集 */
- (NSArray *)findIsWinningWithArray1:(NSArray *)array1 array2:(NSArray *)array2
{
    NSMutableArray *allArray = [NSMutableArray new];
    for (NSString *str in array1) {
        if ([array2 containsObject:str]) {
            [allArray addObject:str];
        }
    }
    return allArray;
}

- (NSString *)getUpOrDownPeriodsString:(BOOL)isUp withPeriodString:(NSString *)periodString
{
    NSString *str = @"";
    if ([periodString containsString:@"周日"]) {
        str = [NSString stringWithFormat:@"%@(%@)",[ToolClass stringFromDateWithFormat:@"yyyy-MM-dd" date:[ToolClass dateFromTimeInterval:[ToolClass timeIntervalFromDateString:[periodString substringToIndex:10] format:@"yyyy-MM-dd"] + (isUp ? -60*60*24*3 : 60*60*24*2)]], isUp ? @"周四" : @"周二"];
    }else if ([periodString containsString:@"周二"]){
        str = [NSString stringWithFormat:@"%@(%@)",[ToolClass stringFromDateWithFormat:@"yyyy-MM-dd" date:[ToolClass dateFromTimeInterval:[ToolClass timeIntervalFromDateString:[periodString substringToIndex:10] format:@"yyyy-MM-dd"] + (isUp ? -60*60*24*2 : 60*60*24*2)]], isUp ? @"周日" : @"周四"];

    }else if ([periodString containsString:@"周四"]){
        str = [NSString stringWithFormat:@"%@(%@)",[ToolClass stringFromDateWithFormat:@"yyyy-MM-dd" date:[ToolClass dateFromTimeInterval:[ToolClass timeIntervalFromDateString:[periodString substringToIndex:10] format:@"yyyy-MM-dd"] + (isUp ? -60*60*24*2 : 60*60*24*3)]], isUp ? @"周二" : @"周日"];

    }else{
        str = @"未知";
    }
    return str;
}

- (NSString *)getCurrentPeriodsString
{
    NSString *str = @"";
    NSDate *nowDate = [NSDate date];
    NSString *todayWeek = [ToolClass getWeekDayFordate:nowDate];
    NSTimeInterval nowTime = [ToolClass timeIntervalFromDate:nowDate];
    if ([todayWeek isEqualToString:@"周日"]) {
        if ([ToolClass stringFromDateWithFormat:@"HH" date:nowDate].intValue >= 21) {
            str = [NSString stringWithFormat:@"%@(周日)",[ToolClass stringFromDateWithFormat:@"yyyy-MM-dd" date:nowDate]];
        }else{
            str = [NSString stringWithFormat:@"%@(周四)",[ToolClass stringFromDateWithFormat:@"yyyy-MM-dd" date:[ToolClass dateFromTimeInterval:nowTime - 60*60*24*3]]];
        }
    }else if ([todayWeek isEqualToString:@"周一"]){
        str = [NSString stringWithFormat:@"%@(周日)",[ToolClass stringFromDateWithFormat:@"yyyy-MM-dd" date:[ToolClass dateFromTimeInterval:nowTime - 60*60*24]]];
    }else if ([todayWeek isEqualToString:@"周二"]){
        if ([ToolClass stringFromDateWithFormat:@"HH" date:nowDate].intValue >= 21) {
            str = [NSString stringWithFormat:@"%@(周二)",[ToolClass stringFromDateWithFormat:@"yyyy-MM-dd" date:nowDate]];
        }else{
            str = [NSString stringWithFormat:@"%@(周日)",[ToolClass stringFromDateWithFormat:@"yyyy-MM-dd" date:[ToolClass dateFromTimeInterval:nowTime - 60*60*24*2]]];
        }
    }else if ([todayWeek isEqualToString:@"周三"]){
        str = [NSString stringWithFormat:@"%@(周二)",[ToolClass stringFromDateWithFormat:@"yyyy-MM-dd" date:[ToolClass dateFromTimeInterval:nowTime - 60*60*24]]];
    }else if ([todayWeek isEqualToString:@"周四"]){
        if ([ToolClass stringFromDateWithFormat:@"HH" date:nowDate].intValue >= 21) {
            str = [NSString stringWithFormat:@"%@(周四)",[ToolClass stringFromDateWithFormat:@"yyyy-MM-dd" date:nowDate]];
        }else{
            str = [NSString stringWithFormat:@"%@(周二)",[ToolClass stringFromDateWithFormat:@"yyyy-MM-dd" date:[ToolClass dateFromTimeInterval:nowTime - 60*60*24*2]]];
        }
    }else if ([todayWeek isEqualToString:@"周五"]){
        str = [NSString stringWithFormat:@"%@(周四)",[ToolClass stringFromDateWithFormat:@"yyyy-MM-dd" date:[ToolClass dateFromTimeInterval:nowTime - 60*60*24]]];
    }else if ([todayWeek isEqualToString:@"周六"]){
        str = [NSString stringWithFormat:@"%@(周四)",[ToolClass stringFromDateWithFormat:@"yyyy-MM-dd" date:[ToolClass dateFromTimeInterval:nowTime - 60*60*24*2]]];
    }else{
        str = @"未知";
    }
    return str;
}

- (NSString *)getFormatStringWithDict:(NSDictionary *)dict
{
    /** @{@"example1":exampleArray1, @"example2":exampleArray2, @"example3":exampleArray3, @"example4":exampleArray4, @"sevenArray":sevenArray, @"allArrayCount":@(allArray.count).stringValue, @"allArray":allArray, @"dictArr":dictArr} */
    NSString *example1 = [dict[@"example1"] componentsJoinedByString:@","];
    NSString *example2 = [dict[@"example2"] componentsJoinedByString:@","];
    NSString *example3 = [dict[@"example3"] componentsJoinedByString:@","];
    NSString *example4 = [dict[@"example4"] componentsJoinedByString:@","];
    NSString *sevenStr = [dict[@"sevenArray"] componentsJoinedByString:@","];
    NSString *allStr = [dict[@"allArray"] componentsJoinedByString:@","];
    NSString *dictString = [dict[@"dictArr"] componentsJoinedByString:@""];
    /** 
        ==========================
        = 例一：02,08,11,15,21,23 =
        = 例二：02,06,09,19,22,29 =
        = 例三：01,04,08,13,24,28 =
        = 例四：06,08,14,16,23,27 =
        ==========7个号码==========
        =  02,06,08,14,16,23,27  =
        ==========================
        共19个号码：01,02,04,06,08,09,11,13,14,15,16,19,21,22,23,24,27,28,29
        出现次数：08-3,06-2,23-2,02-2,27-1,16-1,14-1;
        28-1,24-1,13-1,04-1,01-1,29-1,22-1,19-1,09-1,21-1,15-1,11-1。 
     */
    return [NSString stringWithFormat:@"==========================\n= 例一：%@ =\n= 例二：%@ =\n= 例三：%@ =\n= 例四：%@ =\n========= 7个号码 =========\n=  %@  =\n==========================\n共%@个号码：%@\n出现次数：%@", example1, example2, example3, example4, sevenStr, dict[@"allArrayCount"], allStr, dictString];
}

//- (void)textFieldDidChange:(UITextField *)textField
//{
//    if (textField.text.length == 2) {
//        if (self.numArray.count == 6) {
//            [self.numArray replaceObjectAtIndex:textField.tag - 1000 withObject:textField.text];
//        }else{
//            [self.numArray addObject:textField.text];
//        }
//        if (textField.tag != 1005) {
//            textField.enabled = NO;
//            UITextField *tempText = [self.textFieldBg viewWithTag:textField.tag + 1];
//            tempText.enabled = YES;
//            [tempText becomeFirstResponder];
//            tempText.layer.borderColor = [UIColor blackColor].CGColor;
//        }else{
//            [textField resignFirstResponder];
//            SaveModel *model = [SaveModel new];
//            model.time = [self getCurrentPeriodsString];
//            model.number = [self.numArray componentsJoinedByString:@","];
//            [FMDatabaseTool saveObjectToDB:model withTableName:NSStringFromClass([SaveModel class])];
//            self.model = model;
//            [self reloadUI];
//        }
//    }
//}

#pragma mark - UITextFieldDelegate

/** - (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
 {
 
 }
 */

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"range:%lu",(unsigned long)range.length);
    //删除可以输入
    if ([string isEqualToString:@""]) {
        return YES;
    }
    //控制只能输入数字
    NSString *text = @"^[0-9]*$";
    NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", text];
    if (![regextest evaluateWithObject:string]) {
        return NO;
    }
    //判断输入数字大小的逻辑
    if ((textField.text.length == 0 && string.intValue > 3) || (textField.text.length == 1 && ((textField.text.intValue * 10 + string.intValue) > 33 || (textField.text.intValue * 10 + string.intValue) == 0))) {
        return NO;
    }

//    //跳转输入框的逻辑
//    if (textField.text.length == 2) {
//        if (self.numArray.count > 0) {
//            [self.numArray replaceObjectAtIndex:textField.tag - 1000 withObject:textField.text];
//        }else{
//            [self.numArray addObject:textField.text];
//        }
//        if (textField.tag != 1005) {
//            textField.enabled = NO;
//            UITextField *tempText = [self.textFieldBg viewWithTag:textField.tag + 1];
//            tempText.text = string;
//            tempText.enabled = YES;
//            [tempText becomeFirstResponder];
//            tempText.layer.borderColor = [UIColor blackColor].CGColor;
//        }else{
//            [textField resignFirstResponder];
//            SaveModel *model = [SaveModel new];
//            model.time = [self getCurrentPeriodsString];
//            model.number = [self.numArray componentsJoinedByString:@","];
//            [FMDatabaseTool saveObjectToDB:model withTableName:NSStringFromClass([SaveModel class])];
//            self.model = model;
//            [self reloadUI];
//        }
//    }
    //如果够两位就不让输入
    return textField.text.length < 2;
}

//- (void)textFieldDidDeleteBackward:(UITextField *)textField
//{
//    if (textField.text.length == 0 || !textField.text){
//        if (textField.tag != 1000) {
//            textField.enabled = NO;
//            textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
//            UITextField *tempText = [self.textFieldBg viewWithTag:textField.tag - 1];
//            tempText.enabled = YES;
//            [tempText becomeFirstResponder];
//            tempText.layer.borderColor = [UIColor blackColor].CGColor;
//        }
//    }
//}

#pragma mark - MLMSegmentPageDelegate

- (void)scrollThroughIndex:(NSInteger)index
{
    
}

#pragma mark - UIGestureRecognizerDelegate
// called when a gesture recognizer attempts to transition out of UIGestureRecognizerStatePossible. returning NO causes it to transition to UIGestureRecognizerStateFailed
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //4
//    self.pageView.viewsScroll.canCancelContentTouches = NO;
    NSLog(@"");
    if ((self.pageView.showIndex == 0 && ((UISwipeGestureRecognizer *)gestureRecognizer).direction == UISwipeGestureRecognizerDirectionRight) || (self.pageView.showIndex == 1 && ((UISwipeGestureRecognizer *)gestureRecognizer).direction == UISwipeGestureRecognizerDirectionLeft)) {
        self.pageView.viewsScroll.scrollEnabled = NO;
        NSLog(@"self.pageView.showIndex:%ld,((UISwipeGestureRecognizer *)gestureRecognizer).direction:%lu",(long)self.pageView.showIndex, (unsigned long)((UISwipeGestureRecognizer *)gestureRecognizer).direction);
        return YES;
    }
    return NO;
}

// called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
// return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
//
// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //3
    NSLog(@"");
    return YES;
}

// called once per attempt to recognize, so failure requirements can be determined lazily and may be set up between recognizers across view hierarchies
// return YES to set up a dynamic failure requirement between gestureRecognizer and otherGestureRecognizer
//
// note: returning YES is guaranteed to set up the failure requirement. returning NO does not guarantee that there will not be a failure requirement as the other gesture's counterpart delegate or subclass methods may return YES
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    //2
//    NSLog(@"");
//    return YES;
//}
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    NSLog(@"");
//    return YES;
//}

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //1
    NSLog(@"");
    return YES;
}

// called before pressesBegan:withEvent: is called on the gesture recognizer for a new press. return NO to prevent the gesture recognizer from seeing this press
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceivePress:(UIPress *)press
//{
//    NSLog(@"");
//    return YES;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
