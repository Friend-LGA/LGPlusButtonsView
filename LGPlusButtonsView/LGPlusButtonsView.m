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

#define kLGPlusButtonsViewDegreesToRadians(d) ((d) * M_PI / 180)

@interface WrapperView : UIView

@property (assign, nonatomic) UIView *actionView;

@end

@implementation WrapperView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    //NSLog(@"\nself = %@\nsuper = %@\nactionView = %@\nsubviews = %@\n\n", self, [super hitTest:point withEvent:event], _actionView, self.subviews);
    
    UIView *superView = [super hitTest:point withEvent:event];
    
    UIView *view;
    if (superView)
        view = superView;
    else if (_actionView)
        view = _actionView;
    
    return view;
}

@end

#pragma mark -

@interface LGPlusButton (protected)

@property (assign, nonatomic, getter=isShowing) BOOL showing;

@end

#pragma mark -

@interface LGPlusButtonsView ()

typedef enum
{
    LGPlusButtondescriptionsPositionLeft  = 0,
    LGPlusButtondescriptionsPositionRight = 1
}
LGPlusButtonDescriptionsPosition;

@property (assign, nonatomic, getter=isObserversAdded) BOOL observersAdded;

@property (assign, nonatomic) LGPlusButtonDescriptionsPosition descriptionsPosition;

@property (assign, nonatomic) UIView *parentView;

@property (strong, nonatomic) NSMutableArray *buttonWrapperViews1;
@property (strong, nonatomic) NSMutableArray *buttonWrapperViews2;
@property (strong, nonatomic) NSMutableArray *descriptionWrapperViews;

@property (strong, nonatomic) WrapperView   *plusButtonWrapperView1;
@property (strong, nonatomic) WrapperView   *plusButtonWrapperView2;
@property (strong, nonatomic) UILabel       *plusDescription;
@property (strong, nonatomic) WrapperView   *plusDescriptionWrapperView;

@property (assign, nonatomic) CGFloat offsetY;
@property (assign, nonatomic) CGFloat tempOffsetY;
@property (assign, nonatomic) CGFloat tempDiff;

@property (assign, nonatomic, getter=isShowsPlusButton) BOOL showsPlusButton;

@end

@implementation LGPlusButtonsView

