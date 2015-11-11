//
//  PlusViewController.m
//  LGPlusButtonsViewDemo
//
//  Created by Grigory Lutkov on 05.03.15.
//  Copyright (c) 2015 Grigory Lutkov. All rights reserved.
//

#import "PlusViewController.h"
#import "LGPlusButtonsView.h"

@interface PlusViewController ()

@property (strong, nonatomic) UIView            *contentView;
@property (strong, nonatomic) UILabel           *textLabel;
@property (strong, nonatomic) LGPlusButtonsView *plusButtonsView;

@end

@implementation PlusViewController

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self)
    {
        self.title = title;

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showHideButtonsAction)];

        // -----

        _contentView = [UIView new];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_contentView];

        _textLabel = [UILabel new];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.text = @"UIView";
        [_contentView addSubview:_textLabel];

        _plusButtonsView = [[LGPlusButtonsView alloc] initWithView:_contentView
                                                   numberOfButtons:3
                                                   showsPlusButton:NO
                                                     actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                            {
                                NSLog(@"%@, %@, %i", title, description, (int)index);
                            }
                                           plusButtonActionHandler:nil];

        [_plusButtonsView setButtonsTitles:@[@"1", @"2", @"3"] forState:UIControlStateNormal];
        [_plusButtonsView setDescriptionsTexts:@[@"Button One description", @"Button Two description", @"Button Three description"]];
        _plusButtonsView.position = LGPlusButtonsViewPositionTopRight;
        _plusButtonsView.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
        [_plusButtonsView setButtonsTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_plusButtonsView setButtonsAdjustsImageWhenHighlighted:NO];
        [_plusButtonsView setButtonsImage:[UIImage imageNamed:@"Circle_Normal"] forState:UIControlStateNormal];
        [_plusButtonsView setButtonsImage:[UIImage imageNamed:@"Circle_Highlighted"] forState:UIControlStateHighlighted];
        [_plusButtonsView setButtonsLayerShadowColor:[UIColor blackColor] shadowOpacity:0.5 shadowOffset:CGSizeZero shadowRadius:2.f];
    }
    return self;
}

- (void)showHideButtonsAction
{
    if (_plusButtonsView.isShowing)
        [_plusButtonsView hideAnimated:YES completionHandler:nil];
    else
        [_plusButtonsView showAnimated:YES completionHandler:nil];
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

    CGFloat topInset = 0.f;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
    {
        topInset += (self.navigationController.navigationBarHidden ? 0.f : MIN(self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height));
        topInset += ([UIApplication sharedApplication].statusBarHidden ? 0.f : MIN([UIApplication sharedApplication].statusBarFrame.size.width, [UIApplication sharedApplication].statusBarFrame.size.height));
    }
    _contentView.frame = CGRectMake(0.f, topInset, self.view.frame.size.width, self.view.frame.size.height-topInset);

    [_textLabel sizeToFit];
    _textLabel.center = CGPointMake(_contentView.frame.size.width/2, _contentView.frame.size.height-20.f-_textLabel.frame.size.height/2);
    _textLabel.frame = CGRectIntegral(_textLabel.frame);

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
