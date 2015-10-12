//
//  ViewController.m
//  VHLRefresh
//
//  Created by vincent on 15/10/10.
//  Copyright (c) 2015年 Darnel Studio. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+VHLRefresh.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView1;
    BOOL animate;
}
@property (strong, nonatomic) NSMutableArray *arrays;

@property (strong, nonatomic) UIScrollView *contentScrollView;

@property (strong, nonatomic) UITableView *tableView1;
@property (strong, nonatomic) UITableView *tableView2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    animate = YES;
    
    self.arrays = [NSMutableArray array];
    for (int i=0; i<20; i++) {
        [self.arrays addObject:@0];
    }
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.contentScrollView];
    
    self.tableView1 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tableView1.dataSource = self;
    self.tableView1.delegate = self;
    [self.contentScrollView addSubview:self.tableView1];
    self.tableView1.tableFooterView = [UIView new];
    
    self.tableView1.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    
    __weak __typeof(self)weakSelf = self;
    self.tableView1.refreshFooter = [self.tableView1 addRefreshFooterViewWithHandler:^{
        [weakSelf footerrefressss];
    }];
    self.tableView1.refreshFooter.autoLoadMore = NO;
    self.tableView1.refreshFooter.autoLoadHeight = 100;
    
    NSDictionary *upDic = @{
                            @"normalText" : @"上拉查看图文详情",
                            @"pullingText" : @"上拉查看图文详情",
                            @"loadingText" : @"上拉查看图文详情"
                            };
    [self.tableView1.refreshFooter setValue:upDic forKey:@"stateTextDic"];
    
    //0------------------------------------------------
    self.tableView2 = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tableView2.dataSource = self;
    self.tableView2.delegate = self;
    self.tableView2.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.contentScrollView addSubview:self.tableView2];
    self.tableView2.tableFooterView = [UIView new];
    
    self.tableView2.refreshHeader = [self.tableView2 addRefreshHeaderViewWithHandler:^{
        [weakSelf endRefreshings];
    }];
    self.tableView2.refreshFooter = [self.tableView2 addRefreshFooterViewWithHandler:^{
        [weakSelf performSelector:@selector(footerRefresha) withObject:nil afterDelay:3];
    }];
    self.tableView2.refreshFooter.autoLoadMore   = YES;
    self.tableView2.refreshFooter.autoLoadHeight = 1;
    
    self.tableView1.showsVerticalScrollIndicator = NO;
    self.tableView2.showsVerticalScrollIndicator = NO;
}
- (void)endRefreshings{
    animate = NO;
    __weak __typeof(self)weakSelf = self;
    [self.tableView2.refreshHeader endRefreshing];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = weakSelf.tableView2.frame;
        frame.origin.y = 0;
        weakSelf.tableView1.frame = frame;
        
        frame = weakSelf.tableView2.frame;
        frame.origin.y = kScreenHeight;
        weakSelf.tableView2.frame = frame;
    } completion:^(BOOL finished) {
        weakSelf.title = @"FirstTableView";
        animate = YES;
    }];
}
- (void)footerrefressss{
    animate = NO;
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = weakSelf.tableView1.frame;
        frame.origin.y = - (self.view.bounds.size.height + 60);
        weakSelf.tableView1.frame = frame;
        
        frame = weakSelf.tableView2.frame;
        frame.origin.y = 0;
        weakSelf.tableView2.frame = frame;
    } completion:^(BOOL finished) {
        weakSelf.title = @"SecondTableView";
        [weakSelf.tableView1.refreshFooter endRefreshing];
        weakSelf.tableView2.refreshFooter.noMoreData = NO;
    }];
}
- (void)footerRefresha{
    if(self.tableView2.refreshFooter.noMoreData) return;
    for (int i = 0; i<5; i++) {
        [self.arrays addObject:@0];
    }
    [self.tableView1 reloadData];
    [self.tableView2 reloadData];
    [self.tableView2.refreshFooter endRefreshing];
    if(self.arrays.count > 15)
    {
        self.tableView2.refreshFooter.noMoreData = YES;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrays.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(tableView == self.tableView1){
        cell.textLabel.text = [NSString stringWithFormat:@"Cell %d -- 1", (int)indexPath.row];
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"Cell %d -- 2", (int)indexPath.row];
    }
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView == self.tableView1)
    {
        CGFloat moreY = (scrollView.contentOffset.y + self.tableView1.bounds.size.height - 60 - scrollView.contentSize.height);
        NSLog(@"%f %f %f %f",scrollView.contentOffset.y,scrollView.contentSize.height,self.tableView1.bounds.size.height - 60,moreY);
        if(moreY >= 0 && animate){
            self.tableView2.frame = CGRectMake(0, self.view.bounds.size.height - moreY, self.tableView2.frame.size.width, self.tableView2.frame.size.height);
        }
    }
}
@end
