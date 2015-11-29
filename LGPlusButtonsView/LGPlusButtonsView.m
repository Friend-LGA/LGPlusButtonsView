//
//  LGPlusButtonsView.m
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

#import "LGPlusButtonsView.h"
#import "LGPlusButton.h"
#import "LGPlusButtonDescription.h"
#import "LGPlusButtonsViewShared.h"

#define kLGPlusButtonsViewDegreesToRadians(d)     ((d) * M_PI / 180)
#define kLGPlusButtonsViewAssertionWarning(value) [NSString stringWithFormat:@"Number of buttons needs to be equal to numbers of %@", value]
#define kLGPlusButtonsViewIndexAssertionWarning   [NSString stringWithFormat:@"Index is out of buttons range"]

@interface WrapperView : UIView

@property (assign, nonatomic) UIView *actionView;

@end

@implementation WrapperView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    //NSLog(@"\nself = %@\nsuper = %@\nsubviews = %@\nsupersubviews = %@\n\n", self, [super hitTest:point withEvent:event], self.subviews, self.superview.subviews);

    UIView *view = nil;

    if (_actionView)
    {
        CGPoint newPoint = [self convertPoint:point toView:_actionView];

        view = [_actionView hitTest:newPoint withEvent:event];
    }

    return view;
}

@end

#pragma mark -

@interface LGPlusButtonsView ()

typedef NS_ENUM(NSUInteger, LGPlusButtonDescriptionsPosition)
{
    LGPlusButtonDescriptionsPositionLeft  = 0,
    LGPlusButtonDescriptionsPositionRight = 1
};

@property (assign, nonatomic, getter=isObserversAdded) BOOL observersAdded;
@property (assign, nonatomic, getter=isObserversForScrollViewAdded) BOOL observersForScrollViewAdded;

@property (assign, nonatomic) LGPlusButtonDescriptionsPosition descriptionsPosition;

@property (assign, nonatomic) UIView *parentView;

@property (strong, nonatomic) WrapperView *contentView;
@property (strong, nonatomic) WrapperView *buttonsContentView;
@property (strong, nonatomic) UIView *descriptionsContentView;
@property (strong, nonatomic) UIView *coverView;

@property (strong, nonatomic) NSMutableArray *buttonsArray;
@property (strong, nonatomic) NSMutableArray *buttonWrapperViewsArray1;
@property (strong, nonatomic) NSMutableArray *buttonWrapperViewsArray2;

@property (strong, nonatomic) NSMutableArray *descriptionsArray;
@property (strong, nonatomic) NSMutableArray *descriptionWrapperViewsArray;

@property (assign, nonatomic) CGFloat offsetY;
@property (assign, nonatomic) CGFloat tempOffsetY;
@property (assign, nonatomic) CGFloat tempDiff;

@property (strong, nonatomic) NSMutableDictionary *contentEdgeInsetsDictionary;

@property (assign, nonatomic, getter=isFirstButtonIsPlusButton) BOOL firstButtonIsPlusButton;

@property (assign, nonatomic) NSTimeInterval hideAnimationCoef;

@end

@implementation LGPlusButtonsView

- (instancetype)initWithNumberOfButtons:(NSUInteger)numberOfButtons
                firstButtonIsPlusButton:(BOOL)firstButtonIsPlusButton
                          showAfterInit:(BOOL)showAfterInit
{
    self = [super init];
    if (self)
    {
        _appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndSlideVertical;
        _buttonsAppearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndSlideHorizontal;
        _firstButtonIsPlusButton = firstButtonIsPlusButton;
        _scrollSensitivity = 64.f;
        _appearingAnimationSpeed = 0.3;
        _buttonsAppearingAnimationSpeed = 0.3;
        _hideAnimationCoef = 0.66;
        _showHideOnScroll = YES;
        _disableShowHideOnScrollIfContentSizeLessThenFrame = YES;

        // -----

        _contentEdgeInsetsDictionary = [NSMutableDictionary new];

        [self setContentEdgeInsets:UIEdgeInsetsMake(kLGPlusButtonsViewMargin, kLGPlusButtonsViewMargin, kLGPlusButtonsViewMargin, kLGPlusButtonsViewMargin)
                    forOrientation:LGPlusButtonsViewOrientationAll];

        // -----

        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;

        // -----

        _coverView = [UIView new];
        _coverView.backgroundColor = [UIColor clearColor];
        _coverView.userInteractionEnabled = YES;
        [self addSubview:_coverView];

        _contentView = [WrapperView new];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.userInteractionEnabled = YES;
        [self addSubview:_contentView];

        _buttonsContentView = [WrapperView new];
        _buttonsContentView.backgroundColor = [UIColor clearColor];
        _buttonsContentView.userInteractionEnabled = YES;
        [_contentView addSubview:_buttonsContentView];

        _descriptionsContentView = [UIView new];
        _descriptionsContentView.backgroundColor = [UIColor clearColor];
        _descriptionsContentView.userInteractionEnabled = NO;
        [_contentView addSubview:_descriptionsContentView];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [_coverView addGestureRecognizer:tapGesture];

        // -----

        _buttonWrapperViewsArray1 = [NSMutableArray new];
        _buttonWrapperViewsArray2 = [NSMutableArray new];
        _buttonsArray = [NSMutableArray new];

        for (NSUInteger i=0; i<numberOfButtons; i++)
        {
            WrapperView *wrapperView1 = [WrapperView new];
            wrapperView1.backgroundColor = [UIColor clearColor];
            wrapperView1.clipsToBounds = NO;
            wrapperView1.layer.masksToBounds = NO;
            wrapperView1.layer.anchorPoint = CGPointMake(0.5, 0.5);
            wrapperView1.userInteractionEnabled = YES;
            [_buttonsContentView addSubview:wrapperView1];

            [_buttonWrapperViewsArray1 addObject:wrapperView1];

            WrapperView *wrapperView2 = [WrapperView new];
            wrapperView2.backgroundColor = [UIColor clearColor];
            wrapperView2.clipsToBounds = NO;
            wrapperView2.layer.masksToBounds = NO;
            wrapperView2.layer.anchorPoint = CGPointMake(0.5, 0.5);
            wrapperView2.userInteractionEnabled = YES;
            [wrapperView1 addSubview:wrapperView2];

            [_buttonWrapperViewsArray2 addObject:wrapperView2];

            LGPlusButton *button = [LGPlusButton new];
            button.tag = i;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            if (showAfterInit) button.showing = ((firstButtonIsPlusButton && i == 0) || !firstButtonIsPlusButton);
            [wrapperView2 addSubview:button];

            [_buttonsArray addObject:button];

            wrapperView2.actionView = button;
        }

        // -----

        _descriptionWrapperViewsArray = [NSMutableArray new];
        _descriptionsArray = [NSMutableArray new];

        for (NSUInteger i=0; i<_buttonsArray.count; i++)
        {
            UIView *wrapperView = [UIView new];
            wrapperView.backgroundColor = [UIColor clearColor];
            wrapperView.clipsToBounds = NO;
            wrapperView.layer.masksToBounds = NO;
            wrapperView.layer.anchorPoint = CGPointMake(0.5, 0.5);
            wrapperView.userInteractionEnabled = NO;
            [_descriptionsContentView addSubview:wrapperView];

            [_descriptionWrapperViewsArray addObject:wrapperView];

            LGPlusButtonDescription *description = [LGPlusButtonDescription new];
            [wrapperView addSubview:description];

            [_descriptionsArray addObject:description];
        }

        // -----

        _showing = showAfterInit;
        self.hidden = !showAfterInit;
        _coverView.hidden = !(showAfterInit && !firstButtonIsPlusButton);
        _coverView.alpha = (showAfterInit && !firstButtonIsPlusButton ? 1.f : 0.f);
    }
    return self;
}

+ (instancetype)plusButtonsViewWithNumberOfButtons:(NSUInteger)numberOfButtons
                           firstButtonIsPlusButton:(BOOL)firstButtonIsPlusButton
                                     showAfterInit:(BOOL)showAfterInit
{
    return [[self alloc] initWithNumberOfButtons:numberOfButtons
                         firstButtonIsPlusButton:firstButtonIsPlusButton
                                   showAfterInit:showAfterInit];
}

#pragma mark -

- (instancetype)initWithNumberOfButtons:(NSUInteger)numberOfButtons
                firstButtonIsPlusButton:(BOOL)firstButtonIsPlusButton
                          showAfterInit:(BOOL)showAfterInit
                          actionHandler:(void(^)(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index))actionHandler
{
    self = [self initWithNumberOfButtons:numberOfButtons
                 firstButtonIsPlusButton:firstButtonIsPlusButton
                           showAfterInit:showAfterInit];
    if (self)
    {
        _actionHandler = actionHandler;
    }
    return self;
}

