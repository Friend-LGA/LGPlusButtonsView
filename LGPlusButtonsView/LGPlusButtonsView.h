//
//  LGPlusButtonsView.h
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

@class LGPlusButtonsView;

static NSString *const kLGPlusButtonsViewWillShowNotification        = @"kLGPlusButtonsViewWillShowNotification";
static NSString *const kLGPlusButtonsViewWillHideNotification        = @"kLGPlusButtonsViewWillHideNotification";
static NSString *const kLGPlusButtonsViewDidShowNotification         = @"kLGPlusButtonsViewDidShowNotification";
static NSString *const kLGPlusButtonsViewDidHideNotification         = @"kLGPlusButtonsViewDidHideNotification";
static NSString *const kLGPlusButtonsViewWillShowButtonsNotification = @"kLGPlusButtonsViewWillShowButtonsNotification";
static NSString *const kLGPlusButtonsViewWillHideButtonsNotification = @"kLGPlusButtonsViewWillHideButtonsNotification";
static NSString *const kLGPlusButtonsViewDidShowButtonsNotification  = @"kLGPlusButtonsViewDidShowButtonsNotification";
static NSString *const kLGPlusButtonsViewDidHideButtonsNotification  = @"kLGPlusButtonsViewDidHideButtonsNotification";
static NSString *const kLGPlusButtonsViewActionNotification          = @"kLGPlusButtonsViewActionNotification";


@protocol LGPlusButtonsViewDelegate <NSObject>

@optional

- (void)plusButtonsViewWillShow:(LGPlusButtonsView *)plusButtonsView;
- (void)plusButtonsViewWillHide:(LGPlusButtonsView *)plusButtonsView;
- (void)plusButtonsViewDidShow:(LGPlusButtonsView *)plusButtonsView;
- (void)plusButtonsViewDidHide:(LGPlusButtonsView *)plusButtonsView;
- (void)plusButtonsViewWillShowButtons:(LGPlusButtonsView *)plusButtonsView;
- (void)plusButtonsViewWillHideButtons:(LGPlusButtonsView *)plusButtonsView;
- (void)plusButtonsViewDidShowButtons:(LGPlusButtonsView *)plusButtonsView;
- (void)plusButtonsViewDidHideButtons:(LGPlusButtonsView *)plusButtonsView;
- (void)plusButtonsView:(LGPlusButtonsView *)plusButtonsView buttonPressedWithTitle:(NSString *)title description:(NSString *)description index:(NSUInteger)index;

@end

@interface LGPlusButtonsView : UIView

typedef NS_ENUM(NSUInteger, LGPlusButtonsViewOrientation)
{
    LGPlusButtonsViewOrientationAll       = 0,
    LGPlusButtonsViewOrientationPortrait  = 1,
    LGPlusButtonsViewOrientationLandscape = 2
};

typedef NS_ENUM(NSUInteger, LGPlusButtonsViewPosition)
{
    LGPlusButtonsViewPositionBottomRight = 0,
    LGPlusButtonsViewPositionBottomLeft  = 1,
    LGPlusButtonsViewPositionTopRight    = 2,
    LGPlusButtonsViewPositionTopLeft     = 3,
    LGPlusButtonsViewPositionRightBottom = LGPlusButtonsViewPositionBottomRight,
    LGPlusButtonsViewPositionLeftBottom  = LGPlusButtonsViewPositionBottomLeft,
    LGPlusButtonsViewPositionRightTop    = LGPlusButtonsViewPositionTopRight,
    LGPlusButtonsViewPositionLeftTop     = LGPlusButtonsViewPositionTopRight
};

typedef NS_ENUM(NSUInteger, LGPlusButtonsAppearingAnimationType)
{
    LGPlusButtonsAppearingAnimationTypeNone                            = 0,
    LGPlusButtonsAppearingAnimationTypeCrossDissolve                   = 1,
    LGPlusButtonsAppearingAnimationTypeCrossDissolveAndSlideHorizontal = 2,
    LGPlusButtonsAppearingAnimationTypeCrossDissolveAndSlideVertical   = 3,
    LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop             = 4
};

typedef NS_ENUM(NSUInteger, LGPlusButtonAnimationType)
{
    LGPlusButtonAnimationTypeNone          = 0,
    LGPlusButtonAnimationTypeRotate        = 1,
    LGPlusButtonAnimationTypeCrossDissolve = 2
};

