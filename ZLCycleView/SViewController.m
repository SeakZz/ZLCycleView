//
//  SViewController.m
//  ZLCycleView
//
//  Created by long on 2017/5/13.
//  Copyright © 2017年 long. All rights reserved.
//

#import "SViewController.h"
#import "ZLCycleView.h"

@interface SViewController () <ZLCycleViewDelegate, ZLCycleViewDatasource>

@property (nonatomic, strong) NSArray *array;
@property (weak, nonatomic) IBOutlet ZLCycleView *cycleV;

@end

@implementation SViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _cycleV.delegate = self;
    _cycleV.dataSource = self;
    _cycleV.isAutoPlay = YES;
    _cycleV.scrollDirection = UICollectionViewScrollDirectionVertical;
    [_cycleV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    self.array = @[@"detail_0.jpg", @"detail_1.jpg", @"detail_2.jpg", @"detail_3.jpg"];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