+ (instancetype)plusButtonsViewWithNumberOfButtons:(NSUInteger)numberOfButtons
                           firstButtonIsPlusButton:(BOOL)firstButtonIsPlusButton
                                     showAfterInit:(BOOL)showAfterInit
                                     actionHandler:(void(^)(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index))actionHandler
{
    return [[self alloc] initWithNumberOfButtons:numberOfButtons
                         firstButtonIsPlusButton:firstButtonIsPlusButton
                                   showAfterInit:showAfterInit
                                   actionHandler:actionHandler];
}

#pragma mark -

- (instancetype)initWithNumberOfButtons:(NSUInteger)numberOfButtons
                firstButtonIsPlusButton:(BOOL)firstButtonIsPlusButton
                          showAfterInit:(BOOL)showAfterInit
                               delegate:(id<LGPlusButtonsViewDelegate>)delegate
{
    self = [self initWithNumberOfButtons:numberOfButtons
                 firstButtonIsPlusButton:firstButtonIsPlusButton
                           showAfterInit:showAfterInit];
    if (self)
    {
        _delegate = delegate;
    }
    return self;
}

+ (instancetype)plusButtonsViewWithNumberOfButtons:(NSUInteger)numberOfButtons
                           firstButtonIsPlusButton:(BOOL)firstButtonIsPlusButton
                                     showAfterInit:(BOOL)showAfterInit
                                          delegate:(id<LGPlusButtonsViewDelegate>)delegate
{
    return [[self alloc] initWithNumberOfButtons:numberOfButtons
                         firstButtonIsPlusButton:firstButtonIsPlusButton
                                   showAfterInit:showAfterInit
                                        delegate:delegate];
}

#pragma mark - Dealloc

- (void)dealloc
{
#if DEBUG
    NSLog(@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__);
#endif
}

#pragma mark -

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    //NSLog(@"\nself = %@\nsuper = %@\nsubviews = %@\nsupersubviews = %@\n\n", self, [super hitTest:point withEvent:event], self.subviews, self.superview.subviews);

    UIView *view = nil;

    for (LGPlusButton *button in _buttonsArray)
    {
        CGPoint newPoint = [self convertPoint:point toView:button];

        view = [button hitTest:newPoint withEvent:event];
        if (view) break;
    }

    if (!view && _coverColor && !_coverView.isHidden)
    {
        CGPoint newPoint = [self convertPoint:point toView:_coverView];

        view = [_coverView hitTest:newPoint withEvent:event];
    }

    return view;
}

#pragma mark -

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self removeObservers:self.superview];

    if (newSuperview)
        [self addObservers:newSuperview];

    [super willMoveToSuperview:newSuperview];
}

#pragma mark - Setters and Getters

- (void)setCoverColor:(UIColor *)coverColor
{
    _coverColor = coverColor;

    _coverView.backgroundColor = coverColor;
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSString *contentEdgeInsetsString = NSStringFromUIEdgeInsets(contentEdgeInsets);

    [_contentEdgeInsetsDictionary setObject:contentEdgeInsetsString forKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

    if (orientation == LGPlusButtonsViewOrientationAll)
    {
        [_contentEdgeInsetsDictionary setObject:contentEdgeInsetsString forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationPortrait]];
        [_contentEdgeInsetsDictionary setObject:contentEdgeInsetsString forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationLandscape]];
    }

    [self setNeedsLayout];
}

- (UIEdgeInsets)contentEdgeInsetsForOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSString *contentEdgeInsetsString = [_contentEdgeInsetsDictionary objectForKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

    return (contentEdgeInsetsString ? UIEdgeInsetsFromString(contentEdgeInsetsString) : UIEdgeInsetsZero);
}

#pragma mark Buttons all

- (void)setButtonsTitles:(NSArray *)titles forState:(UIControlState)state
{
    NSAssert(_buttonsArray.count == titles.count, kLGPlusButtonsViewAssertionWarning(@"titles"));

    for (NSUInteger i=0; i<_buttonsArray.count; i++)
        if ([titles[i] isKindOfClass:[NSString class]])
            [_buttonsArray[i] setTitle:titles[i] forState:state];

    [self setNeedsLayout];
}

- (void)setButtonsTitleColor:(UIColor *)titleColor forState:(UIControlState)state
{
    for (LGPlusButton *button in _buttonsArray)
        [button setTitleColor:titleColor forState:state];
}

- (void)setButtonsTitleColors:(NSArray *)titleColors forState:(UIControlState)state
{
    NSAssert(_buttonsArray.count == titleColors.count, kLGPlusButtonsViewAssertionWarning(@"title colors"));

    for (NSUInteger i=0; i<_buttonsArray.count; i++)
        if ([titleColors[i] isKindOfClass:[UIColor class]])
            [_buttonsArray[i] setTitleColor:titleColors[i] forState:state];
}

- (void)setButtonsBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state
{
    for (LGPlusButton *button in _buttonsArray)
        [button setBackgroundImage:backgroundImage forState:state];
}

- (void)setButtonsBackgroundImages:(NSArray *)backgroundImages forState:(UIControlState)state
{
    NSAssert(_buttonsArray.count == backgroundImages.count, kLGPlusButtonsViewAssertionWarning(@"background images"));

    for (NSUInteger i=0; i<_buttonsArray.count; i++)
        if ([backgroundImages[i] isKindOfClass:[UIImage class]])
            [_buttonsArray[i] setBackgroundImage:backgroundImages[i] forState:state];
}

- (void)setButtonsBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    for (LGPlusButton *button in _buttonsArray)
        [button setBackgroundColor:backgroundColor forState:state];
}

- (void)setButtonsBackgroundColors:(NSArray *)backgroundColors forState:(UIControlState)state
{
    NSAssert(_buttonsArray.count == backgroundColors.count, kLGPlusButtonsViewAssertionWarning(@"background colors"));

    for (NSUInteger i=0; i<_buttonsArray.count; i++)
        if ([backgroundColors[i] isKindOfClass:[UIColor class]])
            [_buttonsArray[i] setBackgroundColor:backgroundColors[i] forState:state];
}

- (void)setButtonsImage:(UIImage *)image forState:(UIControlState)state forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    for (LGPlusButton *button in _buttonsArray)
        [button setImage:image forState:state forOrientation:orientation];

    [self setNeedsLayout];
}

- (void)setButtonsImages:(NSArray *)images forState:(UIControlState)state forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSAssert(_buttonsArray.count == images.count, kLGPlusButtonsViewAssertionWarning(@"images"));

    for (NSUInteger i=0; i<_buttonsArray.count; i++)
        if ([images[i] isKindOfClass:[UIImage class]])
            [_buttonsArray[i] setImage:images[i] forState:state forOrientation:orientation];

    [self setNeedsLayout];
}

#pragma mark //

- (void)setButtonsTitleFont:(UIFont *)font forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    for (LGPlusButton *button in _buttonsArray)
        [button setTitleFont:font forOrientation:orientation];

    [self setNeedsLayout];
}

- (void)setButtonsInsets:(UIEdgeInsets)insets forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    for (LGPlusButton *button in _buttonsArray)
        [button setInsets:insets forOrientation:orientation];

    [self setNeedsLayout];
}

- (void)setButtonsOffset:(CGPoint)offset forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    for (LGPlusButton *button in _buttonsArray)
        [button setOffset:offset forOrientation:orientation];

    [self setNeedsLayout];
}

- (void)setButtonsSize:(CGSize)size forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    for (LGPlusButton *button in _buttonsArray)
        [button setSize:size forOrientation:orientation];

    [self setNeedsLayout];
}

- (void)setButtonsContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    for (LGPlusButton *button in _buttonsArray)
        [button setContentEdgeInsets:contentEdgeInsets forOrientation:orientation];
}

- (void)setButtonsTitleOffset:(CGPoint)titleOffset forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    for (LGPlusButton *button in _buttonsArray)
        [button setTitleOffset:titleOffset forOrientation:orientation];
}

- (void)setButtonsImageOffset:(CGPoint)imageOffset forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    for (LGPlusButton *button in _buttonsArray)
        [button setImageOffset:imageOffset forOrientation:orientation];
}

#pragma mark //

- (void)setButtonsImageViewContentMode:(UIViewContentMode)contentMode
{
    for (LGPlusButton *button in _buttonsArray)
        button.imageView.contentMode = contentMode;
}

