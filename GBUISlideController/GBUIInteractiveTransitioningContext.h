//
//  GBUIInteractiveTransitioningContext.h
//  GBUISlideController
//
//  Created by George Boumis on 19/1/14.
//  Copyright (c) 2014 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSUInteger, GBUIInteractiveTransitioningDirection) {
	GBUIInteractiveTransitioningDirectionTop,
	GBUIInteractiveTransitioningDirectionLeft,
	GBUIInteractiveTransitioningDirectionRight,
	GBUIInteractiveTransitioningDirectionBottom
};

@interface GBUIInteractiveTransitioningContext : NSObject
@property (strong, nonatomic, readonly) UIView *containerView;
@property (copy, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) UIViewController *sourceViewController;
@property (strong, readonly, nonatomic) UIViewController *destinationController;
@property (nonatomic, readwrite) GBUIInteractiveTransitioningDirection direction;
@property (nonatomic, readwrite) float percent;
@property (nonatomic, readwrite, getter = isTransitionCompleted) BOOL completeTransition;

- (instancetype)initWithFrame:(CGRect)frame parentViewController:(UIViewController *)controller;
- (void)startTransitioningInView:(UIView *)view;
@end
