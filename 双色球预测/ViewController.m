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
#import "SettingViewController.h"

NSString *tempCurrentChase = @"00";
BOOL currentExceptIsWinning = NO;
BOOL lastClickIsNext = NO;  // 上次操作是否是下一期

static BOOL canAddAnimation = NO;
static TCTimer *tcd;

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
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _effectPWView = [[UIVisualEffectView alloc] initWithEffect:blur];
        _effectPWView.userInteractionEnabled = YES;
        _effectPWView.frame = self.view.frame;
        _effectPWView.alpha = 1;
    }
    return _effectPWView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"双色球预测";
    self.view.backgroundColor = UIColorFromRGB(0xf4f6f5);
    // 控制是否显示键盘上的工具条。
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    // 获取到当前期追号的号码
    tempCurrentChase = [ToolClass objectForKey:kCurrentChase] ? : @"00";
    [self createUI];
    /** 设置好篮球后刷新数据以及UI */
    [NotificationCenter addObserver:self selector:@selector(refreshAction) name:kNOTIFICATION_SETBLUENUMBERSDONE object:nil];
    [self requestDataIsRefresh:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadUI];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)createUI
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1242x2208"]];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
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
    }];
    self.nextExpectView.titleLable.text = @"下期预测号码";
    
//    UIImageView *headerImageBg = [[UIImageView alloc] init/*WithImage:[UIImage imageNamed:@"bookshelf_header_mask"]*/];
//    [self.view insertSubview:headerImageBg atIndex:0];
//    [headerImageBg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_topLayoutGuideTop);
//        make.left.right.equalTo(self.view);
//        make.bottom.equalTo(self.nextExpectView.btnBg.mas_centerY).offset(viewAdapter(0));
//    }];
//    headerImageBg.backgroundColor = RGBACOLOR(236, 237, 236, 1);
//    [headerImageBg addSubview:self.effectPWView];
    
    UIView *lastExpectBg = [UIView new];
    UIView *nextExpectBg = [UIView new];
    lastExpectBg.backgroundColor = RGBACOLOR(251, 244, 211, 0.3);
    nextExpectBg.backgroundColor = RGBACOLOR(251, 244, 211, 0.3);
    //预测信息
    self.pageView = [[MLMSegmentPage alloc] initSegmentWithFrame:CGRectZero titlesArray:@[@"本期预测情况", @"下期预测情况"] vcOrviews:@[lastExpectBg, nextExpectBg] headStyle:SegmentHeadStyleSlide];
    self.pageView.delegate = self;
    self.pageView.headWidth = viewAdapter(230);
    self.pageView.headHeight = viewAdapter(40);
    self.pageView.headAlignment = MLMSegmentHeadAlignmentCenter;
    self.pageView.headColor = RGBACOLOR(255, 255, 255, 0);//UIColorFromRGB(0xf4f6f5);
    self.pageView.fontSize = viewAdapter(15);
    self.pageView.deselectColor = UIColorFromRGBWithAlpha(0xffffff, 1);
    self.pageView.selectColor = RGBACOLOR(39, 38, 91, 1);
    //滑块占比,默认 - 1
    self.pageView.slideScale = 1;
    //滑块高度
    self.pageView.slideHeight = viewAdapter(32);
    //滑块颜色
    self.pageView.slideColor = UIColorFromRGBWithAlpha(0xffffff, 1);
    self.pageView.bottomLineHeight = viewAdapter(0);
    [self.view addSubview:self.pageView];
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.nextExpectView.mas_bottom).offset(viewAdapter(0));
    }];
    
    UIView *slideBg = [UIView new];
    [self.pageView insertSubview:slideBg belowSubview:self.pageView.headView];
    [slideBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.pageView.headView);
        make.width.equalTo(self.pageView.headView);
        make.height.mas_equalTo(self.pageView.slideHeight);
    }];
    [slideBg.superview layoutIfNeeded];
    slideBg.layer.cornerRadius = slideBg.bounds.size.height/2;
    slideBg.layer.borderColor = [UIColor whiteColor].CGColor;
    slideBg.layer.borderWidth = viewAdapter(1.5);
    slideBg.backgroundColor = RGBACOLOR(39, 38, 91, 1);
    
    UIView *leftLine = [UIView new];
    [slideBg addSubview:leftLine];
    [leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(slideBg);
        make.left.equalTo(self.pageView);
        make.right.equalTo(slideBg.mas_left);
        make.height.mas_equalTo(viewAdapter(1.5));
    }];
    leftLine.backgroundColor = [UIColor whiteColor];
    
    UIView *rightLine = [UIView new];
    [slideBg addSubview:rightLine];
    [rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(slideBg);
        make.left.equalTo(slideBg.mas_right);
        make.right.equalTo(self.pageView);
        make.height.mas_equalTo(viewAdapter(1.5));
    }];
    rightLine.backgroundColor = [UIColor whiteColor];
    
    UIView *pageViewBg = [UIView new];
    [self.pageView insertSubview:pageViewBg belowSubview:slideBg];
    [pageViewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.pageView);
        make.top.equalTo(slideBg.mas_centerY).offset(viewAdapter(0));
        make.bottom.equalTo(self.pageView.viewsScroll.mas_top).offset(viewAdapter(0));
    }];
    pageViewBg.backgroundColor = RGBACOLOR(251, 244, 211, 0.3);
