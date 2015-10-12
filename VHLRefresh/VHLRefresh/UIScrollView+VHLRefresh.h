//
//  UIScrollView+VHLRefresh.h
//  VHLRefresh
//
//  Created by vincent on 15/10/10.
//  Copyright (c) 2015年 Darnel Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHLRefreshHeaderView.h"
#import "VHLRefreshFooterView.h"

@interface UIScrollView (VHLRefresh)

//Header
@property (strong, nonatomic) VHLRefreshHeaderView *refreshHeader;
//默认的下拉刷新视图
- (VHLRefreshHeaderView *)addRefreshHeaderViewWithHandler:(VHLRefreshedHandler)refreshHandler;
// 扩展的下拉刷新视图
- (VHLRefreshHeaderView *)addRefreshHeaderView:(VHLRefreshHeaderView *)refreshHeaderView
                                     andler:(VHLRefreshedHandler)refreshHandler;

//footer
@property (strong, nonatomic) VHLRefreshFooterView *refreshFooter;
//默认的上拉刷新视图
- (VHLRefreshFooterView *)addRefreshFooterViewWithHandler:(VHLRefreshedHandler)refreshHandler;
// 扩展的上拉刷新
- (VHLRefreshFooterView *)addRefreshFooterView:(VHLRefreshFooterView *)refreshFooterView
                                       handler:(VHLRefreshedHandler)refreshHandler;

@end