- (void)setButtonsClipsToBounds:(BOOL)clipsToBounds
{
    for (LGPlusButton *button in _buttonsArray)
        button.clipsToBounds = clipsToBounds;
}

- (void)setButtonsAdjustsImageWhenHighlighted:(BOOL)adjustsImageWhenHighlighted
{
    for (LGPlusButton *button in _buttonsArray)
        button.adjustsImageWhenHighlighted = adjustsImageWhenHighlighted;
}

- (void)setButtonsAdjustsImageWhenDisabled:(BOOL)adjustsImageWhenDisabled
{
    for (LGPlusButton *button in _buttonsArray)
        button.adjustsImageWhenDisabled = adjustsImageWhenDisabled;
}

- (void)setButtonsEnabled:(BOOL)enabled
{
    for (LGPlusButton *button in _buttonsArray)
        button.enabled = enabled;
}

#pragma mark //

- (void)setButtonsLayerCornerRadius:(CGFloat)cornerRadius forOrientation:(LGPlusButtonsViewOrientation)orientation;
{
    for (LGPlusButton *button in _buttonsArray)
        [button setLayerCornerRadius:cornerRadius forOrientation:orientation];
}

- (void)setButtonsLayerBorderColor:(UIColor *)borderColor
{
    for (LGPlusButton *button in _buttonsArray)
        button.layer.borderColor = borderColor.CGColor;
}

- (void)setButtonsLayerBorderWidth:(CGFloat)borderWidth
{
    for (LGPlusButton *button in _buttonsArray)
        button.layer.borderWidth = borderWidth;
}

- (void)setButtonsLayerShadowColor:(UIColor *)shadowColor
{
    _buttonsContentView.layer.shadowColor = shadowColor.CGColor;
}

- (void)setButtonsLayerShadowRadius:(CGFloat)shadowRadius
{
    _buttonsContentView.layer.shadowRadius = shadowRadius;
}

- (void)setButtonsLayerShadowOpacity:(CGFloat)shadowOpacity
{
    _buttonsContentView.layer.shadowOpacity = shadowOpacity;
}

- (void)setButtonsLayerShadowOffset:(CGSize)shadowOffset
{
    _buttonsContentView.layer.shadowOffset = shadowOffset;
}

#pragma mark Button at index

- (void)setButtonAtIndex:(NSUInteger)index title:(NSString *)title forState:(UIControlState)state
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] setTitle:title forState:state];

    [self setNeedsLayout];
}

- (void)setButtonAtIndex:(NSUInteger)index titleColor:(UIColor *)titleColor forState:(UIControlState)state
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] setTitleColor:titleColor forState:state];
}

- (void)setButtonAtIndex:(NSUInteger)index backgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] setBackgroundImage:backgroundImage forState:state];
}

- (void)setButtonAtIndex:(NSUInteger)index backgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] setBackgroundColor:backgroundColor forState:state];
}

- (void)setButtonAtIndex:(NSUInteger)index image:(UIImage *)image forState:(UIControlState)state forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] setImage:image forState:state forOrientation:orientation];

    [self setNeedsLayout];
}

#pragma mark //

- (void)setButtonAtIndex:(NSUInteger)index titleFont:(UIFont *)font forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] setTitleFont:font forOrientation:orientation];

    [self setNeedsLayout];
}

- (void)setButtonAtIndex:(NSUInteger)index insets:(UIEdgeInsets)insets forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] setInsets:insets forOrientation:orientation];

    [self setNeedsLayout];
}

- (void)setButtonAtIndex:(NSUInteger)index offset:(CGPoint)offset forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] setOffset:offset forOrientation:orientation];

    [self setNeedsLayout];
}

- (void)setButtonAtIndex:(NSUInteger)index size:(CGSize)size forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] setSize:size forOrientation:orientation];

    [self setNeedsLayout];
}

- (void)setButtonAtIndex:(NSUInteger)index contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] setContentEdgeInsets:contentEdgeInsets forOrientation:orientation];
}

- (void)setButtonAtIndex:(NSUInteger)index titleOffset:(CGPoint)titleOffset forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] setTitleOffset:titleOffset forOrientation:orientation];
}

- (void)setButtonAtIndex:(NSUInteger)index imageOffset:(CGPoint)imageOffset forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] setImageOffset:imageOffset forOrientation:orientation];
}

#pragma mark //

- (void)setButtonAtIndex:(NSUInteger)index imageViewContentMode:(UIViewContentMode)contentMode
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] imageView].contentMode = contentMode;
}

- (void)setButtonAtIndex:(NSUInteger)index clipsToBounds:(BOOL)clipsToBounds
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] setClipsToBounds:clipsToBounds];
}

- (void)setButtonAtIndex:(NSUInteger)index adjustsImageWhenHighlighted:(BOOL)adjustsImageWhenHighlighted
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] setAdjustsImageWhenHighlighted:adjustsImageWhenHighlighted];
}

- (void)setButtonAtIndex:(NSUInteger)index adjustsImageWhenDisabled:(BOOL)adjustsImageWhenDisabled
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] setAdjustsImageWhenDisabled:adjustsImageWhenDisabled];
}

- (void)setButtonAtIndex:(NSUInteger)index enabled:(BOOL)enabled
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] setEnabled:enabled];
}

#pragma mark //

- (void)setButtonAtIndex:(NSUInteger)index layerCornerRadius:(CGFloat)cornerRadius forOrientation:(LGPlusButtonsViewOrientation)orientation;
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] setLayerCornerRadius:cornerRadius forOrientation:orientation];
}

- (void)setButtonAtIndex:(NSUInteger)index layerBorderColor:(UIColor *)borderColor
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] layer].borderColor = borderColor.CGColor;
}

- (void)setButtonAtIndex:(NSUInteger)index layerBorderWidth:(CGFloat)borderWidth
{
    NSAssert(_buttonsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_buttonsArray[index] layer].borderWidth = borderWidth;
}

#pragma mark Descriptions all

- (void)setDescriptionsTexts:(NSArray *)texts
{
    NSAssert(_descriptionsArray.count == texts.count, kLGPlusButtonsViewAssertionWarning(@"texts"));

    for (NSUInteger i=0; i<_descriptionsArray.count; i++)
        [_descriptionsArray[i] setText:texts[i]];

    [self setNeedsLayout];
}

- (void)setDescriptionsTextColor:(UIColor *)textColor
{
    for (LGPlusButtonDescription *description in _descriptionsArray)
        description.textColor = textColor;
}

- (void)setDescriptionsBackgroundColor:(UIColor *)backgroundColor
{
    for (LGPlusButtonDescription *description in _descriptionsArray)
        description.backgroundColor = backgroundColor;
}

#pragma mark //

- (void)setDescriptionsFont:(UIFont *)font forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    for (LGPlusButtonDescription *description in _descriptionsArray)
        [description setFont:font forOrientation:orientation];
}

- (void)setDescriptionsInsets:(UIEdgeInsets)insets forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    for (LGPlusButtonDescription *description in _descriptionsArray)
        [description setInsets:insets forOrientation:orientation];
}

- (void)setDescriptionsOffset:(CGPoint)offset forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    for (LGPlusButtonDescription *description in _descriptionsArray)
        [description setOffset:offset forOrientation:orientation];
}

- (void)setDescriptionsSize:(CGSize)size forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    for (LGPlusButtonDescription *description in _descriptionsArray)
        [description setSize:size forOrientation:orientation];
}

- (void)setDescriptionsContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    for (LGPlusButtonDescription *description in _descriptionsArray)
        [description setContentEdgeInsets:contentEdgeInsets forOrientation:orientation];
}

#pragma mark //

- (void)setDescriptionsLayerCornerRadius:(CGFloat)cornerRadius forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    for (LGPlusButtonDescription *description in _descriptionsArray)
        [description setLayerCornerRadius:cornerRadius forOrientation:orientation];
}

- (void)setDescriptionsLayerBorderColor:(UIColor *)borderColor
{
    for (LGPlusButtonDescription *description in _descriptionsArray)
        description.layer.borderColor = borderColor.CGColor;
}

- (void)setDescriptionsLayerBorderWidth:(CGFloat)borderWidth
{
    for (LGPlusButtonDescription *description in _descriptionsArray)
        description.layer.borderWidth = borderWidth;
}

- (void)setDescriptionsLayerShadowColor:(UIColor *)shadowColor
{
    _descriptionsContentView.layer.shadowColor = shadowColor.CGColor;
}

- (void)setDescriptionsLayerShadowRadius:(CGFloat)shadowRadius
{
    _descriptionsContentView.layer.shadowRadius = shadowRadius;
}

