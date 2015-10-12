//
//  UIScrollView+VHLRefresh.m
//  VHLRefresh
//
//  Created by vincent on 15/10/10.
//  Copyright (c) 2015年 Darnel Studio. All rights reserved.
//

#import "UIScrollView+VHLRefresh.h"
//View
#import "VHLRefreshHeaderView.h"
#import "VHLRefreshFooterView.h"
//System
#import <objc/runtime.h>

@implementation UIScrollView (VHLRefresh)

#pragma mark - refreshHeader
static const char * VHLRefreshHeaderViewKey = "VHLRefreshHeaderViewKey";
- (void)setRefreshHeader:(VHLRefreshHeaderView *)refreshHeader{
    if(refreshHeader != self.refreshHeader)
    {
        [self.refreshHeader removeFromSuperview];
        [self addSubview:refreshHeader];
        
        objc_setAssociatedObject(self, VHLRefreshHeaderViewKey, refreshHeader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (VHLRefreshHeaderView *)refreshHeader{
    return objc_getAssociatedObject(self, VHLRefreshHeaderViewKey);
}
//默认的下拉刷新视图
- (VHLRefreshHeaderView *)addRefreshHeaderViewWithHandler:(VHLRefreshedHandler)refreshHandler{
    return [self addRefreshHeaderView:[[VHLRefreshHeaderView alloc] init] andler:refreshHandler];
}
// 扩展的下拉刷新视图
- (VHLRefreshHeaderView *)addRefreshHeaderView:(VHLRefreshHeaderView *)refreshHeaderView
                                        andler:(VHLRefreshedHandler)refreshHandler{
    [refreshHeaderView setValue:refreshHandler forKey:@"refreshHandler"];
    [refreshHeaderView setValue:self forKey:@"scrollView"];
    return refreshHeaderView;
}
#pragma mark - refreshFooter
static const char * VHLRefreshFooterViewKey = "VHLRefreshFooterViewKey";
- (void)setRefreshFooter:(VHLRefreshFooterView *)refreshFooter{
    if (refreshFooter != self.refreshFooter) {
        [self.refreshFooter removeFromSuperview];
        [self addSubview:refreshFooter];
        
        objc_setAssociatedObject(self, VHLRefreshFooterViewKey, refreshFooter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

-(VHLRefreshFooterView *)refreshFooter{
    return objc_getAssociatedObject(self, VHLRefreshFooterViewKey);
}
//默认的上拉刷新
- (VHLRefreshFooterView *)addRefreshFooterViewWithHandler:(VHLRefreshedHandler)refreshHandler{
    return [self addRefreshFooterView:[[VHLRefreshFooterView alloc] init] handler:refreshHandler];
}
// 扩展的上拉刷新
- (VHLRefreshFooterView *)addRefreshFooterView:(VHLRefreshFooterView *)refreshFooterView
                                       handler:(VHLRefreshedHandler)refreshHandler{
    [refreshFooterView setValue:refreshHandler forKey:@"refreshHandler"];
    [refreshFooterView setValue:self forKey:@"scrollView"];
    return refreshFooterView;
}
@end
