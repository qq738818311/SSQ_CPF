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
#import "OpenAwardView.h"
#import "WiningDetail.h"
#import "LastExpectView.h"
#import "SegmentPageHead.h"
#import "BottomBar.h"

static BOOL canAddAnimation = NO;
static dispatch_source_t timer;

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
//@property (nonatomic, strong) LastExpectView *lastExpectView;//上期开奖号码
@property (nonatomic, strong) MLMSegmentPage *pageView;

@property (nonatomic, strong) UIVisualEffectView *effectPWView;

@end

@implementation ViewController

- (NSMutableArray *)numArray
{
    if (!_numArray) {
        _numArray = [NSMutableArray new];
    }
    return _numArray;
}

- (UIVisualEffectView *)effectPWView
{
    if (!_effectPWView) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectPWView = [[UIVisualEffectView alloc] initWithEffect:blur];
        _effectPWView.userInteractionEnabled = YES;
        _effectPWView.frame = self.view.frame;
        _effectPWView.alpha = 0.5;
    }
    return _effectPWView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"双色球预测";
    self.view.backgroundColor = UIColorFromRGB(0xf4f6f5);
    // 控制是否显示键盘上的工具条。
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [self createUI];
    [self requestData];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)createUI
{
    self.openAwardView = [OpenAwardView new];
    [self.view addSubview:self.openAwardView];
    [self.openAwardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide).offset(viewAdapter(5));
        make.left.equalTo(self.view).offset(viewAdapter(20));
        make.right.equalTo(self.view).offset(viewAdapter(-20));
    }];
    
    //中奖信息
    self.winingDetailView = [WiningDetail new];
    [self.view addSubview:self.winingDetailView];
    [self.winingDetailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.openAwardView.mas_bottom).offset(viewAdapter(5));
        make.left.equalTo(self.view).offset(viewAdapter(15));
        make.right.equalTo(self.view).offset(viewAdapter(-15));
    }];

    
    //下期预测号码
    self.nextExpectView = [LastExpectView new];
    [self.view addSubview:self.nextExpectView];
    [self.nextExpectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.winingDetailView.mas_bottom);
        make.left.right.equalTo(self.view).offset(viewAdapter(0));
//        make.right.equalTo(self.view).offset(viewAdapter(-15));
    }];
    self.nextExpectView.titleLable.text = @"下期预测号码";
    
    UIImageView *headerImageBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookshelf_header_mask"]];
    [self.view insertSubview:headerImageBg atIndex:0];
    [headerImageBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideTop);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.nextExpectView).offset(viewAdapter(-18));
    }];
    
    UIView *pageViewBg = [UIView new];
    [self.view insertSubview:pageViewBg belowSubview:self.winingDetailView];
    [pageViewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(headerImageBg.mas_bottom).offset(viewAdapter(0));
    }];
    pageViewBg.backgroundColor = [UIColor whiteColor];
    pageViewBg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    pageViewBg.layer.borderWidth = viewAdapter(0.5);
    
    UIView *lastExpectBg = [UIView new];
    UIView *nextExpectBg = [UIView new];
    lastExpectBg.backgroundColor = RGBACOLOR(251, 244, 211, 1);
    nextExpectBg.backgroundColor = RGBACOLOR(251, 244, 211, 1);
    //预测信息
    self.pageView = [[MLMSegmentPage alloc] initSegmentWithFrame:CGRectZero titlesArray:@[@"本期预测情况", @"下期预测情况"] vcOrviews:@[lastExpectBg, nextExpectBg] headStyle:SegmentHeadStyleLine];
    self.pageView.delegate = self;
    self.pageView.headHeight = viewAdapter(40);
    self.pageView.headColor = RGBACOLOR(255, 255, 255, 1);//UIColorFromRGB(0xf4f6f5);
    self.pageView.fontScale = 0.95;//.85;
    self.pageView.fontSize = viewAdapter(18);
    self.pageView.lineScale = .9;
    self.pageView.deselectColor = [UIColor grayColor];
    self.pageView.selectColor = [UIColor redColor];
    self.pageView.bottomLineHeight = viewAdapter(0.8);
    self.pageView.bottomLineColor = UIColorFromRGBWithAlpha(0xf4f6f5, 1);
    self.pageView.backgroundColor = [UIColor whiteColor];
    [pageViewBg addSubview:self.pageView];
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(pageViewBg);
        make.top.equalTo(pageViewBg).offset(viewAdapter(18));
    }];
    
    //上一期
    self.lastExpect = [UITextView new];
    [lastExpectBg addSubview:self.lastExpect];
    [self.lastExpect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(WIDTH - viewAdapter(30));
        make.centerX.equalTo(lastExpectBg);
        make.top.equalTo(lastExpectBg);
        make.bottom.equalTo(lastExpectBg);
    }];
    self.lastExpect.font = [UIFont fontWithName:@"Menlo-Bold" size:viewAdapter(16)];
//    self.lastExpect.numberOfLines = 0;
    self.lastExpect.editable = NO;