//    pageViewBg.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    pageViewBg.layer.borderWidth = viewAdapter(0.5);

    
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
    
    __block NSString *nextNumber = @"";
    WeakObj(self);
    [bottomBar setButtonClick:^(UIButton *button, NSInteger index) {
        nextNumber = @"";
        if (index == 0 || index == 1) {//上一期或下一期
            [selfWeak upAndDownButtonClick:button];
        }else if (index == 2){//刷新
            [selfWeak refreshAction];
        }else if (index == 3){//设置
            [selfWeak presentViewController:[[UINavigationController alloc] initWithRootViewController:[[SettingViewController alloc] init]] animated:YES completion:^{
                [ToolClass cancelTimeCountDownWith:tcd];
                selfWeak.nextExpectView.startBtn.selected = NO;
            }];
        }
    }];
    
    [self.nextExpectView setButtonClick:^(UIButton *button, NSInteger index) {
        NSDictionary *dict = [OperationManager getResultWithArray:[[selfWeak.model.number componentsSeparatedByString:@"+"].firstObject componentsSeparatedByString:@","]];
        if (index == 0) {//开始&停止
            if (button.selected) {//开始
                [ToolClass cancelTimeCountDownWith:tcd];
                tcd = [ToolClass timeCountDownWithCount:3000 perTime:0.02 inProgress:^(int time) {
                    [selfWeak.nextExpectView setLastExpectViewWithText:[[OperationManager allNumbersChooesSevenNumberWithAllNumbers:dict[@"allArray"]] componentsJoinedByString:@","]];
                } completion:^{
                    
                }];
            }else{//停止
                [ToolClass cancelTimeCountDownWith:tcd];
                nextNumber = [[OperationManager allNumbersChooesSevenNumberWithAllNumbers:dict[@"allArray"]] componentsJoinedByString:@","];
                [selfWeak.nextExpectView setLastExpectViewWithText:nextNumber];
            }
        }else{//保存
            if (!selfWeak.nextExpectView.startBtn.selected) {//只有在停止状态下才可以保存
                if (nextNumber.length > 0) {
                    NSString *string = [selfWeak getFormatStringWithDict:dict];
                    if (kIsString(selfWeak.model.nextNumber)) {//判断是否已经保存过下期预测号码了
                        if ([nextNumber isEqualToString:selfWeak.model.nextNumber]) {
                            [ToolClass showMBMessageTitle:@"显示的账号与保存的账号一样，无需保存" toView:selfWeak.view];
                        }else{
                            [ToolClass showAlertControllerWithPreferredStyle:UIAlertControllerStyleAlert title:@"检测到已有保存过的号码\n是否更新?" message:@"" handlerBlock:^(NSUInteger buttonIndex) {
                                if (buttonIndex == 1) {
                                    selfWeak.nextExpect.text = [NSString stringWithFormat:@"========= 7个号码 =========\n=  %@  =\n%@", nextNumber, string];
                                    selfWeak.model.nextNumber = nextNumber;
                                    [FMDatabaseTool saveObjectToDB:selfWeak.model withTableName:NSStringFromClass([SaveModel class])];
                                    [ToolClass showMBMessageTitle:@"保存成功" toView:selfWeak.view completion:^{
                                        nextNumber = @"";
                                    }];
                                }
                            } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                        }
                    }else{
                        selfWeak.nextExpect.text = [NSString stringWithFormat:@"========= 7个号码 =========\n=  %@  =\n%@", nextNumber, string];
                        selfWeak.model.nextNumber = nextNumber;
                        [FMDatabaseTool saveObjectToDB:selfWeak.model withTableName:NSStringFromClass([SaveModel class])];
                        [ToolClass showMBMessageTitle:@"保存成功" toView:selfWeak.view completion:^{
                            nextNumber = @"";
                        }];
                    }
                }else{
                    [ToolClass showMBMessageTitle:@"显示的账号与保存的账号一样，无需保存" toView:selfWeak.view];
                }
            }
        }
    }];
}

