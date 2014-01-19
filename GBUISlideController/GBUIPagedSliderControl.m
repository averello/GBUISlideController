//
//  GBUIPagedSliderControl.m
//  GBUISlideController
//
//  Created by George Boumis on 16/12/13.
//  Copyright (c) 2013 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
//

#import "GBUIPagedSliderControl.h"

@interface GBUIPagedSliderItem ()
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation GBUIPagedSliderItem

- (instancetype)init {
	self = [super init];
	if (nil!=self) {
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textAlignment = NSTextAlignmentCenter;
	}
	return self;
}

- (NSString *)debugDescription {
	return [NSString stringWithFormat:@"<%@: %p titleLabel:%@>", NSStringFromClass(self.class), self, _titleLabel];
}
@end

@interface GBUIPagedSliderControl ()
@property (strong, nonatomic) NSArray *subviewConstraints;
@property (readwrite, nonatomic) CGPoint startPoint;
@property (readwrite, nonatomic) UIOffset startOffset;
@property (readwrite, nonatomic) BOOL trackingThumbView;
@property (strong, nonatomic) NSLayoutConstraint *centerXcontraintOfThumbmView;
@property (strong, nonatomic) UITouch *trackingTouch;
@end

@implementation GBUIPagedSliderControl


- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (nil!=self) {
		[self setupUI];
	}
	return self;
}

- (void)setupUI {
	_backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
	_thumbView = [[UIView alloc] initWithFrame:CGRectZero];
	
	_backgroundView.translatesAutoresizingMaskIntoConstraints =
	_thumbView.translatesAutoresizingMaskIntoConstraints = NO;
	
	self.layer.borderWidth = _thumbView.layer.borderWidth = 1.0f;
	self.layer.cornerRadius = _thumbView.layer.cornerRadius = 3.0f;
	self.layer.borderColor = [UIColor blueColor].CGColor;
	self.clipsToBounds = YES;
	
	_thumbView.layer.borderColor = [UIColor darkGrayColor].CGColor;
	_thumbView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:0.9f];
	_backgroundView.backgroundColor = [UIColor lightGrayColor];
	
	[self addSubview:_backgroundView];
	[self addSubview:_thumbView];
	[self bringSubviewToFront:_thumbView];
	
	self.userInteractionEnabled = YES;
}

- (void)updateConstraints {
	[super updateConstraints];
	if (_subviewConstraints)
		[self removeConstraints:_subviewConstraints];
	_subviewConstraints = [self constraintsFroSubviews];
	[self addConstraints:_subviewConstraints];
}

//- (void)layoutSubviews {
//	self.selectedIndex = _selectedIndex;
//	[super layoutSubviews];
//}

- (NSArray *)constraintsFroSubviews {
	@autoreleasepool {
		NSMutableArray *constraints = [[NSMutableArray alloc] init];
		NSDictionary *bindings = NSDictionaryOfVariableBindings(_backgroundView, _thumbView);
//		NSDictionary *metrics = NSDictionaryOfVariableBindings(<#...#>);
		[constraints addObjectsFromArray:
		 [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundView]|" options:0 metrics:nil views:bindings]];
		[constraints addObjectsFromArray:
		 [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundView]|" options:0 metrics:nil views:bindings]];
		
		[constraints addObjectsFromArray:
		 [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(1)-[_thumbView]-(1)-|" options:0 metrics:nil views:bindings]];
		_centerXcontraintOfThumbmView = [NSLayoutConstraint constraintWithItem:_thumbView attribute:(NSLayoutAttributeCenterX) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeCenterX) multiplier:1.0f constant:0.0f];
		[constraints addObject:_centerXcontraintOfThumbmView];
		
		NSUInteger count = 1;
		if (_items)
			count = _items.count;
		[constraints addObject:
		 [NSLayoutConstraint constraintWithItem:_thumbView attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeWidth) multiplier:1.0f/(CGFloat)count constant:-2.0f]];
		
		if (_backgroundDecorationView) {
			NSDictionary *bindings = NSDictionaryOfVariableBindings(_backgroundDecorationView);
			[constraints addObjectsFromArray:
			 [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundDecorationView]|" options:0 metrics:nil views:bindings]];
			[constraints addObjectsFromArray:
			 [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundDecorationView]|" options:0 metrics:nil views:bindings]];
		}
		
		if (_items) {
			NSUInteger count = _items.count;
			[_items enumerateObjectsUsingBlock:^(GBUIPagedSliderItem *item, NSUInteger index, BOOL *stop) {
				item.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
				if (index == 0)
					[constraints addObject:
					 [NSLayoutConstraint constraintWithItem:item.titleLabel attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeLeft) multiplier:1.0f constant:0.0f]];
				
				else if (index == count-1)
					[constraints addObject:
					 [NSLayoutConstraint constraintWithItem:item.titleLabel attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeRight) multiplier:1.0f constant:0.0f]];
				else
					[constraints addObject:
					 [NSLayoutConstraint constraintWithItem:item.titleLabel attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:[_items[index-1] titleLabel]	attribute:(NSLayoutAttributeRight) multiplier:1.0f constant:0.0f]];
				[constraints addObject:
				 [NSLayoutConstraint constraintWithItem:item.titleLabel attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeWidth) multiplier:1.0f/(CGFloat)count constant:0.0f]];
				
				UILabel *titleLabel = item.titleLabel;
				[constraints addObjectsFromArray:
				 [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel)]];
			}];
		}
		return constraints;
	}
}

