//
//  VHLRefreshFooterView.m
//  VHLRefresh
//
//  Created by vincent on 15/10/10.
//  Copyright (c) 2015年 Darnel Studio. All rights reserved.
//

#import "VHLRefreshFooterView.h"
#import "VHLRefreshComponent.h"

const CGFloat VHLRefreshFooterHeight = 60;

#define TextColor [UIColor colorWithWhite:0.314 alpha:1.000]
#define TextFont  [UIFont systemFontOfSize:13.0f]
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@interface VHLRefreshFooterView()

//View
@property (nonatomic, strong)  UILabel *statusLabel;
@property (nonatomic, strong)  UIImageView *arrowImage;
@property (nonatomic, strong)  UIActivityIndicatorView *activityView;

//Data
@property (nonatomic, strong) NSDictionary *stateTextDic;

@end

@implementation VHLRefreshFooterView

- (instancetype)init{
    if (self = [super init]) {
        [self drawRefreshView];
        [self initData];
    }
    return self;
}
//
- (void)drawRefreshView {
    self.backgroundColor = [UIColor clearColor];
    self.frame = CGRectMake(0, 0, ScreenWidth, VHLRefreshFooterHeight);
    
    _statusLabel = [[UILabel alloc] init];
    _statusLabel.frame = CGRectMake(0, 0, ScreenWidth, VHLRefreshFooterHeight);
    _statusLabel.font = TextFont;
    _statusLabel.textColor = TextColor;
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_statusLabel];
    
    _arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_pull_refresh"]];
    _arrowImage.frame = CGRectMake(ScreenWidth/2.0 - 70,(VHLRefreshFooterHeight-32)/2.0, 32, 32);
    [self addSubview:_arrowImage];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.color = TextColor;
    _activityView.frame = _arrowImage.frame;
    [self addSubview:_activityView];
}

- (void)initData {
    _loadMoreEnabled = YES;
    _autoLoadHeight = 40;
    _autoLoadMore = YES;
    _noMoreData = NO;
    
    _stateTextDic = @{@"normalText"  : @"上拉加载",
                      @"pullingText" : @"释放加载更多",
                      @"loadingText" : @"正在加载...",
                      @"noMoreData"  : @"数据已经全部加载完成"
                      };
    
    self.refreshState = VHLRefreshStateIdle;
}
//
- (void)setScrollView:(UIScrollView *)scrollView {
    if (_scrollView != scrollView) {
        _scrollViewOriginalInset = scrollView.contentInset;
        _scrollView = scrollView;
        [_scrollView addSubview:self];
        //init
        [self refreshFootViewFrame];
    }
}

#pragma MARK - Observer - 监听滚动信息
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    if(self.noMoreData) return;         //如果是显示的是没有更多数据,那么就不做处理
    
    if (self.refreshState == VHLRefreshStateRefreshing || !self.loadMoreEnabled) {
        return;
    }
    if(self.autoLoadMore)
    {
        if(self.autoRefreshHeigh > 1)
        {
            self.refreshState = VHLRefreshStateRefreshing;
        }
        return;
    }else{
        if (self.scrollView.isDragging) {
            if(self.dragHeight < VHLRefreshFooterHeight)
            {
                self.refreshState = VHLRefreshStateIdle;
            }else{
                self.refreshState = VHLRefreshStatePulling;
            }
        }else{
            if (self.refreshState == VHLRefreshStatePulling) {
                self.refreshState = VHLRefreshStateRefreshing;
            }
        }
    }
}
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change{
    [self refreshFootViewFrame];
}
/**
 *  将上拉刷新视图加载到滚动视图的最后面
 */
