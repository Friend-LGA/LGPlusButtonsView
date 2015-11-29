//
//  LGPlusButtonDescription.m
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

#import "LGPlusButtonDescription.h"
#import "LGPlusButtonsViewShared.h"

@interface LGPlusButtonDescription ()

@property (strong, nonatomic) NSMutableDictionary *fontsDictionary;
@property (strong, nonatomic) NSMutableDictionary *insetsDictionary;
@property (strong, nonatomic) NSMutableDictionary *offsetDictionary;
@property (strong, nonatomic) NSMutableDictionary *sizesDictionary;
@property (strong, nonatomic) NSMutableDictionary *contentEdgeInsetsDictionary;
@property (strong, nonatomic) NSMutableDictionary *layerCornerRadiusDictionary;

@property (assign, nonatomic) UIEdgeInsets contentEdgeInsets;
@property (assign, nonatomic) UIEdgeInsets insets;
@property (assign, nonatomic) CGSize size;

@end

@implementation LGPlusButtonDescription

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.numberOfLines = 0;
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = YES;
        self.userInteractionEnabled = NO;

        // -----

        _fontsDictionary = [NSMutableDictionary new];
        _insetsDictionary = [NSMutableDictionary new];
        _offsetDictionary = [NSMutableDictionary new];
        _sizesDictionary = [NSMutableDictionary new];
        _contentEdgeInsetsDictionary = [NSMutableDictionary new];
        _layerCornerRadiusDictionary = [NSMutableDictionary new];

        // -----

        [self setFont:[UIFont systemFontOfSize:14.f] forOrientation:LGPlusButtonsViewOrientationAll];
        [self setInsets:UIEdgeInsetsMake(kLGPlusButtonsViewMargin, kLGPlusButtonsViewMargin, kLGPlusButtonsViewMargin, kLGPlusButtonsViewMargin) forOrientation:LGPlusButtonsViewOrientationAll];
    }
    return self;
}

#pragma mark -

- (void)drawTextInRect:(CGRect)rect
{
    rect.origin.x += _contentEdgeInsets.left;
    rect.size.width -= (_contentEdgeInsets.left+_contentEdgeInsets.right);

    [super drawTextInRect:rect];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    LGPlusButtonsViewOrientation orientation = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? LGPlusButtonsViewOrientationPortrait : LGPlusButtonsViewOrientationLandscape;

    // -----

    CGSize descriptionSize = [self sizeForOrientation:orientation];
    if (!CGSizeEqualToSize(descriptionSize, CGSizeZero))
        return descriptionSize;

    size.width -= (_insets.left+_insets.right+_contentEdgeInsets.left+_contentEdgeInsets.right);

    CGSize resultSize = (self.text.length ? [super sizeThatFits:size] : CGSizeZero);

    if (!CGSizeEqualToSize(resultSize, CGSizeZero))
    {
        resultSize.width += _contentEdgeInsets.left+_contentEdgeInsets.right;
        resultSize.height += _contentEdgeInsets.top+_contentEdgeInsets.bottom;
    }

    return resultSize;
}

#pragma mark - Setters and Getters

- (void)updateParametersForOrientation:(LGPlusButtonsViewOrientation)orientation
{
    self.font               = [self fontForOrientation:orientation];
    self.contentEdgeInsets  = [self contentEdgeInsetsForOrientation:orientation];
    self.insets             = [self insetsForOrientation:orientation];
    self.size               = [self sizeForOrientation:orientation];
    self.layer.cornerRadius = [self layerCornerRadiusForOrientation:orientation];
}

- (void)setFont:(UIFont *)font forOrientation:(LGPlusButtonsViewOrientation)orientation
{
    [_fontsDictionary setObject:font forKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

    if (orientation == LGPlusButtonsViewOrientationAll)
    {
        [_fontsDictionary setObject:font forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationPortrait]];
        [_fontsDictionary setObject:font forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationLandscape]];
    }

    [self setNeedsLayout];
}

- (UIFont *)fontForOrientation:(LGPlusButtonsViewOrientation)orientation
{
    return [_fontsDictionary objectForKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];
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

    [_offsetDictionary setObject:offsetString forKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

    if (orientation == LGPlusButtonsViewOrientationAll)
    {
        [_offsetDictionary setObject:offsetString forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationPortrait]];
        [_offsetDictionary setObject:offsetString forKey:[LGPlusButtonsViewShared stringFromOrientation:LGPlusButtonsViewOrientationLandscape]];
    }

    [self setNeedsLayout];
}

- (CGPoint)offsetForOrientation:(LGPlusButtonsViewOrientation)orientation
{
    NSString *offsetString = [_offsetDictionary objectForKey:[LGPlusButtonsViewShared stringFromOrientation:orientation]];

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