- (instancetype)initWithView:(UIView *)view
             numberOfButtons:(NSUInteger)numberOfButtons
             showsPlusButton:(BOOL)showsPlusButton
{
    self = [super init];
    if (self)
    {
        _parentView = view;
        _showWhenScrolling = YES;
        _appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndSlideVertical;
        _buttonsAppearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndSlideHorizontal;
        _showsPlusButton = showsPlusButton;
        _descriptionOffsetX = 6.f;
        
        // -----
        
        self.backgroundColor = [UIColor clearColor];
        self.hidden = YES;
        
        // -----
        
        _buttonWrapperViews1 = [NSMutableArray new];
        _buttonWrapperViews2 = [NSMutableArray new];
        _buttons = [NSMutableArray new];
        
        if (self.isShowsPlusButton)
        {
            _plusButtonWrapperView1 = [WrapperView new];
            _plusButtonWrapperView1.backgroundColor = [UIColor clearColor];
            _plusButtonWrapperView1.clipsToBounds = NO;
            _plusButtonWrapperView1.layer.masksToBounds = NO;
            _plusButtonWrapperView1.layer.anchorPoint = CGPointMake(0.5, 0.5);
            _plusButtonWrapperView1.userInteractionEnabled = YES;
            [self addSubview:_plusButtonWrapperView1];
            
            [_buttonWrapperViews1 addObject:_plusButtonWrapperView1];
            
            _plusButtonWrapperView2 = [WrapperView new];
            _plusButtonWrapperView2.backgroundColor = [UIColor clearColor];
            _plusButtonWrapperView2.clipsToBounds = NO;
            _plusButtonWrapperView2.layer.masksToBounds = NO;
            _plusButtonWrapperView2.layer.anchorPoint = CGPointMake(0.5, 0.5);
            _plusButtonWrapperView2.userInteractionEnabled = YES;
            [_plusButtonWrapperView1 addSubview:_plusButtonWrapperView2];
            
            [_buttonWrapperViews2 addObject:_plusButtonWrapperView2];
            
            _plusButton = [LGPlusButton new];
            [_plusButton addTarget:self action:@selector(plusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [_plusButtonWrapperView2 addSubview:_plusButton];
            
            _plusButtonWrapperView2.actionView = _plusButton;
            [_buttons addObject:_plusButton];
        }
        
        // -----
        
        for (NSUInteger i=0; i<numberOfButtons; i++)
        {
            WrapperView *wrapperView1 = [WrapperView new];
            wrapperView1.backgroundColor = [UIColor clearColor];
            wrapperView1.clipsToBounds = NO;
            wrapperView1.layer.masksToBounds = NO;
            wrapperView1.layer.anchorPoint = CGPointMake(0.5, 0.5);
            wrapperView1.userInteractionEnabled = YES;
            [self addSubview:wrapperView1];
            
            [_buttonWrapperViews1 addObject:wrapperView1];
            
            WrapperView *wrapperView2 = [WrapperView new];
            wrapperView2.backgroundColor = [UIColor clearColor];
            wrapperView2.clipsToBounds = NO;
            wrapperView2.layer.masksToBounds = NO;
            wrapperView2.layer.anchorPoint = CGPointMake(0.5, 0.5);
            wrapperView2.userInteractionEnabled = YES;
            [wrapperView1 addSubview:wrapperView2];
            
            [_buttonWrapperViews2 addObject:wrapperView2];
            
            LGPlusButton *button = [LGPlusButton new];
            button.tag = i;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [wrapperView2 addSubview:button];
            
            wrapperView2.actionView = button;
            [_buttons addObject:button];
        }
        
        // -----
        
        _descriptionWrapperViews = [NSMutableArray new];
        _descriptions = [NSMutableArray new];
        
        for (NSUInteger i=0; i<_buttons.count; i++)
        {
            if (i == 0 && self.isShowsPlusButton)
            {
                _plusDescriptionWrapperView = [WrapperView new];
                _plusDescriptionWrapperView.backgroundColor = [UIColor clearColor];
                _plusDescriptionWrapperView.clipsToBounds = NO;
                _plusDescriptionWrapperView.layer.masksToBounds = NO;
                _plusDescriptionWrapperView.layer.anchorPoint = CGPointMake(0.5, 0.5);
                _plusDescriptionWrapperView.userInteractionEnabled = NO;
                [self addSubview:_plusDescriptionWrapperView];
                
                [_descriptionWrapperViews addObject:_plusDescriptionWrapperView];
                
                _plusDescription = [UILabel new];
                _plusDescription.textColor = [UIColor whiteColor];
                _plusDescription.textAlignment = NSTextAlignmentCenter;
                _plusDescription.font = [UIFont systemFontOfSize:14];
                _plusDescription.numberOfLines = 1;
                _plusDescription.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8];
                _plusDescription.layer.cornerRadius = 10.f;
                _plusDescription.layer.masksToBounds = YES;
                _plusDescription.userInteractionEnabled = NO;
                [_plusDescriptionWrapperView addSubview:_plusDescription];
                
                [_descriptions addObject:_plusDescription];
            }
            else
            {
                WrapperView *wrapperView = [WrapperView new];
                wrapperView.backgroundColor = [UIColor clearColor];
                wrapperView.clipsToBounds = NO;
                wrapperView.layer.masksToBounds = NO;
                wrapperView.layer.anchorPoint = CGPointMake(0.5, 0.5);
                wrapperView.userInteractionEnabled = NO;
                [self addSubview:wrapperView];
                
                [_descriptionWrapperViews addObject:wrapperView];
                
                UILabel *label = [UILabel new];
                label.textColor = [UIColor whiteColor];
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [UIFont systemFontOfSize:14];
                label.numberOfLines = 1;
                label.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8];
                label.layer.cornerRadius = 10.f;
                label.layer.masksToBounds = YES;
                label.userInteractionEnabled = NO;
                [wrapperView addSubview:label];
                
                [_descriptions addObject:label];
            }
        }
        
        // -----
        
        [self layoutInvalidate];
        [_parentView addSubview:self];
    }
    return self;
}

+ (instancetype)plusButtonsViewWithView:(UIView *)view
                        numberOfButtons:(NSUInteger)numberOfButtons
                        showsPlusButton:(BOOL)showsPlusButton
{
    return [[self alloc] initWithView:view
                      numberOfButtons:numberOfButtons
                      showsPlusButton:showsPlusButton];
}

#pragma mark -

- (instancetype)initWithView:(UIView *)view
             numberOfButtons:(NSUInteger)numberOfButtons
             showsPlusButton:(BOOL)showsPlusButton
               actionHandler:(void(^)(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index))actionHandler
     plusButtonActionHandler:(void(^)(LGPlusButtonsView *plusButtonView))plusButtonActionHandler
{
    self = [self initWithView:view numberOfButtons:numberOfButtons showsPlusButton:showsPlusButton];
    if (self)
    {
        _actionHandler = actionHandler;
        _plusButtonActionHandler = plusButtonActionHandler;
    }
    return self;
}

+ (instancetype)plusButtonsViewWithView:(UIView *)view
                        numberOfButtons:(NSUInteger)numberOfButtons
                        showsPlusButton:(BOOL)showsPlusButton
                          actionHandler:(void(^)(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index))actionHandler
                plusButtonActionHandler:(void(^)(LGPlusButtonsView *plusButtonView))plusButtonActionHandler
{
    return [[self alloc] initWithView:view
                      numberOfButtons:numberOfButtons
                      showsPlusButton:showsPlusButton
                        actionHandler:actionHandler
              plusButtonActionHandler:plusButtonActionHandler];
}

#pragma mark -

