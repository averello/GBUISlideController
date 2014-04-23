//
//  GBUISlideController.m
//  GBUISlideController
//
//  Created by George Boumis on 16/12/13.
//  Copyright (c) 2013 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
//

#import "GBUISlideController.h"
#import "GBUIPagedSliderControl.h"
#import "GBUIInteractiveTransitioningContext.h"
#import <objc/runtime.h>
#import "GBUISlideController_Protected.h"

@interface GBUISlideController () {
	@protected
	struct {
		CGFloat pagedSliderControlHeight;
		CGFloat horizontalSegmentedControlMargin;
		CGFloat verticalSegmentedControlMargin;
		CGFloat transitionDuration;
		CGFloat transitionDelay;
		UIViewAnimationOptions transitionAnimationOptions;
	} _options;
	
	struct {
		unsigned int animating:1;
		unsigned int isControlViewDetached:1;
	} _flags;
}
@property (strong, nonatomic) UIView *controlWrapperView;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) GBUIInteractiveTransitioningContext *interactiveTransitioningContext;
@end


@implementation GBUISlideController

#pragma makr - Basic Views

- (GBUIPagedSliderControl *)pagedSliderControl {
	if (nil == _pagedSliderControl) {
		_pagedSliderControl = [[GBUIPagedSliderControl alloc] initWithFrame:CGRectZero];
		[_pagedSliderControl addTarget:self action:@selector(pagedSliderControlAction:) forControlEvents:(UIControlEventValueChanged)];
		[_pagedSliderControl addTarget:self action:@selector(pagedSliderControlStartAction:) forControlEvents:(UIControlEventTouchDown)];
		[_pagedSliderControl addTarget:self action:@selector(pagedSliderControlEndAction:) forControlEvents:(UIControlEventTouchUpInside)];
	}
	return _pagedSliderControl;
}

- (UIView *)containerView {
	if (nil == _containerView) {
		_containerView = [[UIView alloc] initWithFrame:CGRectZero];
//		_containerView.showsHorizontalScrollIndicator = NO;
//		_containerView.showsVerticalScrollIndicator = NO;
	}
	return _containerView;
}

- (UIView *)controlWrapperView {
	if (nil == _controlWrapperView) {
		_controlWrapperView = [[UIView alloc] initWithFrame:CGRectZero];
		[_controlWrapperView addSubview:self.pagedSliderControl];
		self.pagedSliderControl.translatesAutoresizingMaskIntoConstraints = NO;
		[_controlWrapperView addConstraints:[self constraintsForWrapperView]];
	}
	return _controlWrapperView;
}

- (NSArray *)constraintsForWrapperView {
	@autoreleasepool {
		NSMutableArray *constraints = [[NSMutableArray alloc] init];
		NSDictionary *bindings = NSDictionaryOfVariableBindings(_pagedSliderControl);
		NSNumber *leftPagedSliderControlMargin, *rightPagedSliderControlMargin, *topPagedSliderControlMargin, *bottomPagedSliderControlMargin;
		leftPagedSliderControlMargin = _leftPagedSliderControlMargin;
		rightPagedSliderControlMargin = _rightPagedSliderControlMargin;
		topPagedSliderControlMargin = _topMargin;
		bottomPagedSliderControlMargin = _bottomPagedSliderControlMargin;
		
		//TODO: integrate with options
		NSDictionary *metrics = NSDictionaryOfVariableBindings(leftPagedSliderControlMargin, rightPagedSliderControlMargin, topPagedSliderControlMargin, bottomPagedSliderControlMargin);
		[constraints addObjectsFromArray:
		 [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(leftPagedSliderControlMargin)-[_pagedSliderControl]-(rightPagedSliderControlMargin)-|" options:(0) metrics:metrics views:bindings]];
		[constraints addObjectsFromArray:
		 [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topPagedSliderControlMargin)-[_pagedSliderControl]-(bottomPagedSliderControlMargin)-|" options:(0) metrics:metrics views:bindings]];
		return constraints;
	}
}

- (NSArray *)constraintsFroSubviews {
	@autoreleasepool {
		if (_flags.isControlViewDetached) {
			UIView *contentView = self.contentView;
			NSNumber *topmargin = _topMargin;
			NSDictionary *metrics = NSDictionaryOfVariableBindings(topmargin);
			NSMutableArray *constraints = [[NSMutableArray alloc] init];
			id top = self.topLayoutGuide, bottom = self.bottomLayoutGuide;
			NSDictionary *bindings = NSDictionaryOfVariableBindings(contentView, top, bottom);
			[constraints addObjectsFromArray:
			 [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:bindings]];
			[constraints addObjectsFromArray:
			 [NSLayoutConstraint constraintsWithVisualFormat:@"V:[top]-(topmargin)-[contentView][bottom]" options:0 metrics:metrics views:bindings]];
			return constraints;
		}
		else
			return [super constraintsFroSubviews];
	}
}

- (NSArray *)selectedViewControllerConstraints {
	@autoreleasepool {
		NSDictionary *bindings = @{ @"_selectedViewControllerView" : _selectedViewController.view };
		
		NSArray *horizontalContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_selectedViewControllerView]|" options:(0) metrics:nil views:bindings];
		NSArray *verticalContraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_selectedViewControllerView]|" options:(0) metrics:nil views:bindings];
		
		NSMutableArray *constraints = [[NSMutableArray alloc] initWithCapacity:horizontalContraints.count + verticalContraints.count];
		[constraints addObjectsFromArray:horizontalContraints];
		[constraints addObjectsFromArray:verticalContraints];
		return constraints.copy;
	}
}

- (UIView *)controlView {
	return self.controlWrapperView;
}

- (UIView *)contentView {
	return self.containerView;
}

#pragma mark - Contro View

- (void)detachControlView {
	_flags.isControlViewDetached = 1;
	[self.controlView removeFromSuperview];
	self.controlView.translatesAutoresizingMaskIntoConstraints = YES;
	[self updateViewConstraints];
}

- (void)reattachControlView {
	_flags.isControlViewDetached = 0;
	self.controlView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view insertSubview:self.controlView aboveSubview:self.contentView];
	[self updateViewConstraints];
	
}

