//
//  LGPlusButton.m
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

#import "LGPlusButton.h"
#import "LGPlusButtonsViewShared.h"

@interface LGPlusButton ()

@property (strong, nonatomic) NSMutableDictionary *imagesDictionary;
@property (strong, nonatomic) NSMutableDictionary *titleFontsDictionary;
@property (strong, nonatomic) NSMutableDictionary *insetsDictionary;
@property (strong, nonatomic) NSMutableDictionary *offsetsDictionary;
@property (strong, nonatomic) NSMutableDictionary *sizesDictionary;
@property (strong, nonatomic) NSMutableDictionary *contentEdgeInsetsDictionary;
@property (strong, nonatomic) NSMutableDictionary *titleOffsetsDictionary;
@property (strong, nonatomic) NSMutableDictionary *imageOffsetsDictionary;
@property (strong, nonatomic) NSMutableDictionary *backgroundColorsDictionary;
@property (strong, nonatomic) NSMutableDictionary *layerCornerRadiusDictionary;

@property (assign, nonatomic) UIEdgeInsets insets;
@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) CGPoint titleOffset;
@property (assign, nonatomic) CGPoint imageOffset;

@end

@implementation LGPlusButton

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.layer.masksToBounds = YES;
        self.imageView.contentMode = UIViewContentModeCenter;

        // -----

        _imagesDictionary = [NSMutableDictionary new];
        _titleFontsDictionary = [NSMutableDictionary new];
        _insetsDictionary = [NSMutableDictionary new];
        _offsetsDictionary = [NSMutableDictionary new];
        _sizesDictionary = [NSMutableDictionary new];
        _contentEdgeInsetsDictionary = [NSMutableDictionary new];
        _titleOffsetsDictionary = [NSMutableDictionary new];
        _imageOffsetsDictionary = [NSMutableDictionary new];
        _backgroundColorsDictionary = [NSMutableDictionary new];
        _layerCornerRadiusDictionary = [NSMutableDictionary new];

        // -----

        [self setInsets:UIEdgeInsetsMake(kLGPlusButtonsViewMargin, kLGPlusButtonsViewMargin, kLGPlusButtonsViewMargin, kLGPlusButtonsViewMargin) forOrientation:LGPlusButtonsViewOrientationAll];
    }
    return self;
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];

    // -----

    LGPlusButtonsViewOrientation orientation = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationLandscape;

    // -----

    CGFloat scaleX = [[self.layer valueForKeyPath:@"transform.scale.x"] floatValue];
    CGFloat scaleY = [[self.layer valueForKeyPath:@"transform.scale.y"] floatValue];
    
    CGRect selfFrame = CGRectMake(0.f, 0.f, self.frame.size.width/scaleX, self.frame.size.height/scaleY);

    UIEdgeInsets contentEdgeInsets = [self contentEdgeInsetsForOrientation:orientation];

    CGSize sizeToFit = CGSizeMake(selfFrame.size.width-contentEdgeInsets.left-contentEdgeInsets.right,
                                  selfFrame.size.height-contentEdgeInsets.top-contentEdgeInsets.bottom);
    
    if (self.titleLabel.text.length)
    {
        CGSize titleLabelSize = [self.titleLabel sizeThatFits:sizeToFit];
        CGRect titleLabelFrame = CGRectMake(selfFrame.size.width/2-titleLabelSize.width/2+_titleOffset.x,
                                            selfFrame.size.height/2-titleLabelSize.height/2+_titleOffset.y,
                                            titleLabelSize.width,
                                            titleLabelSize.height);
        if ([UIScreen mainScreen].scale == 1.f)
            titleLabelFrame = CGRectIntegral(titleLabelFrame);
        self.titleLabel.frame = titleLabelFrame;
    }
    
    if (self.imageView.image)
    {
        CGSize imageViewSize = [self.imageView sizeThatFits:sizeToFit];
        if (imageViewSize.width > sizeToFit.width || imageViewSize.height > sizeToFit.height)
        {
            CGFloat aspect = imageViewSize.width/imageViewSize.height;

            imageViewSize.width = (imageViewSize.width > imageViewSize.height ? sizeToFit.width : sizeToFit.height);
            imageViewSize.height = imageViewSize.width/aspect;

        }
        CGRect imageViewFrame = CGRectMake(selfFrame.size.width/2-imageViewSize.width/2+_imageOffset.x,
                                           selfFrame.size.height/2-imageViewSize.height/2+_imageOffset.y,
                                           imageViewSize.width,
                                           imageViewSize.height);
        if ([UIScreen mainScreen].scale == 1.f)
            imageViewFrame = CGRectIntegral(imageViewFrame);
        self.imageView.frame = imageViewFrame;
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    LGPlusButtonsViewOrientation orientation = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationLandscape;

    // -----

    CGSize buttonSize = [self sizeForOrientation:orientation];
    if (!CGSizeEqualToSize(buttonSize, CGSizeZero))
        return buttonSize;

    UIEdgeInsets contentEdgeInsets = [self contentEdgeInsetsForOrientation:orientation];

    CGSize titleLabelSize = (self.titleLabel.text.length ? [self.titleLabel sizeThatFits:size] : CGSizeZero);
    CGSize imageViewSize = (self.imageView.image ? [self.imageView sizeThatFits:size] : CGSizeZero);

    CGSize resultSize = CGSizeMake(MAX(titleLabelSize.width, imageViewSize.width)+contentEdgeInsets.left+contentEdgeInsets.right,
                                   MAX(titleLabelSize.height, imageViewSize.height)+contentEdgeInsets.top+contentEdgeInsets.bottom);

    return resultSize;
}