- (instancetype)initWithView:(UIView *)view
             numberOfButtons:(NSUInteger)numberOfButtons
             showsPlusButton:(BOOL)showsPlusButton
                    delegate:(id<LGPlusButtonsViewDelegate>)delegate
{
    self = [self initWithView:view numberOfButtons:numberOfButtons showsPlusButton:showsPlusButton];
    if (self)
    {
        _delegate = delegate;
    }
    return self;
}

+ (instancetype)plusButtonsViewWithView:(UIView *)view
                        numberOfButtons:(NSUInteger)numberOfButtons
                        showsPlusButton:(BOOL)showsPlusButton
                               delegate:(id<LGPlusButtonsViewDelegate>)delegate
{
    return [[self alloc] initWithView:view
                      numberOfButtons:numberOfButtons
                      showsPlusButton:showsPlusButton
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

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (!newSuperview)
        [self removeObservers];
    else
        [self addObservers];
}

#pragma mark - Setters and Getters

- (void)setButtonsTitles:(NSArray *)titles forState:(UIControlState)state
{
    BOOL isChanged = NO;
    
    for (NSUInteger i=0; i<_buttons.count; i++)
    {
        LGPlusButton *button = _buttons[i];
        
        if (![button.titleLabel.text isEqualToString:titles[i]])
        {
            [button setTitle:titles[i] forState:state];
            
            isChanged = YES;
        }
    }
    
    if (isChanged) [self layoutInvalidate];
}

- (void)setButtonsTitleColor:(UIColor *)titleColor forState:(UIControlState)state
{
    for (LGPlusButton *button in _buttons)
        [button setTitleColor:titleColor forState:state];
}

- (void)setButtonsImage:(UIImage *)image forState:(UIControlState)state
{
    BOOL isChanged = NO;
    
    for (LGPlusButton *button in _buttons)
    {
        if (!CGSizeEqualToSize(button.imageView.image.size, image.size))
            isChanged = YES;
        
        [button setImage:image forState:state];
    }
    
    if (isChanged) [self layoutInvalidate];
}

- (void)setButtonsBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state
{
    for (LGPlusButton *button in _buttons)
        [button setBackgroundImage:backgroundImage forState:state];
}

- (void)setButtonsBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    for (LGPlusButton *button in _buttons)
        [button setBackgroundColor:backgroundColor forState:state];
}

- (void)setButtonsTitleFont:(UIFont *)font
{
    BOOL isChanged = NO;
    
    for (LGPlusButton *button in _buttons)
        if (![button.titleLabel.font isEqual:font])
        {
            button.titleLabel.font = font;
            
            isChanged = YES;
        }
    
    if (isChanged) [self layoutInvalidate];
}

#pragma mark -

- (void)setDescriptionsTexts:(NSArray *)texts
{
    BOOL isChanged = NO;
    
    for (NSUInteger i=0; i<_descriptions.count; i++)
    {
        UILabel *label = _descriptions[i];
        
        if (![label.text isEqualToString:texts[i]])
        {
            label.text = texts[i];
            
            isChanged = YES;
        }
    }
    
    if (isChanged) [self layoutInvalidate];
}

- (void)setDescriptionsTextColor:(UIColor *)textColor
{
    for (UILabel *label in _descriptions)
        label.textColor = textColor;
}

- (void)setDescriptionsBackgroundColor:(UIColor *)backgroundColor
{
    for (UILabel *label in _descriptions)
        label.backgroundColor = backgroundColor;
}

- (void)setDescriptionsFont:(UIFont *)font
{
    BOOL isChanged = NO;
    
    for (UILabel *label in _descriptions)
        if (![label.font isEqual:font])
        {
            label.font = font;
            
            isChanged = YES;
        }
    
    if (isChanged) [self layoutInvalidate];
}

- (void)setDescriptionOffsetX:(CGFloat)descriptionOffsetX
{
    if (_descriptionOffsetX != descriptionOffsetX)
    {
        _descriptionOffsetX = descriptionOffsetX;
        
        [self layoutInvalidate];
    }
}

#pragma mark -

- (void)setButtonsClipsToBounds:(BOOL)clipsToBounds
{
    for (LGPlusButton *button in _buttons)
        button.clipsToBounds = clipsToBounds;
}

- (void)setButtonsContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets
{
    BOOL isChanged = NO;
    
    for (LGPlusButton *button in _buttons)
        if (!UIEdgeInsetsEqualToEdgeInsets(button.contentEdgeInsets, contentEdgeInsets))
        {
            button.contentEdgeInsets = contentEdgeInsets;
            
            isChanged = YES;
        }
    
    if (isChanged) [self layoutInvalidate];
}

- (void)setButtonsAdjustsImageWhenHighlighted:(BOOL)adjustsImageWhenHighlighted
{
    for (LGPlusButton *button in _buttons)
        button.adjustsImageWhenHighlighted = adjustsImageWhenHighlighted;
}

#pragma mark -

- (void)setButtonsLayerMasksToBounds:(BOOL)masksToBounds
{
    for (LGPlusButton *button in _buttons)
        button.layer.masksToBounds = masksToBounds;
}

