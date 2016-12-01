//
//  MLMSegmentPage.m
//  MLMSegmentPage
//
//  Created by my on 16/11/4.
//  Copyright © 2016年 my. All rights reserved.
//

#import "MLMSegmentPage.h"

@interface MLMSegmentPage () <NSCacheDelegate,MLMSegmentHeadDelegate,UIScrollViewDelegate>
{
    NSArray *titlesArray;
    NSArray *viewsArray;
    
    NSInteger currentIndex;
}
//@property (nonatomic, strong) NSCache *viewsCache;//存储页面(使用计数功能)
@property (nonatomic, strong) MLMSegmentHead *headView;

@end

@implementation MLMSegmentPage

#pragma mark - init
- (instancetype)initSegmentWithFrame:(CGRect)frame titlesArray:(NSArray *)titles vcOrviews:(NSArray *)views headStyle:(MLMSegmentHeadStyle)style {
    if (self = [super initWithFrame:frame]) {
        _headStyle = style;
        titlesArray = [titles copy];
        viewsArray = [views copy];
        [self defaultSet];
        [self createView];
//        [self addObserver:self forKeyPath:@"superview" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

#pragma mark - 默认
- (void)defaultSet {
//    _countLimit = titlesArray.count;

//    _headStyle = SegmentHeadStyleLine;

    _headHeight = 50;
    currentIndex = 0;
    
    _headColor = [UIColor whiteColor];
    _selectColor = [UIColor blackColor];
    _deselectColor = [UIColor lightGrayColor];
    
    _showIndex = 0;
    
    _fontSize = 13;
    _fontScale = 1;
    
    _lineHeight = 2.5;
    _lineScale = 1;
    
    _slideScale = 1;
    _maxTitleNum = 5;
    
    _bottomLineColor = [UIColor grayColor];
    _bottomLineHeight = 1;
    
}

//#pragma mark - viewsCache
//- (NSCache *)viewsCache {
//    if (!_viewsCache) {
//        _viewsCache = [[NSCache alloc] init];
//        _viewsCache.countLimit = _countLimit;
//        _viewsCache.delegate = self;
//    }
//    return _viewsCache;
//}

#pragma mark - headView
- (MLMSegmentHead *)headView {
    if (!_headView) {
        _headView = [[MLMSegmentHead alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, _headHeight) titles:titlesArray headStyle:_headStyle];
        _headView.delegate = self;
    }
    return _headView;
}

- (void)setHeadColor:(UIColor *)headColor
{
    _headColor = headColor;
    _headView.headColor = _headColor;
}

- (void)setHeadHeight:(CGFloat)headHeight
{
    _headHeight = headHeight;
    _viewsScroll.frame = CGRectMake(0, _headHeight, self.frame.size.width, self.frame.size.height - _headHeight);
    
    _headView.slideHeight = _slideHeight ? : _headHeight*.8;
    _headView.frame = CGRectMake(0, 0, self.frame.size.width, _headHeight);
}

- (void)setSelectColor:(UIColor *)selectColor
{
    _selectColor = selectColor;
    _headView.selectColor = _selectColor;
    if (_headStyle == SegmentHeadStyleLine) {
        _lineColor = _lineColor ? : _selectColor;
        _headView.lineColor = _lineColor;
    }
    if (_headStyle == SegmentHeadStyleArrow) {
        _arrowColor = _arrowColor ? : _selectColor;
        _headView.arrowColor = _arrowColor;
    }
}

- (void)setDeselectColor:(UIColor *)deselectColor
{
    _deselectColor = deselectColor;
    _headView.deSelectColor = _deselectColor;
    if (_headStyle == SegmentHeadStyleSlide) {
        _slideColor = _slideColor ? : _deselectColor;
        _headView.slideColor = _slideColor;
    }
}

- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    _headView.fontSize = _fontSize;
}

- (void)setFontScale:(CGFloat)fontScale
{
    _fontScale = fontScale;
    _headView.fontScale = _fontScale;
}

- (void)setShowIndex:(NSInteger)showIndex
{
    _showIndex = showIndex;
    _showIndex = MIN(titlesArray.count-1, MAX(0, _showIndex));
    _headView.showIndex = _showIndex;
    currentIndex = _showIndex;

    [_headView setSelectIndex:currentIndex];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    _headView.lineColor = _lineColor;
}

- (void)setLineHeight:(CGFloat)lineHeight
{
    _lineHeight = lineHeight;
    _headView.lineHeight = _lineHeight;
}

- (void)setLineScale:(CGFloat)lineScale
{
    _lineScale = lineScale;
    _headView.lineScale = _lineScale;
}

- (void)setArrowColor:(UIColor *)arrowColor
{
    _arrowColor = arrowColor;
    _headView.arrowColor = _arrowColor;
}

- (void)setSlideColor:(UIColor *)slideColor
{
    _slideColor = slideColor;
    _headView.slideColor = _slideColor;
}

- (void)setSlideHeight:(CGFloat)slideHeight
{
    _slideHeight = slideHeight;
    _headView.slideHeight = _slideHeight;
}

- (void)setSlideCorner:(CGFloat)slideCorner
{
    _slideCorner = slideCorner;
    _headView.slideCorner = _slideCorner;
}

- (void)setSlideScale:(CGFloat)slideScale
{
    _slideScale = slideScale;
    _headView.slideScale = _slideScale;
}

- (void)setMaxTitleNum:(NSInteger)maxTitleNum
{
    _maxTitleNum = maxTitleNum;
    _headView.maxTitles = _maxTitleNum;
}

- (void)setBottomLineHeight:(CGFloat)bottomLineHeight
{
    _bottomLineHeight = bottomLineHeight;
    _headView.bottomLineHeight = _bottomLineHeight;
}

- (void)setBottomLineColor:(UIColor *)bottomLineColor
{
    _bottomLineColor = bottomLineColor;
    _headView.bottomLineColor = _bottomLineColor;
}

#pragma mark - layoutsubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    _headView.frame = CGRectMake(0, 0, self.frame.size.width, _headHeight);
    _viewsScroll.frame = CGRectMake(0, _headHeight, self.frame.size.width, self.frame.size.height - _headHeight);
    [_viewsScroll setContentOffset:CGPointMake(_showIndex * self.frame.size.width, 0) animated:YES];
    [_viewsScroll setContentSize:CGSizeMake(titlesArray.count *_viewsScroll.frame.size.width, _viewsScroll.frame.size.height)];
    for (int i = 0; i < _viewsScroll.subviews.count; i++) {
        UIView *view = _viewsScroll.subviews[i];
        view.frame = CGRectMake(i*_viewsScroll.frame.size.width, 0, _viewsScroll.frame.size.width, _viewsScroll.frame.size.height);
    }
}


