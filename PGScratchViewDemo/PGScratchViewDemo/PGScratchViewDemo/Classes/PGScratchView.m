//
//  PGScratchView.m
//  PGScratchViewDemo
//
//  Created by Page on 2016/10/23.
//  Designed By PageGuo,
//  QQ:799573715
//  github:https://github.com/PageGuo/PGScratchView

#import "PGScratchView.h"

@interface PGScratchView ()

/**
 *  分成的16等份的区域
 */
@property (nonatomic, strong) NSMutableArray *rectArr;

/**
 *  已经走过的面积
 */
@property (nonatomic, strong) NSMutableArray *passRectArr;

@end

@implementation PGScratchView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setOpaque:NO];
        
        _sizeBrush = 10.0;
        _passCount = 10;
        self.rectArr = [NSMutableArray array];
        
        CGFloat rectW = self.bounds.size.width / 4;
        CGFloat rectH = self.bounds.size.height / 4;
        
        for (int i = 0; i < 4; i++) {
            
            for (int j = 0; j < 4; j++) {
                
                CGRect rect = CGRectMake(j * rectW, i * rectH, rectW, rectH);
                
                [self.rectArr addObject:[NSValue valueWithCGRect:rect]];
            }
        }
    }
    return self;
}

#pragma mark -
#pragma mark CoreGraphics methods

// Will be called every touch and at the first init
- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    UIImage *imageToDraw = [UIImage imageWithCGImage:scratchImage];
    
    [imageToDraw drawInRect:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
}

// Method to change the view which will be scratched
- (void)setHideView:(UIView *)hideView {
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
    
    float scale = [UIScreen mainScreen].scale;
    
    UIGraphicsBeginImageContextWithOptions(hideView.bounds.size, NO, 0);
    [hideView.layer renderInContext:UIGraphicsGetCurrentContext()];
    hideView.layer.contentsScale = scale;
    hideImage = UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();
    
    size_t imageWidth = CGImageGetWidth(hideImage);
    size_t imageHeight = CGImageGetHeight(hideImage);
    
    CFMutableDataRef pixels = CFDataCreateMutable(NULL, imageWidth * imageHeight);
    contextMask = CGBitmapContextCreate(CFDataGetMutableBytePtr(pixels), imageWidth, imageHeight , 8, imageWidth, colorspace, kCGImageAlphaNone);
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(pixels);
    
    CGContextSetFillColorWithColor(contextMask, [UIColor blackColor].CGColor);
    CGContextFillRect(contextMask, self.frame);
    
    CGContextSetStrokeColorWithColor(contextMask, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(contextMask, _sizeBrush);
    CGContextSetLineCap(contextMask, kCGLineCapRound);
    
    CGImageRef mask = CGImageMaskCreate(imageWidth, imageHeight, 8, 8, imageWidth, dataProvider, nil, NO);
    scratchImage = CGImageCreateWithMask(hideImage, mask);
    
    CGImageRelease(mask);
    CGColorSpaceRelease(colorspace);
}

- (void)scratchTheViewFrom:(CGPoint)startPoint to:(CGPoint)endPoint {
    
    float scale = [UIScreen mainScreen].scale;
    
    CGContextMoveToPoint(contextMask, startPoint.x * scale, (self.frame.size.height - startPoint.y) * scale);
    CGContextAddLineToPoint(contextMask, endPoint.x * scale, (self.frame.size.height - endPoint.y) * scale);
    CGContextStrokePath(contextMask);
    [self setNeedsDisplay];
    
}

#pragma mark -
#pragma mark Touch event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [[event touchesForView:self] anyObject];
    currentTouchLocation = [touch locationInView:self];
    
    //获取touch对象
    UITouch * t = touches.anyObject;
    
    [self recordPassRect:t];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [[event touchesForView:self] anyObject];
    
    if (!CGPointEqualToPoint(previousTouchLocation, CGPointZero))
    {
        currentTouchLocation = [touch locationInView:self];
    }
    
    previousTouchLocation = [touch previousLocationInView:self];
    
    [self scratchTheViewFrom:previousTouchLocation to:currentTouchLocation];
    
    //获取touch对象
    UITouch *t = touches.anyObject;
    
    [self recordPassRect:t];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [[event touchesForView:self] anyObject];
    
    if (!CGPointEqualToPoint(previousTouchLocation, CGPointZero))
    {
        previousTouchLocation = [touch previousLocationInView:self];
        [self scratchTheViewFrom:previousTouchLocation to:currentTouchLocation];
    }
    
    //获取touch对象
    UITouch * t = touches.anyObject;
    
    [self recordPassRect:t];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
   
    [super touchesCancelled:touches withEvent:event];
}

- (void)initScratch {
    
    currentTouchLocation = CGPointZero;
    previousTouchLocation = CGPointZero;
}

#pragma mark --记录走过的区域
- (void)recordPassRect:(UITouch *)touch {
    
    //获取点击的点
    CGPoint point =[touch locationInView:touch.view];
    
    // 遍历所有的区域,判断是否包含了点击的点
    for (int i=0; i < self.rectArr.count; i++) {
        CGRect rect = [self.rectArr[i] CGRectValue];
        
        if (CGRectContainsPoint(rect, point)) {
            
            if (![self.passRectArr containsObject:self.rectArr[i]]) {
                //把触摸到区域添加到数组
                [self.passRectArr addObject:self.rectArr[i]];
                
                //经过了一半的区域,则移除自身
                if (self.passRectArr.count >= self.passCount) {
                    
                    [self dismiss];
                }
            }
            
        }
    }
}

#pragma mark --从父控件移除
- (void)dismiss {
    
    [self removeFromSuperview];
    
    [self.passRectArr removeAllObjects];
    
    if ([self.scratchViewDelegate respondsToSelector:@selector(openAllCoverScratchView:)]) {
        
        [self.scratchViewDelegate openAllCoverScratchView:self];
    }
    
}

#pragma mark --懒加载走过路程的数组
- (NSMutableArray *)passRectArr {
    if (_passRectArr == nil) {
        _passRectArr = [NSMutableArray array];
    }
    return _passRectArr;
}


@end