- (void)setDescriptionsLayerShadowOpacity:(CGFloat)shadowOpacity
{
    _descriptionsContentView.layer.shadowOpacity = shadowOpacity;
}

- (void)setDescriptionsLayerShadowOffset:(CGSize)shadowOffset
{
    _descriptionsContentView.layer.shadowOffset = shadowOffset;
}

#pragma mark Description at index

- (void)setDescriptionAtIndex:(NSUInteger)index text:(NSString *)text
{
    NSAssert(_descriptionsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_descriptionsArray[index] setText:text];

    [self setNeedsLayout];
}

- (void)setDescriptionAtIndex:(NSUInteger)index textColor:(UIColor *)textColor
{
    NSAssert(_descriptionsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_descriptionsArray[index] setTextColor:textColor];
}

- (void)setDescriptionAtIndex:(NSUInteger)index backgroundColor:(UIColor *)backgroundColor
{
    NSAssert(_descriptionsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_descriptionsArray[index] setBackgroundColor:backgroundColor];
}

#pragma mark //

- (void)setDescriptionAtIndex:(NSUInteger)index font:(UIFont *)font forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSAssert(_descriptionsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_descriptionsArray[index] setFont:font forOrientation:orientation];
}

- (void)setDescriptionAtIndex:(NSUInteger)index insets:(UIEdgeInsets)insets forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSAssert(_descriptionsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_descriptionsArray[index] setInsets:insets forOrientation:orientation];
}

- (void)setDescriptionAtIndex:(NSUInteger)index offset:(CGPoint)offset forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSAssert(_descriptionsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_descriptionsArray[index] setOffset:offset forOrientation:orientation];
}

- (void)setDescriptionAtIndex:(NSUInteger)index size:(CGSize)size forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSAssert(_descriptionsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_descriptionsArray[index] setSize:size forOrientation:orientation];
}

- (void)setDescriptionAtIndex:(NSUInteger)index contentEdgeInsets:(UIEdgeInsets)contentEdgeInsets forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSAssert(_descriptionsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_descriptionsArray[index] setContentEdgeInsets:contentEdgeInsets forOrientation:orientation];
}

#pragma mark //

- (void)setDescriptionAtIndex:(NSUInteger)index layerCornerRadius:(CGFloat)cornerRadius forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSAssert(_descriptionsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_descriptionsArray[index] setLayerCornerRadius:cornerRadius forOrientation:orientation];
}

- (void)setDescriptionAtIndex:(NSUInteger)index layerBorderColor:(UIColor *)borderColor
{
    NSAssert(_descriptionsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_descriptionsArray[index] layer].borderColor = borderColor.CGColor;
}

- (void)setDescriptionAtIndex:(NSUInteger)index layerBorderWidth:(CGFloat)borderWidth
{
    NSAssert(_descriptionsArray.count > index, kLGPlusButtonsViewIndexAssertionWarning);

    [_descriptionsArray[index] layer].borderWidth = borderWidth;
}

#pragma mark - View

- (void)setPosition:(LGPlusButtonsViewPosition)position
{
    _position = position;

    if (_position == LGPlusButtonsViewPositionBottomRight || _position == LGPlusButtonsViewPositionTopRight)
        _descriptionsPosition = LGPlusButtonDescriptionsPositionLeft;
    else
        _descriptionsPosition = LGPlusButtonDescriptionsPositionRight;

    [self setNeedsLayout];
}

