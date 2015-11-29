//
//  LGPlusButton.h
//  LGPlusButtonsView
//
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Grigory Lutkov <Friend.LGA@gmail.com>
//  (https://github.com/Friend-LGA/LGPlusButtonsView)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <UIKit/UIKit.h>
#import "LGPlusButtonsView.h"

@interface LGPlusButton : UIButton

@property (assign, nonatomic, getter=isShowing) BOOL showing;

- (void)updateParametersForOrientation:(LGPlusButtonsViewOrientation)orientation;

- (void)setImage:(UIImage *)image forState:(UIControlState)state forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (UIImage *)imageForState:(UIControlState)state forOrientation:(LGPlusButtonsViewOrientation)orientation;

- (void)setTitleFont:(UIFont *)font forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (UIFont *)titleFontForOrientation:(LGPlusButtonsViewOrientation)orientation;

- (void)setInsets:(UIEdgeInsets)insets forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (UIEdgeInsets)insetsForOrientation:(LGPlusButtonsViewOrientation)orientation;

- (void)setOffset:(CGPoint)offset forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (CGPoint)offsetForOrientation:(LGPlusButtonsViewOrientation)orientation;

- (void)setSize:(CGSize)size forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (CGSize)sizeForOrientation:(LGPlusButtonsViewOrientation)orientation;

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (UIEdgeInsets)contentEdgeInsetsForOrientation:(LGPlusButtonsViewOrientation)orientation;

- (void)setTitleOffset:(CGPoint)titleOffset forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (CGPoint)titleOffsetForOrientation:(LGPlusButtonsViewOrientation)orientation;

- (void)setImageOffset:(CGPoint)imageOffset forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (CGPoint)imageOffsetForOrientation:(LGPlusButtonsViewOrientation)orientation;

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;
- (UIColor *)backgroundColorForState:(UIControlState)state;

- (void)setLayerCornerRadius:(CGFloat)cornerRadius forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (CGFloat)layerCornerRadiusForOrientation:(LGPlusButtonsViewOrientation)orientation;

/** Unavailable, use titleOffset and imageOffset instead */
- (void)setContentHorizontalAlignment:(UIControlContentHorizontalAlignment)contentHorizontalAlignment __attribute__((unavailable("Use titleOffset and imageOffset instead")));
/** Unavailable, use titleOffset and imageOffset instead */
- (UIControlContentHorizontalAlignment)contentHorizontalAlignment                                     __attribute__((unavailable("Use titleOffset and imageOffset instead")));
/** Unavailable, use titleOffset and imageOffset instead */
- (void)setContentVerticalAlignment:(UIControlContentVerticalAlignment)contentVerticalAlignment       __attribute__((unavailable("Use titleOffset and imageOffset instead")));
/** Unavailable, use titleOffset and imageOffset instead */
- (UIControlContentVerticalAlignment)contentVerticalAlignment                                         __attribute__((unavailable("Use titleOffset and imageOffset instead")));
/** Unavailable, use titleOffset and imageOffset instead */
- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets                                              __attribute__((unavailable("Use titleOffset and imageOffset instead")));
/** Unavailable, use titleOffset and imageOffset instead */
- (UIEdgeInsets)titleEdgeInsets                                                                       __attribute__((unavailable("Use titleOffset and imageOffset instead")));
/** Unavailable, use titleOffset and imageOffset instead */
- (void)setImageEdgeInsets:(UIEdgeInsets)imageEdgeInsets                                              __attribute__((unavailable("Use titleOffset and imageOffset instead")));
/** Unavailable, use titleOffset and imageOffset instead */
- (UIEdgeInsets)imageEdgeInsets                                                                       __attribute__((unavailable("Use titleOffset and imageOffset instead")));

@end