@property (assign, nonatomic, readonly, getter=isShowing) BOOL showing;
@property (assign, nonatomic, readonly, getter=isButtonsShowing) BOOL buttonsShowing;
@property (assign, nonatomic, getter=isShowHideOnScroll) BOOL showHideOnScroll;
/** Hide additional buttons on scroll. Default is NO */
@property (assign, nonatomic, getter=isHideButtonsOnScroll) BOOL hideButtonsOnScroll;
/** Default is YES */
@property (assign, nonatomic, getter=isDisableShowHideOnScrollIfContentSizeLessThenFrame) BOOL disableShowHideOnScrollIfContentSizeLessThenFrame;

@property (assign, nonatomic) CGPoint                             offset;
@property (assign, nonatomic) LGPlusButtonsViewPosition           position;
/** How much scroll you need to show/hide buttons. Default is 64.f */
@property (assign, nonatomic) CGFloat                             scrollSensitivity;
@property (assign, nonatomic) LGPlusButtonsAppearingAnimationType appearingAnimationType;
@property (assign, nonatomic) LGPlusButtonsAppearingAnimationType buttonsAppearingAnimationType;
@property (assign, nonatomic) LGPlusButtonAnimationType           plusButtonAnimationType;
@property (strong, nonatomic) UIColor                             *coverColor;

/** Default is 0.3 */
@property (assign, nonatomic) IBInspectable NSTimeInterval appearingAnimationSpeed;
/** Default is 0.3 */
@property (assign, nonatomic) IBInspectable NSTimeInterval buttonsAppearingAnimationSpeed;

/** When user will interact with this scroll view, LGPlusButtonsView will show/hide */
@property (assign, nonatomic) UIScrollView *observedScrollView;

#pragma mark - Handlers

/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^willShowHandler)(LGPlusButtonsView *plusButtonView);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^willHideHandler)(LGPlusButtonsView *plusButtonView);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^didShowHandler)(LGPlusButtonsView *plusButtonView);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^didHideHandler)(LGPlusButtonsView *plusButtonView);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^willShowButtonsHandler)(LGPlusButtonsView *plusButtonView);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^willHideButtonsHandler)(LGPlusButtonsView *plusButtonView);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^didShowButtonsHandler)(LGPlusButtonsView *plusButtonView);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^didHideButtonsHandler)(LGPlusButtonsView *plusButtonView);

/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^actionHandler)(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index);

@property (assign, nonatomic) id<LGPlusButtonsViewDelegate> delegate;

/** Defailt is {4.f, 4.f, 4.f, 4.f} */
- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (UIEdgeInsets)contentEdgeInsetsForOrientation:(LGPlusButtonsViewOrientation)orientation;

#pragma mark - Buttons all

- (void)setButtonsTitles:(NSArray *)titles                     forState:(UIControlState)state;
- (void)setButtonsTitleColor:(UIColor *)titleColor             forState:(UIControlState)state;
- (void)setButtonsTitleColors:(NSArray *)titleColors           forState:(UIControlState)state;
- (void)setButtonsBackgroundImage:(UIImage *)backgroundImage   forState:(UIControlState)state;
- (void)setButtonsBackgroundImages:(NSArray *)backgroundImages forState:(UIControlState)state;
- (void)setButtonsBackgroundColor:(UIColor *)backgroundColor   forState:(UIControlState)state;
- (void)setButtonsBackgroundColors:(NSArray *)backgroundColors forState:(UIControlState)state;
- (void)setButtonsImage:(UIImage *)image                       forState:(UIControlState)state forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setButtonsImages:(NSArray *)images                     forState:(UIControlState)state forOrientation:(LGPlusButtonsViewOrientation)orientation;

- (void)setButtonsTitleFont:(UIFont *)font                          forOrientation:(LGPlusButtonsViewOrientation)orientation;
/** Defailt is {4.f, 4.f, 4.f, 4.f} */
- (void)setButtonsInsets:(UIEdgeInsets)insets                       forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setButtonsOffset:(CGPoint)offset                            forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setButtonsSize:(CGSize)size                                 forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setButtonsContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setButtonsTitleOffset:(CGPoint)titleOffset                  forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setButtonsImageOffset:(CGPoint)imageOffset                  forOrientation:(LGPlusButtonsViewOrientation)orientation;