#pragma mark - Slider actions

- (void)pagedSliderControlAction:(GBUIPagedSliderControl *)control {
//	NSLog(@"percent:%lf selectedIndex:%lu speculativeIndex:%lu value:%lf", control.totalPercent, (unsigned long)control.selectedIndex, (unsigned long)control.speculativeIndex, control.value);
	_interactiveTransitioningContext.percent = control.totalPercent;
}

- (void)pagedSliderControlStartAction:(GBUIPagedSliderControl *)control {
//	NSLog(@"percent:%lf selectedIndex:%lu speculativeIndex:%lu value:%lf", control.totalPercent, (unsigned long)control.selectedIndex, (unsigned long)control.speculativeIndex, control.value);
	_interactiveTransitioningContext = [[GBUIInteractiveTransitioningContext alloc] initWithFrame:self.contentView.bounds parentViewController:self];
	_interactiveTransitioningContext.viewControllers = _viewControllers;
	_interactiveTransitioningContext.percent = control.totalPercent;
	_interactiveTransitioningContext.sourceViewController = _selectedViewController;
	[_interactiveTransitioningContext startTransitioningInView:self.contentView];
}

- (void)pagedSliderControlEndAction:(GBUIPagedSliderControl *)control {
	if (nil!=_interactiveTransitioningContext) {
		_interactiveTransitioningContext.completeTransition = YES;
			_interactiveTransitioningContext.sourceViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
		[self addChildViewController:_interactiveTransitioningContext.sourceViewController];
		[self.contentView addSubview:_interactiveTransitioningContext.sourceViewController.view];
		[self.contentView addConstraints:self.selectedViewControllerConstraints];
		[_interactiveTransitioningContext.sourceViewController didMoveToParentViewController:self];
		_interactiveTransitioningContext = nil;
	}
	self.selectedIndex = control.selectedIndex;
}

#pragma mark - Controller Logic