#pragma mark - Setters and Getters

- (void)updateParametersForOrientation:(LGPlusButtonsViewOrientation)orientation
{
    [self setImage:[self imageForState:UIControlStateNormal forOrientation:orientation] forState:UIControlStateNormal];
    [self setImage:[self imageForState:UIControlStateHighlighted forOrientation:orientation] forState:UIControlStateHighlighted];
    [self setImage:[self imageForState:UIControlStateSelected forOrientation:orientation] forState:UIControlStateSelected];
    [self setImage:[self imageForState:UIControlStateDisabled forOrientation:orientation] forState:UIControlStateDisabled];
    [self setImage:[self imageForState:UIControlStateHighlighted|UIControlStateSelected forOrientation:orientation] forState:UIControlStateHighlighted|UIControlStateSelected];
    [self setImage:[self imageForState:UIControlStateHighlighted|UIControlStateDisabled forOrientation:orientation] forState:UIControlStateHighlighted|UIControlStateDisabled];
    [self setImage:[self imageForState:UIControlStateSelected|UIControlStateDisabled forOrientation:orientation] forState:UIControlStateSelected|UIControlStateDisabled];

    self.titleLabel.font    = [self titleFontForOrientation:orientation];
    self.contentEdgeInsets  = [self contentEdgeInsetsForOrientation:orientation];
    self.insets             = [self insetsForOrientation:orientation];
    self.size               = [self sizeForOrientation:orientation];
    self.titleOffset        = [self titleOffsetForOrientation:orientation];
    self.imageOffset        = [self imageOffsetForOrientation:orientation];
    self.layer.cornerRadius = [self layerCornerRadiusForOrientation:orientation];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    [_imagesDictionary setObject:image forKey:[LGPlusButtonsViewShared stringFromState:state andOrientation:orientation]];

    if (orientation == LGPlusButtonsViewOrientationAll)
    {
        [_imagesDictionary setObject:image forKey:[LGPlusButtonsViewShared stringFromState:state andOrientation:LGPlusButtonsViewOrientationPortrait]];
        [_imagesDictionary setObject:image forKey:[LGPlusButtonsViewShared stringFromState:state andOrientation:LGPlusButtonsViewOrientationLandscape]];
    }

    [self setNeedsLayout];
}

- (UIImage *)imageForState:(UIControlState)state forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    return [_imagesDictionary objectForKey:[LGPlusButtonsViewShared stringFromState:state andOrientation:orientation]];
}

- (void)setTitleFont:(UIFont *)font forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    [_titleFontsDictionary setObject:font forKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

    if (orientation == LGPlusButtonsViewOrientationAll)
    {
        [_titleFontsDictionary setObject:font forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationPortrait]];
        [_titleFontsDictionary setObject:font forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationLandscape]];
    }

    [self setNeedsLayout];
}

- (UIFont *)titleFontForOrientation:(LGPlusButtonsViewOrientation)orientation
{
    return [_titleFontsDictionary objectForKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];
}

- (void)setInsets:(UIEdgeInsets)insets forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSString *insetsString = NSStringFromUIEdgeInsets(insets);

    [_insetsDictionary setObject:insetsString forKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

    if (orientation == LGPlusButtonsViewOrientationAll)
    {
        [_insetsDictionary setObject:insetsString forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationPortrait]];
        [_insetsDictionary setObject:insetsString forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationLandscape]];
    }

    [self setNeedsLayout];
}