//    self.lastExpect.backgroundColor = [UIColor whiteColor];//UIColorFromRGB(0xf4f6f5);
    self.lastExpect.backgroundColor = RGBACOLOR(251, 244, 211, 0);

    //下一期
    self.nextExpect = [UITextView new];
    [nextExpectBg addSubview:self.nextExpect];
    [self.nextExpect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(WIDTH - viewAdapter(30));
        make.centerX.equalTo(nextExpectBg);
        make.top.equalTo(nextExpectBg);
        make.bottom.equalTo(nextExpectBg);
    }];
    self.nextExpect.font = [UIFont fontWithName:@"Menlo-Bold" size:viewAdapter(16)];
//    self.nextExpect.numberOfLines = 0;
    self.nextExpect.editable = NO;
//    self.nextExpect.backgroundColor = [UIColor whiteColor];//UIColorFromRGB(0xf4f6f5);
    self.nextExpect.backgroundColor = RGBACOLOR(251, 244, 211, 0);

    //上一期和下一期的手势
    UISwipeGestureRecognizer *lastExpectSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upAndDownButtonClick:)];
    lastExpectSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    lastExpectSwipe.delegate = self;
    UISwipeGestureRecognizer *nextExpectSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upAndDownButtonClick:)];
    nextExpectSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    nextExpectSwipe.delegate = self;
    [self.pageView addGestureRecognizer:lastExpectSwipe];
    [self.pageView addGestureRecognizer:nextExpectSwipe];
    
    BottomBar *bottomBar = [BottomBar new];
    [self.view addSubview:bottomBar];
    [bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pageView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(viewAdapter(50));
    }];
    
    WeakObj(self);
    [bottomBar setButtonClick:^(UIButton *button, NSInteger index) {
        if (index == 0 || index == 1) {//上一期或下一期
            [selfWeak upAndDownButtonClick:button];
        }else if (index == 2){//刷新
            [ToolClass cancelTimeCountDownWith:timer];
            self.nextExpectView.startBtn.selected = NO;
            canAddAnimation = YES;
            [selfWeak requestData];
        }else if (index == 3){//设置
        
        }
    }];
    
    __block NSString *nextNumber = @"";
    [self.nextExpectView setButtonClick:^(UIButton *button, NSInteger index) {
        NSDictionary *dict = [OperationManager getResultWithArray:[[selfWeak.model.number componentsSeparatedByString:@"+"].firstObject componentsSeparatedByString:@","]];
        NSString *string = [selfWeak getFormatStringWithDict:dict];
        if (index == 0) {//开始&停止
            if (button.selected) {//开始
                [ToolClass cancelTimeCountDownWith:timer];
                timer = [ToolClass timeCountDownWithCount:3000 perTime:0.02 inProgress:^(int time) {
                    [selfWeak.nextExpectView setLastExpectViewWithText:[[OperationManager allNumbersChooesSevenNumberWithAllNumbers:dict[@"allArray"]] componentsJoinedByString:@","]];
                } completion:^{
                    
                }];
            }else{//停止
                [ToolClass cancelTimeCountDownWith:timer];
                nextNumber = [[OperationManager allNumbersChooesSevenNumberWithAllNumbers:dict[@"allArray"]] componentsJoinedByString:@","];
                [selfWeak.nextExpectView setLastExpectViewWithText:nextNumber];
            }
        }else{//保存
            if (nextNumber.length > 0) {
                selfWeak.nextExpect.text = [NSString stringWithFormat:@"========= 7个号码 =========\n=  %@  =\n%@", nextNumber, string];
                selfWeak.model.nextNumber = nextNumber;
                [FMDatabaseTool saveObjectToDB:selfWeak.model withTableName:NSStringFromClass([SaveModel class])];
                [ToolClass showMBMessageTitle:@"保存成功" toView:selfWeak.view completion:^{
                    nextNumber = @"";
                }];
            }
        }
    }];
}