- (void)setOffset:(CGPoint)offset
{
    _offset = offset;

    [self setNeedsLayout];
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];

    // -----

    LGPlusButtonsViewOrientation orientation = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationLandscape;

    // -----

    UIEdgeInsets parentInset = UIEdgeInsetsZero;
    CGPoint parentOffset = CGPointZero;

    if ([self.superview isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *parentScrollView = (UIScrollView *)self.superview;

        parentInset = parentScrollView.contentInset;
        parentOffset = parentScrollView.contentOffset;
    }

    // -----

    CGRect selfFrame = CGRectMake(parentOffset.x, parentOffset.y, self.superview.bounds.size.width, self.superview.bounds.size.height);
    if ([UIScreen mainScreen].scale == 1.f)
        selfFrame = CGRectIntegral(selfFrame);
    self.frame = selfFrame;

    _coverView.frame = CGRectMake(0.f, 0.f, selfFrame.size.width, selfFrame.size.height);

    // -----

    CGSize buttonsContentViewSize = CGSizeZero;

    for (LGPlusButton *button in _buttonsArray)
    {
        [button updateParametersForOrientation:orientation];

        if (CGSizeEqualToSize([button sizeForOrientation:orientation], CGSizeZero))
        {
            CGSize size = [button sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];

            [button setSize:size forOrientation:orientation];
        }

        CGSize buttonSize = [button sizeForOrientation:orientation];
        UIEdgeInsets buttonInsets = [button insetsForOrientation:orientation];

        buttonsContentViewSize.width = MAX(buttonsContentViewSize.width, buttonSize.width + buttonInsets.left + buttonInsets.right);
        buttonsContentViewSize.height += [button sizeForOrientation:orientation].height + buttonInsets.top + buttonInsets.bottom;
    }

    // -----

    UIEdgeInsets contentEdgeInsets = [self contentEdgeInsetsForOrientation:orientation];

    CGRect contentViewFrame = CGRectMake(parentInset.left+contentEdgeInsets.left,
                                         parentInset.top+contentEdgeInsets.top,
                                         selfFrame.size.width-parentInset.left-parentInset.right-contentEdgeInsets.left-contentEdgeInsets.right,
                                         selfFrame.size.height-parentInset.top-parentInset.bottom-contentEdgeInsets.top-contentEdgeInsets.bottom);
    if ([UIScreen mainScreen].scale == 1.f)
        contentViewFrame = CGRectIntegral(contentViewFrame);
    _contentView.frame = contentViewFrame;

    // -----

    CGPoint buttonsContentViewOrigin = CGPointZero;
    if (_position == LGPlusButtonsViewPositionBottomRight)
        buttonsContentViewOrigin = CGPointMake(contentViewFrame.size.width-buttonsContentViewSize.width, contentViewFrame.size.height-buttonsContentViewSize.height);
    else if (_position == LGPlusButtonsViewPositionBottomLeft)
        buttonsContentViewOrigin = CGPointMake(0.f, contentViewFrame.size.height-buttonsContentViewSize.height);
    else if (_position == LGPlusButtonsViewPositionTopRight)
        buttonsContentViewOrigin = CGPointMake(contentViewFrame.size.width-buttonsContentViewSize.width, 0.f);
    else if (_position == LGPlusButtonsViewPositionTopLeft)
        buttonsContentViewOrigin = CGPointMake(0.f, 0.f);

    buttonsContentViewOrigin.x += _offset.x;
    buttonsContentViewOrigin.y += _offset.y;

    CGRect buttonsContentViewFrame = CGRectMake(buttonsContentViewOrigin.x, buttonsContentViewOrigin.y, buttonsContentViewSize.width, buttonsContentViewSize.height);
    if ([UIScreen mainScreen].scale == 1.f)
        buttonsContentViewFrame = CGRectIntegral(buttonsContentViewFrame);
    _buttonsContentView.frame = buttonsContentViewFrame;

    // -----

    CGRect descriptionsContentViewFrame = CGRectZero;

    if (_descriptionsPosition == LGPlusButtonDescriptionsPositionLeft)
        descriptionsContentViewFrame = CGRectMake(0.f,
                                                  buttonsContentViewFrame.origin.y,
                                                  contentViewFrame.size.width-buttonsContentViewFrame.size.width,
                                                  buttonsContentViewFrame.size.height);
    else
        descriptionsContentViewFrame = CGRectMake(buttonsContentViewFrame.origin.x+buttonsContentViewFrame.size.width,
                                                  buttonsContentViewFrame.origin.y,
                                                  contentViewFrame.size.width-(buttonsContentViewFrame.origin.x+buttonsContentViewFrame.size.width),
                                                  buttonsContentViewFrame.size.height);

    if ([UIScreen mainScreen].scale == 1.f)
        descriptionsContentViewFrame = CGRectIntegral(descriptionsContentViewFrame);
    _descriptionsContentView.frame = descriptionsContentViewFrame;

    // -----

    for (NSUInteger i=0; i<_buttonsArray.count; i++)
    {
        WrapperView *buttonWrapperView1 = _buttonWrapperViewsArray1[i];
        WrapperView *buttonWrapperView2 = _buttonWrapperViewsArray2[i];
        LGPlusButton *button = _buttonsArray[i];

        CGSize buttonSize = [button sizeForOrientation:orientation];
        UIEdgeInsets buttonInsets = [button insetsForOrientation:orientation];
        CGPoint buttonOffset = [button offsetForOrientation:orientation];

        CGRect buttonFrame = CGRectZero;

        if (i == 0)
        {
            if (_position == LGPlusButtonsViewPositionBottomRight)
                buttonFrame = CGRectMake(buttonsContentViewSize.width-buttonInsets.right-buttonSize.width,
                                         buttonsContentViewFrame.size.height-buttonInsets.bottom-buttonSize.height,
                                         buttonSize.width,
                                         buttonSize.height);
            else if (_position == LGPlusButtonsViewPositionBottomLeft)
                buttonFrame = CGRectMake(buttonInsets.left,
                                         buttonsContentViewFrame.size.height-buttonInsets.bottom-buttonSize.height,
                                         buttonSize.width,
                                         buttonSize.height);
            else if (_position == LGPlusButtonsViewPositionTopRight)
                buttonFrame = CGRectMake(buttonsContentViewSize.width-buttonInsets.right-buttonSize.width,
                                         buttonInsets.top,
                                         buttonSize.width,
                                         buttonSize.height);
            else if (_position == LGPlusButtonsViewPositionTopLeft)
                buttonFrame = CGRectMake(buttonInsets.left,
                                         buttonInsets.top,
                                         buttonSize.width,
                                         buttonSize.height);
        }
        else
        {
            CGRect previousWrapperFrame = [_buttonWrapperViewsArray1[i-1] frame];

            if (_position == LGPlusButtonsViewPositionBottomRight)
                buttonFrame = CGRectMake(buttonsContentViewSize.width-buttonInsets.right-buttonSize.width,
                                         previousWrapperFrame.origin.y-buttonInsets.top-buttonInsets.bottom-buttonSize.height,
                                         buttonSize.width,
                                         buttonSize.height);
            else if (_position == LGPlusButtonsViewPositionBottomLeft)
                buttonFrame = CGRectMake(buttonInsets.left,
                                         previousWrapperFrame.origin.y-buttonInsets.top-buttonInsets.bottom-buttonSize.height,
                                         buttonSize.width,
                                         buttonSize.height);
            else if (_position == LGPlusButtonsViewPositionTopRight)
                buttonFrame = CGRectMake(buttonsContentViewSize.width-buttonInsets.right-buttonSize.width,
                                         previousWrapperFrame.origin.y+previousWrapperFrame.size.height+buttonInsets.bottom+buttonInsets.top,
                                         buttonSize.width,
                                         buttonSize.height);
            else if (_position == LGPlusButtonsViewPositionTopLeft)
                buttonFrame = CGRectMake(buttonInsets.left,
                                         previousWrapperFrame.origin.y+previousWrapperFrame.size.height+buttonInsets.bottom+buttonInsets.top,
                                         buttonSize.width,
                                         buttonSize.height);
        }

        buttonFrame.origin.x += buttonOffset.x;
        buttonFrame.origin.y += buttonOffset.y;

        if ([UIScreen mainScreen].scale == 1.f)
            buttonFrame = CGRectIntegral(buttonFrame);

        buttonWrapperView1.transform = CGAffineTransformIdentity;
        buttonWrapperView1.frame = buttonFrame;

        buttonWrapperView2.frame = CGRectMake(buttonWrapperView1.frame.size.width/2, buttonWrapperView1.frame.size.height/2, 0.f, 0.f);

        button.frame = CGRectMake(-buttonWrapperView1.frame.size.width/2, -buttonWrapperView1.frame.size.height/2, buttonWrapperView1.frame.size.width, buttonWrapperView1.frame.size.height);
    }

    // -----

    for (NSUInteger i=0; i<_descriptionsArray.count; i++)
    {
        WrapperView *buttonWrapperView1 = _buttonWrapperViewsArray1[i];
        LGPlusButton *button = _buttonsArray[i];

        CGSize buttonSize = [button sizeForOrientation:orientation];
        UIEdgeInsets buttonInsets = [button insetsForOrientation:orientation];

        UIView *descriptionWrapperView = _descriptionWrapperViewsArray[i];
        LGPlusButtonDescription *description = _descriptionsArray[i];

        description.textAlignment = (_descriptionsPosition == LGPlusButtonDescriptionsPositionLeft ? NSTextAlignmentRight : NSTextAlignmentLeft);
        [description updateParametersForOrientation:orientation];

        UIEdgeInsets descriptionInsets = [description insetsForOrientation:orientation];
        CGPoint descriptionOffset = [description offsetForOrientation:orientation];

        if (description.text.length)
        {
            if (CGSizeEqualToSize([description sizeForOrientation:orientation], CGSizeZero))
            {
                CGSize size = [description sizeThatFits:CGSizeMake(descriptionsContentViewFrame.size.width, CGFLOAT_MAX)];

                [description setSize:size forOrientation:orientation];
            }

            CGSize descriptionSize = [description sizeForOrientation:orientation];

            descriptionWrapperView.transform = CGAffineTransformIdentity;
            CGRect descriptionWrapperViewFrame = buttonWrapperView1.frame;

            CGRect descriptionFrame = CGRectZero;

            if (_descriptionsPosition == LGPlusButtonDescriptionsPositionLeft)
            {
                descriptionWrapperViewFrame.origin.x = descriptionsContentViewFrame.size.width+buttonInsets.left;
                descriptionWrapperView.frame = descriptionWrapperViewFrame;

                descriptionFrame = CGRectMake(-buttonInsets.left-descriptionInsets.right-descriptionSize.width,
                                              descriptionWrapperView.frame.size.height/2.f-descriptionSize.height/2.f,
                                              descriptionSize.width,
                                              descriptionSize.height);
            }
            else
            {
                descriptionWrapperViewFrame.origin.x = -buttonSize.width-buttonInsets.right;
                descriptionWrapperView.frame = descriptionWrapperViewFrame;

                descriptionFrame = CGRectMake(descriptionWrapperView.frame.size.width+buttonInsets.right+descriptionInsets.left,
                                              descriptionWrapperView.frame.size.height/2.f-descriptionSize.height/2.f,
                                              descriptionSize.width,
                                              descriptionSize.height);
            }

            descriptionFrame.origin.x += descriptionOffset.x;
            descriptionFrame.origin.y += descriptionOffset.y;

            if ([UIScreen mainScreen].scale == 1.f)
                descriptionFrame = CGRectIntegral(descriptionFrame);

            description.frame = descriptionFrame;

        }
        else
        {
            descriptionWrapperView.transform = CGAffineTransformIdentity;
            descriptionWrapperView.frame = CGRectZero;

            description.frame = CGRectZero;
        }
    }

    // -----

    for (NSUInteger i=0; i<_buttonsArray.count; i++)
    {
        WrapperView *buttonWrapperView1 = _buttonWrapperViewsArray1[i];
        LGPlusButton *button = _buttonsArray[i];

        if (CGAffineTransformEqualToTransform(buttonWrapperView1.transform, CGAffineTransformIdentity) && button.frame.size.width > 1.f && button.frame.size.height > 1.f)
        {
            LGPlusButtonsAppearingAnimationType animationType = NSNotFound;

            if (!self.isShowing)
            {
                if (self.isFirstButtonIsPlusButton)
                {
                    if (i == 0)
                        animationType = _appearingAnimationType;
                    else
                    {
                        if (button.isShowing)
                            animationType = _appearingAnimationType;
                        else
                            animationType = _buttonsAppearingAnimationType;
                    }
                }
                else
                {
                    if (!button.isShowing)
                        animationType = _appearingAnimationType;
                }
            }
            else
            {
                if (self.isFirstButtonIsPlusButton)
                {
                    if (!button.isShowing)
                        animationType = _buttonsAppearingAnimationType;
                }
            }

            if (animationType != NSNotFound)
                [self hideAnimationsWithButtonAtIndex:i animationType:animationType];
        }
    }
}

- (void)updatePosition
{
    UIScrollView *parentScrollView = (UIScrollView *)self.superview;

    CGPoint parentOffset = parentScrollView.contentOffset;

    self.center = CGPointMake(parentOffset.x+parentScrollView.frame.size.width/2.f, parentOffset.y+parentScrollView.frame.size.height/2);
}

#pragma mark - Actions

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    if (self.isFirstButtonIsPlusButton)
        [self hideButtonsAnimated:YES completionHandler:nil];
    else
        [self hideAnimated:YES completionHandler:nil];
}

