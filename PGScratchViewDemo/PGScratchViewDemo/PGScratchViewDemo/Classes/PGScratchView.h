//
//  PGScratchView.h
//  PGScratchViewDemo
//
//  Created by Page on 2016/10/23.
//  Designed By PageGuo,
//  QQ:799573715
//  github:https://github.com/PageGuo/PGScratchView

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@class PGScratchView;

@protocol PGScratchViewDelegate <NSObject>

/**
 *  打开全部图层之后的代理方法
 */
- (void)openAllCoverScratchView:(PGScratchView *)scratchView;

@end

@interface PGScratchView : UIView {
    
    CGPoint previousTouchLocation;
    CGPoint currentTouchLocation;
    
    CGImageRef hideImage;
    CGImageRef scratchImage;
    
    CGContextRef contextMask;
}

/**
 *  路径宽度，默认为10.0
 */
@property (nonatomic, assign) float sizeBrush;

/**
 *  经过多少块撤销图层，默认为10.0，最大为16
 */
@property (nonatomic, assign) int passCount;

@property (nonatomic, strong) UIView *hideView;

/**
 *  设置覆盖在上的图层view
 */
- (void)setHideView:(UIView *)hideView;

/**
 *  代理属性
 */
@property (nonatomic, assign) id<PGScratchViewDelegate>scratchViewDelegate;

@end
