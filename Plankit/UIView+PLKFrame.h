//
//  UIView+PLKFrame.h
//  Plankit
//
//  Created by ke.xu on 2018/9/27.
//  Copyright © 2018年 Jason Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (PLKFrame)

@property (nonatomic, readwrite) CGFloat left, right, top, bottom, width, height;
@property (nonatomic, readwrite) CGPoint topCenter, bottomCenter, leftCenter, rightCenter;
@property (nonatomic, readwrite) CGPoint leftTop, leftBottom, rightTop, rightBottom;
@property (nonatomic, readonly) CGPoint boundsCenter;
@property (nonatomic, readwrite) CGSize size;

@end

NS_ASSUME_NONNULL_END
