//
//  VHLRefreshFooterView.h
//  VHLRefresh
//
//  Created by vincent on 15/10/10.
//  Copyright (c) 2015年 Darnel Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHLRefreshComponent.h"

/**
 *  上拉刷新视图
 */
@interface VHLRefreshFooterView : VHLRefreshComponent

/** 是否自动加载更多*/
@property (nonatomic) BOOL autoLoadMore;
/** 加载更多是否可用,NO就隐藏 */
@property (nonatomic) BOOL loadMoreEnabled;
/** 没有更多数据了 */
@property (nonatomic) BOOL noMoreData;
/** 当滚动视图距离底部多少时,自动加载更多,默认40 */
@property (nonatomic) CGFloat autoLoadHeight;

@end