- (void)buttonAction:(LGPlusButton *)button
{
    NSUInteger index = button.tag;

    LGPlusButtonDescription *description = _descriptionsArray[index];

    if (self.isFirstButtonIsPlusButton && index == 0)
    {
        if (button.isSelected)
            [self hideButtonsAnimated:YES completionHandler:nil];
        else
            [self showButtonsAnimated:YES completionHandler:nil];
    }

    // -----

    if (_actionHandler) _actionHandler(self, button.titleLabel.text, description.text, button.tag);

    if (_delegate && [_delegate respondsToSelector:@selector(plusButtonsView:buttonPressedWithTitle:description:index:)])
        [_delegate plusButtonsView:self buttonPressedWithTitle:button.titleLabel.text description:description.text index:button.tag];

    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if (button.titleLabel.text)
        [userInfo setObject:button.titleLabel.text forKey:@"title"];
    if (description.text)
        [userInfo setObject:description.text forKey:@"description"];
    if (button.tag != NSNotFound)
        [userInfo setObject:[NSNumber numberWithInteger:button.tag] forKey:@"index"];

    [[NSNotificationCenter defaultCenter] postNotificationName:kLGPlusButtonsViewActionNotification object:self userInfo:userInfo];
}

#pragma mark - Animations

- (void)showAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    if (!self.isShowing)
    {
        _showing = YES;
        self.hidden = NO;

        // -----

        if (_willShowHandler) _willShowHandler(self);

        if (_delegate && [_delegate respondsToSelector:@selector(plusButtonsViewWillShow:)])
            [_delegate plusButtonsViewWillShow:self];

        [[NSNotificationCenter defaultCenter] postNotificationName:kLGPlusButtonsViewWillShowNotification object:self userInfo:nil];

        // -----

        NSTimeInterval delay = _appearingAnimationSpeed/10.f;

        for (NSInteger i=0; i<_buttonsArray.count; i++)
        {
            LGPlusButton *button = _buttonsArray[i];

            if (!self.isFirstButtonIsPlusButton ||
                (self.isFirstButtonIsPlusButton && (i == 0  || (i > 0 && button.isShowing))))
            {
                if (!self.isFirstButtonIsPlusButton ||
                    (self.isFirstButtonIsPlusButton && i == 0))
                    button.showing = YES;

                __block NSUInteger index = i;

                [self showButtonAtIndex:i
                          animationType:_appearingAnimationType
                                  delay:delay*i
                         animationSpeed:_appearingAnimationSpeed
                               animated:animated
                      completionHandler:^(BOOL result)
                 {
                     if (result && index == _buttonsArray.count-1)
                     {
                         if (completionHandler) completionHandler();

                         // -----

                         if (_didShowHandler) _didShowHandler(self);

                         if (_delegate && [_delegate respondsToSelector:@selector(plusButtonsViewDidShow:)])
                             [_delegate plusButtonsViewDidShow:self];

                         [[NSNotificationCenter defaultCenter] postNotificationName:kLGPlusButtonsViewDidShowNotification object:self userInfo:nil];
                     }
                 }];
            }
        }

        if (!self.isFirstButtonIsPlusButton)
            [self showCoverViewAnimated:animated
                          animationType:_appearingAnimationType];
    }
}

- (void)hideAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    if (self.isShowing)
    {
        _showing = NO;

        // -----

        if (_willHideHandler) _willHideHandler(self);

        if (_delegate && [_delegate respondsToSelector:@selector(plusButtonsViewWillHide:)])
            [_delegate plusButtonsViewWillHide:self];

        [[NSNotificationCenter defaultCenter] postNotificationName:kLGPlusButtonsViewWillHideNotification object:self userInfo:nil];

        // -----

        NSTimeInterval delay = _appearingAnimationSpeed/10.f;

        for (NSInteger i=0; i<_buttonsArray.count; i++)
        {
            LGPlusButton *button = _buttonsArray[i];

            if (!self.isFirstButtonIsPlusButton ||
                (self.isFirstButtonIsPlusButton && (i == 0  || (i > 0 && button.isShowing))))
            {
                if (!self.isFirstButtonIsPlusButton ||
                    (self.isFirstButtonIsPlusButton && i == 0))
                    button.showing = NO;

                __block NSUInteger index = i;

                [self hideButtonAtIndex:i
                          animationType:_appearingAnimationType
                                  delay:delay*i
                         animationSpeed:_appearingAnimationSpeed
                               animated:animated
                      completionHandler:^(BOOL result)
                 {
                     if (result && index == _buttonsArray.count-1)
                     {
                         self.hidden = YES;

                         if (completionHandler) completionHandler();

                         // -----

                         if (_didHideHandler) _didHideHandler(self);

                         if (_delegate && [_delegate respondsToSelector:@selector(plusButtonsViewDidHide:)])
                             [_delegate plusButtonsViewDidHide:self];

                         [[NSNotificationCenter defaultCenter] postNotificationName:kLGPlusButtonsViewDidHideNotification object:self userInfo:nil];
                     }
                 }];
            }
        }

        if (!self.isFirstButtonIsPlusButton)
            [self hideCoverViewAnimated:animated
                          animationType:_appearingAnimationType];
    }
}

#pragma mark -

- (void)showButtonsAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    if (self.isFirstButtonIsPlusButton)
    {
        LGPlusButton *plusButton = _buttonsArray[0];
        plusButton.selected = YES;

        [self selectPlusButtonViewWithAnimationType:_plusButtonAnimationType
                                           animated:animated
                                  completionHandler:nil];

        // -----

        if (_willShowButtonsHandler) _willShowButtonsHandler(self);

        if (_delegate && [_delegate respondsToSelector:@selector(plusButtonsViewWillShowButtons:)])
            [_delegate plusButtonsViewWillShowButtons:self];

        [[NSNotificationCenter defaultCenter] postNotificationName:kLGPlusButtonsViewWillShowButtonsNotification object:self userInfo:nil];

        // -----

        NSTimeInterval delay = _buttonsAppearingAnimationSpeed/10.f;

        for (NSInteger i=1; i<_buttonsArray.count; i++)
        {
            LGPlusButton *button = _buttonsArray[i];

            if (!button.isShowing)
            {
                button.showing = YES;

                __block NSUInteger index = i;

                [self showButtonAtIndex:i
                          animationType:_buttonsAppearingAnimationType
                                  delay:delay*(i-1)
                         animationSpeed:_buttonsAppearingAnimationSpeed
                               animated:animated
                      completionHandler:^(BOOL result)
                 {
                     if (result && index == _buttonsArray.count)
                     {
                         if (completionHandler) completionHandler();

                         // -----

                         if (_didShowButtonsHandler) _didShowButtonsHandler(self);

                         if (_delegate && [_delegate respondsToSelector:@selector(plusButtonsViewDidShowButtons:)])
                             [_delegate plusButtonsViewDidShowButtons:self];

                         [[NSNotificationCenter defaultCenter] postNotificationName:kLGPlusButtonsViewDidShowButtonsNotification object:self userInfo:nil];
                     }
                 }];
            }
        }

        [self showCoverViewAnimated:animated
                      animationType:_buttonsAppearingAnimationType];
    }
}

- (void)hideButtonsAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    if (self.isFirstButtonIsPlusButton)
    {
        LGPlusButton *plusButton = _buttonsArray[0];
        plusButton.selected = NO;

        [self deselectPlusButtonViewWithAnimationType:_plusButtonAnimationType
                                             animated:animated
                                    completionHandler:nil];

        // -----

        if (_willHideButtonsHandler) _willHideButtonsHandler(self);

        if (_delegate && [_delegate respondsToSelector:@selector(plusButtonsViewWillHideButtons:)])
            [_delegate plusButtonsViewWillHideButtons:self];

        [[NSNotificationCenter defaultCenter] postNotificationName:kLGPlusButtonsViewWillHideButtonsNotification object:self userInfo:nil];

        // -----

        NSTimeInterval delay = _buttonsAppearingAnimationSpeed/10.f;

        for (NSInteger i=1; i<_buttonsArray.count; i++)
        {
            LGPlusButton *button = _buttonsArray[i];

            if (button.isShowing)
            {
                button.showing = NO;

                __block NSUInteger index = i;

                [self hideButtonAtIndex:i
                          animationType:_buttonsAppearingAnimationType
                                  delay:delay*(i-1)
                         animationSpeed:_buttonsAppearingAnimationSpeed
                               animated:animated
                      completionHandler:^(BOOL result)
                 {
                     if (result && index == _buttonsArray.count)
                     {
                         if (completionHandler) completionHandler();

                         // -----

                         if (_didHideButtonsHandler) _didHideButtonsHandler(self);

                         if (_delegate && [_delegate respondsToSelector:@selector(plusButtonsViewDidHideButtons:)])
                             [_delegate plusButtonsViewDidHideButtons:self];

                         [[NSNotificationCenter defaultCenter] postNotificationName:kLGPlusButtonsViewDidHideButtonsNotification object:self userInfo:nil];
                     }
                 }];
            }
        }

        [self hideCoverViewAnimated:animated
                      animationType:_buttonsAppearingAnimationType];
    }
}

