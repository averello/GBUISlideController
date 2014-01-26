/*!
 *  @file UILabel+Boldable.h
 *  @brief GBUISlideController
 *
 *  Created by @author George Boumis
 *  @date 26/1/14.
 *  @copyright   Copyright (c) 2014 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
 */

#import <UIKit/UIKit.h>

/*!
 *  @public
 *  @category UILabel_Boldable
 *  @brief A class.
 *  @details Some details.
 *  @related UILabel
 */
@interface UILabel (Boldable)
@property (nonatomic, strong) UIFont *boldFont;
@property (nonatomic, readwrite) BOOL bold;
@end