- (UIEdgeInsets)insetsForOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSString *insetsString = [_insetsDictionary objectForKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

    return (insetsString ? UIEdgeInsetsFromString(insetsString) : UIEdgeInsetsZero);
}

- (void)setOffset:(CGPoint)offset forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSString *offsetString = NSStringFromCGPoint(offset);

    [_offsetsDictionary setObject:offsetString forKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

    if (orientation == LGPlusButtonsViewOrientationAll)
    {
        [_offsetsDictionary setObject:offsetString forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationPortrait]];
        [_offsetsDictionary setObject:offsetString forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationLandscape]];
    }

    [self setNeedsLayout];
}

- (CGPoint)offsetForOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSString *offsetString = [_offsetsDictionary objectForKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

    return (offsetString ? CGPointFromString(offsetString) : CGPointZero);
}

- (void)setSize:(CGSize)size forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSString *sizeString = NSStringFromCGSize(size);

    [_sizesDictionary setObject:sizeString forKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

    if (orientation == LGPlusButtonsViewOrientationAll)
    {
        [_sizesDictionary setObject:sizeString forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationPortrait]];
        [_sizesDictionary setObject:sizeString forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationLandscape]];
    }

    [self setNeedsLayout];
}

- (CGSize)sizeForOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSString *sizeString = [_sizesDictionary objectForKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

    return (sizeString ? CGSizeFromString(sizeString) : CGSizeZero);
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

- (void)setTitleOffset:(CGPoint)titleOffset forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSString *titleOffsetString = NSStringFromCGPoint(titleOffset);

    [_titleOffsetsDictionary setObject:titleOffsetString forKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

    if (orientation == LGPlusButtonsViewOrientationAll)
    {
        [_titleOffsetsDictionary setObject:titleOffsetString forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationPortrait]];
        [_titleOffsetsDictionary setObject:titleOffsetString forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationLandscape]];
    }

    [self setNeedsLayout];
}

- (CGPoint)titleOffsetForOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSString *titleOffsetString = [_titleOffsetsDictionary objectForKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

    return (titleOffsetString ? CGPointFromString(titleOffsetString) : CGPointZero);
}

- (void)setImageOffset:(CGPoint)imageOffset forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSString *imageOffsetString = NSStringFromCGPoint(imageOffset);

    [_imageOffsetsDictionary setObject:imageOffsetString forKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

    if (orientation == LGPlusButtonsViewOrientationAll)
    {
        [_imageOffsetsDictionary setObject:imageOffsetString forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationPortrait]];
        [_imageOffsetsDictionary setObject:imageOffsetString forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationLandscape]];
    }

    [self setNeedsLayout];
}

- (CGPoint)imageOffsetForOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSString *imageOffsetString = [_imageOffsetsDictionary objectForKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

    return (imageOffsetString ? CGPointFromString(imageOffsetString) : CGPointZero);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    [self setBackgroundImage:[LGPlusButtonsViewShared image1x1WithColor:backgroundColor] forState:state];

    [_backgroundColorsDictionary setObject:backgroundColor forKey:[LGPlusButtonsViewShared stringFromState:state]];
}

- (UIColor *)backgroundColorForState:(UIControlState)state
{
    return [_backgroundColorsDictionary objectForKey:[LGPlusButtonsViewShared stringFromState:state]];
}

- (void)setLayerCornerRadius:(CGFloat)cornerRadius forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSNumber *cornerRadiusNumber = [NSNumber numberWithFloat:cornerRadius];

    [_layerCornerRadiusDictionary setObject:cornerRadiusNumber forKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

    if (orientation == LGPlusButtonsViewOrientationAll)
    {
        [_layerCornerRadiusDictionary setObject:cornerRadiusNumber forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationPortrait]];
        [_layerCornerRadiusDictionary setObject:cornerRadiusNumber forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationLandscape]];
    }

    [self setNeedsLayout];
}

- (CGFloat)layerCornerRadiusForOrientation:(LGPlusButtonsViewOrientation)orientation;
{
    NSNumber *cornerRadiusNumber = [_layerCornerRadiusDictionary objectForKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

    return (cornerRadiusNumber ? cornerRadiusNumber.floatValue : 0.f);
}

@end
