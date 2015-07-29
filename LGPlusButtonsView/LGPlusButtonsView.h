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
#import "LGPlusButton.h"

@class LGPlusButtonsView;

@protocol LGPlusButtonsViewDelegate <NSObject>

@optional

- (void)plusButtonsView:(LGPlusButtonsView *)plusButtonsView buttonPressedWithTitle:(NSString *)title description:(NSString *)description index:(NSUInteger)index;
- (void)plusButtonsViewPlusButtonPressed:(LGPlusButtonsView *)plusButtonsView;

@end

@interface LGPlusButtonsView : UIView

typedef enum
{
    LGPlusButtonsViewPositionBottomRight = 0,
    LGPlusButtonsViewPositionBottomLeft  = 1,
    LGPlusButtonsViewPositionTopRight    = 2,
    LGPlusButtonsViewPositionTopLeft     = 3
}
LGPlusButtonsViewPosition;

typedef enum
{
    LGPlusButtonsAppearingAnimationTypeNone                            = 0,
    LGPlusButtonsAppearingAnimationTypeCrossDissolve                   = 1,
    LGPlusButtonsAppearingAnimationTypeCrossDissolveAndSlideHorizontal = 2,
    LGPlusButtonsAppearingAnimationTypeCrossDissolveAndSlideVertical   = 3,
    LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop             = 4
}
LGPlusButtonsAppearingAnimationType;

typedef enum
{
    LGPlusButtonAnimationTypeNone          = 0,
    LGPlusButtonAnimationTypeRotate        = 1,
    LGPlusButtonAnimationTypeCrossDissolve = 2
}
LGPlusButtonAnimationType;

@property (assign, nonatomic, getter=isShowing)           BOOL showing;
@property (assign, nonatomic, getter=isShowWhenScrolling) BOOL showWhenScrolling;

@property (strong, nonatomic) LGPlusButton *plusButton;

/** First is plusButton */
@property (strong, nonatomic) NSMutableArray *buttons;
/** First is plusButton description */
@property (strong, nonatomic) NSMutableArray *descriptions;

@property (assign, nonatomic) UIEdgeInsets contentInset;
@property (assign, nonatomic) UIEdgeInsets buttonInset;
@property (assign, nonatomic) CGSize       buttonsSize;
@property (assign, nonatomic) CGSize       plusButtonSize;
/** Description horizontal offset from button, default is 6.f */
@property (assign, nonatomic) CGFloat      descriptionOffsetX;
@property (assign, nonatomic) CGPoint      offset;

@property (assign, nonatomic) LGPlusButtonsAppearingAnimationType appearingAnimationType;
@property (assign, nonatomic) LGPlusButtonsAppearingAnimationType buttonsAppearingAnimationType;
@property (assign, nonatomic) LGPlusButtonAnimationType           plusButtonAnimationType;
@property (assign, nonatomic) LGPlusButtonsViewPosition           position;

/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^actionHandler)(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index);
/** Do not forget about weak referens to self */
@property (strong, nonatomic) void (^plusButtonActionHandler)(LGPlusButtonsView *plusButtonView);

@property (assign, nonatomic) id<LGPlusButtonsViewDelegate> delegate;

- (instancetype)initWithView:(UIView *)view
             numberOfButtons:(NSUInteger)numberOfButtons
             showsPlusButton:(BOOL)showsPlusButton;

+ (instancetype)plusButtonsViewWithView:(UIView *)view
                        numberOfButtons:(NSUInteger)numberOfButtons
                        showsPlusButton:(BOOL)showsPlusButton;

#pragma mark -

/** Do not forget about weak referens to self for actionHandler and plusButtonActionHandler blocks */
- (instancetype)initWithView:(UIView *)view
             numberOfButtons:(NSUInteger)numberOfButtons
             showsPlusButton:(BOOL)showsPlusButton
               actionHandler:(void(^)(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index))actionHandler
     plusButtonActionHandler:(void(^)(LGPlusButtonsView *plusButtonView))plusButtonActionHandler;

/** Do not forget about weak referens to self for actionHandler and plusButtonActionHandler blocks */
+ (instancetype)plusButtonsViewWithView:(UIView *)view
                        numberOfButtons:(NSUInteger)numberOfButtons
                        showsPlusButton:(BOOL)showsPlusButton
                          actionHandler:(void(^)(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index))actionHandler
                plusButtonActionHandler:(void(^)(LGPlusButtonsView *plusButtonView))plusButtonActionHandler;

#pragma mark -

- (instancetype)initWithView:(UIView *)view
             numberOfButtons:(NSUInteger)numberOfButtons
             showsPlusButton:(BOOL)showsPlusButton
                    delegate:(id<LGPlusButtonsViewDelegate>)delegate;

+ (instancetype)plusButtonsViewWithView:(UIView *)view
                        numberOfButtons:(NSUInteger)numberOfButtons
                        showsPlusButton:(BOOL)showsPlusButton
                               delegate:(id<LGPlusButtonsViewDelegate>)delegate;

#pragma mark -

- (void)setButtonsTitles:(NSArray *)titles forState:(UIControlState)state;
- (void)setButtonsTitleColor:(UIColor *)titleColor forState:(UIControlState)state;
- (void)setButtonsImage:(UIImage *)image forState:(UIControlState)state;
- (void)setButtonsBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state;
- (void)setButtonsBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;
- (void)setButtonsTitleFont:(UIFont *)font;

#pragma mark -

- (void)setDescriptionsTexts:(NSArray *)texts;
- (void)setDescriptionsTextColor:(UIColor *)textColor;
- (void)setDescriptionsBackgroundColor:(UIColor *)backgroundColor;
- (void)setDescriptionsFont:(UIFont *)font;

#pragma mark -

- (void)setButtonsClipsToBounds:(BOOL)clipsToBounds;
- (void)setButtonsContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets;
- (void)setButtonsAdjustsImageWhenHighlighted:(BOOL)adjustsImageWhenHighlighted;

#pragma mark -

- (void)setButtonsLayerMasksToBounds:(BOOL)masksToBounds;
- (void)setButtonsLayerCornerRadius:(CGFloat)cornerRadius;
- (void)setButtonsLayerBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;
- (void)setButtonsLayerShadowColor:(UIColor *)shadowColor shadowOpacity:(float)shadowOpacity shadowOffset:(CGSize)shadowOffset shadowRadius:(CGFloat)shadowRadius;

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