- (void)requestData
{
    SaveModel *model = (SaveModel *)[FMDatabaseTool findByFirstProperty:[self getCurrentPeriodsString] withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
    if (model) {
        self.model = model;
        [self reloadUI];
    }else{
        [ToolClass showMBConnectTitle:@"" toView:self.view afterDelay:0 isNeedUserInteraction:NO];
        [ToolClass requestPOSTWithURL:@"http://f.apiplus.cn/ssq-1.json" parameters:nil isCache:YES success:^(id responseObject, NSString *msg) {
            NSArray *data = responseObject[@"data"];
            NSDictionary *dataDict = data.firstObject;
            NSString *dateStr = [NSString stringWithFormat:@"%@(%@)", [dataDict[@"opentime"] componentsSeparatedByString:@" "].firstObject, [ToolClass getWeekDayFordate:[ToolClass dateFromTimeInterval:[dataDict[@"opentimestamp"] doubleValue]]]];
            SaveModel *model =  [SaveModel new];
            model.time = dateStr;
            model.number = dataDict[@"opencode"];
            model.expect = dataDict[@"expect"];
            [FMDatabaseTool saveObjectToDB:model withTableName:NSStringFromClass([SaveModel class])];
            self.model = model;
            [self reloadUI];
            [ToolClass hideMBConnect];
        } failure:^(NSString *errorInfo, NSError *error) {
            if ([errorInfo containsString:@"无缓存"]) {
                SaveModel *model = (SaveModel *)[FMDatabaseTool findByFirstProperty:[self getCurrentPeriodsString] withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
                if (model) {
                    self.model = model;
                    [self reloadUI];
                }
            }
            [ToolClass hideMBConnect];
        }];
    }
    if (canAddAnimation) {
        CATransition *animation = [CATransition animation];
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.type = @"cube";
        animation.repeatCount = 10;
        animation.repeatDuration = 1;
        animation.subtype = kCATransitionFromRight;
        [[self.pageView layer] addAnimation:animation forKey:@"animation"];
        canAddAnimation = NO;
    }
}

- (void)upAndDownButtonClick:(id)object
{
    CATransition *animation = [CATransition animation];
//    animation.delegate = self;
    animation.duration = 0.5;
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
        [ToolClass cancelTimeCountDownWith:timer];
        self.nextExpectView.startBtn.selected = NO;
        self.model = model;
        [self reloadUI];
        [[self.pageView layer] addAnimation:animation forKey:@"animation"];
    }else{
        [ToolClass showMBMessageTitle:mbMessage toView:self.view];
    }
}

//设置显示数据
- (void)reloadUI
{
    self.nextExpectView.buttonEnabled = [self.model.time isEqualToString:[self getCurrentPeriodsString]];

    //设置当前期开奖号码
    [self.openAwardView setOpenAwardViewWithModel:self.model];
    //上一期的时间
    NSString *lastTimeStr = [self getUpOrDownPeriodsString:YES withPeriodString:self.model.time];
    //上一期的模型
    SaveModel *lastTimeModel = (SaveModel *)[FMDatabaseTool findByFirstProperty:lastTimeStr withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
    
    if (lastTimeModel) {
        //获取上期预测结果
        NSDictionary *dict = [OperationManager getResultWithArray:[lastTimeModel.number componentsSeparatedByString:@","]];
        //本期中奖号码
        NSArray *okNums = [[self.model.number componentsSeparatedByString:@"+"].firstObject componentsSeparatedByString:@","];
        //7个号码中买中的号码
        NSArray *sevenArray = [self findIsWinningWithArray1:okNums array2:[lastTimeModel.nextNumber componentsSeparatedByString:@","]];
        //所有个号码中测中的号码
        NSArray *allArray = [self findIsWinningWithArray1:okNums array2:dict[@"allArray"]];
        //中奖信息拼参
        NSDictionary *winingDetailDict = @{@"sevenArray":sevenArray, @"allArray":allArray};
        //设置中奖信息
        [self.winingDetailView setWiningDetailWithDictionary:winingDetailDict];
        //设置上期开奖号码
//        [self.lastExpectView setLastExpectViewWithText:lastTimeModel.number];
        
        //上期预测情况
        NSString *string = [NSString stringWithFormat:@"========= 7个号码 =========\n=  %@  =\n%@", lastTimeModel.nextNumber, [self getFormatStringWithDict:dict]];
        NSMutableAttributedString *attuibutedString = [[NSMutableAttributedString alloc] initWithString:string];
        [attuibutedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Menlo-Bold" size:viewAdapter(16)] range:NSMakeRange(0, attuibutedString.length)];
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
        self.lastExpect.text = @"未查询到上期开奖号码";
        self.pageView.showIndex = 1;
    }
    
    //下期预测情况
    NSDictionary *dict = [OperationManager getResultWithArray:[[self.model.number componentsSeparatedByString:@"+"].firstObject componentsSeparatedByString:@","]];
    NSString *string = [self getFormatStringWithDict:dict];
    self.nextExpect.text = string;
    
    if (self.model.nextNumber.length > 0) {//已有预测号码
        [self.nextExpectView setLastExpectViewWithText:self.model.nextNumber];
        self.nextExpect.text = [NSString stringWithFormat:@"========= 7个号码 =========\n=  %@  =\n%@", self.model.nextNumber, string];
    }else{//没有预测号码
        self.nextExpectView.startBtn.selected = YES;
        timer = [ToolClass timeCountDownWithCount:3000 perTime:0.02 inProgress:^(int time) {
            [self.nextExpectView setLastExpectViewWithText:[[OperationManager allNumbersChooesSevenNumberWithAllNumbers:dict[@"allArray"]] componentsJoinedByString:@","]];
        } completion:^{
            
        }];
    }
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
//    NSString *sevenStr = [dict[@"sevenArray"] componentsJoinedByString:@","];
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
    return [NSString stringWithFormat:@"==========================\n= 例一：%@ =\n= 例二：%@ =\n= 例三：%@ =\n= 例四：%@ =\n==========================\n共%@个号码：%@\n出现次数：%@", example1, example2, example3, example4, dict[@"allArrayCount"], allStr, dictString];
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

- (void)selectedIndex:(NSInteger)index
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
