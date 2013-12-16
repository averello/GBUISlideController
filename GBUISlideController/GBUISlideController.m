//
//  GBUISlideController.m
//  GBUISlideController
//
//  Created by George Boumis on 16/12/13.
//  Copyright (c) 2013 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
//

#import "GBUISlideController.h"
#import "GBUIPagedSliderControl.h"

@interface GBUISlideController ()
@property (strong, nonatomic) UIView *controlWrapperView;
@property (strong, nonatomic) GBUIPagedSliderControl *pagedSliderControl;
@property (strong, nonatomic) UIView *containerView;
@end


@implementation GBUISlideController

#pragma makr - Basic Views

- (GBUIPagedSliderControl *)pagedSliderControl {
	if (nil == _pagedSliderControl) {
		_pagedSliderControl = [[GBUIPagedSliderControl alloc] initWithFrame:CGRectZero];
	}
	return _pagedSliderControl;
}

- (UIView *)containerView {
	if (nil == _containerView) {
		_containerView = [[UIView alloc] initWithFrame:CGRectZero];
	}
	return _containerView;
}

- (UIView *)controlWrapperView {
	if (nil == _controlWrapperView) {
		_controlWrapperView = [[UIView alloc] initWithFrame:CGRectZero];
		[_controlWrapperView addSubview:self.pagedSliderControl];
		self.pagedSliderControl.translatesAutoresizingMaskIntoConstraints = NO;
		[_controlWrapperView addConstraints:[self constraintsFroWrapperView]];
	}
	return _controlWrapperView;
}

- (NSArray *)constraintsFroWrapperView {
	@autoreleasepool {
		NSMutableArray *constraints = [[NSMutableArray alloc] init];
		NSDictionary *bindings = NSDictionaryOfVariableBindings(_pagedSliderControl);
		NSNumber *leftPagedSliderControlMargin, *rightPagedSliderControlMargin, *topPagedSliderControlMargin, *bottomPagedSliderControlMargin;
		leftPagedSliderControlMargin = rightPagedSliderControlMargin = topPagedSliderControlMargin = bottomPagedSliderControlMargin = @(10.0f);
		NSDictionary *metrics = NSDictionaryOfVariableBindings(leftPagedSliderControlMargin, rightPagedSliderControlMargin, topPagedSliderControlMargin, bottomPagedSliderControlMargin);
		[constraints addObjectsFromArray:
		 [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(leftPagedSliderControlMargin)-[_pagedSliderControl]-(rightPagedSliderControlMargin)-|" options:(0) metrics:metrics views:bindings]];
		[constraints addObjectsFromArray:
		 [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topPagedSliderControlMargin)-[_pagedSliderControl]-(bottomPagedSliderControlMargin)-|" options:(0) metrics:metrics views:bindings]];
		return constraints;
	}
}

- (UIView *)controlView {
	return self.controlWrapperView;
}

- (UIView *)contentView {
	return self.containerView;
}

#pragma mark - Basic Views

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	_pagedSliderControl.backgroundColor = [UIColor purpleColor];
	_containerView.backgroundColor = [UIColor yellowColor];
}

@end