- (void)setViewControllers:(NSArray *)viewControllers {
	[self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
	@autoreleasepool {
		/* If the view is not loaded, then proceed with loading */
		if (!self.isViewLoaded)
			[self loadView];
		
		UIViewController *previouslySelectedViewController = _selectedViewController;
		NSInteger previouslySelectedViewControllerIndex = _selectedIndex;
		
		/* We are setting all the controllers so remove the selected one */
		[self removeSelectedViewController];
		[_viewControllers makeObjectsPerformSelector:@selector(setSlideController:) withObject:nil];
		
		/* Copy the array */
		_viewControllers = viewControllers.copy;
		
		/* If the array is empty then return */
		if ( _viewControllers.count == 0) {
			_selectedIndex = NSNotFound;
			_selectedViewController = nil;
			_viewControllers = nil;
			return;
		}
		[_viewControllers makeObjectsPerformSelector:@selector(setSlideController:) withObject:self];
		
		/* Add all segments */
		NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:_viewControllers.count];
		for (UIViewController *controller in _viewControllers) {
			GBUIPagedSliderItem *pagedSliderItem = [[GBUIPagedSliderItem alloc] init];
			pagedSliderItem.titleLabel.text = pagedSliderItem.description;
			[items addObject:pagedSliderItem];
		}
		
		/* Selected index by default 0 */
		_selectedIndex = 0;
		
		/* Re-select the last selected controller if present in the current view controllers array or the same index */
		if (nil!=previouslySelectedViewController) {
			NSInteger previouslySelectedViewControllerCurrentIndex = [_viewControllers indexOfObject:previouslySelectedViewController];
			if (previouslySelectedViewControllerCurrentIndex!=NSNotFound)
				_selectedIndex = previouslySelectedViewControllerCurrentIndex;
			else if (previouslySelectedViewControllerIndex < _viewControllers.count)
				_selectedIndex = previouslySelectedViewControllerIndex;
		}
		
		_pagedSliderControl.items = items;
		[_pagedSliderControl setSelectedIndex:_selectedIndex animated:animated];
		_selectedViewController = _viewControllers[_selectedIndex];
		
		/* Add the child view controller */
		[self addChildViewController:_selectedViewController];
		_selectedViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
		if (animated) {
			[UIView animateWithDuration:_options.transitionDuration delay:_options.transitionDelay options:(_options.transitionAnimationOptions) animations:^{
				[self.view addSubview:_selectedViewController.view];
			} completion:^(BOOL finished) {
				if (finished) {
					[_selectedViewController didMoveToParentViewController:self];
					[self.contentView addConstraints:self.selectedViewControllerConstraints];
				}
			}];
		}
		else {
			[self.contentView addSubview:_selectedViewController.view];
			[_selectedViewController didMoveToParentViewController:self];
			
			/* Add the constraints */
			[self.contentView addConstraints:self.selectedViewControllerConstraints];
		}
	}
}

- (void)removeSelectedViewController {
	if (_selectedViewController) {
		/* Remove the child */
		[_selectedViewController willMoveToParentViewController:nil];
		[_selectedViewController.view removeFromSuperview];
		[_selectedViewController removeFromParentViewController];
		_selectedViewController = nil;
		_selectedIndex = NSNotFound;
	}
}


- (void)setSelectedViewController:(UIViewController *)selectedViewController {
	if (nil==_viewControllers)
		return;
	NSAssert(selectedViewController != nil, @"The selected view controller should not be 'nil'");
	if (nil==selectedViewController) return;
	
	if (![_viewControllers containsObject:selectedViewController]) {
		NSAssert(NO, @"The selected view controller does not exist");
		[NSException raise:NSInvalidArgumentException format:@"-[%@ %@] only a view controller in the segment controller's list of view controllers can be selected.", self.class, NSStringFromSelector(_cmd)];
		return;
	}
	
	self.selectedIndex = [_viewControllers indexOfObject:selectedViewController];
	_pagedSliderControl.selectedIndex = _selectedIndex;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
	if (_flags.animating)
		return;
	
	if (nil==_viewControllers)
		return;
	NSUInteger count = _viewControllers.count;
	if (_selectedIndex==selectedIndex)
		return;
	if (count==0)
		return;
	NSAssert(selectedIndex<count, @"The selected index is out of bounds");
	if (selectedIndex >= count)
		return;
	
	/* Find the source and the destination controllers */
	UIViewController *sourceViewController = _selectedViewController;
	UIViewController *destinationViewController = _viewControllers[selectedIndex];
	
	/* Ask the delegate if the selection is permitted */
//	if (!_shouldSelectViewControllerDelagateBlock(destinationViewController)) {
//		_segmentedControl.selectedSegmentIndex = _selectedIndex;
//		return;
//	}
	
	/* Indicate animations to prevent problems with very rapid selection */
	_flags.animating = 1;
	
	/* Find the direction of the transition */
//	GBUISlideControllerTransitionDirection direction;
//	if (_selectedIndex<selectedIndex)
//		direction = GBUISlideControllerTransitionDirectionRight;
//	else
//		direction = GBUISlideControllerTransitionDirectionLeft;
	
//	_willSelectViewControllerDelagateBlock(destinationViewController);
	
	_selectedIndex = selectedIndex;
	_selectedViewController = destinationViewController;
	
//	_didSelectViewControllerDelagateBlock(nil==_transitionAnimationBlock, destinationViewController);
	
	/* Transition */
//	[self performTransitionFromViewController:sourceViewController toViewController:destinationViewController direction:direction completion:_didSelectViewControllerDelagateBlock];
	
	[sourceViewController willMoveToParentViewController:nil];
	[self addChildViewController:destinationViewController];
	destinationViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
	
	[self transitionFromViewController:sourceViewController toViewController:destinationViewController duration:_options.transitionDuration options:(_options.transitionAnimationOptions) animations:^{
		[self.contentView addConstraints:self.selectedViewControllerConstraints];
		[self.contentView bringSubviewToFront:destinationViewController.view];
	} completion:^(BOOL finished) {
		[sourceViewController removeFromParentViewController];
		[destinationViewController didMoveToParentViewController:self];
		if (_flags.isControlViewDetached==0)
			[self.view bringSubviewToFront:self.controlView];
		_flags.animating = 0;
	}];
}

