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
/** 翻页回调 */
- (void)cycleView:(ZLCycleView *)cycleView pageControl:(UIPageControl *)pageControl currentIndex:(NSInteger)idx;

@end

@protocol ZLCycleViewDatasource <NSObject>

@required
/** 数据源数量 */
- (NSInteger)numberOfItemsInCycleView:(ZLCycleView *)cycleView;
/** 自定义cell */
- (__kindof UICollectionViewCell *)cycleView:(ZLCycleView *)cycleView cellForItemAtRow:(NSInteger)row;

@optional
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

/** 数量为1时隐藏pagecontrol */
@property (nonatomic, assign) BOOL hidesForSinglePage;

/** 重载 */
- (void)reloadData;

/** 开始/结束播放 */
- (void)startCycle;
- (void)stopCycle;

/** 注册cell */
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forRow:(NSInteger)row;

@end

