//
//  GBUISlideController.h
//  GBUISlideController
//
//  Created by George Boumis on 16/12/13.
//  Copyright (c) 2013 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBUIControlViewController/GBUIControlViewController.h"

@interface GBUISlideController : GBUIControlViewController
@property (nonatomic, strong, readonly) UIView *controlView;
@property (nonatomic, strong, readonly) UIView *contentView;
@end
