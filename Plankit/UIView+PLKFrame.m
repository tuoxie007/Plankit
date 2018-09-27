//
//  UIView+PLKFrame.m
//  Plankit
//
//  Created by ke.xu on 2018/9/27.
//  Copyright © 2018年 Jason Hsu. All rights reserved.
//

#import "UIView+PLKFrame.h"

CGRect ccr(CGFloat x, CGFloat y, CGFloat w, CGFloat h) {
    static CGFloat scale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    if (scale > 1) {
        return CGRectMake(ceilf(x*scale)/scale, ceilf(y*scale)/scale, ceilf(w*scale)/scale, ceilf(h*scale)/scale);
    }
    return CGRectMake(ceilf(x), ceilf(y), ceilf(w), ceilf(h));
}
CGPoint ccp(CGFloat x, CGFloat y) {
    return CGPointMake(x, y);
}
CGSize ccs(CGFloat w, CGFloat h) {
    return CGSizeMake(w, h);
}

@implementation UIView (PLKFrame)

- (CGFloat)left
{
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)left {
    self.frame = ccr(left, self.top, self.width, self.height);
}

- (CGFloat)right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    self.frame = ccr(right-self.width, self.top, self.width, self.height);
}

- (CGFloat)top
{
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)top {
    self.frame = ccr(self.left, top, self.width, self.height);
}

- (CGFloat)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    self.frame = ccr(self.left, bottom-self.height, self.width, self.height);
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    self.frame = ccr(self.left, self.top, width, self.height);
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    self.frame = ccr(self.left, self.top, self.width, height);
}

- (CGPoint)topCenter {
    return ccp(self.center.x, self.top);
}

- (void)setTopCenter:(CGPoint)topCenter {
    self.center = topCenter;
    self.top = topCenter.y;
}

- (CGPoint)bottomCenter {
    return ccp(self.center.x, self.bottom);
}

- (void)setBottomCenter:(CGPoint)bottomCenter {
    self.center = bottomCenter;
    self.bottom = bottomCenter.y;
}

- (CGPoint)leftCenter {
    return ccp(self.left, self.center.y);
}

- (void)setLeftCenter:(CGPoint)leftCenter {
    self.center = leftCenter;
    self.left = leftCenter.x;
}

- (CGPoint)rightCenter {
    return ccp(self.right, self.center.y);
}

- (void)setRightCenter:(CGPoint)rightCenter {
    self.center = rightCenter;
    self.right = rightCenter.x;
}

- (CGPoint)leftTop {
    return ccp(self.left, self.top);
}

- (void)setLeftTop:(CGPoint)leftTop {
    self.left = leftTop.x;
    self.top = leftTop.y;
}

- (CGPoint)leftBottom {
    return ccp(self.left, self.bottom);
}

- (void)setLeftBottom:(CGPoint)leftBottom {
    self.left = leftBottom.x;
    self.bottom = leftBottom.y;
}

- (CGPoint)rightTop {
    return ccp(self.right, self.top);
}

- (void)setRightTop:(CGPoint)rightTop {
    self.right = rightTop.x;
    self.top = rightTop.y;
}

- (CGPoint)rightBottom {
    return ccp(self.right, self.bottom);
}

- (void)setRightBottom:(CGPoint)rightBottom {
    self.right = rightBottom.x;
    self.bottom = rightBottom.y;
}

- (CGPoint)boundsCenter {
    return ccp(self.center.x - self.left, self.center.y - self.top);
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    self.frame = ccr(self.left, self.top, size.width, size.height);
}

@end