- (void)setButtonsLayerCornerRadius:(CGFloat)cornerRadius
{
    for (LGPlusButton *button in _buttons)
        button.layer.cornerRadius = cornerRadius;
}

- (void)setButtonsLayerBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth
{
    for (LGPlusButton *button in _buttons)
    {
        button.layer.borderColor = borderColor.CGColor;
        button.layer.borderWidth = borderWidth;
    }
}

- (void)setButtonsLayerShadowColor:(UIColor *)shadowColor shadowOpacity:(float)shadowOpacity shadowOffset:(CGSize)shadowOffset shadowRadius:(CGFloat)shadowRadius
{
    for (LGPlusButton *button in _buttons)
    {
        button.layer.shadowColor = shadowColor.CGColor;
        button.layer.shadowOpacity = shadowOpacity;
        button.layer.shadowOffset = shadowOffset;
        button.layer.shadowRadius = shadowRadius;
    }
}

#pragma mark -

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInset, contentInset))
    {
        _contentInset = contentInset;
        
        [self layoutInvalidate];
    }
}

- (void)setButtonInset:(UIEdgeInsets)buttonInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_buttonInset, buttonInset))
    {
        _buttonInset = buttonInset;
        
        [self layoutInvalidate];
    }
}

- (void)setButtonsSize:(CGSize)buttonsSize
{
    if (!CGSizeEqualToSize(_buttonsSize, buttonsSize))
    {
        _buttonsSize = buttonsSize;
        
        [self layoutInvalidate];
    }
}

- (void)setPlusButtonSize:(CGSize)plusButtonSize
{
    if (!CGSizeEqualToSize(_plusButtonSize, plusButtonSize))
    {
        _plusButtonSize = plusButtonSize;
        
        [self layoutInvalidate];
    }
}

- (void)setPosition:(LGPlusButtonsViewPosition)position
{
    if (_position != position)
    {
        _position = position;
        
        if (_position == LGPlusButtonsViewPositionBottomRight || _position == LGPlusButtonsViewPositionTopRight)
            _descriptionsPosition = LGPlusButtondescriptionsPositionLeft;
        else
            _descriptionsPosition = LGPlusButtondescriptionsPositionRight;
        
        [self layoutInvalidate];
    }
}

- (void)setOffset:(CGPoint)offset
{
    if (!CGPointEqualToPoint(_offset, offset))
    {
        _offset = offset;
        
        [self layoutInvalidate];
    }
}

#pragma mark -