#pragma mark - createView
- (void)createView {
    _headView.headColor = _headColor;
    _headView.selectColor = _selectColor;
    _headView.deSelectColor = _deselectColor;
    _headView.fontSize = _fontSize;
    _headView.fontScale = _fontScale;
    _showIndex = MIN(titlesArray.count-1, MAX(0, _showIndex));
    _headView.showIndex = _showIndex;
    
    currentIndex = _showIndex;
    
    _headView.lineColor = _lineColor ? : _selectColor;
    _headView.lineHeight = _lineHeight;
    _headView.lineScale = _lineScale;
    
    _headView.arrowColor = _arrowColor ? : _selectColor;
    
    _headView.slideColor = _slideColor ? : _deselectColor;
    _headView.slideHeight = _slideHeight ? : _headHeight*.8;
    _headView.slideCorner = _slideCorner ? : _slideHeight ? _slideHeight/2 : _headHeight*.8/2;
    _headView.slideScale = _slideScale;
    
    _headView.maxTitles = _maxTitleNum;
    
    _headView.bottomLineHeight = _bottomLineHeight;
    _headView.bottomLineColor = _bottomLineColor;
    
    [self addSubview:self.headView];
    [self createViewsScroll];
    
    
    [self defaultViewCache];

}


#pragma mark - create_scroll
- (void)createViewsScroll {
    _viewsScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _headHeight, self.frame.size.width, self.frame.size.height - _headHeight)];
    _viewsScroll.showsVerticalScrollIndicator = NO;
    _viewsScroll.showsHorizontalScrollIndicator = NO;
    _viewsScroll.bounces = NO;
    _viewsScroll.delegate = self;
    _viewsScroll.pagingEnabled = YES;
    [_viewsScroll setContentOffset:CGPointMake(_showIndex * self.frame.size.width, 0)];
    [_viewsScroll setContentSize:CGSizeMake(titlesArray.count *_viewsScroll.frame.size.width, _viewsScroll.frame.size.height)];
    [self addSubview:_viewsScroll];
}



- (void)defaultViewCache {
//    NSInteger startIndex;
//    if (viewsArray.count-_showIndex > _countLimit) {
//        startIndex = _showIndex;
//    } else {
//        startIndex = _showIndex - (_countLimit - (viewsArray.count-_showIndex));
//    }
    for (NSInteger i = 0; i < viewsArray.count; i ++) {
        [self addViewCacheIndex:i];
    }

}

