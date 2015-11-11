//
//  PlusScrollViewController.m
//  LGPlusButtonsViewDemo
//
//  Created by Grigory Lutkov on 26.02.15.
//  Copyright (c) 2015 Grigory Lutkov. All rights reserved.
//

#import "PlusScrollViewController.h"
#import "LGPlusButtonsView.h"

@interface PlusScrollViewController ()

@property (strong, nonatomic) UIScrollView      *scrollView;
@property (strong, nonatomic) UILabel           *textLabel;
@property (strong, nonatomic) LGPlusButtonsView *plusButtonsView;

@end

@implementation PlusScrollViewController

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self)
    {
        self.title = title;

        // -----

        _scrollView = [UIScrollView new];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.alwaysBounceVertical = YES;
        [self.view addSubview:_scrollView];

        _textLabel = [UILabel new];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.text = @"UIScrollView";
        [_scrollView addSubview:_textLabel];

        _plusButtonsView = [[LGPlusButtonsView alloc] initWithView:_scrollView
                                                   numberOfButtons:3
                                                   showsPlusButton:YES
                                                     actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                            {
                                NSLog(@"%@, %@, %i", title, description, (int)index);
                            }
                                           plusButtonActionHandler:nil];

        [_plusButtonsView setButtonsTitles:@[@"+", @"1", @"2", @"3"] forState:UIControlStateNormal];
        [_plusButtonsView setDescriptionsTexts:@[@"", @"Button One description", @"Button Two description", @"Button Three description"]];
        _plusButtonsView.position = LGPlusButtonsViewPositionBottomRight;
        _plusButtonsView.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndSlideVertical;
        _plusButtonsView.buttonsAppearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndSlideHorizontal;
        _plusButtonsView.plusButtonAnimationType = LGPlusButtonAnimationTypeRotate;
        [_plusButtonsView setButtonsTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_plusButtonsView setButtonsAdjustsImageWhenHighlighted:NO];
        [_plusButtonsView setButtonsImage:[UIImage imageNamed:@"Circle_Normal"] forState:UIControlStateNormal];
        [_plusButtonsView setButtonsImage:[UIImage imageNamed:@"Circle_Highlighted"] forState:UIControlStateHighlighted];
        [_plusButtonsView setButtonsLayerShadowColor:[UIColor blackColor] shadowOpacity:0.5 shadowOffset:CGSizeZero shadowRadius:2.f];
        //_plusButtonsView.alwaysVisible = YES;
        //_plusButtonsView.hideButtonsOnScroll = YES;
        //_plusButtonsView.scrollSensitivity = 0.f;

        [_plusButtonsView showAnimated:NO completionHandler:nil];
    }
    return self;
}

#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__);
}

#pragma mark - Appearing

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    _scrollView.frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height);

    [_textLabel sizeToFit];
    _textLabel.center = CGPointMake(_scrollView.frame.size.width/2, 20.f+_textLabel.frame.size.height/2);
    _textLabel.frame = CGRectIntegral(_textLabel.frame);

    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 3000.f);

    // -----

    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);

    CGFloat buttonSide = (isPortrait ? 64.f : 44.f);
    CGFloat inset = (isPortrait ? 3.f : 2.f);
    CGFloat buttonsFontSize = (isPortrait ? 30.f : 20.f);
    CGFloat plusButtonFontSize = buttonsFontSize*1.5;

    _plusButtonsView.buttonInset = UIEdgeInsetsMake(inset, inset, inset, inset);
    _plusButtonsView.contentInset = UIEdgeInsetsMake(inset, inset, inset, inset);
    [_plusButtonsView setButtonsTitleFont:[UIFont boldSystemFontOfSize:buttonsFontSize]];

    _plusButtonsView.plusButton.titleLabel.font = [UIFont systemFontOfSize:plusButtonFontSize];
    _plusButtonsView.plusButton.titleOffset = CGPointMake(0.f, -plusButtonFontSize*0.1);

    _plusButtonsView.buttonsSize = CGSizeMake(buttonSide, buttonSide);
}

@end
