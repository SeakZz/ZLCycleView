//
//  ZLCycleView.h
//  ZLCycleView
//
//  Created by long on 2017/5/13.
//  Copyright © 2017年 long. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZLCycleView;

@protocol ZLCycleViewDelegate <NSObject>

@optional
/** 点击图片回调 */
- (void)cycleView:(ZLCycleView *)cycleView didSelectItemAtRow:(NSInteger)idx;
/** 翻页回调(半页, 实现之后自己控制pagecontrol翻页) */
- (void)cycleView:(ZLCycleView *)cycleView pageControl:(UIPageControl *)pageControl currentIndex:(NSInteger)idx;
/** 翻页回调(整页, 实现之后自己控制pagecontrol翻页) */
- (void)cycleViewDidScrollToNext:(ZLCycleView *)cycleView pageControl:(UIPageControl *)pageControl currentIndex:(NSInteger)idx;

@end

@protocol ZLCycleViewDatasource <NSObject>

@required
/** 数据源数量 */
- (NSInteger)numberOfItemsInCycleView:(ZLCycleView *)cycleView;

@optional
/** 设置图片数据源(不使用自定义cell时实现) */
- (void)cycleView:(ZLCycleView *)cycleView imageViewForItem:(UIImageView *)imageView atRow:(NSInteger)row;
/** 自定义cell */
- (__kindof UICollectionViewCell *)cycleView:(ZLCycleView *)cycleView cellForItemAtRow:(NSInteger)row;
/** 自定义pagecontrol */
- (__kindof UIPageControl *)pageControlInCycleView:(ZLCycleView *)cycleView;

@end

@interface ZLCycleView : UIView


@property (nonatomic, weak) id <ZLCycleViewDelegate> delegate;
@property (nonatomic, weak) id <ZLCycleViewDatasource> dataSource;


/** 自动播放 default NO */
@property (nonatomic, assign) BOOL isAutoPlay;
/** 播放间隔时间 default 4 */
@property (nonatomic, assign) NSInteger waitTime;
/** 滚动方向 default horizontal */
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

/** 是否能滑动 */
@property (nonatomic, assign) BOOL scrollEnabled;

/** 数量为1时隐藏pagecontrol */
@property (nonatomic, assign) BOOL hidesForSinglePage;
/** 是否使用默认pagecontrol  default YES */
@property (nonatomic, assign) BOOL hasPage;
/** 当前page颜色 */
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor;
/** page颜色 */
@property (nonatomic, strong) UIColor *pageIndicatorTintColor;

/** 重载 */
- (void)reloadData;

/** 开始轮播 */
- (void)startCycle;
/** 结束轮播 */
- (void)stopCycle;

/** 注册cell(自定义cell时注册cell) */
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
/** 注册cell(自定义cell时注册cell) */
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;
/** 重用cell(自定义cell) */
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forRow:(NSInteger)row;

@end



@interface ZLCycleViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end
