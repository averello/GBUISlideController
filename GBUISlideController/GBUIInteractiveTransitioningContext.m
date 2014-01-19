//
//  GBUIInteractiveTransitioningContext.m
//  GBUISlideController
//
//  Created by George Boumis on 19/1/14.
//  Copyright (c) 2014 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
//

#import "GBUIInteractiveTransitioningContext.h"

@interface GBUIInteractiveTransitioningContext ()
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) NSLayoutConstraint *moveContraint;
@property (strong, nonatomic) UIViewController *parentViewController;
@end

@implementation GBUIInteractiveTransitioningContext

- (instancetype)init {
	self = [self initWithFrame:CGRectZero parentViewController:nil];
	if (nil!=self) {
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame parentViewController:(UIViewController *)controller {
	self = [super init];
	if (nil!=self) {
		_containerView = [[UIView alloc] initWithFrame:frame];
		_containerView.userInteractionEnabled = NO;
		_parentViewController = controller;
	}
	return self;
}

- (void)startTransitioningInView:(UIView *)view {
	[view addSubview:_containerView];
	NSMutableArray *constraints = [[NSMutableArray alloc] init];
	NSDictionary *bindings = NSDictionaryOfVariableBindings(_containerView);
	[constraints addObjectsFromArray:
	 [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_containerView]|" options:0 metrics:nil views:bindings]];
	[constraints addObjectsFromArray:
	 [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_containerView]|" options:0 metrics:nil views:bindings]];
	[view addConstraints:constraints];
}

- (void)setCompleteTransition:(BOOL)completeTransition {
	if (nil==_viewControllers)return;
	_completeTransition = YES;
	NSUInteger maxValue = _viewControllers.count;
	self.percent = _percent;
	NSUInteger index = _percent * (CGFloat)(maxValue);
	index = MAX(0, MIN(index, maxValue-1));
	_destinationController = _viewControllers[index];
	for (UIViewController *controller in _viewControllers) {
		[controller willMoveToParentViewController:nil];
		[controller.view removeFromSuperview];
		controller.view.translatesAutoresizingMaskIntoConstraints = YES;
		[controller removeFromParentViewController];
	}
	[_containerView removeFromSuperview];
}

- (void)setViewControllers:(NSArray *)viewControllers {
	if (_viewControllers) {
		for (UIViewController *controller in _viewControllers) {
			[controller willMoveToParentViewController:nil];
			[controller.view removeFromSuperview];
			[controller removeFromParentViewController];
		}
	}
	
	_viewControllers = viewControllers.copy;
	
	if (_viewControllers) {
		for (UIViewController *controller in _viewControllers) {
			[_parentViewController addChildViewController:controller];
			[_containerView addSubview:controller.view];
			[_parentViewController didMoveToParentViewController:_parentViewController];
			controller.view.translatesAutoresizingMaskIntoConstraints = NO;
		}
		[_containerView addConstraints:[self constraintsForSubviews]];
		UIViewController *firstController = _viewControllers.firstObject;
		_moveContraint = [NSLayoutConstraint constraintWithItem:_containerView attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:firstController.view attribute:(NSLayoutAttributeLeft) multiplier:1.0f constant:0.0f];
		[_containerView addConstraint:_moveContraint];
		[_containerView addConstraint:
		 [NSLayoutConstraint constraintWithItem:firstController.view attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:_containerView attribute:(NSLayoutAttributeTop) multiplier:1.0f constant:0.0f]];
	}
}

- (void)setPercent:(float)percent {
//	float oldPercent = _percent;
	_percent = percent;
//	float newPercent = _percent;
	if (nil==_viewControllers) return;
	NSUInteger maxValue = _viewControllers.count;
//	CGFloat oldConstant = _moveContraint.constant;
	CGFloat newConstant = _percent * CGRectGetWidth(_containerView.bounds) * (maxValue-1);
//	NSUInteger oldIndex = round(oldPercent * (CGFloat)(maxValue));
//	oldIndex = MAX(0, MIN(oldIndex, maxValue-1));
//	NSUInteger newIndex = round(newPercent * (CGFloat)(maxValue));
//	newIndex = MAX(0, MIN(newIndex, maxValue-1));
//	UIViewController *fromController = _viewControllers[oldIndex];
//	UIViewController *toController = _viewControllers[newIndex];
//	if (newIndex != oldIndex) {
//		[fromController willMoveToParentViewController:nil];
//		[_parentViewController addChildViewController:toController];
//		[fromController removeFromParentViewController];
//		[toController didMoveToParentViewController:_parentViewController];
//	}
	_moveContraint.constant = newConstant;
//	if (newIndex != oldIndex) {
//		[fromController removeFromParentViewController];
//		[toController didMoveToParentViewController:_parentViewController];
//	}
}

- (NSArray *)constraintsForSubviews {
	@autoreleasepool {
		NSMutableArray *constraints = [[NSMutableArray alloc] init];
		UIViewController *lastViewController = nil;
		for (UIViewController *controller in _viewControllers) {
			[constraints addObject:
			 [NSLayoutConstraint constraintWithItem:_containerView attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationEqual) toItem:controller.view attribute:(NSLayoutAttributeWidth) multiplier:1.0f constant:0.0f]];
			[constraints addObject:
			 [NSLayoutConstraint constraintWithItem:_containerView attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:controller.view attribute:(NSLayoutAttributeHeight) multiplier:1.0f constant:0.0f]];
			if (lastViewController) {
				[constraints addObject:
				 [NSLayoutConstraint constraintWithItem:lastViewController.view attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationEqual) toItem:controller.view attribute:(NSLayoutAttributeLeft) multiplier:1.0f constant:0.0f]];
				[constraints addObject:
				 [NSLayoutConstraint constraintWithItem:lastViewController.view attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:controller.view attribute:(NSLayoutAttributeTop) multiplier:1.0f constant:0.0f]];
			}
			lastViewController = controller;
		}
		return constraints;
	}
}
@end