#pragma mark - Cover View Animations

- (void)showCoverViewAnimated:(BOOL)animated
                animationType:(LGPlusButtonsAppearingAnimationType)type
{
    if (_coverColor && ![_coverColor isEqual:[UIColor clearColor]])
    {
        _coverView.hidden = NO;

        if ([self.superview isKindOfClass:[UIScrollView class]])
            [(UIScrollView *)self.superview setScrollEnabled:NO];

        _coverView.alpha = [(CALayer *)_coverView.layer.presentationLayer opacity];
        [_coverView.layer removeAllAnimations];

        if (!animated || type == LGPlusButtonsAppearingAnimationTypeNone)
        {
            _coverView.alpha = 1.f;
        }
        else
        {
            NSTimeInterval animationSpeed = (self.isFirstButtonIsPlusButton ? _appearingAnimationSpeed : _buttonsAppearingAnimationSpeed);
            CGFloat dif = 1.f-_coverView.alpha;
            NSTimeInterval duration = animationSpeed*dif;

            [LGPlusButtonsView animateStandardWithDuration:duration
                                                     delay:0.f
                                                animations:^(void)
             {
                 _coverView.alpha = 1.f;
             }
                                                completion:nil];
        }
    }
}

- (void)hideCoverViewAnimated:(BOOL)animated
                animationType:(LGPlusButtonsAppearingAnimationType)type
{
    if (_coverColor && ![_coverColor isEqual:[UIColor clearColor]])
    {
        _coverView.alpha = [(CALayer *)_coverView.layer.presentationLayer opacity];
        [_coverView.layer removeAllAnimations];

        if (!animated || type == LGPlusButtonsAppearingAnimationTypeNone)
        {
            _coverView.alpha = 0.f;
            _coverView.hidden = YES;

            if ([self.superview isKindOfClass:[UIScrollView class]])
                [(UIScrollView *)self.superview setScrollEnabled:YES];
        }
        else
        {
            NSTimeInterval animationSpeed = (self.isFirstButtonIsPlusButton ? _appearingAnimationSpeed : _buttonsAppearingAnimationSpeed);
            CGFloat dif = _coverView.alpha-0.f;
            NSTimeInterval duration = animationSpeed*dif;

            [LGPlusButtonsView animateStandardWithDuration:duration
                                                     delay:0.f
                                                animations:^(void)
             {
                 _coverView.alpha = 0.f;
             }
                                                completion:^(BOOL finished)
             {
                 if (finished)
                 {
                     _coverView.hidden = YES;

                     if ([self.superview isKindOfClass:[UIScrollView class]])
                         [(UIScrollView *)self.superview setScrollEnabled:YES];
                 }
             }];
        }
    }
}

#pragma mark - Button Animations

- (void)showButtonAtIndex:(NSUInteger)index
            animationType:(LGPlusButtonsAppearingAnimationType)type
                    delay:(NSTimeInterval)delay
           animationSpeed:(NSTimeInterval)animationSpeed
                 animated:(BOOL)animated
        completionHandler:(void(^)(BOOL result))completionHandler
{
    WrapperView *buttonWrapperView1 = _buttonWrapperViewsArray1[index];
    WrapperView *descriptionWrapperView = _descriptionWrapperViewsArray[index];

    // -----

    CGAffineTransform transform = CGAffineTransformIdentity;

    if (type == LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop)
    {
        CGFloat scaleX = [[(CALayer *)buttonWrapperView1.layer.presentationLayer valueForKeyPath:@"transform.scale.x"] floatValue];
        CGFloat scaleY = [[(CALayer *)buttonWrapperView1.layer.presentationLayer valueForKeyPath:@"transform.scale.y"] floatValue];

        if (scaleX && scaleY)
            transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(scaleX, scaleY));
    }
    else
    {
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation([[(CALayer *)buttonWrapperView1.layer.presentationLayer valueForKeyPath:@"transform.translation.x"] floatValue],
                                                                                        [[(CALayer *)buttonWrapperView1.layer.presentationLayer valueForKeyPath:@"transform.translation.y"] floatValue]));
    }

    buttonWrapperView1.alpha = [(CALayer *)buttonWrapperView1.layer.presentationLayer opacity];
    buttonWrapperView1.transform = transform;

    descriptionWrapperView.alpha = buttonWrapperView1.alpha;
    descriptionWrapperView.transform = buttonWrapperView1.transform;

    // -----

    [buttonWrapperView1.layer removeAllAnimations];
    [descriptionWrapperView.layer removeAllAnimations];

    // -----

    if (!animated || type == LGPlusButtonsAppearingAnimationTypeNone)
    {
        [self showAnimationsWithButtonAtIndex:index];

        if (completionHandler) completionHandler(YES);
    }
    else
    {
        CGFloat dif = 1.f-buttonWrapperView1.alpha;
        NSTimeInterval duration = animationSpeed*dif;

        [LGPlusButtonsView animateStandardWithDuration:duration
                                                 delay:delay
                                            animations:^(void)
         {
             [self showAnimationsWithButtonAtIndex:index];
         }
                                            completion:^(BOOL finished)
         {
             if (completionHandler) completionHandler(finished);
         }];
    }
}

- (void)showAnimationsWithButtonAtIndex:(NSUInteger)index
{
    WrapperView *buttonWrapperView1 = _buttonWrapperViewsArray1[index];
    WrapperView *descriptionWrapperView = _descriptionWrapperViewsArray[index];

    // -----

    CGAffineTransform transform = CGAffineTransformIdentity;

    buttonWrapperView1.alpha = 1.f;
    buttonWrapperView1.transform = transform;

    descriptionWrapperView.alpha = buttonWrapperView1.alpha;
    descriptionWrapperView.transform = buttonWrapperView1.transform;
}

- (void)hideButtonAtIndex:(NSUInteger)index
            animationType:(LGPlusButtonsAppearingAnimationType)type
                    delay:(NSTimeInterval)delay
           animationSpeed:(NSTimeInterval)animationSpeed
                 animated:(BOOL)animated
        completionHandler:(void(^)(BOOL result))completionHandler
{
    WrapperView *buttonWrapperView1 = _buttonWrapperViewsArray1[index];
    WrapperView *descriptionWrapperView = _descriptionWrapperViewsArray[index];

    // -----

    CGAffineTransform transform = CGAffineTransformIdentity;

    if (type == LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop)
    {
        CGFloat scaleX = [[(CALayer *)buttonWrapperView1.layer.presentationLayer valueForKeyPath:@"transform.scale.x"] floatValue];
        CGFloat scaleY = [[(CALayer *)buttonWrapperView1.layer.presentationLayer valueForKeyPath:@"transform.scale.y"] floatValue];

        if (scaleX && scaleY)
            transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(scaleX, scaleY));
    }
    else
    {
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation([[(CALayer *)buttonWrapperView1.layer.presentationLayer valueForKeyPath:@"transform.translation.x"] floatValue],
                                                                                        [[(CALayer *)buttonWrapperView1.layer.presentationLayer valueForKeyPath:@"transform.translation.y"] floatValue]));
    }

    buttonWrapperView1.alpha = [(CALayer *)buttonWrapperView1.layer.presentationLayer opacity];
    buttonWrapperView1.transform = transform;

    descriptionWrapperView.alpha = buttonWrapperView1.alpha;
    descriptionWrapperView.transform = buttonWrapperView1.transform;

    // -----

    [buttonWrapperView1.layer removeAllAnimations];
    [descriptionWrapperView.layer removeAllAnimations];

    // -----

    if (type == LGPlusButtonsAppearingAnimationTypeNone)
    {
        [self hideAnimationsWithButtonAtIndex:index
                                animationType:type];

        if (completionHandler) completionHandler(YES);
    }
    else
    {
        if (animated)
        {
            CGFloat dif = buttonWrapperView1.alpha-0.f;
            NSTimeInterval duration = animationSpeed*dif*_hideAnimationCoef;

            [UIView animateWithDuration:duration
                                  delay:delay
                                options:0
                             animations:^(void)
             {
                 [self hideAnimationsWithButtonAtIndex:index
                                         animationType:type];
             }
                             completion:^(BOOL finished)
             {
                 if (completionHandler) completionHandler(finished);
             }];
        }
        else
        {
            [self hideAnimationsWithButtonAtIndex:index
                                    animationType:type];

            if (completionHandler) completionHandler(YES);
        }
    }
}

