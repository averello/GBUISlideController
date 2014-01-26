//
//  GBUIPagedSliderControl.h
//  GBUISlideController
//
//  Created by George Boumis on 16/12/13.
//  Copyright (c) 2013 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabel+Boldable.h"

@interface GBUIPagedSliderItem : NSObject
@property (strong, nonatomic, readonly) UILabel *titleLabel;
@end

@interface GBUIPagedSliderControl : UIControl
@property (strong, nonatomic) UIView *backgroundDecorationView;
@property (strong, nonatomic, readonly) UIView *backgroundView;
@property (strong, nonatomic, readonly) UIView *thumbView;

@property (readwrite, nonatomic) NSUInteger selectedIndex;
@property (readwrite, nonatomic) float totalPercent;
@property (readonly, nonatomic) NSUInteger minValue;
@property (readonly, nonatomic) NSUInteger maxValue;
@property (readonly, nonatomic) float step;

@property (readonly, nonatomic) NSUInteger speculativeIndex;
@property (readonly, nonatomic) float value;

@property (copy, nonatomic) NSArray *items;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;
@end