- (void)layoutInvalidate
{
    if (self.superview)
    {
        UIEdgeInsets parentInset = UIEdgeInsetsZero;
        CGPoint parentOffset = CGPointZero;
        
        if ([_parentView isKindOfClass:[UIScrollView class]])
        {
            UIScrollView *parentScrollView = (UIScrollView *)_parentView;
            
            parentInset = parentScrollView.contentInset;
            parentOffset = parentScrollView.contentOffset;
        }
        
        // -----
        
        NSMutableArray *buttonsSizeArray = [NSMutableArray new];
        
        CGSize selfSize = CGSizeMake(_buttonInset.left+_buttonInset.right+_contentInset.left+_contentInset.right,
                                     (_buttonInset.left+_buttonInset.right)*_buttons.count+_contentInset.top+_contentInset.bottom);
        
        if (!CGSizeEqualToSize(_buttonsSize, CGSizeZero))
        {
            if (!CGSizeEqualToSize(_plusButtonSize, CGSizeZero) && self.isShowsPlusButton)
            {
                selfSize.width += MAX(_plusButtonSize.width, _buttonsSize.width);
                selfSize.height += _plusButtonSize.height+(_buttonsSize.height*_buttons.count-1);
            }
            else
            {
                selfSize.width += _buttonsSize.width;
                selfSize.height += _buttonsSize.height*_buttons.count;
            }
        }
        else
        {
            CGFloat width = 0.f;
            
            for (NSUInteger i=0; i<_buttons.count; i++)
            {
                if (i == 0 && !CGSizeEqualToSize(_plusButtonSize, CGSizeZero) && self.isShowsPlusButton)
                {
                    [buttonsSizeArray addObject:NSStringFromCGSize(_plusButtonSize)];
                    
                    width = MAX(width, _plusButtonSize.width);
                    selfSize.height += _plusButtonSize.height;
                }
                else
                {
                    LGPlusButton *button = _buttons[i];
                    
                    CGSize buttonSize = [button sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
                    
                    [buttonsSizeArray addObject:NSStringFromCGSize(buttonSize)];
                    
                    width = MAX(width, buttonSize.width);
                    selfSize.height += buttonSize.height;
                }
            }
            
            selfSize.width += width;
        }
        
        // -----
        
        CGPoint selfOrigin = CGPointZero;
        if (_position == LGPlusButtonsViewPositionBottomRight)
        {
            selfOrigin = CGPointMake(_parentView.frame.size.width-parentInset.right-selfSize.width+parentOffset.x,
                                     _parentView.frame.size.height-parentInset.bottom-selfSize.height+parentOffset.y);
        }
        else if (_position == LGPlusButtonsViewPositionBottomLeft)
        {
            selfOrigin = CGPointMake(parentInset.left+parentOffset.x,
                                     _parentView.frame.size.height-parentInset.bottom-selfSize.height+parentOffset.y);
        }
        else if (_position == LGPlusButtonsViewPositionTopRight)
        {
            selfOrigin = CGPointMake(_parentView.frame.size.width-parentInset.right-selfSize.width+parentOffset.x,
                                     parentInset.top+parentOffset.y);
        }
        else if (_position == LGPlusButtonsViewPositionTopLeft)
        {
            selfOrigin = CGPointMake(parentInset.left+parentOffset.x,
                                     parentInset.top+parentOffset.y);
        }
        selfOrigin.x += _offset.x;
        selfOrigin.y += _offset.y;
        
        CGRect selfFrame = CGRectMake(selfOrigin.x, selfOrigin.y, selfSize.width, selfSize.height);
        if ([UIScreen mainScreen].scale == 1.f) selfFrame = CGRectIntegral(selfFrame);
        self.frame = selfFrame;
        
        // -----
        
        for (NSUInteger i=0; i<_buttons.count; i++)
        {
            WrapperView *buttonWrapperView1 = _buttonWrapperViews1[i];
            WrapperView *buttonWrapperView2 = _buttonWrapperViews2[i];
            LGPlusButton *button = _buttons[i];
            
            CGRect buttonFrame = CGRectZero;
            CGSize buttonSize = CGSizeZero;
            
            if (i == 0 && !CGSizeEqualToSize(_plusButtonSize, CGSizeZero) && self.isShowsPlusButton)
                buttonSize = _plusButtonSize;
            else if (!CGSizeEqualToSize(_buttonsSize, CGSizeZero))
                buttonSize = _buttonsSize;
            else
                buttonSize = CGSizeFromString(buttonsSizeArray[i]);
            
            if (i == 0)
            {
                if (_position == LGPlusButtonsViewPositionBottomRight)
                {
                    buttonFrame = CGRectMake(selfFrame.size.width-_contentInset.right-_buttonInset.right-buttonSize.width,
                                             selfFrame.size.height-_contentInset.bottom-_buttonInset.bottom-buttonSize.height,
                                             buttonSize.width,
                                             buttonSize.height);
                }
                else if (_position == LGPlusButtonsViewPositionBottomLeft)
                {
                    buttonFrame = CGRectMake(_contentInset.left+_buttonInset.left,
                                             selfFrame.size.height-_contentInset.bottom-_buttonInset.bottom-buttonSize.height,
                                             buttonSize.width,
                                             buttonSize.height);
                }
                else if (_position == LGPlusButtonsViewPositionTopRight)
                {
                    buttonFrame = CGRectMake(selfFrame.size.width-_contentInset.right-_buttonInset.right-buttonSize.width,
                                             _contentInset.top+_buttonInset.top,
                                             buttonSize.width,
                                             buttonSize.height);
                }
                else if (_position == LGPlusButtonsViewPositionTopLeft)
                {
                    buttonFrame = CGRectMake(_contentInset.left+_buttonInset.left,
                                             _contentInset.top+_buttonInset.top,
                                             buttonSize.width,
                                             buttonSize.height);
                }
            }
            else
            {
                WrapperView *previousWrapperView1 = _buttonWrapperViews1[i-1];
                
                if (_position == LGPlusButtonsViewPositionBottomRight)
                {
                    buttonFrame = CGRectMake(selfFrame.size.width-_contentInset.right-_buttonInset.right-buttonSize.width,
                                             previousWrapperView1.frame.origin.y-_buttonInset.top-_buttonInset.bottom-buttonSize.height,
                                             buttonSize.width,
                                             buttonSize.height);
                }
                else if (_position == LGPlusButtonsViewPositionBottomLeft)
                {
                    buttonFrame = CGRectMake(_contentInset.left+_buttonInset.left,
                                             previousWrapperView1.frame.origin.y-_buttonInset.top-_buttonInset.bottom-buttonSize.height,
                                             buttonSize.width,
                                             buttonSize.height);
                }
                else if (_position == LGPlusButtonsViewPositionTopRight)
                {
                    buttonFrame = CGRectMake(selfFrame.size.width-_contentInset.right-_buttonInset.right-buttonSize.width,
                                             previousWrapperView1.frame.origin.y+previousWrapperView1.frame.size.height+_buttonInset.bottom+_buttonInset.top,
                                             buttonSize.width,
                                             buttonSize.height);
                }
                else if (_position == LGPlusButtonsViewPositionTopLeft)
                {
                    buttonFrame = CGRectMake(_contentInset.left+_buttonInset.left,
                                             previousWrapperView1.frame.origin.y+previousWrapperView1.frame.size.height+_buttonInset.bottom+_buttonInset.top,
                                             buttonSize.width,
                                             buttonSize.height);
                }
            }
            
            if ([UIScreen mainScreen].scale == 1.f) buttonFrame = CGRectIntegral(buttonFrame);
            buttonWrapperView1.transform = CGAffineTransformIdentity;
            buttonWrapperView1.frame = buttonFrame;
            
            buttonWrapperView2.frame = CGRectMake(buttonWrapperView1.frame.size.width/2, buttonWrapperView1.frame.size.height/2, 0.f, 0.f);
            button.frame = CGRectMake(-buttonWrapperView1.frame.size.width/2, -buttonWrapperView1.frame.size.height/2, buttonWrapperView1.frame.size.width, buttonWrapperView1.frame.size.height);
        }
        
        // -----
        
        for (NSUInteger i=0; i<_buttons.count; i++)
        {
            WrapperView *buttonWrapperView1 = _buttonWrapperViews1[i];
            LGPlusButton *button = _buttons[i];
            
            WrapperView *descriptionWrapperView = _descriptionWrapperViews[i];
            UILabel *label = _descriptions[i];
            
            if (label.text.length)
            {
                descriptionWrapperView.transform = CGAffineTransformIdentity;
                descriptionWrapperView.frame = CGRectMake(buttonWrapperView1.frame.origin.x+button.contentEdgeInsets.left,
                                                          buttonWrapperView1.frame.origin.y+button.contentEdgeInsets.top,
                                                          buttonWrapperView1.frame.size.width-button.contentEdgeInsets.left-button.contentEdgeInsets.right,
                                                          buttonWrapperView1.frame.size.height-button.contentEdgeInsets.top-button.contentEdgeInsets.bottom);
                CGFloat paddingWidth = 8.f;
                CGFloat paddingHeight = 4.f;
                
                CGSize labelSize = [label sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
                
                CGFloat originX;
                if (_descriptionsPosition == LGPlusButtondescriptionsPositionLeft)
                    originX = -labelSize.width-_descriptionOffsetX-paddingWidth*2;
                else
                    originX = descriptionWrapperView.frame.size.width+_descriptionOffsetX;
                
                CGRect labelFrame = CGRectMake(originX,
                                               descriptionWrapperView.frame.size.height/2-labelSize.height/2-paddingHeight,
                                               labelSize.width+paddingWidth*2,
                                               labelSize.height+paddingHeight*2);
                if ([UIScreen mainScreen].scale == 1.f) labelFrame = CGRectIntegral(labelFrame);
                label.frame = labelFrame;
            }
            else
            {
                descriptionWrapperView.transform = CGAffineTransformIdentity;
                descriptionWrapperView.frame = CGRectZero;
                
                label.frame = CGRectZero;
            }
        }
        
        // -----
        
        for (NSUInteger i=0; i<_buttons.count; i++)
        {
            WrapperView *buttonWrapperView1 = _buttonWrapperViews1[i];
            LGPlusButton *button = _buttons[i];
            
            if (!button.isShowing && CGAffineTransformEqualToTransform(buttonWrapperView1.transform, CGAffineTransformIdentity) && button.frame.size.width > 1.f && button.frame.size.height > 1.f)
                [self hideAnimationsWithButtonAtIndex:i animationType:((i == 0 || !self.isShowsPlusButton) ? _appearingAnimationType : _buttonsAppearingAnimationType)];
        }
    }
}

- (void)updatePosition
{
    if (self.superview)
    {
        UIEdgeInsets parentInset = UIEdgeInsetsZero;
        CGPoint parentOffset = CGPointZero;
        
        if ([_parentView isKindOfClass:[UIScrollView class]])
        {
            UIScrollView *parentScrollView = (UIScrollView *)_parentView;
            
            parentInset = parentScrollView.contentInset;
            parentOffset = parentScrollView.contentOffset;
        }
        
        CGPoint selfOrigin = CGPointZero;
        if (_position == LGPlusButtonsViewPositionBottomRight)
        {
            selfOrigin = CGPointMake(_parentView.frame.size.width-parentInset.right-self.frame.size.width+parentOffset.x,
                                     _parentView.frame.size.height-parentInset.bottom-self.frame.size.height+parentOffset.y);
        }
        else if (_position == LGPlusButtonsViewPositionBottomLeft)
        {
            selfOrigin = CGPointMake(parentInset.left+parentOffset.x,
                                     _parentView.frame.size.height-parentInset.bottom-self.frame.size.height+parentOffset.y);
        }
        else if (_position == LGPlusButtonsViewPositionTopRight)
        {
            selfOrigin = CGPointMake(_parentView.frame.size.width-parentInset.right-self.frame.size.width+parentOffset.x,
                                     parentInset.top+parentOffset.y);
        }
        else if (_position == LGPlusButtonsViewPositionTopLeft)
        {
            selfOrigin = CGPointMake(parentInset.left+parentOffset.x,
                                     parentInset.top+parentOffset.y);
        }
        
        CGRect selfFrame = CGRectMake(selfOrigin.x, selfOrigin.y, self.frame.size.width, self.frame.size.height);
        if ([UIScreen mainScreen].scale == 1.f) selfFrame = CGRectIntegral(selfFrame);
        self.center = CGPointMake(selfFrame.origin.x+selfFrame.size.width/2, selfFrame.origin.y+selfFrame.size.height/2);
    }
}

#pragma mark - Actions

- (void)plusButtonAction:(LGPlusButton *)button
{
    if (_plusButton.isSelected)
        [self hideButtonsAnimated:YES completionHandler:nil];
    else
        [self showButtonsAnimated:YES completionHandler:nil];
    
    if (_plusButtonActionHandler) _plusButtonActionHandler(self);
    
    if (_delegate && [_delegate respondsToSelector:@selector(plusButtonsViewPlusButtonPressed:)])
        [_delegate plusButtonsViewPlusButtonPressed:self];
}

- (void)buttonAction:(LGPlusButton *)button
{
    NSUInteger index = [_buttons indexOfObject:button];
    
    UILabel *descriptionLabel = _descriptions[index];
    
    if (_actionHandler) _actionHandler(self, button.titleLabel.text, descriptionLabel.text, button.tag);
    
    if (_delegate && [_delegate respondsToSelector:@selector(plusButtonsView:buttonPressedWithTitle:description:index:)])
        [_delegate plusButtonsView:self buttonPressedWithTitle:button.titleLabel.text description:descriptionLabel.text index:button.tag];
}

#pragma mark - Animations

- (void)showAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    if (!self.isShowing)
    {
        _showing = YES;
        _plusButton.showing = YES;
        
        self.hidden = NO;
        
        NSTimeInterval delay = 0.03;
        
        if (self.isShowsPlusButton)
        {
            for (NSInteger i=0; i<_buttons.count; i++)
            {
                LGPlusButton *button = _buttons[i];
                
                if (i == 0  || (i > 0 && button.isShowing))
                {
                    [self showButtonAtIndex:i
                              animationType:_appearingAnimationType
                                      delay:delay*i
                                   animated:animated
                          completionHandler:^(BOOL result)
                     {
                         if (completionHandler) completionHandler();
                     }];
                }
            }
        }
        else
        {
            for (NSInteger i=0; i<_buttons.count; i++)
            {
                LGPlusButton *button = _buttons[i];
                
                button.showing = YES;
                
                [self showButtonAtIndex:i
                          animationType:_appearingAnimationType
                                  delay:delay*i
                               animated:animated
                      completionHandler:^(BOOL result)
                 {
                     if (completionHandler) completionHandler();
                 }];
            }
        }
    }
}

- (void)hideAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    if (self.isShowing)
    {
        _showing = NO;
        _plusButton.showing = NO;
        
        NSTimeInterval delay = 0.03;
        
        if (self.isShowsPlusButton)
        {
            for (NSInteger i=0; i<_buttons.count; i++)
            {
                LGPlusButton *button = _buttons[i];
                
                if (i == 0 || (i > 0 && button.isShowing))
                {
                    __block NSUInteger index = i;
                    
                    [self hideButtonAtIndex:i
                              animationType:_appearingAnimationType
                                      delay:delay*i
                                   animated:animated
                          completionHandler:^(BOOL result)
                     {
                         if (result && index == _buttons.count-1)
                             self.hidden = YES;
                         
                         if (completionHandler) completionHandler();
                     }];
                }
            }
        }
        else
        {
            for (NSInteger i=0; i<_buttons.count; i++)
            {
                LGPlusButton *button = _buttons[i];
                
                button.showing = NO;
                
                __block NSUInteger index = i;
                
                [self hideButtonAtIndex:i
                          animationType:_appearingAnimationType
                                  delay:delay*i
                               animated:animated
                      completionHandler:^(BOOL result)
                 {
                     if (result && index == _buttons.count-1)
                         self.hidden = YES;
                     
                     if (completionHandler) completionHandler();
                 }];
            }
        }
    }
}

