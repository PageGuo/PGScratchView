//
//  ViewController.m
//  PGScratchViewDemo
//
//  Created by Page on 2016/10/23.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "ViewController.h"
#import "PGScratchView.h"

@interface ViewController ()<PGScratchViewDelegate>

/**
 *  第一个底部指示Label
 */
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;

/**
 *  第二个底部指示Label
 */
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;

@property (weak, nonatomic) IBOutlet UIButton *reCoverButton;

/**
 *  自定义的覆盖view
 */
@property (nonatomic, strong) PGScratchView *customeScratchView;

/**
 *  图片作为覆盖view
 */
@property (nonatomic, strong) PGScratchView *imageScratchView;

/**
 *  用来绘制的图片
 */
@property (nonatomic, strong) UIImageView *coverImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    /*自定义刮奖view*/
    //原始分支
    //自定义view
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 225, 110)];
    customView.backgroundColor = [UIColor greenColor];
    
    UILabel *customTopSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, customView.bounds.size.width, 20)];
    customTopSubLabel.text = @"刮奖";
    customTopSubLabel.textAlignment = NSTextAlignmentCenter;
    
    [customView addSubview:customTopSubLabel];
    
    UILabel *customBottomSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(customTopSubLabel.frame) + 20, customView.bounds.size.width, 20)];
    customBottomSubLabel.text = @"刮开得积分";
    customBottomSubLabel.textAlignment = NSTextAlignmentCenter;
    
    [customView addSubview:customBottomSubLabel];
    
    //添加
    [self.customeScratchView setHideView:customView];
    [self.view addSubview:self.customeScratchView];
    
    
    /*用图片作为刮奖view*/
    [self.imageScratchView setHideView:self.coverImageView];
    [self.view addSubview:self.imageScratchView];
    
    /*
     实现方法：把PGScratchView覆盖在刮奖显示的view上
     */
}

#pragma mark --实现代理方法
- (void)openAllCoverScratchView:(PGScratchView *)scratchView {
    
    NSLog(@"全部刮开了~~");
    
    //控制重绘button
    if (scratchView == self.imageScratchView) {
        
        self.reCoverButton.hidden = NO;
        
    }else {
        
    }
}

#pragma mark --重新绘制
- (IBAction)reCoverButtonClick:(UIButton *)sender {
    
    sender.hidden = YES;
    
    [self.imageScratchView setHideView:self.coverImageView];
    [self.view addSubview:self.imageScratchView];
    
}

#pragma mark --懒加载子控件
- (PGScratchView *)customeScratchView {
    
    if (_customeScratchView == nil) {
        _customeScratchView = [[PGScratchView alloc] initWithFrame:CGRectMake(75, 100, 225, 110)];
        _customeScratchView.scratchViewDelegate = self;
        _customeScratchView.passCount = 8;
        _customeScratchView.sizeBrush = 30.0;
    }
    
    return _customeScratchView;
}

- (PGScratchView *)imageScratchView {
    
    if (_imageScratchView == nil) {
        _imageScratchView = [[PGScratchView alloc] initWithFrame:CGRectMake(75, CGRectGetMaxY(self.customeScratchView.frame) + 100, 225, 110)];
        _imageScratchView.scratchViewDelegate = self;
        _imageScratchView.sizeBrush = 20.0;
    }
    
    return _imageScratchView;
}

- (UIImageView *)coverImageView {
    
    if (_coverImageView == nil) {
        _coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paymentAnswerSuccess_coupon_cover"]];
    }
    
    return _coverImageView;
}

@end