- (void)setButtonsImageViewContentMode:(UIViewContentMode)contentMode;
- (void)setButtonsClipsToBounds:(BOOL)clipsToBounds;
- (void)setButtonsAdjustsImageWhenHighlighted:(BOOL)adjustsImageWhenHighlighted;
- (void)setButtonsAdjustsImageWhenDisabled:(BOOL)adjustsImageWhenDisabled;
- (void)setButtonsEnabled:(BOOL)enabled;

- (void)setButtonsLayerCornerRadius:(CGFloat)cornerRadius forOrientation:(LGPlusButtonsViewOrientation)orientation;;
- (void)setButtonsLayerBorderColor:(UIColor *)borderColor;
- (void)setButtonsLayerBorderWidth:(CGFloat)borderWidth;
- (void)setButtonsLayerShadowColor:(UIColor *)shadowColor;
- (void)setButtonsLayerShadowRadius:(CGFloat)shadowRadius;
- (void)setButtonsLayerShadowOpacity:(CGFloat)shadowOpacity;
- (void)setButtonsLayerShadowOffset:(CGSize)shadowOffset;

#pragma mark - Button at index

- (void)setButtonAtIndex:(NSUInteger)index title:(NSString *)title                    forState:(UIControlState)state;
- (void)setButtonAtIndex:(NSUInteger)index titleColor:(UIColor *)titleColor           forState:(UIControlState)state;
- (void)setButtonAtIndex:(NSUInteger)index backgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state;
- (void)setButtonAtIndex:(NSUInteger)index backgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;
- (void)setButtonAtIndex:(NSUInteger)index image:(UIImage *)image                     forState:(UIControlState)state forOrientation:(LGPlusButtonsViewOrientation)orientation;

- (void)setButtonAtIndex:(NSUInteger)index titleFont:(UIFont *)font                          forOrientation:(LGPlusButtonsViewOrientation)orientation;
/** Defailt is {4.f, 4.f, 4.f, 4.f} */
- (void)setButtonAtIndex:(NSUInteger)index insets:(UIEdgeInsets)insets                       forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setButtonAtIndex:(NSUInteger)index offset:(CGPoint)offset                            forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setButtonAtIndex:(NSUInteger)index size:(CGSize)size                                 forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setButtonAtIndex:(NSUInteger)index contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setButtonAtIndex:(NSUInteger)index titleOffset:(CGPoint)titleOffset                  forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setButtonAtIndex:(NSUInteger)index imageOffset:(CGPoint)imageOffset                  forOrientation:(LGPlusButtonsViewOrientation)orientation;

- (void)setButtonAtIndex:(NSUInteger)index imageViewContentMode:(UIViewContentMode)contentMode;
- (void)setButtonAtIndex:(NSUInteger)index clipsToBounds:(BOOL)clipsToBounds;
- (void)setButtonAtIndex:(NSUInteger)index adjustsImageWhenHighlighted:(BOOL)adjustsImageWhenHighlighted;
- (void)setButtonAtIndex:(NSUInteger)index adjustsImageWhenDisabled:(BOOL)adjustsImageWhenDisabled;
- (void)setButtonAtIndex:(NSUInteger)index enabled:(BOOL)enabled;

- (void)setButtonAtIndex:(NSUInteger)index layerCornerRadius:(CGFloat)cornerRadius forOrientation:(LGPlusButtonsViewOrientation)orientation;;
- (void)setButtonAtIndex:(NSUInteger)index layerBorderColor:(UIColor *)borderColor;
- (void)setButtonAtIndex:(NSUInteger)index layerBorderWidth:(CGFloat)borderWidth;

#pragma mark - Descriptions all

- (void)setDescriptionsTexts:(NSArray *)texts;
- (void)setDescriptionsTextColor:(UIColor *)textColor;
- (void)setDescriptionsBackgroundColor:(UIColor *)backgroundColor;

/** Defailt is [UIFont systemFontOfSize:14.f] */
- (void)setDescriptionsFont:(UIFont *)font                               forOrientation:(LGPlusButtonsViewOrientation)orientation;
/** Defailt is {4.f, 4.f, 4.f, 4.f} */
- (void)setDescriptionsInsets:(UIEdgeInsets)insets                       forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setDescriptionsOffset:(CGPoint)offset                            forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setDescriptionsSize:(CGSize)size                                 forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setDescriptionsContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets forOrientation:(LGPlusButtonsViewOrientation)orientation;

