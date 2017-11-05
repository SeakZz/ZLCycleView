//
//  ZLCycleView.m
//  ZLCycleView
//
//  Created by long on 2017/5/13.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ZLCycleView.h"

static NSString * const reuseIdentifier = @"ZLCycleCell";

@interface ZLCycleView () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) NSInteger totalItems;
@property (nonatomic, assign) NSInteger totalPages;

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation ZLCycleView {
    
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
    
    [self _layout];
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
- (void)applicationBecomeActive:(NSNotification *)noti {
    if (_isAutoPlay) {
        [self startCycle];
    }
}
- (void)applicationEnterBackground:(NSNotification *)noti {
    if (_isAutoPlay) {
        [self stopCycle];
    }
}

- (void)dealloc {
    if (_isAutoPlay) {
        [self stopCycle];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - life
- (UIPageControl *)normalPageControl {
    UIPageControl *page = [[UIPageControl alloc] init];
    page.currentPageIndicatorTintColor = [UIColor whiteColor];
    page.pageIndicatorTintColor = [UIColor grayColor];
    return page;
}
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        self.layout = [[UICollectionViewFlowLayout alloc] init];
        self.layout.scrollDirection = _scrollDirection;
        self.layout.minimumLineSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
    }
    return _collectionView;
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

- (void)setDataSource:(id<ZLCycleViewDatasource>)dataSource {
    _dataSource = dataSource;
    
    if ([self.dataSource respondsToSelector:@selector(pageControlInCycleView:)]) {
        self.pageControl = [self.dataSource pageControlInCycleView:self];
    } else {
        self.pageControl = [self normalPageControl];
    }
    self.pageControl.userInteractionEnabled = NO;
    [self addSubview:self.pageControl];
    
    if (![self.dataSource respondsToSelector:@selector(cycleView:cellForItemAtRow:)]) {
        [self registerNormalCell];
    }
}
- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    _scrollDirection = scrollDirection;
    
    self.layout.scrollDirection = scrollDirection;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    
    if ([self.dataSource respondsToSelector:@selector(pageControlInCycleView:)] || self.hasPage) {
        self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    }
}
- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    _pageIndicatorTintColor = pageIndicatorTintColor;
    
    if ([self.dataSource respondsToSelector:@selector(pageControlInCycleView:)] || self.hasPage) {
        self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
    }
}
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    self.collectionView.backgroundColor = backgroundColor;
}

#pragma mark - method
- (void)setupInitialStatus {
    _waitTime = 4;
    _isAutoPlay = NO;
    _scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _hidesForSinglePage = YES;
    _hasPage = YES;
    self.scrollEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground:) name: UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self addSubview:self.collectionView];
}
- (void)scrollToRow:(NSInteger)row animated:(BOOL)animated {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:animated];
}

- (void)registerNormalCell {
    [self.collectionView registerClass:[ZLCycleViewCell class]  forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)_layout {
    
    self.layout.itemSize = self.bounds.size;
    self.collectionView.frame = self.bounds;
    if ((![self.dataSource respondsToSelector:@selector(pageControlInCycleView:)] && self.hasPage)) {
        self.pageControl.frame = CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 30);
    }
    
    if (!self.totalPages) [self reloadData];
}


#pragma mark - public method
- (void)reloadData {
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
        self.collectionView.scrollEnabled = self.scrollEnabled;
        _totalItems = _totalPages * 10000;
    }
    if ([self.dataSource respondsToSelector:@selector(pageControlInCycleView:)] || self.hasPage) {
        self.pageControl.numberOfPages = _totalPages;
        self.pageControl.currentPage = _currentPage;
        if (_hidesForSinglePage) {
            self.pageControl.hidden = _totalPages == 1;
        }
    }
    self.pageControl.hidden = !self.hasPage;
    
    if (_isAutoPlay) {
        [self setupTimer];
    }
    
    [self.collectionView reloadData];
    [self scrollToRow:_totalItems/2 animated:NO];
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
    
    if (![self.dataSource respondsToSelector:@selector(pageControlInCycleView:)] && !self.hasPage) {
        return;
    }
    
    if (_currentPage == [self pageControlCurrentPage]) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(cycleView:pageControl:currentIndex:)]) {
        [self.delegate cycleView:self pageControl:self.pageControl currentIndex:[self pageControlCurrentPage]];
    } else {
        if (![self.delegate respondsToSelector:@selector(cycleViewDidScrollToNext:pageControl:currentIndex:)]) {
            self.pageControl.currentPage = [self pageControlCurrentPage];
        }
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
    
    
    if ([self.delegate respondsToSelector:@selector(cycleViewDidScrollToNext:pageControl:currentIndex:)]) {
        if (![self.dataSource respondsToSelector:@selector(pageControlInCycleView:)] && !self.hasPage) {
            return;
        }
        [self.delegate cycleViewDidScrollToNext:self pageControl:self.pageControl currentIndex:[self pageControlCurrentPage]];
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    if ([self.delegate respondsToSelector:@selector(cycleViewDidScrollToNext:pageControl:currentIndex:)]) {
        if (![self.dataSource respondsToSelector:@selector(pageControlInCycleView:)] && !self.hasPage) {
            return;
        }
        [self.delegate cycleViewDidScrollToNext:self pageControl:self.pageControl currentIndex:[self pageControlCurrentPage]];
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
    } else {
        
        ZLCycleViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        if ([self.dataSource respondsToSelector:@selector(cycleView:imageViewForItem:atRow:)]) {
            [self.dataSource cycleView:self imageViewForItem:cell.imageView atRow:indexPath.row % _totalPages];
        }
        
        return cell;
    }
}


#pragma mark - collectionviewdelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(cycleView:didSelectItemAtRow:)]) {
        [self.delegate cycleView:self didSelectItemAtRow:indexPath.row % _totalPages];
    }
}

@end




/**
 default cell
 */
@implementation ZLCycleViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    }
    return _imageView;
}

@end
