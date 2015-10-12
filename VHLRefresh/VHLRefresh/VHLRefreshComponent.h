//
//  VHLRefreshComponent.h
//  VHLRefresh
//
//  Created by vincent on 15/10/10.
//  Copyright (c) 2015年 Darnel Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VHLRefreshState){
    /** 普通闲置状态 */
    VHLRefreshStateIdle                     = 1,
    /** 即将刷新的状态 */
    VHLRefreshStateWillRefresh              = 2,
    /** 松开就可以进行刷新的状态 */
    VHLRefreshStatePulling                  = 3,
    /** 正在刷新中的状态 */
    VHLRefreshStateRefreshing               = 4,
    /** 所有数据加载完毕，没有更多数据了 */
    VHLRefreshStateNoMoreData               = 5
};

/** 进入刷新状态的回调 */
typedef void (^VHLRefreshedHandler)();

/** 当前屏幕的宽度*/
#define VHLRefreshScreenWidth [UIScreen mainScreen].bounds.size.width

/**
 *  刷新控件视图的基类
 */
@interface VHLRefreshComponent : UIView {
    /** 记录scrollView刚开始的inset */
    UIEdgeInsets _scrollViewOriginalInset;
    /** 父滚动视图控件 */
    __weak UIScrollView *_scrollView;
    /** 当前的刷新状态 */
    VHLRefreshState _refreshState;
}
/** 记录scrollView刚开始的inset */
@property (assign, nonatomic, readonly) UIEdgeInsets scrollViewOriginalInset;
/** 父控件 */
@property (weak, nonatomic, readonly) UIScrollView *scrollView;
/** 刷新回调Block */
@property (nonatomic, copy) VHLRefreshedHandler refreshHandler;
/** 刷新状态 一般交给子类内部实现 */
@property (assign, nonatomic) VHLRefreshState refreshState;

/** 拖动的高度*/
@property (nonatomic, assign) CGFloat dragHeight;

#pragma mark - 刷新状态控制
/** 进入刷新状态 */
- (void)beginRefreshing;
/** 结束刷新状态 */
- (void)endRefreshing;
/** 是否正在刷新 */
- (BOOL)isRefreshing;

#pragma mark - 子类需要实现的方法
/** 当scrollView的contentOffset发生改变的时候调用 */
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change;
/** 当scrollView的contentSize发生改变的时候调用 */
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change;
/** 当scrollView的拖拽状态发生改变的时候调用 */
- (void)scrollViewPanStateDidChange:(NSDictionary *)change;

@end