- (void)hideAnimationsWithButtonAtIndex:(NSUInteger)index
                          animationType:(LGPlusButtonsAppearingAnimationType)type
{
    WrapperView *buttonWrapperView1 = _buttonWrapperViewsArray1[index];
    WrapperView *descriptionWrapperView = _descriptionWrapperViewsArray[index];

    // -----

    CGAffineTransform transform = CGAffineTransformIdentity;

    if (type == LGPlusButtonsAppearingAnimationTypeNone)
    {
        // no transform
    }
    else if (type == LGPlusButtonsAppearingAnimationTypeCrossDissolve)
    {
        // no transform
    }
    else if (type == LGPlusButtonsAppearingAnimationTypeCrossDissolveAndSlideHorizontal)
    {
        if (_position == LGPlusButtonsViewPositionRightTop || _position == LGPlusButtonsViewPositionRightBottom)
            transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(buttonWrapperView1.frame.size.width, 0.f));
        else
            transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(-buttonWrapperView1.frame.size.width, 0.f));
    }
    else if (type == LGPlusButtonsAppearingAnimationTypeCrossDissolveAndSlideVertical)
    {
        if (_position == LGPlusButtonsViewPositionBottomLeft || _position == LGPlusButtonsViewPositionBottomRight)
            transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(0.f, buttonWrapperView1.frame.size.height));
        else
            transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(0.f, -buttonWrapperView1.frame.size.height));
    }
    else if (type == LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop)
    {
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(0.5, 0.5));
    }

    buttonWrapperView1.alpha = 0.f;
    buttonWrapperView1.transform = transform;

    descriptionWrapperView.alpha = buttonWrapperView1.alpha;
    descriptionWrapperView.transform = buttonWrapperView1.transform;
}

#pragma mark -

- (void)selectPlusButtonViewWithAnimationType:(LGPlusButtonAnimationType)type animated:(BOOL)animated completionHandler:(void(^)(BOOL result))completionHandler
{
    WrapperView *plusButtonWrapperView2 = _buttonWrapperViewsArray2[0];

    // -----

    if (type == LGPlusButtonAnimationTypeCrossDissolve)
    {
        if (animated)
            [UIView transitionWithView:plusButtonWrapperView2
                              duration:_buttonsAppearingAnimationSpeed
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:completionHandler];
    }
    else if (type == LGPlusButtonAnimationTypeRotate)
    {
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeRotation(kLGPlusButtonsViewDegreesToRadians(45)));

        if (animated)
        {
            [UIView animateWithDuration:_buttonsAppearingAnimationSpeed
                             animations:^(void)
             {
                 plusButtonWrapperView2.transform = transform;
             }];
        }
        else
        {
            plusButtonWrapperView2.transform = transform;

            if (completionHandler) completionHandler(YES);
        }
    }
}

- (void)deselectPlusButtonViewWithAnimationType:(LGPlusButtonAnimationType)type animated:(BOOL)animated completionHandler:(void(^)(BOOL result))completionHandler
{
    WrapperView *plusButtonWrapperView2 = _buttonWrapperViewsArray2[0];

    // -----

    if (type == LGPlusButtonAnimationTypeCrossDissolve)
    {
        if (animated)
            [UIView transitionWithView:plusButtonWrapperView2
                              duration:_buttonsAppearingAnimationSpeed
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:completionHandler];
    }
    else if (type == LGPlusButtonAnimationTypeRotate)
    {
        if (animated)
        {
            [UIView animateWithDuration:_buttonsAppearingAnimationSpeed
                             animations:^(void)
             {
                 plusButtonWrapperView2.transform = CGAffineTransformIdentity;
             }];
        }
        else
        {
            plusButtonWrapperView2.transform = CGAffineTransformIdentity;

            if (completionHandler) completionHandler(YES);
        }
    }
}

#pragma mark - Observers

- (void)addObservers:(UIView *)view
{
    if (!self.isObserversAdded && view)
    {
        _observersAdded = YES;

        [view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];

        if ([view isKindOfClass:[UIScrollView class]])
        {
            [view addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
            [view addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [view addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        }

        if (_observedScrollView)
        {
            NSAssert([_observedScrollView isKindOfClass:[UIScrollView class]], @"observedScrollView needs to have UIScrollView kind of class");

            _observersForScrollViewAdded = YES;

            [_observedScrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
            [_observedScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [_observedScrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

- (void)removeObservers:(UIView *)view
{
    if (self.isObserversAdded && view)
    {
        _observersAdded = NO;

        [view removeObserver:self forKeyPath:@"frame"];

        if ([view isKindOfClass:[UIScrollView class]])
        {
            [view removeObserver:self forKeyPath:@"contentInset"];
            [view removeObserver:self forKeyPath:@"contentOffset"];
            [view removeObserver:self forKeyPath:@"contentSize"];
        }

        if (self.isObserversForScrollViewAdded)
        {
            NSAssert([_observedScrollView isKindOfClass:[UIScrollView class]], @"observedScrollView needs to have UIScrollView kind of class");

            _observersForScrollViewAdded = NO;

            [_observedScrollView removeObserver:self forKeyPath:@"contentInset"];
            [_observedScrollView removeObserver:self forKeyPath:@"contentOffset"];
            [_observedScrollView removeObserver:self forKeyPath:@"contentSize"];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"])
        [self setNeedsLayout];
    else if ([keyPath isEqualToString:@"contentInset"])
        [self setNeedsLayout];
    else if ([keyPath isEqualToString:@"contentOffset"])
    {
        if ([object isEqual:self.superview])
            [self updatePosition];

        if (!self.isShowHideOnScroll ||
            (_observedScrollView && ![object isEqual:_observedScrollView]) ||
            (!_observedScrollView && ![object isEqual:self.superview]))
            return;

        UIScrollView *scrollView = (UIScrollView *)object;

        if (self.isDisableShowHideOnScrollIfContentSizeLessThenFrame &&
            scrollView.contentSize.height <= scrollView.frame.size.height-(scrollView.contentInset.top+scrollView.contentInset.bottom))
            return;

        CGPoint newOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];

        CGFloat offsetY = newOffset.y;
        CGFloat tempDiff = self.tempOffsetY - offsetY;

        if ((self.tempDiff > 0.f && tempDiff < 0.f) || (self.tempDiff < 0.f && tempDiff > 0.f) || self.tempDiff == 0.f)
        {
            self.offsetY = offsetY;
            self.tempDiff = tempDiff;
        }
        else
        {
            CGFloat diff = self.offsetY - offsetY;

            if (scrollView.isTracking && scrollView.isDragging && (diff > _scrollSensitivity || diff < -_scrollSensitivity))
            {
                if (self.offsetY > offsetY)
                    [self showAnimated:YES completionHandler:nil];
                else
                    [self hideAnimated:YES completionHandler:^(void)
                     {
                         if (self.isHideButtonsOnScroll)
                             [self hideButtonsAnimated:NO completionHandler:nil];
                     }];
            }
        }

        if (offsetY >= -scrollView.contentInset.top &&
            offsetY < scrollView.contentSize.height-scrollView.frame.size.height+scrollView.contentInset.bottom)
            self.tempOffsetY = offsetY;
    }
    else if ([keyPath isEqualToString:@"contentSize"])
    {
        //
    }
    else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark -

- (void)setObservedScrollView:(UIScrollView *)observedScrollView
{
    if (observedScrollView)
        NSAssert([observedScrollView isKindOfClass:[UIScrollView class]], @"observedScrollView needs to have UIScrollView kind of class");
    
    if (self.isObserversForScrollViewAdded)
    {
        [_observedScrollView removeObserver:self forKeyPath:@"contentInset"];
        [_observedScrollView removeObserver:self forKeyPath:@"contentOffset"];
        [_observedScrollView removeObserver:self forKeyPath:@"contentSize"];
    }
    
    if (observedScrollView)
    {
        _observersForScrollViewAdded = YES;
        
        [observedScrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
        [observedScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [observedScrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    else _observersForScrollViewAdded = NO;
    
    _observedScrollView = observedScrollView;
}

#pragma mark - Support

+ (void)animateStandardWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay animations:(void(^)())animations completion:(void(^)(BOOL finished))completion
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
    {
        [UIView animateWithDuration:duration
                              delay:delay
             usingSpringWithDamping:1.f
              initialSpringVelocity:0.5
                            options:0
                         animations:animations
                         completion:completion];
    }
    else
    {
        [UIView animateWithDuration:duration*0.66
                              delay:delay
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:animations
                         completion:completion];
    }
}

@end