#pragma mark -

- (void)showButtonsAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    if (self.isShowsPlusButton)
    {
        _plusButton.selected = YES;
        
        [self selectPlusButtonViewWithAnimationType:_plusButtonAnimationType animated:YES completionHandler:nil];
        
        NSTimeInterval delay = 0.03;
        
        for (NSInteger i=1; i<_buttons.count; i++)
        {
            LGPlusButton *button = _buttons[i];
            
            if (!button.isShowing)
            {
                button.showing = YES;
                
                if (_plusButton.isShowing)
                {
                    [self showButtonAtIndex:i
                              animationType:_buttonsAppearingAnimationType
                                      delay:delay*(i-1)
                                   animated:animated
                          completionHandler:^(BOOL result)
                     {
                         if (completionHandler) completionHandler();
                     }];
                }
                else
                {
                    [self hideButtonAtIndex:i
                              animationType:_appearingAnimationType
                                      delay:delay*(i-1)
                                   animated:animated
                          completionHandler:^(BOOL result)
                     {
                         if (completionHandler) completionHandler();
                     }];
                }
            }
        }
    }
}

- (void)hideButtonsAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    if (self.isShowsPlusButton)
    {
        _plusButton.selected = NO;
        
        [self deselectPlusButtonViewWithAnimationType:_plusButtonAnimationType animated:YES completionHandler:nil];
        
        NSTimeInterval delay = 0.03;
        
        for (NSInteger i=1; i<_buttons.count; i++)
        {
            LGPlusButton *button = _buttons[i];
            
            if (button.isShowing)
            {
                button.showing = NO;
                
                [self hideButtonAtIndex:i
                          animationType:_buttonsAppearingAnimationType
                                  delay:delay*(i-1)
                               animated:animated
                      completionHandler:^(BOOL result)
                 {
                     if (completionHandler) completionHandler();
                 }];
            }
        }
    }
}

