//
//  GBUISlideController.h
//  GBUISlideController
//
//  Created by George Boumis on 16/12/13.
//  Copyright (c) 2013 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBUIControlViewController/GBUIControlViewController.h"
#import "GBUIPagedSliderControl.h"

typedef NS_ENUM(NSUInteger, GBUISlideControllerTransitionDirection) {
	GBUISlideControllerTransitionDirectionTop,
	GBUISlideControllerTransitionDirectionLeft,
	GBUISlideControllerTransitionDirectionRight,
	GBUISlideControllerTransitionDirectionBottom
};

@class GBUIPagedSliderItem;

@interface GBUISlideController : GBUIControlViewController<UIViewControllerTransitioningDelegate>
@property (nonatomic, strong, readonly) UIView *controlView;
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong) NSNumber *topMargin;
@property (nonatomic, strong) NSNumber *leftPagedSliderControlMargin, *rightPagedSliderControlMargin, *topPagedSliderControlMargin, *bottomPagedSliderControlMargin;
- (void)detachControlView;
- (void)reattachControlView;

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, readwrite) NSUInteger selectedIndex;
@property (nonatomic, assign) UIViewController *selectedViewController;

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

@end

@interface UIViewController (GBUISlideController)
@property (nonatomic, readonly, strong) GBUISlideController *slideController;
@property (nonatomic, readonly, strong) GBUIPagedSliderItem *slideItem;
@end
