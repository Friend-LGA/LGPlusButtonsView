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

// Do not forget about "protected"
@interface LGPlusButton ()

@property (assign, nonatomic, getter=isShowing) BOOL showing;

@end

@implementation LGPlusButton

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.layer.anchorPoint = CGPointMake(0.5, 0.5);
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        _titleOffset = CGPointZero;
        _imageOffset = CGPointZero;
    }
    return self;
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat scaleX = [[self.layer valueForKeyPath:@"transform.scale.x"] floatValue];
    CGFloat scaleY = [[self.layer valueForKeyPath:@"transform.scale.y"] floatValue];
    
    CGRect selfFrame = CGRectMake(0.f, 0.f, self.frame.size.width/scaleX, self.frame.size.height/scaleY);
    
    CGSize sizeToFit = CGSizeMake(selfFrame.size.width-self.contentEdgeInsets.left-self.contentEdgeInsets.right,
                                  selfFrame.size.height-self.contentEdgeInsets.top-self.contentEdgeInsets.bottom);
    
    if (self.titleLabel.text.length)
    {
        CGSize titleLabelSize = [self.titleLabel sizeThatFits:sizeToFit];
        CGRect titleLabelFrame = CGRectMake(selfFrame.size.width/2-titleLabelSize.width/2+_titleOffset.x,
                                            selfFrame.size.height/2-titleLabelSize.height/2+_titleOffset.y,
                                            titleLabelSize.width,
                                            titleLabelSize.height);
        if ([UIScreen mainScreen].scale == 1.f) titleLabelFrame = CGRectIntegral(titleLabelFrame);
        self.titleLabel.frame = titleLabelFrame;
    }
    
    if (self.imageView.image)
    {
        CGSize imageViewSize = [self.imageView sizeThatFits:sizeToFit];
        CGRect imageViewFrame = CGRectMake(selfFrame.size.width/2-imageViewSize.width/2+_imageOffset.x,
                                           selfFrame.size.height/2-imageViewSize.height/2+_imageOffset.y,
                                           imageViewSize.width,
                                           imageViewSize.height);
        if ([UIScreen mainScreen].scale == 1.f) imageViewFrame = CGRectIntegral(imageViewFrame);
        self.imageView.frame = imageViewFrame;
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize titleLabelSize = (self.titleLabel.text.length ? [self.titleLabel sizeThatFits:size] : CGSizeZero);
    CGSize imageViewSize = (self.imageView.image ? [self.imageView sizeThatFits:size] : CGSizeZero);
    
    CGSize resultSize = CGSizeMake(MAX(titleLabelSize.width, imageViewSize.width)+self.contentEdgeInsets.left+self.contentEdgeInsets.right,
                                   MAX(titleLabelSize.height, imageViewSize.height)+self.contentEdgeInsets.top+self.contentEdgeInsets.bottom);
    
    return resultSize;
}

#pragma mark - Setters and Getters

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    [self setBackgroundImage:[LGPlusButton image1x1WithColor:backgroundColor] forState:state];
}

- (void)setTitleOffset:(CGPoint)titleOffset
{
    if (!CGPointEqualToPoint(_titleOffset, titleOffset))
    {
        _titleOffset = titleOffset;
        
        [self layoutSubviews];
    }
}

- (void)setImageOffset:(CGPoint)imageOffset
{
    if (!CGPointEqualToPoint(_imageOffset, imageOffset))
    {
        _imageOffset = imageOffset;
        
        [self layoutSubviews];
    }
}

#pragma mark - Support

+ (UIImage *)image1x1WithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.f, 0.f, 1.f, 1.f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
