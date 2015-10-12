//
//  VHLRefreshHeaderView.m
//  VHLRefresh
//
//  Created by vincent on 15/10/10.
//  Copyright (c) 2015年 Darnel Studio. All rights reserved.
//

#import "VHLRefreshHeaderView.h"
#import "VHLRefreshComponent.h"

const CGFloat VHLRefreshHeaderHeight = 60;

#define TextColor [UIColor colorWithRed:120/255.0 green:120/255.0 blue:120/255.0 alpha:1.0]
#define TextFont  [UIFont systemFontOfSize:12.0f]

@interface VHLRefreshHeaderView()

//自定义头部刷新视图
@property (nonatomic, strong)  UILabel *statusLabel;
@property (nonatomic, strong)  UIImageView *arrowImage;
@property (nonatomic, strong)  UIActivityIndicatorView *activityView;

//Data
@property (nonatomic, strong) NSDictionary *stateTextDic;
@property (nonatomic, assign) BOOL needLoadingAnimation;    //default YES

#pragma Mark - 子类需要实现的方法                       <-   ---------------  看这里
/** 初始化刷新视图*/
- (void)drawRefreshView;

/** 提供显示文本数据 */
- (NSDictionary *)stateTextDic;

//animation
/** 刷新空闲状态时的效果*/
- (void)normalAnimation;
/** 正在刷新时的效果*/
- (void)loadingAnimation;
/** 拖动时的效果*/
- (void)pullingAnimation;

@end

@implementation VHLRefreshHeaderView

//
- (instancetype)init{
    if(self = [super init])
    {
        [self drawRefreshView];
        [self initData];
    }
    return self;
}
/**
 *  创建刷新视图
 */
- (void)drawRefreshView {
    self.backgroundColor = [UIColor clearColor];
    self.frame = CGRectMake(0, -VHLRefreshHeaderHeight, VHLRefreshScreenWidth, VHLRefreshHeaderHeight);
    
    _statusLabel = [[UILabel alloc] init];
    _statusLabel.frame = CGRectMake(0, 0, VHLRefreshScreenWidth, VHLRefreshHeaderHeight);
    _statusLabel.font = TextFont;
    _statusLabel.textColor = TextColor;
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_statusLabel];
    
    _arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_pull_refresh"]];
    _arrowImage.frame = CGRectMake(VHLRefreshScreenWidth/2.0 - 60,(VHLRefreshHeaderHeight-32)/2.0, 32, 32);
    [self addSubview:_arrowImage];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.color = TextColor;
    _activityView.frame = _arrowImage.frame;
    [self addSubview:_activityView];
}
- (NSDictionary *)stateTextDic{
    return @{@"normalText" : @"下拉刷新",
             @"pullingText" : @"释放更新",
             @"loadingText" : @"加载中..."
             };
}
- (void)initData{
    _needLoadingAnimation = YES;

    self.refreshState = VHLRefreshStateIdle;
}
//
- (void)setScrollView:(UIScrollView *)scrollView {
    if(_scrollView != scrollView)
    {
        _scrollViewOriginalInset = scrollView.contentInset;
        _scrollView = scrollView;
        [_scrollView addSubview:self];
    }
}
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    if (self.dragHeight < 0 || self.refreshState == VHLRefreshStateRefreshing) {       //如果正在刷新
        return;
    }
    if (self.scrollView.isDragging) {
        if (self.dragHeight < VHLRefreshHeaderHeight) {
            self.refreshState = VHLRefreshStateWillRefresh;     //即将刷新的状态
        }else{
            self.refreshState = VHLRefreshStatePulling;         //松开就可以刷新的状态
        }
    }else{
        if (self.refreshState == VHLRefreshStatePulling) {
            self.refreshState = VHLRefreshStateRefreshing;
        }
    }
    //NSLog(@"ContentOffset :%@",change);
}
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change{
    //NSLog(@"ContentSize :%@",change);
}
- (void)scrollViewPanStateDidChange:(NSDictionary *)change{
    //NSLog(@"PanState :%@",change);
}
//
- (void)setRefreshState:(VHLRefreshState)refreshState{
    if (refreshState != _refreshState ) {
        _refreshState = refreshState;

        [self refreshStatusAnimation];
    }
}

- (void)refreshStatusAnimation{
    switch (self.refreshState) {
        case VHLRefreshStateIdle: {                             //空闲状态
            [self normalAnimation];
            break;
        }
        case VHLRefreshStateWillRefresh:
        {
            [self normalAnimation];
            break;
        }
        case VHLRefreshStatePulling: {                          //释放就可以刷新
            [self pullingAnimation];
            break;
        }
        case VHLRefreshStateRefreshing: {                       //开始刷新
            [self loadingAnimation];
            
            if (self.refreshHandler) {
                self.refreshHandler();
            }
            break;
        }
        default: {
            break;
        }
    }
}
- (void)normalAnimation{
    _statusLabel.text = self.stateTextDic[@"normalText"];
    
    _arrowImage.hidden = NO;
    [_activityView stopAnimating];
    [UIView animateWithDuration:0.3 animations:^{
        _arrowImage.transform = CGAffineTransformIdentity;
        self.scrollView.contentInset = _scrollViewOriginalInset;
    }];
}

- (void)pullingAnimation{
    _statusLabel.text = self.stateTextDic[@"pullingText"];
    
    [UIView animateWithDuration:0.3 animations:^{
        _arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
    }];
}

- (void)loadingAnimation {
    _statusLabel.text = self.stateTextDic[@"loadingText"];
    
    _arrowImage.hidden = YES;
    _arrowImage.transform = CGAffineTransformIdentity;
    [_activityView startAnimating];
    [UIView animateWithDuration:0.3 animations:^{
        UIEdgeInsets inset = _scrollViewOriginalInset;
        inset.top += VHLRefreshHeaderHeight;
        self.scrollView.contentInset = inset;
    }];
}
#pragma mark - base funcation
- (CGFloat)dragHeight {
    return (self.scrollView.contentOffset.y + _scrollViewOriginalInset.top) * -1.0;
}
#pragma mark - public funcation
- (void)beginRefreshing{
    self.refreshState = VHLRefreshStateRefreshing;
}
- (void)endRefreshing{
    self.refreshState = VHLRefreshStateIdle;
}
- (BOOL)isRefreshing{
    if (self.refreshState == VHLRefreshStateRefreshing) {
        return YES;
    }else{
        return NO;
    }
}
@end