#pragma mark - createByVC
- (void)addViewCacheIndex:(NSInteger)index {
    id object = viewsArray[index];
    if ([object isKindOfClass:[NSString class]]) {
        Class class = NSClassFromString(object);
        if ([class isSubclassOfClass:[UIViewController class]]) {//vc
            UIViewController *vc = [class new];
            [self addVC:vc atIndex:index];
        } else if ([class isSubclassOfClass:[UIView class]]){//view
            UIView *view = [class new];
            [self addView:view atIndex:index];
        } else {
            NSLog(@"please enter the correct name of class!");
        }
    } else {
        if ([object isKindOfClass:[UIViewController class]]) {
            [self addVC:object atIndex:index];
        } else if ([object isKindOfClass:[UIView class]]) {
            [self addView:object atIndex:index];
        } else {
            NSLog(@"this class was not found!");
        }
    }

}

#pragma mark - addvc
- (void)addVC:(UIViewController *)vc atIndex:(NSInteger)index {
    NSLog(@"add - %@",@(index));
//    [self.viewsCache setObject:vc forKey:@(index)];

    vc.view.frame = CGRectMake(index*_viewsScroll.frame.size.width, 0, _viewsScroll.frame.size.width, _viewsScroll.frame.size.height);
    [_viewsScroll addSubview:vc.view];
}

- (void)addAllVC
{
    UIViewController *vc = [self viewController];
    if (vc) {
        for (id object in viewsArray) {
            if ([object isKindOfClass:[UIViewController class]]) {
                [vc addChildViewController:object];
            }
        }
        NSLog(@"ssssss:%@",[self viewController].childViewControllers);
    }
}

#pragma mark - addview
- (void)addView:(UIView *)view atIndex:(NSInteger)index {
//    [self.viewsCache setObject:view forKey:@(index)];
    
    view.frame = CGRectMake(index*_viewsScroll.frame.size.width, 0, _viewsScroll.frame.size.width, _viewsScroll.frame.size.height);
    [_viewsScroll addSubview:view];
}



#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:_viewsScroll]) {
        CGFloat scale = scrollView.contentOffset.x/scrollView.contentSize.width;
        [_headView changePointScale:scale];
        NSInteger curIndex = [@((scale+(1/(CGFloat)titlesArray.count)/2)*titlesArray.count) integerValue];
        if ([self.delegate respondsToSelector:@selector(scrollThroughIndex:)]) {
            [self.delegate scrollThroughIndex:curIndex];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isEqual:_viewsScroll]) {
        //滑动结束
        currentIndex = scrollView.contentOffset.x/scrollView.frame.size.width;
        [_headView setSelectIndex:currentIndex];
        _showIndex = currentIndex;
//        if (![_viewsCache objectForKey:@(currentIndex)]) {
//            [self addViewCacheIndex:currentIndex];
//        }
        if ([self.delegate respondsToSelector:@selector(selectedIndex:)]) {
            [self.delegate selectedIndex:currentIndex];
        }
    }

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([scrollView isEqual:_viewsScroll]) {
        //动画结束
        currentIndex = scrollView.contentOffset.x/scrollView.frame.size.width;
        [_headView setSelectIndex:currentIndex];
        _showIndex = currentIndex;
//        if (![_viewsCache objectForKey:@(currentIndex)]) {
//            [self addViewCacheIndex:currentIndex];
//        }
    }
}


#pragma mark - SegmentHeadViewDelegate
- (void)didSelectedIndex:(NSInteger)index {
    [_viewsScroll setContentOffset:CGPointMake(index*self.frame.size.width, 0) animated:YES];
    _showIndex = index;
    if ([self.delegate respondsToSelector:@selector(selectedIndex:)]) {
        [self.delegate selectedIndex:index];
    }
    
}

//#pragma mark - NSCacheDelegate
//-(void)cache:(NSCache *)cache willEvictObject:(id)obj {
//    NSLog(@"remove - %@",NSStringFromClass([obj class]));
//    if ([obj isKindOfClass:[UIViewController class]]) {
//        UIViewController *vc = obj;
//        [vc.view removeFromSuperview];
//        vc.view = nil;
//        [vc removeFromParentViewController];
//    } else {
//        UIView *vw = obj;
//        [vw removeFromSuperview];
//        vw = nil;
//    }
//}

#pragma mark - 重写父类方法

/** 当视图移动完成后调用 */
- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self addAllVC];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
//    if ([keyPath isEqualToString:@"superview"]) {
//        [self addAllVC];
//    }
}

#pragma mark - dealloc
- (void)dealloc {
//    _viewsCache.delegate = nil;
//    _viewsCache = nil;
//    [self removeObserver:self forKeyPath:@"superview"];
}

@end