//- (void)performTransitionFromViewController:(UIViewController *)sourceViewController toViewController:(UIViewController *)destinationViewController direction:(GBUISegmentControllerTransitionDirection)direction completion:(void(^)(BOOL finished, UIViewController *destinationViewController))didSelectViewControllerDelagateBlock {
//	
//	[sourceViewController willMoveToParentViewController:nil];
//	[self addChildViewController:destinationViewController];
//	destinationViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
//	
//	/* If custom animation is provided then used it */
//	if (_transitionAnimationBlock) {
//		[_containerView insertSubview:destinationViewController.view aboveSubview:sourceViewController.view];
//		_transitionAnimationBlock(sourceViewController, destinationViewController, direction, ^(BOOL finished) {
//			_flags.animating = 0;
//			didSelectViewControllerDelagateBlock(finished, destinationViewController);
//		});
//		
//		[sourceViewController removeFromParentViewController];
//		[destinationViewController didMoveToParentViewController:self];
//		[_containerView addConstraints:self.selectedViewControllerConstraints];
//	}
//	else {
//		/* If no custom animation provided then animate according to the options */
//		[self transitionFromViewController:sourceViewController toViewController:destinationViewController duration:_options.transitionDuration options:(_options.transitionAnimationOptions) animations:^{
//			[_containerView addConstraints:self.selectedViewControllerConstraints];
//			[_containerView bringSubviewToFront:destinationViewController.view];
//		} completion:^(BOOL finished) {
//			[sourceViewController removeFromParentViewController];
//			[destinationViewController didMoveToParentViewController:self];
//			[self.view bringSubviewToFront:_topToolbar];
//			_flags.animating = 0;
//		}];
//		
//		//		[UIView transitionFromView:sourceViewController.view toView:destinationViewController.view duration:_options.transitionDuration options:(_options.transitionAnimationOptions) completion:^(BOOL finished) {
//		//			if (finished) {
//		//				[sourceViewController removeFromParentViewController];
//		//				[destinationViewController didMoveToParentViewController:self];
//		//				[_containerView addConstraints:self.selectedViewControllerConstraints];
//		//			}
//		//		}];
//	}
//}


#pragma mark - Basic Views
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (nil!=self) {
        [self _init];
    }
    return self;
}

- (void)_init {
	_selectedIndex = NSNotFound;
	
	_options.horizontalSegmentedControlMargin = 7.0f;
	_options.verticalSegmentedControlMargin = 7.0f;
	_options.pagedSliderControlHeight = 25.0f;
	_options.transitionDuration = 0.45f;
	
	_topMargin = @(0);
	_leftPagedSliderControlMargin = _rightPagedSliderControlMargin = _topPagedSliderControlMargin = _bottomPagedSliderControlMargin = @(10.0f);
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	_pagedSliderControl.backgroundColor = [UIColor purpleColor];
//	self.contentView.backgroundColor = [UIColor yellowColor];
//		
//	NSUInteger count = 3;
//	NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:count];
//	for (NSUInteger i=0; i<count; i++) {
//		GBUIPagedSliderItem *item = [[GBUIPagedSliderItem alloc] init];
//		item.titleLabel.text = [NSString stringWithFormat:@"title %lu", (unsigned long)i];
//		items[i] = item;
//	}
//	self.pagedSliderControl.items = items;
	
//	double delayInSeconds = 2.0;
//	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//		[self detachControlView];
//		self.navigationItem.titleView = self.controlView;
//		
//		double delayInSeconds = 2.0;
//		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//			[self reattachControlView];
//		});
//	});
}

@end

static NSString const * const GBUISlideControllerProperty = @"kGBUISlideControllerProperty";

@implementation UIViewController (GBUISlideController)
@dynamic slideController;
@dynamic slideItem;

- (GBUISlideController *)slideController {
	return objc_getAssociatedObject(self, &GBUISlideControllerProperty);
}

- (void)setSlideController:(GBUISlideController *)slideController {
	objc_setAssociatedObject(self, &GBUISlideControllerProperty, slideController, OBJC_ASSOCIATION_RETAIN);
}

- (GBUIPagedSliderItem *)slideItem {
	GBUISlideController *slideController = self.slideController;
	if (nil==slideController)
		return nil;
	NSUInteger index = [slideController.viewControllers indexOfObject:self];
	if (index == NSNotFound)
		return nil;
	return self.slideController.pagedSliderControl.items[index];
}

@end