- (void)refreshFootViewFrame {
    CGRect frame = self.frame;
    frame.origin.y =  MAX(self.scrollView.frame.size.height, self.scrollView.contentSize.height);
    self.frame = frame;
}
#pragma MARK - Util - calculate
- (CGFloat)dragHeight {
    CGFloat contentHeight = self.scrollView.contentSize.height;
    CGFloat tableViewHeight = self.scrollView.bounds.size.height;
    CGFloat originY = MAX(contentHeight, tableViewHeight);
    return  self.scrollView.contentOffset.y + self.scrollView.bounds.size.height - originY - _scrollViewOriginalInset.bottom;
}
- (CGFloat)autoRefreshHeigh{
    CGFloat contentHeight = self.scrollView.contentSize.height;
    CGFloat tableViewHeight = self.scrollView.bounds.size.height;
    CGFloat originY = MAX(contentHeight, tableViewHeight);
    return  self.scrollView.contentOffset.y + self.scrollView.bounds.size.height - originY - _scrollViewOriginalInset.bottom + _autoLoadHeight;
}
#pragma MARK - View Option
- (void)setRefreshState:(VHLRefreshState)refreshState{
    if(_refreshState != refreshState)
    {
        _refreshState = refreshState;
        
        [self refreshStatusAnimation];
    }
}
- (void)refreshStatusAnimation {
    switch (self.refreshState) {
        case VHLRefreshStateIdle:
        {
            [self normalAnimation];
            break;
        }
        case VHLRefreshStatePulling:
        {
            [self pullingAnimation];
            break;
        }
        case VHLRefreshStateRefreshing:
        {
            [self loadingAnimation];
            
            if (self.refreshHandler) {
                self.refreshHandler();
            }
            break;
        }
        case VHLRefreshStateWillRefresh: {
            [self noMoreData];
            break;
        }
        case VHLRefreshStateNoMoreData: {
            [self noMoreDataAnimation];
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
        _arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
        self.scrollView.contentInset = _scrollViewOriginalInset;
    }];
}

- (void)pullingAnimation{
    _statusLabel.text = self.stateTextDic[@"pullingText"];
    
    [UIView animateWithDuration:0.3 animations:^{
        _arrowImage.transform = CGAffineTransformIdentity;
    }];
}

- (void)loadingAnimation {
    _statusLabel.text = self.stateTextDic[@"loadingText"];
    
    _arrowImage.hidden = YES;
    _arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
    [_activityView startAnimating];
    
    [UIView animateWithDuration:0.3 animations:^{
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.bottom += VHLRefreshFooterHeight;
        self.scrollView.contentInset = inset;
    }];
}
- (void)noMoreDataAnimation{
    _statusLabel.text = self.stateTextDic[@"noMoreData"];
    
    _arrowImage.hidden = YES;
    _arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
    [_activityView stopAnimating];
    
    [UIView animateWithDuration:0.3 animations:^{
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.bottom += VHLRefreshFooterHeight;
        self.scrollView.contentInset = inset;
    }];
}
#pragma MARK - SET Property
- (void)setAutoLoadMore:(BOOL)autoLoadMore {
    if (autoLoadMore != _autoLoadMore) {
        _autoLoadMore = autoLoadMore;
        if (_autoLoadMore) {
            [_arrowImage removeFromSuperview];
            _arrowImage.image = nil;
            
            self.stateTextDic = @{@"normalText" : @"正在加载...",
                                  @"pullingText" : @"正在加载...",
                                  @"loadingText" : @"正在加载..."
                                  };
        }else {
            _arrowImage.image = [UIImage imageNamed:@"grayArrow"];
            [self addSubview:_arrowImage];
            
            self.stateTextDic = @{@"normalText" : @"上拉加载",
                                  @"pullingText" : @"释放加载",
                                  @"loadingText" : @"正在加载..."
                                  };
        }
    }
}
- (void)setLoadMoreEnabled:(BOOL)loadMoreEnabled {
    if (loadMoreEnabled != _loadMoreEnabled) {
        _loadMoreEnabled = loadMoreEnabled;
        
        if (_loadMoreEnabled) {
            [self removeFromSuperview];
            [self.scrollView addSubview:self];
        }else {
            [self removeFromSuperview];
        }
    }
}
- (void)setNoMoreData:(BOOL)noMoreData{
    if(noMoreData){
        _noMoreData = YES;
        self.refreshState = VHLRefreshStateNoMoreData;
    }else{
        _noMoreData = NO;
        self.refreshState = VHLRefreshStateIdle;
    }
}

- (void)setStateTextDic:(NSDictionary *)stateTextDic {
    _stateTextDic = stateTextDic;
}

#pragma MARK - public methods
- (void)endRefreshing{
    self.refreshState = VHLRefreshStateIdle;
}
@end
