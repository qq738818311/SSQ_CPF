//
//  SetBlueViewController.m
//  双色球预测
//
//  Created by Sifude_PF on 2017/4/10.
//  Copyright © 2017年 CPF. All rights reserved.
//

#import "SetBlueViewController.h"
#import "CustomSlider.h"
#import "ViewController.h"

@interface SetBlueViewController ()

@property (nonatomic, strong) NSMutableArray *selectedNums;

@property (nonatomic, strong) UIView *selectBlueBallBg;
@property (nonatomic, strong) CustomSlider *slider;

@end

@implementation SetBlueViewController

- (NSMutableArray *)selectedNums
{
    if (!_selectedNums) {
        _selectedNums = [NSMutableArray array];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *str = [ToolClass objectForKey:kSelectedNumbers];
            if (kIsString(str)) {
                [_selectedNums addObjectsFromArray:[NSMutableArray arrayWithArray:[str   componentsSeparatedByString:@","]]];
                for (UIButton *button in self.selectBlueBallBg.subviews) {
                    if ([_selectedNums containsObject:[button titleForState:UIControlStateNormal]]) {
                        button.selected = YES;
                    }
                }
            }
        });
    }
    return _selectedNums;
}

#define SPACING viewAdapter(10)

#define blueLabelHW ((WIDTH - SPACING*10)/7)

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xf4f6f5);
    self.navigationItem.title = @"设置篮球规则";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(settingDone)];
    
    [self createUI];
}

- (void)createUI
{
    // 说明label
    UILabel *detailLabel = [UILabel new];
    detailLabel.text = @"     请选择需要追号的几个号码:";
    detailLabel.backgroundColor = UIColorFromRGB(0xdddddd);
    detailLabel.font = [UIFont systemFontOfSize:viewAdapter(15.5)];
    [self.view addSubview:detailLabel];
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(viewAdapter(44));
    }];
    
    //选号区
    self.selectBlueBallBg = [UIView new];
    for (int i = 0; i < 16; i++) {
        UIButton *selectNumBtn = [UIButton new];
        selectNumBtn.layer.borderColor = [UIColor blueColor].CGColor;
        selectNumBtn.layer.borderWidth = viewAdapter(2.5);
        selectNumBtn.layer.masksToBounds = YES;
        selectNumBtn.layer.cornerRadius = ((WIDTH - SPACING*10)/7)/2;
        selectNumBtn.tag = 1000 + i;
        [selectNumBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [selectNumBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [selectNumBtn setBackgroundImage:[UIImage imageWithColor:[UIColor blueColor]] forState:UIControlStateSelected];
        [selectNumBtn addTarget:self action:@selector(numberButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        selectNumBtn.titleLabel.font = [UIFont systemFontOfSize:viewAdapter(25)];
        [self.selectBlueBallBg addSubview:selectNumBtn];
        int horizontal = i%7;
        int vertical = i/7;
        [selectNumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo((WIDTH - SPACING*10)/7);
            make.top.equalTo(self.selectBlueBallBg).offset(SPACING +vertical*(((WIDTH - SPACING*10)/7)+ SPACING));
            make.left.equalTo(self.selectBlueBallBg).offset(SPACING + horizontal*(((WIDTH - SPACING*10)/7)+ SPACING));
            if (vertical == 2) {
                make.bottom.equalTo(self.selectBlueBallBg).offset(-SPACING).priorityLow();
            }
        }];
        NSString *title = kTwoBitString([@(i+1) stringValue]);
        [selectNumBtn setTitle:title forState:UIControlStateNormal];
    }
    [self.view addSubview:self.selectBlueBallBg];
    [self.selectBlueBallBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(detailLabel.mas_bottom);
        make.left.equalTo(self.view).offset(SPACING);
        make.right.equalTo(self.view).offset(-SPACING);
    }];
    
    [self selectedNums];
    
    // 设置当前期追的号码
    UILabel *detailLabel1 = [UILabel new];
    detailLabel1.text = @"     请设置当前期追的号码：";
    detailLabel1.backgroundColor = UIColorFromRGB(0xdddddd);
    detailLabel1.font = [UIFont systemFontOfSize:viewAdapter(15.5)];
    [self.view addSubview:detailLabel1];
    [detailLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.selectBlueBallBg.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(viewAdapter(44));
    }];
    
    self.slider = [[CustomSlider alloc] init];
    self.slider.minimumValue = 1;//下限
    self.slider.maximumValue = 16;//上限
    self.slider.value = [[ToolClass objectForKey:kCurrentChase] integerValue] ? : 1;
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    // 滑动结束时调用，UIControlEventTouchUpInside UIControlEventTouchUpOutside UIControlEventTouchCancel这三个都可以
    [self.slider addTarget:self action:@selector(sliderTouchEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    [self.view addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(detailLabel1.mas_bottom).offset(viewAdapter(20));
        make.left.equalTo(self.view).offset(viewAdapter(20));
        make.right.equalTo(self.view).offset(viewAdapter(-20));
    }];
    
}

- (void)numberButtonSelected:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        [self.selectedNums addObject:[button titleForState:UIControlStateNormal]];
    }else{
        [self.selectedNums removeObject:[button titleForState:UIControlStateNormal]];
    }
}

- (void)sliderValueChanged:(UISlider *)slider
{
    slider.value = (int)slider.value;
    self.slider.blueLabel.text = kTwoBitString([@((int)slider.value) stringValue]);
}

- (void)sliderTouchEnd:(UISlider *)slider
{
    slider.value = (int)slider.value;
}

- (void)settingDone
{
    if (self.selectedNums.count) {
        [self.selectedNums sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        // 选择追号的号码
        [ToolClass setObject:[self.selectedNums componentsJoinedByString:@","] forKey:kSelectedNumbers];
        // 当前追号
        [ToolClass setObject:self.slider.blueLabel.text forKey:kCurrentChase];
        tempCurrentChase = self.slider.blueLabel.text;
        [NotificationCenter postNotificationName:kNOTIFICATION_SETBLUENUMBERSDONE object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [ToolClass showMBMessageTitle:@"还没有选择追号的号码！" toView:self.view];
    }
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

@end
