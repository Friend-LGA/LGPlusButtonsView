# LGPlusButtonsView

iOS implementation of Floating Action Button (Google Plus Button, fab), that shows more options.

## Preview

<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGPlusButtonsView/Preview.gif" width="218"/>
<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGPlusButtonsView/1.png" width="218"/>
<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGPlusButtonsView/2.png" width="218"/>
<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGPlusButtonsView/3.png" width="218"/>

## Installation

### With source code

[Download repository](https://github.com/Friend-LGA/LGPlusButtonsView/archive/master.zip), then add [LGPlusButtonsView directory](https://github.com/Friend-LGA/LGPlusButtonsView/blob/master/LGPlusButtonsView/) to your project.

### With CocoaPods

CocoaPods is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. To install with cocoaPods, follow the "Get Started" section on [CocoaPods](https://cocoapods.org/).

#### Podfile
```ruby
platform :ios, '6.0'
pod 'LGPlusButtonsView', '~> 1.1.0'
```

### With Carthage

Carthage is a lightweight dependency manager for Swift and Objective-C. It leverages CocoaTouch modules and is less invasive than CocoaPods. To install with carthage, follow the instruction on [Carthage](https://github.com/Carthage/Carthage/).

#### Cartfile
```
github "Friend-LGA/LGPlusButtonsView" ~> 1.1.0
```

## Usage

In the source files where you need to use the library, import the header file:

```objective-c
#import "LGPlusButtonsView.h"
```

### Initialization

You have several methods for initialization:

```objective-c
- (instancetype)initWithNumberOfButtons:(NSUInteger)numberOfButtons
                firstButtonIsPlusButton:(BOOL)firstButtonIsPlusButton
                          showAfterInit:(BOOL)showAfterInit;
```

More init methods you can find in [LGPlusButtonsView.h](https://github.com/Friend-LGA/LGPlusButtonsView/blob/master/LGPlusButtonsView/LGPlusButtonsView.h)

### Handle actions

To handle actions you can use blocks, delegate, or notifications:

#### Delegate

```objective-c
@property (assign, nonatomic) id<LGPlusButtonsViewDelegate> delegate;

- (void)plusButtonsViewWillShow:(LGPlusButtonsView *)plusButtonsView;
- (void)plusButtonsViewWillHide:(LGPlusButtonsView *)plusButtonsView;
- (void)plusButtonsViewDidShow:(LGPlusButtonsView *)plusButtonsView;
- (void)plusButtonsViewDidHide:(LGPlusButtonsView *)plusButtonsView;
- (void)plusButtonsViewWillShowButtons:(LGPlusButtonsView *)plusButtonsView;
- (void)plusButtonsViewWillHideButtons:(LGPlusButtonsView *)plusButtonsView;
- (void)plusButtonsViewDidShowButtons:(LGPlusButtonsView *)plusButtonsView;
- (void)plusButtonsViewDidHideButtons:(LGPlusButtonsView *)plusButtonsView;
- (void)plusButtonsView:(LGPlusButtonsView *)plusButtonsView buttonPressedWithTitle:(NSString *)title description:(NSString *)description index:(NSUInteger)index;
```

#### Blocks

```objective-c
@property (strong, nonatomic) void (^willShowHandler)(LGPlusButtonsView *plusButtonView);
@property (strong, nonatomic) void (^willHideHandler)(LGPlusButtonsView *plusButtonView);
@property (strong, nonatomic) void (^didShowHandler)(LGPlusButtonsView *plusButtonView);
@property (strong, nonatomic) void (^didHideHandler)(LGPlusButtonsView *plusButtonView);
@property (strong, nonatomic) void (^willShowButtonsHandler)(LGPlusButtonsView *plusButtonView);
@property (strong, nonatomic) void (^willHideButtonsHandler)(LGPlusButtonsView *plusButtonView);
@property (strong, nonatomic) void (^didShowButtonsHandler)(LGPlusButtonsView *plusButtonView);
@property (strong, nonatomic) void (^didHideButtonsHandler)(LGPlusButtonsView *plusButtonView);
@property (strong, nonatomic) void (^actionHandler)(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index);
```

#### Notifications

```objective-c
kLGPlusButtonsViewWillShowNotification;
kLGPlusButtonsViewWillHideNotification;
kLGPlusButtonsViewDidShowNotification;
kLGPlusButtonsViewDidHideNotification;
kLGPlusButtonsViewWillShowButtonsNotification;
kLGPlusButtonsViewWillHideButtonsNotification;
kLGPlusButtonsViewDidShowButtonsNotification;
kLGPlusButtonsViewDidHideButtonsNotification;
kLGPlusButtonsViewActionNotification;
```

### More

For more details try Xcode [Demo project](https://github.com/Friend-LGA/LGPlusButtonsView/blob/master/Demo) and see [LGPlusButtonsView.h](https://github.com/Friend-LGA/LGPlusButtonsView/blob/master/LGPlusButtonsView/LGPlusButtonsView.h)

## License

LGPlusButtonsView is released under the MIT license. See [LICENSE](https://raw.githubusercontent.com/Friend-LGA/LGPlusButtonsView/master/LICENSE) for details.
