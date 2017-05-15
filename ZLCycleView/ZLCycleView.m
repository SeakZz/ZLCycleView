//
//  ZLCycleView.m
//  ZLCycleView
//
//  Created by long on 2017/5/13.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ZLCycleView.h"

@interface ZLCycleView () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) NSInteger totalItems;
@property (nonatomic, assign) NSInteger totalPages;

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation ZLCycleView {
    
    BOOL _needReload;
    CGRect _pageControlFrame;
    NSInteger _currentPage;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupInitialStatus];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self setupInitialStatus];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_needReload) {
        self.layout.itemSize = self.bounds.size;
        self.collectionView.frame = self.bounds;
        if ([self.dataSource respondsToSelector:@selector(pageControlInCycleView:)]) {
            self.pageControl.frame = _pageControlFrame;
        }
        [self reloadData];
        _needReload = NO;
    }
}


- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    
    if (!newWindow) {
        if (_isAutoPlay) {
            [self stopCycle];
        }
    } else {
        if (_isAutoPlay) {
            [self startCycle];
        }
    }
}

- (void)dealloc {
    if (_isAutoPlay) {
        [self stopCycle];
    }
    self.delegate = nil;
    self.dataSource = nil;
}

#pragma mark - method
- (void)setupInitialStatus {
    _waitTime = 4;
    _isAutoPlay = NO;
    _needReload = YES;
    _scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _hidesForSinglePage = YES;
    
    [self setupCollectionView];
}
- (void)startCycle {
    [self setupTimer];
}
- (void)stopCycle {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

- (void)scrollToRow:(NSInteger)row animated:(BOOL)animated {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:animated];
}

#pragma mark - override method
- (void)reloadData {
    [self.collectionView reloadData];
    _currentPage = 0;
    
    if ([self.dataSource respondsToSelector:@selector(numberOfItemsInCycleView:)]) {
        _totalPages = [self.dataSource numberOfItemsInCycleView:self];
    }
    
    if (_totalPages == 0) {
        return;
    } else if (_totalPages == 1) {
        self.collectionView.scrollEnabled = NO;
        _totalItems = _totalPages;
    }
    if (_totalPages > 1) {
        self.collectionView.scrollEnabled = YES;
        _totalItems = _totalPages * 100;
    }
    if ([self.dataSource respondsToSelector:@selector(pageControlInCycleView:)]) {
        self.pageControl.numberOfPages = _totalPages;
        if (_hidesForSinglePage) {
            self.pageControl.hidden = _totalPages == 1;
        }
    }
    if (_isAutoPlay) {
        [self setupTimer];
    }
    
    [self scrollToRow:_totalItems/2 animated:NO];
}
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}
- (void)registerNib:(nullable UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
}
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forRow:(NSInteger)row {
    NSIndexPath *idp = [NSIndexPath indexPathForItem:row inSection:0];
    return [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:idp];
}

#pragma mark - scrollviewdelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (![self.dataSource respondsToSelector:@selector(pageControlInCycleView:)]) {
        return;
    }
    
    if (_currentPage == [self pageControlCurrentPage]) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(cycleView:pageControl:currentIndex:)]) {
        [self.delegate cycleView:self pageControl:self.pageControl currentIndex:[self pageControlCurrentPage]];
    } else {
        self.pageControl.currentPage = [self pageControlCurrentPage];
    }
    _currentPage = [self pageControlCurrentPage];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (_isAutoPlay) {
        [self stopCycle];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (_isAutoPlay) {
        [self setupTimer];
    }
}

- (NSInteger)pageControlCurrentPage {
    NSInteger idx = _scrollDirection == UICollectionViewScrollDirectionVertical ? (self.collectionView.contentOffset.y + self.bounds.size.height/2) / self.collectionView.bounds.size.height: (self.collectionView.contentOffset.x + self.bounds.size.width/2) / self.collectionView.bounds.size.width;
    
    return idx % _totalPages;
}
- (NSInteger)currentIndex {
    return _scrollDirection == UICollectionViewScrollDirectionVertical ? self.collectionView.contentOffset.y / self.bounds.size.height :
    self.collectionView.contentOffset.x / self.bounds.size.width;
}

#pragma mark - collectionviewdatasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _totalItems;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.dataSource respondsToSelector:@selector(cycleView:cellForItemAtRow:)]) {
        
        return [self.dataSource cycleView:self cellForItemAtRow:indexPath.row % _totalPages];
    }
    
    return nil;
}


#pragma mark - collectionviewdelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(cycleView:didSelectItemAtRow:)]) {
        [self.delegate cycleView:self didSelectItemAtRow:indexPath.row % _totalPages];
    }
}

#pragma mark - init
- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [self.dataSource pageControlInCycleView:self];
        _pageControlFrame = _pageControl.frame;
        _pageControl.userInteractionEnabled = NO;
        [self addSubview:_pageControl];
    }
    return _pageControl;
}
- (void)setupCollectionView {
    self.layout = [[UICollectionViewFlowLayout alloc] init];
    self.layout.scrollDirection = _scrollDirection;
    self.layout.minimumLineSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    
    self.collectionView.pagingEnabled = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.collectionView];
    
}
- (void)setupTimer {
    [self stopCycle];
    if (_totalPages <= 1) {
        return;
    }
    
    dispatch_queue_t queue = dispatch_queue_create("com.timer.zl", DISPATCH_QUEUE_CONCURRENT);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, dispatch_walltime(DISPATCH_TIME_NOW, _waitTime * NSEC_PER_SEC), _waitTime * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollToRow:[self currentIndex] + 1 animated:YES];
        });
    });
    dispatch_resume(self.timer);
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    _scrollDirection = scrollDirection;
    
    self.layout.scrollDirection = scrollDirection;
}


@end