#pragma mark - Button Animations

- (void)showButtonAtIndex:(NSUInteger)index
            animationType:(LGPlusButtonsAppearingAnimationType)type
                    delay:(NSTimeInterval)delay
                 animated:(BOOL)animated
        completionHandler:(void(^)(BOOL result))completionHandler
{
    WrapperView *buttonWrapperView1 = _buttonWrapperViews1[index];
    WrapperView *descriptionWrapperView = _descriptionWrapperViews[index];
    
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
        
        [LGPlusButtonsView animateStandardWithDuration:0.3*dif
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
    WrapperView *buttonWrapperView1 = _buttonWrapperViews1[index];
    WrapperView *descriptionWrapperView = _descriptionWrapperViews[index];
    
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
                 animated:(BOOL)animated
        completionHandler:(void(^)(BOOL result))completionHandler
{
    WrapperView *buttonWrapperView1 = _buttonWrapperViews1[index];
    WrapperView *descriptionWrapperView = _descriptionWrapperViews[index];
    
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
            
            [UIView animateWithDuration:0.3*0.66*dif
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
    WrapperView *buttonWrapperView1 = _buttonWrapperViews1[index];
    WrapperView *descriptionWrapperView = _descriptionWrapperViews[index];
    
    // -----
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    if (type == LGPlusButtonsAppearingAnimationTypeNone)
    {
        //
    }
    else if (type == LGPlusButtonsAppearingAnimationTypeCrossDissolve)
    {
        //
    }
    else if (type == LGPlusButtonsAppearingAnimationTypeCrossDissolveAndSlideHorizontal)
    {
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(buttonWrapperView1.frame.size.width, 0.f));
    }
    else if (type == LGPlusButtonsAppearingAnimationTypeCrossDissolveAndSlideVertical)
    {
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(0.f, buttonWrapperView1.frame.size.height));
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
    WrapperView *plusButtonWrapperView2 = _buttonWrapperViews2[0];
    
    // -----
    
    if (type == LGPlusButtonAnimationTypeCrossDissolve)
    {
        if (animated)
            [UIView transitionWithView:plusButtonWrapperView2
                              duration:0.2
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
            [UIView animateWithDuration:0.2
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
    WrapperView *plusButtonWrapperView2 = _buttonWrapperViews2[0];
    
    // -----
    
    if (type == LGPlusButtonAnimationTypeCrossDissolve)
    {
        if (animated)
            [UIView transitionWithView:plusButtonWrapperView2
                              duration:0.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:completionHandler];
    }
    else if (type == LGPlusButtonAnimationTypeRotate)
    {
        if (animated)
        {
            [UIView animateWithDuration:0.2
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

- (void)addObservers
{
    if (!self.isObserversAdded && _parentView)
    {
        _observersAdded = YES;
        
        [_parentView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        
        if ([_parentView isKindOfClass:[UIScrollView class]])
        {
            [_parentView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
            [_parentView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

- (void)removeObservers
{
    if (self.isObserversAdded && _parentView)
    {
        _observersAdded = NO;
        
        [_parentView removeObserver:self forKeyPath:@"frame"];
        
        if ([_parentView isKindOfClass:[UIScrollView class]])
        {
            [_parentView removeObserver:self forKeyPath:@"contentInset"];
            [_parentView removeObserver:self forKeyPath:@"contentOffset"];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"])
        [self layoutInvalidate];
    else if ([keyPath isEqualToString:@"contentInset"])
        [self layoutInvalidate];
    else if ([keyPath isEqualToString:@"contentOffset"])
    {
        [self updatePosition];
        
        if (self.isShowWhenScrolling)
        {
            UIScrollView *scrollView = (UIScrollView *)_parentView;
            
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
                CGFloat minDiff = 64.f;
                CGFloat diff = self.offsetY - offsetY;
                
                if (scrollView.isTracking && scrollView.isDragging && (diff > minDiff || diff < -minDiff))
                {
                    if (self.offsetY > offsetY)
                        [self showAnimated:YES completionHandler:nil];
                    else
                        [self hideAnimated:YES completionHandler:nil];
                }
            }
            
            if (offsetY >= -scrollView.contentInset.top &&
                offsetY < scrollView.contentSize.height-scrollView.frame.size.height+scrollView.contentInset.bottom)
                self.tempOffsetY = offsetY;
        }
    }
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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