/** 刷新触发事件 */
- (void)refreshAction
{
    [ToolClass cancelTimeCountDownWith:tcd];
    self.nextExpectView.startBtn.selected = NO;
    canAddAnimation = YES;
    [self requestDataIsRefresh:YES];
}

- (void)requestDataIsRefresh:(BOOL)isRefresh
{
    /** 如果是刷新将当前期追号置为最新的追号 */
    if (isRefresh) {
        tempCurrentChase = [ToolClass objectForKey:kCurrentChase] ? : @"00";
    }
    SaveModel *model = (SaveModel *)[FMDatabaseTool findByFirstProperty:[ToolClass objectForKey:kLASTEXPECT] withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
    if (model && !isRefresh) {
        self.model = model;
        [self reloadUI];
    }else{
        [ToolClass showMBConnectTitle:@"" toView:self.view afterDelay:1 isNeedUserInteraction:NO];
        [ToolClass requestGETWithURL:NET_API_NEW parameters:@{@"gameEn":@"ssq", @"currentPeriod":GETEXPECT(20)} isCache:NO success:^(id responseObject, NSString *msg) {
            NSArray *data = responseObject[@"game"][@"period"];
            for (int i = 0; i < data.count; i++) {
                NSDictionary *dataDict = data[i];
                NSString *expect = dataDict[@"periodName"];
                if (i == 0) {
                    [ToolClass setObject:expect forKey:kLASTEXPECT];
                }
                SaveModel *model = (SaveModel *)[FMDatabaseTool findByFirstProperty:expect withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
                if (!model) {
                    model = [SaveModel new];
                    model.expect = dataDict[@"periodName"];
                    model.time = [NSString stringWithFormat:@"%@(%@)", [dataDict[@"awardTime"] componentsSeparatedByString:@" "].firstObject, [ToolClass getWeekDayFordate:[ToolClass dateFromDateString:dataDict[@"awardTime"] format:@"yyyy-MM-dd HH:mm:ss"]]];
                    model.number = [[dataDict[@"awardNo"] stringByReplacingOccurrencesOfString:@" " withString:@","] stringByReplacingOccurrencesOfString:@":" withString:@"+"];
                    [FMDatabaseTool saveObjectToDB:model withTableName:NSStringFromClass([SaveModel class])];
                }
                if (i == 0) {
                    [ToolClass setObject:expect forKey:kLASTEXPECT];
                    self.model = model;
                    [self reloadUI];
                }
            }
            [ToolClass hideMBConnect];
        } failure:^(NSString *errorInfo, NSError *error) {
            if ([errorInfo containsString:@"无缓存"]) {
                SaveModel *model = (SaveModel *)[FMDatabaseTool findByFirstProperty:[ToolClass objectForKey:kLASTEXPECT] withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
                if (model) {
                    self.model = model;
                    [self reloadUI];
                }
            }
            [ToolClass hideMBConnect];
            [ToolClass showMBMessageTitle:@"网络错误" toView:self.view];
        }];
//        [ToolClass requestPOSTWithURL:NET_API parameters:nil isCache:NO success:^(id responseObject, NSString *msg) {
//            NSArray *data = responseObject[@"data"];
//            for (int i = 0; i < data.count; i++) {
//                NSDictionary *dataDict = data[i];
//                NSString *expect = dataDict[@"expect"];
//                SaveModel *model = (SaveModel *)[FMDatabaseTool findByFirstProperty:expect withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
//                if (!model) {
//                    model = [SaveModel new];
//                    model.expect = dataDict[@"expect"];
//                    model.time = [NSString stringWithFormat:@"%@(%@)", [dataDict[@"opentime"] componentsSeparatedByString:@" "].firstObject, [ToolClass getWeekDayFordate:[ToolClass dateFromTimeInterval:[dataDict[@"opentimestamp"] doubleValue]]]];
//                    model.number = dataDict[@"opencode"];
//                    [FMDatabaseTool saveObjectToDB:model withTableName:NSStringFromClass([SaveModel class])];
//                }
//                if (i == 0) {
//                    [ToolClass setObject:expect forKey:kLASTEXPECT];
//                    self.model = model;
//                    [self reloadUI];
//                }
//            }
//            [ToolClass hideMBConnect];
//        } failure:^(NSString *errorInfo, NSError *error) {
//            if ([errorInfo containsString:@"无缓存"]) {
//                SaveModel *model = (SaveModel *)[FMDatabaseTool findByFirstProperty:[ToolClass objectForKey:kLASTEXPECT] withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
//                if (model) {
//                    self.model = model;
//                    [self reloadUI];
//                }
//            }
//            [ToolClass hideMBConnect];
//            [ToolClass showMBMessageTitle:@"网络错误" toView:self.view];
//        }];
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

- (void)requestDataWithExpect:(NSInteger)expect animation:(CATransition *)animation isShowNoData:(BOOL)isShowNoData
{
    [ToolClass showMBConnectTitle:@"" toView:self.view afterDelay:0 isNeedUserInteraction:NO];
    [ToolClass requestGETWithURL:NET_API_NEW parameters:@{@"gameEn":@"ssq", @"currentPeriod":GETEXPECT(20)} isCache:NO success:^(id responseObject, NSString *msg) {
        NSArray *data = responseObject[@"game"][@"period"];
        NSDictionary *dataDict = data.firstObject;
        NSString *expect = dataDict[@"periodName"];
        SaveModel *model =  [SaveModel new];
        model.expect = expect;
        model.time = [NSString stringWithFormat:@"%@(%@)", [dataDict[@"awardTime"] componentsSeparatedByString:@" "].firstObject, [ToolClass getWeekDayFordate:[ToolClass dateFromDateString:dataDict[@"awardTime"] format:@"yyyy-MM-dd HH:mm:ss"]]];
        model.number = [[dataDict[@"awardNo"] stringByReplacingOccurrencesOfString:@" " withString:@","] stringByReplacingOccurrencesOfString:@":" withString:@"+"];
        [FMDatabaseTool saveObjectToDB:model withTableName:NSStringFromClass([SaveModel class])];
        self.model = model;
        [self reloadUI];
        [ToolClass hideMBConnect];
    } failure:^(NSString *errorInfo, NSError *error) {
        if ([errorInfo containsString:@"无缓存"]) {
            SaveModel *model = (SaveModel *)[FMDatabaseTool findByFirstProperty:[ToolClass objectForKey:kLASTEXPECT] withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
            if (model) {
                self.model = model;
                [self reloadUI];
            }
        }
        [ToolClass hideMBConnect];
        [ToolClass showMBMessageTitle:@"网络错误" toView:self.view];
    }];
//    [ToolClass requestPOSTWithURL:NET_API parameters:nil isCache:NO success:^(id responseObject, NSString *msg) {
//        NSArray *data = responseObject[@"data"];
//        NSDictionary *dataDict = data.firstObject;
//        NSString *expect = dataDict[@"expect"];
//        SaveModel *model =  [SaveModel new];
//        model.expect = expect;
//        model.time = [NSString stringWithFormat:@"%@(%@)", [dataDict[@"opentime"] componentsSeparatedByString:@" "].firstObject, [ToolClass getWeekDayFordate:[ToolClass dateFromTimeInterval:[dataDict[@"opentimestamp"] doubleValue]]]];
//        model.number = dataDict[@"opencode"];
//        [FMDatabaseTool saveObjectToDB:model withTableName:NSStringFromClass([SaveModel class])];
//        self.model = model;
//        [self reloadUI];
//        [ToolClass hideMBConnect];
//    } failure:^(NSString *errorInfo, NSError *error) {
//        if ([errorInfo containsString:@"无缓存"]) {
//            SaveModel *model = (SaveModel *)[FMDatabaseTool findByFirstProperty:[ToolClass objectForKey:kLASTEXPECT] withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
//            if (model) {
//                self.model = model;
//                [self reloadUI];
//            }
//        }
//        [ToolClass hideMBConnect];
//        [ToolClass showMBMessageTitle:@"网络错误" toView:self.view];
//    }];
}

- (void)reloadUIWithAnimation:(CATransition *)animation
{
//    [ToolClass cancelTimeCountDownWith:timer];
//    NSLog(@"ssssssssssss: 倒计时停止");
    self.nextExpectView.startBtn.selected = NO;
    [self reloadUI];
    [[self.pageView layer] addAnimation:animation forKey:@"animation"];
}

- (SaveModel *)findLastYearLastExpectWithExpect:(NSInteger)expect
{
    return (SaveModel *)[FMDatabaseTool findByFirstProperty:[NSString stringWithFormat:@"%ld%@", [ToolClass stringFromNowDateFormat:@"yyyy"].integerValue -1, [self getOkExpectWith:expect]] withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
}

- (NSString *)getOkExpectWith:(NSInteger)expect
{
    NSString *str = [NSString stringWithFormat:@"%ld", expect];
    if (str.length == 1) {
        return [NSString stringWithFormat:@"00%@", str];
    }else if (str.length == 2){
        return [NSString stringWithFormat:@"0%@", str];
    }else{
        return str;
    }
}

- (NSArray *)getChasenumbers
{
    NSString *str = [ToolClass objectForKey:kSelectedNumbers];
    if (kIsString(str)) {
        return [str componentsSeparatedByString:@","];
    }
    return @[];
}

- (void)upAndDownButtonClick:(id)object
{
    CATransition *animation = [CATransition animation];
//    animation.delegate = self;
    animation.duration = 0.5;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"cube";

    SaveModel *model = nil;
    NSArray *chaseNumbers = [self getChasenumbers];
    if ([object isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)object;
        if (button.tag == 2000) {//上一期
            /** 
             chaseNumbers.count 数组有值，设置了追号以后
             currentExceptIsWinning 当前期是否中奖，已中奖
             [self.model.expect isEqualToString:[ToolClass objectForKey:kLASTEXPECT]] 当前期是否是最新的一期，是最新的一期
             lastClickIsNext 上次操作是否是下一期，是下一期
             */
            if (chaseNumbers.count && (currentExceptIsWinning || [self.model.expect isEqualToString:[ToolClass objectForKey:kLASTEXPECT]] || lastClickIsNext)) {
                NSUInteger index = [chaseNumbers indexOfObject:tempCurrentChase];
                tempCurrentChase = chaseNumbers[index > 0 ? index - 1 : chaseNumbers.count - 1];
            }
            animation.subtype = kCATransitionFromLeft;
            NSInteger lastExpect = [self.model.expect substringFromIndex:4].integerValue - 1;
            if (lastExpect > 0) {//如果不是去年
                model = (SaveModel *)[FMDatabaseTool findByFirstProperty:[NSString stringWithFormat:@"%@%@", [ToolClass stringFromDateWithFormat:@"yyyy" date:[ToolClass dateFromDateString:[self.model.time substringToIndex:10] format:@"yyyy-MM-dd"]], [self getOkExpectWith:lastExpect]] withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
                if (model) {//如果数据库有就直接显示
                    self.model = model;
                    [self reloadUIWithAnimation:animation];
                }else{//如果没有
                    [ToolClass showMBMessageTitle:@"未找到上期数据" toView:self.view];
                }
            }else{//如果是去年
                for (int i = 155; i > 151; i--) {
                    model = [self findLastYearLastExpectWithExpect:i];
                    if (model) {
                        break;
                    }
                }
                if (model) {//如果数据库有就直接显示
                    self.model = model;
                    [self reloadUIWithAnimation:animation];
                }else{//如果没有
                    [ToolClass showMBMessageTitle:@"未找到上期数据" toView:self.view];
                }
            }
            // 将上次操作是否是下一期置为NO
            lastClickIsNext = NO;
        }else{//下一期
            /**
             chaseNumbers.count 数组有值，设置了追号以后
             currentExceptIsWinning 当前期是否中奖，已中奖
             lastClickIsNext 上次操作是否是下一期，不是下一期
             */
            if (chaseNumbers.count && (currentExceptIsWinning || !lastClickIsNext)) {
                NSUInteger index = [chaseNumbers indexOfObject:tempCurrentChase];
                tempCurrentChase = chaseNumbers[index < chaseNumbers.count - 1 ? index + 1 : 0];
            }
            animation.subtype = kCATransitionFromRight;
            NSInteger nextExpect = self.model.expect.integerValue + 1;
            if (nextExpect > [[ToolClass objectForKey:kLASTEXPECT] integerValue]){
                [ToolClass showMBMessageTitle:@"最后一期" toView:self.view];
            }else{
                model = (SaveModel *)[FMDatabaseTool findByFirstProperty:@(nextExpect) withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
                if (model) {//如果数据库有就直接显示
                    self.model = model;
                    [self reloadUIWithAnimation:animation];
                }else{
                    model = (SaveModel *)[FMDatabaseTool findByFirstProperty:[NSString stringWithFormat:@"%ld001", [self.model.time substringToIndex:4].integerValue + 1] withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
                    if (model) {//如果数据库有就直接显示
                        self.model = model;
                        [self reloadUIWithAnimation:animation];
                    }else{
                    
                    }
                }
            }
            // 将上次操作是否是下一期置为YES
            lastClickIsNext = YES;
        }
    }else{
        UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer *)object;
        if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {//上一期
            /**
             chaseNumbers.count 数组有值，设置了追号以后
             currentExceptIsWinning 当前期是否中奖，已中奖
             [self.model.expect isEqualToString:[ToolClass objectForKey:kLASTEXPECT]] 当前期是否是最新的一期，是最新的一期
             lastClickIsNext 上次操作是否是下一期，是下一期
             */
            if (chaseNumbers.count && (currentExceptIsWinning || [self.model.expect isEqualToString:[ToolClass objectForKey:kLASTEXPECT]] || lastClickIsNext)) {
                NSUInteger index = [chaseNumbers indexOfObject:tempCurrentChase];
                tempCurrentChase = chaseNumbers[index > 0 ? index - 1 : chaseNumbers.count - 1];
            }
            animation.subtype = kCATransitionFromLeft;
            NSInteger lastExpect = [self.model.expect substringFromIndex:4].integerValue - 1;
            if (lastExpect > 0) {//如果不是去年
                model = (SaveModel *)[FMDatabaseTool findByFirstProperty:[NSString stringWithFormat:@"%@%@", [ToolClass stringFromDateWithFormat:@"yyyy" date:[ToolClass dateFromDateString:[self.model.time substringToIndex:10] format:@"yyyy-MM-dd"]], [self getOkExpectWith:lastExpect]] withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
                if (model) {//如果数据库有就直接显示
                    self.model = model;
                    [self reloadUIWithAnimation:animation];
                }else{//如果没有
                    [ToolClass showMBMessageTitle:@"未找到上期数据" toView:self.view];
                }
            }else{//如果是去年
                for (int i = 155; i > 151; i--) {
                    model = [self findLastYearLastExpectWithExpect:i];
                    if (model) {
                        break;
                    }
                }
                if (model) {//如果数据库有就直接显示
                    self.model = model;
                    [self reloadUIWithAnimation:animation];
                }else{//如果没有
                    [ToolClass showMBMessageTitle:@"未找到上期数据" toView:self.view];
                }
            }
            // 将上次操作是否是下一期置为NO
            lastClickIsNext = NO;
        }else{//下一期
            /**
             chaseNumbers.count 数组有值，设置了追号以后
             currentExceptIsWinning 当前期是否中奖，已中奖
             lastClickIsNext 上次操作是否是下一期，不是下一期
             */
            if (chaseNumbers.count && (currentExceptIsWinning || !lastClickIsNext)) {
                NSUInteger index = [chaseNumbers indexOfObject:tempCurrentChase];
                tempCurrentChase = chaseNumbers[index < chaseNumbers.count - 1 ? index + 1 : 0];
            }
            animation.subtype = kCATransitionFromRight;
            NSInteger nextExpect = self.model.expect.integerValue + 1;
            if (nextExpect > [[ToolClass objectForKey:kLASTEXPECT] integerValue]){
                [ToolClass showMBMessageTitle:@"最后一期" toView:self.view];
            }else{
                model = (SaveModel *)[FMDatabaseTool findByFirstProperty:@(nextExpect) withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
                if (model) {//如果数据库有就直接显示
                    self.model = model;
                    [self reloadUIWithAnimation:animation];
                }else{
                    model = (SaveModel *)[FMDatabaseTool findByFirstProperty:[NSString stringWithFormat:@"%ld001", [self.model.time substringToIndex:4].integerValue + 1] withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
                    if (model) {//如果数据库有就直接显示
                        self.model = model;
                        [self reloadUIWithAnimation:animation];
                    }else{
                        
                    }
                }
            }
            // 将上次操作是否是下一期置为YES
            lastClickIsNext = YES;
        }
        self.pageView.viewsScroll.scrollEnabled = YES;
    }
}

//设置显示数据
- (void)reloadUI
{
    currentExceptIsWinning = [[self.model.number substringFromIndex:self.model.number.length - 2] isEqualToString:tempCurrentChase];
    self.nextExpectView.buttonEnabled = [self.model.expect isEqualToString:[ToolClass objectForKey:kLASTEXPECT]];

    //上一期的时间
    NSString *lastExpect = @(self.model.expect.integerValue - 1).stringValue;
    //上一期的模型
    SaveModel *lastTimeModel = (SaveModel *)[FMDatabaseTool findByFirstProperty:lastExpect withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
    
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
        //设置当前期开奖号码
        [self.openAwardView setOpenAwardViewWithModel:self.model andWiningNumers:sevenArray];
        //设置中奖信息
        [self.winingDetailView setWiningDetailWithDictionary:winingDetailDict];
        
        //上期预测情况
        NSString *string = [NSString stringWithFormat:@"========= 7个号码 =========\n=  %@  =\n%@", kIsString(lastTimeModel.nextNumber) ? lastTimeModel.nextNumber : @"  本期没有选择7个号码  ", [self getFormatStringWithDict:dict]];
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
        if ([[self.model.expect substringFromIndex:4] isEqualToString:@"001"]) {
            for (int i = 155; i > 151; i--) {
                lastTimeModel = [self findLastYearLastExpectWithExpect:i];
                if (lastTimeModel) {
                    break;
                }
            }
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
                //设置当前期开奖号码
                [self.openAwardView setOpenAwardViewWithModel:self.model andWiningNumers:sevenArray];
                //设置中奖信息
                [self.winingDetailView setWiningDetailWithDictionary:winingDetailDict];
                
                //上期预测情况
                NSString *string = [NSString stringWithFormat:@"========= 7个号码 =========\n=  %@  =\n%@", kIsString(lastTimeModel.nextNumber) ? lastTimeModel.nextNumber : @"  本期没有选择7个号码  ", [self getFormatStringWithDict:dict]];
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
            }else{//如果没有
                [self.winingDetailView setWiningDetailWithDictionary:nil];
                self.lastExpect.text = @"未查询到上期开奖号码";
                self.pageView.showIndex = 1;
            }
        }else{
            //设置当前期开奖号码
            [self.openAwardView setOpenAwardViewWithModel:self.model andWiningNumers:@[]];
            [self.winingDetailView setWiningDetailWithDictionary:nil];
            self.lastExpect.text = @"未查询到上期开奖号码";
            self.pageView.showIndex = 1;
        }
    }
    
    //下期预测情况
    NSDictionary *dict = [OperationManager getResultWithArray:[[self.model.number componentsSeparatedByString:@"+"].firstObject componentsSeparatedByString:@","]];
    NSString *string = [self getFormatStringWithDict:dict];
    self.nextExpect.text = string;
    [ToolClass cancelTimeCountDownWith:tcd];

    if (self.model.nextNumber.length > 0) {//已有预测号码
        [self.nextExpectView setLastExpectViewWithText:self.model.nextNumber];
        self.nextExpect.text = [NSString stringWithFormat:@"========= 7个号码 =========\n=  %@  =\n%@", self.model.nextNumber, string];
    }else{//没有预测号码
        if ([self.model.time isEqualToString:[self getCurrentPeriodsString]]) {//当前期
            self.nextExpectView.startBtn.selected = YES;
            tcd = [ToolClass timeCountDownWithCount:6 perTime:0.5 inProgress:^(int time) {
                if (time%2) {
                    [self.nextExpectView setLastExpectViewWithText:[[@[@"--",@"--",@"--",@"--",@"--",@"--",@"--"] mutableCopy] componentsJoinedByString:@","]];
                }else{
                    [self.nextExpectView setLastExpectViewWithText:[[@[@"  ",@"  ",@"  ",@"  ",@"  ",@"  ",@"  "] mutableCopy] componentsJoinedByString:@","]];
                }
            } completion:^{
                tcd = [ToolClass timeCountDownWithCount:9999999 perTime:0.02 inProgress:^(int time) {
                    [self.nextExpectView setLastExpectViewWithText:[[OperationManager allNumbersChooesSevenNumberWithAllNumbers:dict[@"allArray"]] componentsJoinedByString:@","]];
//                    NSLog(@"ssssssssssss: 倒计时回调又给刷新预测号码了");
                } completion:^{
                    
                }];
            }];
        }else{//如果当前显示不是当前期数而且还没有预测号码的，随机选择一注
            //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //});
            [self.nextExpectView setLastExpectViewWithText:@"--,--,--,--,--,--,--"];
//            NSLog(@"ssssssssssss: 没有预测号码设置好了");
            self.nextExpect.text = [NSString stringWithFormat:@"========= 7个号码 =========\n=    该期没有选择7个号码    =\n%@", string];
        }
    }
    NSLog(@"self.model.number == %@\nself.model.expect == %@\n[ToolClass objectForKey:kLASTEXPECT] == %@", [self.model.number substringFromIndex:self.model.number.length - 2], self.model.expect, [ToolClass objectForKey:kLASTEXPECT]);
    if ([[ToolClass objectForKey:kLASTEXPECT] isEqualToString:self.model.expect] && tempCurrentChase.integerValue > 0) {
        [ToolClass setObject:tempCurrentChase forKey:kCurrentChase];
        NSLog(@"self.model.number == %@\nself.model.expect == %@\n[ToolClass objectForKey:kLASTEXPECT] == %@\ntempCurrentChase == %@", [self.model.number substringFromIndex:self.model.number.length - 2], self.model.expect, [ToolClass objectForKey:kLASTEXPECT], tempCurrentChase);
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
