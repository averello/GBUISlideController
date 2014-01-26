/*!
 *  @file UILabel+Boldable.m
 *  @brief GBUISlideController
 *
 *  Created by @author George Boumis
 *  @date 26/1/14.
 *  @copyright   Copyright (c) 2014 George Boumis <developer.george.boumis@gmail.com>. All rights reserved.
 */

#import "UILabel+Boldable.h"
#import <objc/runtime.h>

static NSString const * const UILabelBoldableBoldProperty = @"kUILabelBoldableBoldProperty";
static NSString const * const UILabelBoldableBoldFontProperty = @"kUILabelBoldableBoldFontProperty";

@implementation UILabel (Boldable)
@dynamic bold;
@dynamic boldFont;

- (UIFont *)boldFont {
	return objc_getAssociatedObject(self, &UILabelBoldableBoldFontProperty);
}

- (void)setBoldFont:(UIFont *)boldFont {
	objc_setAssociatedObject(self, &UILabelBoldableBoldFontProperty, boldFont, OBJC_ASSOCIATION_RETAIN);
	if (!self.bold) return;
	if (self.attributedText == nil) return;
	
	NSAttributedString *attString = [[NSAttributedString alloc] initWithString:self.attributedText.string attributes:@{ NSFontAttributeName : boldFont }];
	self.attributedText = attString;
}


- (void)setBold:(BOOL)bold {
	objc_setAssociatedObject(self, &UILabelBoldableBoldProperty, @(bold), OBJC_ASSOCIATION_RETAIN);
	UIFont *boldFont = self.boldFont;
	if (boldFont == nil) return;
	if (bold) {
		if (self.text == nil) return;
		NSAttributedString *attString = [[NSAttributedString alloc] initWithString:self.text attributes:@{ NSFontAttributeName : boldFont }];
		self.text = nil;
		self.attributedText = attString;
	}
	else {
		if (self.attributedText == nil) return;
		NSString *text = self.attributedText.string;
		self.attributedText = nil;
		self.text = text;
	}
}

- (BOOL)bold {
	NSNumber *boolNumber = objc_getAssociatedObject(self, &UILabelBoldableBoldProperty);
	return boolNumber.boolValue;
}

@end