- (void)setDescriptionsLayerCornerRadius:(CGFloat)cornerRadius forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setDescriptionsLayerBorderColor:(UIColor *)borderColor;
- (void)setDescriptionsLayerBorderWidth:(CGFloat)borderWidth;
- (void)setDescriptionsLayerShadowColor:(UIColor *)shadowColor;
- (void)setDescriptionsLayerShadowRadius:(CGFloat)shadowRadius;
- (void)setDescriptionsLayerShadowOpacity:(CGFloat)shadowOpacity;
- (void)setDescriptionsLayerShadowOffset:(CGSize)shadowOffset;

#pragma mark - Description at index

- (void)setDescriptionAtIndex:(NSUInteger)index text:(NSString *)text;
- (void)setDescriptionAtIndex:(NSUInteger)index textColor:(UIColor *)textColor;
- (void)setDescriptionAtIndex:(NSUInteger)index backgroundColor:(UIColor *)backgroundColor;

/** Defailt is [UIFont systemFontOfSize:14.f] */
- (void)setDescriptionAtIndex:(NSUInteger)index font:(UIFont *)font                               forOrientation:(LGPlusButtonsViewOrientation)orientation;
/** Defailt is {4.f, 4.f, 4.f, 4.f} */
- (void)setDescriptionAtIndex:(NSUInteger)index insets:(UIEdgeInsets)insets                       forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setDescriptionAtIndex:(NSUInteger)index offset:(CGPoint)offset                            forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setDescriptionAtIndex:(NSUInteger)index size:(CGSize)size                                 forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setDescriptionAtIndex:(NSUInteger)index contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets forOrientation:(LGPlusButtonsViewOrientation)orientation;

- (void)setDescriptionAtIndex:(NSUInteger)index layerCornerRadius:(CGFloat)cornerRadius forOrientation:(LGPlusButtonsViewOrientation)orientation;
- (void)setDescriptionAtIndex:(NSUInteger)index layerBorderColor:(UIColor *)borderColor;
- (void)setDescriptionAtIndex:(NSUInteger)index layerBorderWidth:(CGFloat)borderWidth;

#pragma mark -

- (instancetype)initWithNumberOfButtons:(NSUInteger)numberOfButtons
                firstButtonIsPlusButton:(BOOL)firstButtonIsPlusButton
                          showAfterInit:(BOOL)showAfterInit;

+ (instancetype)plusButtonsViewWithNumberOfButtons:(NSUInteger)numberOfButtons
                           firstButtonIsPlusButton:(BOOL)firstButtonIsPlusButton
                                     showAfterInit:(BOOL)showAfterInit;

#pragma mark -

/** Do not forget about weak referens to self for actionHandler and plusButtonActionHandler blocks */
- (instancetype)initWithNumberOfButtons:(NSUInteger)numberOfButtons
                firstButtonIsPlusButton:(BOOL)firstButtonIsPlusButton
                          showAfterInit:(BOOL)showAfterInit
                          actionHandler:(void(^)(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index))actionHandler;

/** Do not forget about weak referens to self for actionHandler and plusButtonActionHandler blocks */
+ (instancetype)plusButtonsViewWithNumberOfButtons:(NSUInteger)numberOfButtons
                           firstButtonIsPlusButton:(BOOL)firstButtonIsPlusButton
                                     showAfterInit:(BOOL)showAfterInit
                                     actionHandler:(void(^)(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index))actionHandler;

#pragma mark -

- (instancetype)initWithNumberOfButtons:(NSUInteger)numberOfButtons
                firstButtonIsPlusButton:(BOOL)firstButtonIsPlusButton
                          showAfterInit:(BOOL)showAfterInit
                               delegate:(id<LGPlusButtonsViewDelegate>)delegate;

+ (instancetype)plusButtonsViewWithNumberOfButtons:(NSUInteger)numberOfButtons
                           firstButtonIsPlusButton:(BOOL)firstButtonIsPlusButton
                                     showAfterInit:(BOOL)showAfterInit
                                          delegate:(id<LGPlusButtonsViewDelegate>)delegate;

#pragma mark -

- (void)showAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler;
- (void)hideAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler;

- (void)showButtonsAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler;
- (void)hideButtonsAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler;

#pragma mark -

/** Unavailable, use +plusButtonsViewWithView... instead */
+ (instancetype)new __attribute__((unavailable("use +plusButtonsViewWithView... instead")));
/** Unavailable, use -initWithView... instead */
- (instancetype)init __attribute__((unavailable("use -initWithView... instead")));
/** Unavailable, use -initWithView... instead */
- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("use -initWithView... instead")));

@end
