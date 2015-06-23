# LGPlusButtonsView

iOS implementation of Google 'plus button', that shows more options.

## Preview

<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGPlusButtonsView/Preview.gif" width="230"/>
<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGPlusButtonsView/1.png" width="230"/>
<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGPlusButtonsView/2.png" width="230"/>
<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGPlusButtonsView/3.png" width="230"/>

## Installation

### With source code

[Download repository](https://github.com/Friend-LGA/LGPlusButtonsView/archive/master.zip), then add [LGPlusButtonsView directory](https://github.com/Friend-LGA/LGPlusButtonsView/blob/master/LGPlusButtonsView/) to your project.

### With CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. See the "Get Started" section for more details.

#### Podfile

```
platform :ios, '6.0'
pod 'LGPlusButtonsView', '~> 1.0.0'
```

## Usage

In the source files where you need to use the library, import the header file:

```objective-c
#import "LGPlusButtonsView.h"
```

### Initialization

You have several methods for initialization:

```objective-c
- (instancetype)initWithView:(UIView *)view
             numberOfButtons:(NSUInteger)numberOfButtons
             showsPlusButton:(BOOL)showsPlusButton;
```

More init methods you can find in [LGPlusButtonsView.h](https://github.com/Friend-LGA/LGPlusButtonsView/blob/master/LGPlusButtonsView/LGPlusButtonsView.h)

### Handle actions

To handle actions you can use initialization methods with blocks or delegate, or implement it after initialization.

#### Delegate

```objective-c
@property (assign, nonatomic) id<LGPlusButtonsViewDelegate> delegate;

- (void)plusButtonsView:(LGPlusButtonsView *)plusButtonsView buttonPressedWithTitle:(NSString *)title description:(NSString *)description index:(NSUInteger)index;
- (void)plusButtonsViewPlusButtonPressed:(LGPlusButtonsView *)plusButtonsView;
```

#### Blocks

```objective-c
@property (strong, nonatomic) void (^actionHandler)(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index);
@property (strong, nonatomic) void (^plusButtonActionHandler)(LGPlusButtonsView *plusButtonView);
```

### More

For more details try Xcode [Demo project](https://github.com/Friend-LGA/LGPlusButtonsView/blob/master/Demo) and see [LGPlusButtonsView.h](https://github.com/Friend-LGA/LGPlusButtonsView/blob/master/LGPlusButtonsView/LGPlusButtonsView.h)

## License

LGPlusButtonsView is released under the MIT license. See [LICENSE](https://raw.githubusercontent.com/Friend-LGA/LGPlusButtonsView/master/LICENSE) for details.
