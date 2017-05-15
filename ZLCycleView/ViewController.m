//
//  ViewController.m
//  ZLCycleView
//
//  Created by long on 2017/5/13.
//  Copyright © 2017年 long. All rights reserved.
//

#import "ViewController.h"
#import "ZLCycleView.h"

@interface ViewController () <ZLCycleViewDelegate, ZLCycleViewDatasource>

@property (nonatomic, strong) NSArray *array;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    ZLCycleView *ccv = [[ZLCycleView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 300)];
    ccv.delegate = self;
    ccv.dataSource = self;
    ccv.isAutoPlay = YES;
        
    [self.view addSubview:ccv];
    [ccv registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
//    self.array = @[@"detail_0.jpg", @"detail_1.jpg", @"detail_2.jpg", @"detail_3.jpg"];
    
    UIActivityIndicatorView *v = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    v.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    v.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [v startAnimating];
    [self.view addSubview:v];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [v removeFromSuperview];
        self.array = @[@"detail_0.jpg", @"detail_1.jpg", @"detail_2.jpg", @"detail_3.jpg"];
        [ccv reloadData];
    });
    
}

- (NSInteger)numberOfItemsInCycleView:(ZLCycleView *)cycleView {
    return self.array.count;
}
- (__kindof UICollectionViewCell *)cycleView:(ZLCycleView *)cycleView cellForItemAtRow:(NSInteger)row {
    UICollectionViewCell *cell = [cycleView dequeueReusableCellWithReuseIdentifier:@"cell" forRow:row];
    
    for (UIView *v in cell.contentView.subviews) {
        [v removeFromSuperview];
    }
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.bounds.size.width, 300)];
    iv.image = [UIImage imageNamed:self.array[row]];
    
    [cell.contentView addSubview:iv];
    
    return cell;
    
}
- (void)cycleView:(ZLCycleView *)cycleView didSelectItemAtRow:(NSInteger)row {
    
    NSLog(@"%ld", (long)row);
}

- (__kindof UIPageControl *)pageControlInCycleView:(ZLCycleView *)cycleView {
    
    UIPageControl *page = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 300 - 30, self.view.frame.size.width, 30)];
    page.currentPageIndicatorTintColor = [UIColor whiteColor];
    page.pageIndicatorTintColor = [UIColor greenColor];
    return page;
}
- (void)cycleView:(ZLCycleView *)cycleView pageControl:(UIPageControl *)pageControl currentIndex:(NSInteger)idx {
    
    pageControl.currentPage = idx;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