- (void)setBackgroundDecorationView:(UIView *)backgroundDecorationView {
	if (_backgroundDecorationView != backgroundDecorationView) {
		[_backgroundDecorationView removeFromSuperview];
		_backgroundDecorationView = nil;
		if (backgroundDecorationView) {
			_backgroundDecorationView = backgroundDecorationView;
			_backgroundDecorationView.translatesAutoresizingMaskIntoConstraints = NO;
			[self insertSubview:_backgroundDecorationView aboveSubview:_backgroundView];
			[self updateConstraintsIfNeeded];
		}
	}
}

- (void)setItems:(NSArray *)items {
	if (_items) {
		for (GBUIPagedSliderItem *item in _items)
			[item.titleLabel removeFromSuperview];
	}
	_items = items.copy;
	
	_minValue = 1;
	_maxValue = MAX(1, _items.count);
	_step = 1;
	
	if (_items) {
		for (GBUIPagedSliderItem *item in items)
			[self insertSubview:item.titleLabel aboveSubview:_thumbView];
		[self updateConstraints];
	}
}

- (CGSize)intrinsicContentSize {
	return CGSizeMake(UIViewNoIntrinsicMetric, 29.0f);
}

- (float)totalPercent {
	CGFloat centerX = _thumbView.center.x;
	CGFloat totalPercent = (centerX - CGRectGetMidX(_thumbView.bounds)) / (CGRectGetWidth(self.bounds) -2*CGRectGetMidX(_thumbView.bounds));
	return totalPercent;
//	UIPercentDrivenInteractiveTransition
}

- (float)value {
	return _minValue + self.totalPercent * (_maxValue-_minValue);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *touch in touches.allObjects) {
		CGPoint locationInView = [touch locationInView:self];
		BOOL containts = CGRectContainsPoint(_thumbView.frame, locationInView);
		if (containts) {
			_startPoint = locationInView;
			_startOffset = UIOffsetMake(_thumbView.center.x - _startPoint.x, _thumbView.center.y - _startPoint.y);
			_trackingThumbView = YES;
			_trackingTouch = touch;
			[self sendActionsForControlEvents:(UIControlEventTouchDown)];
			return;
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_trackingThumbView==NO) return;
	if (![touches containsObject:_trackingTouch]) return;
		
	UITouch *touch = _trackingTouch;
	CGPoint locationInView = [touch locationInView:self];
	CGFloat diff = locationInView.x - CGRectGetMidX(self.bounds);
	CGFloat newCenterX = diff + _startOffset.horizontal;
	newCenterX = MIN(CGRectGetMidX(self.bounds) - CGRectGetMidX(_thumbView.bounds), newCenterX);
	newCenterX = MAX(CGRectGetMidX(_thumbView.bounds) - CGRectGetMidX(self.bounds), newCenterX);
	_centerXcontraintOfThumbmView.constant = newCenterX;//MAX(CGRectGetMidX(_thumbView.bounds), MIN(diff + _startOffset.horizontal, CGRectGetWidth(_thumbView.bounds) - CGRectGetMidX(_thumbView.bounds)));
	NSUInteger index = self.totalPercent * (CGFloat)_maxValue;
	index = MAX(0, MIN(index, _maxValue-1));
	_speculativeIndex = index;
	[self sendActionsForControlEvents:(UIControlEventValueChanged)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (nil==_trackingTouch) {
		UITouch *touch = touches.anyObject;
		CGPoint locationInView = [touch locationInView:self];
		CGFloat centerX = locationInView.x;
		CGFloat totalPercent = (centerX - CGRectGetMidX(_thumbView.bounds)) / (CGRectGetWidth(self.bounds) -2*CGRectGetMidX(_thumbView.bounds));
		
		BOOL containts = CGRectContainsPoint(self.bounds, locationInView);
		if (!containts) return;
		
		NSUInteger index = totalPercent * (CGFloat)_maxValue;
		index = MAX(0, MIN(index, _maxValue-1));
		[self setSelectedIndex:index animated:YES];
		[self sendActionsForControlEvents:(UIControlEventTouchUpInside)];
		return;
	}
	if (![touches containsObject:_trackingTouch]) return;

	CGFloat totalPercent = self.totalPercent;
	NSUInteger index = totalPercent * (CGFloat)_maxValue;
	index = MAX(0, MIN(index, _maxValue-1));
	[self setSelectedIndex:index animated:YES];
	
	_trackingThumbView = NO;
	_trackingTouch = nil;
	[self sendActionsForControlEvents:(UIControlEventTouchUpInside)];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if (![touches containsObject:_trackingTouch]) return;
	
	_centerXcontraintOfThumbmView.constant = _startPoint.x;
	_trackingThumbView = NO;
	_trackingTouch = nil;
	[self sendActionsForControlEvents:(UIControlEventTouchCancel)];
}

-(void)setSelectedIndex:(NSUInteger)selectedIndex {
	_selectedIndex = selectedIndex;
	GBUIPagedSliderItem *item = _items[_selectedIndex];
	CGFloat titleLabelCenterX = item.titleLabel.center.x;
	CGFloat centerX = CGRectGetMidX(self.bounds);
	_centerXcontraintOfThumbmView.constant = titleLabelCenterX - centerX;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
	[_thumbView updateConstraintsIfNeeded];
	[UIView animateWithDuration:0.3f delay:0.0f options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
		self.selectedIndex = selectedIndex;
		[self layoutIfNeeded];
	} completion:nil];
}

@end
