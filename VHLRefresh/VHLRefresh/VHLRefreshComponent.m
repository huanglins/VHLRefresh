//
//  VHLRefreshComponent.m
//  VHLRefresh
//
//  Created by vincent on 15/10/10.
//  Copyright (c) 2015年 Darnel Studio. All rights reserved.
//

#import "VHLRefreshComponent.h"

NSString *const VHLRefreshKeyPathContentOffset = @"contentOffset";
NSString *const VHLRefreshKeyPathContentInset  = @"contentInset";
NSString *const VHLRefreshKeyPathContentSize   = @"contentSize";
NSString *const VHLRefreshKeyPathPanState      = @"state";

@interface VHLRefreshComponent(){}

@end

@implementation VHLRefreshComponent
- (void)dealloc{
    [self removeObservers];
}
/**
 *  该视图即将被添加到父视图时调用
 */
- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    //如果不是UIScrollView,不做任何事
    if(newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) return;
    
    //移除旧视图监听
    [self removeObservers];
    if(newSuperview)
    {
        _scrollView = (UIScrollView *)newSuperview;
        //添加监听
        [self addObservers];
    }
}
#pragma mark - KVO 监听
- (void)addObservers{
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [_scrollView addObserver:self forKeyPath:VHLRefreshKeyPathContentOffset options:options context:nil];
    [_scrollView addObserver:self forKeyPath:VHLRefreshKeyPathContentSize options:options context:nil];
}
- (void)removeObservers
{
    [self.superview removeObserver:self forKeyPath:VHLRefreshKeyPathContentOffset];
    [self.superview removeObserver:self forKeyPath:VHLRefreshKeyPathContentSize];;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 遇到这些情况就直接返回
    if (!self.userInteractionEnabled) return;
    
    // 这个就算看不见也需要处理
    if ([keyPath isEqualToString:VHLRefreshKeyPathContentSize]) {
        [self scrollViewContentSizeDidChange:change];
    }
    
    // 看不见
    if (self.hidden) return;
    if ([keyPath isEqualToString:VHLRefreshKeyPathContentOffset]) {
        [self scrollViewContentOffsetDidChange:change];
    } else if ([keyPath isEqualToString:VHLRefreshKeyPathPanState]) {
        [self scrollViewPanStateDidChange:change];
    }
}
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{}
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change{}
- (void)scrollViewPanStateDidChange:(NSDictionary *)change{}

- (void)beginRefreshing{
    self.refreshState = VHLRefreshStateRefreshing;
}
- (void)endRefreshing{
    self.refreshState = VHLRefreshStateIdle;
};
- (BOOL)isRefreshing{
    return self.refreshState == VHLRefreshStateRefreshing || self.refreshState == VHLRefreshStateWillRefresh;
}

@end
