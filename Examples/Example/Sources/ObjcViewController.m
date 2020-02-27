//
//  ObjcViewController.m
//  Example
//
//  Created by Yoshimasa Niwa on 2/19/20.
//  Copyright © 2020 Yoshimasa Niwa. All rights reserved.
//

// See `ObjcViewController.h` for the details.
#if defined(XCODE_VERSION_ACTUAL) && XCODE_VERSION_ACTUAL >= 1140

#import "ObjcViewController.h"

@import KeyboardGuide;

@interface ObjcViewController () <KBGKeyboardGuideObserver, KBGKeyboardSafeAreaViewDelegate>

@property (nonatomic, nullable) KBGKeyboardSafeAreaView *keyboardSafeAreaView;
@property (nonatomic, nullable) UILabel *label;
@property (nonatomic, nullable) UITextView *textView;

@end

@implementation ObjcViewController

- (instancetype)init
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        [self _objcViewController_initialize];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    [self doesNotRecognizeSelector:_cmd];
    abort();
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self _objcViewController_initialize];
    }
    return self;
}

- (void)_objcViewController_initialize
{
    self.title = @"Example";

    UIBarButtonItem * const doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_action_didTapDone:)];
    self.navigationItem.rightBarButtonItems = @[doneBarButtonItem];
}

// MARK: - Actions

- (void)_action_didTapDone:(id)sender
{
    id<ObjcViewControllerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(objcViewControllerDidTapDone:)]) {
        [delegate objcViewControllerDidTapDone:self];
    }
}

// MARK: - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [KBGKeyboardGuide.sharedGuide addObserver:self];

    if (@available(iOS 13, *)) {
        self.view.backgroundColor = UIColor.systemBackgroundColor;
    } else {
        self.view.backgroundColor = UIColor.whiteColor;
    }

    NSMutableArray<NSLayoutConstraint *> * const constraints = [[NSMutableArray alloc] init];

    KBGKeyboardSafeAreaView * const keyboardSafeAreaView = [[KBGKeyboardSafeAreaView alloc] init];
    keyboardSafeAreaView.delegate = self;

    keyboardSafeAreaView.translatesAutoresizingMaskIntoConstraints = NO;
    [constraints addObject:[keyboardSafeAreaView.topAnchor constraintEqualToAnchor:self.view.topAnchor]];
    [constraints addObject:[keyboardSafeAreaView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor]];
    [constraints addObject:[keyboardSafeAreaView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]];
    [constraints addObject:[keyboardSafeAreaView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor]];
    [self.view addSubview:keyboardSafeAreaView];
    self.keyboardSafeAreaView = keyboardSafeAreaView;

    UILabel * const label = [[UILabel alloc] init];

    label.translatesAutoresizingMaskIntoConstraints = NO;
    [constraints addObject:[label.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor]];
    [constraints addObject:[label.leftAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leftAnchor]];
    [constraints addObject:[label.rightAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.rightAnchor]];
    [self.view addSubview:label];
    self.label = label;

    UITextView * const textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:UIFont.systemFontSize * 2.0];
    textView.layer.borderColor = UIColor.redColor.CGColor;
    textView.layer.borderWidth = 1.0;
    NSMutableString * const text = [[NSMutableString alloc] init];
    for (NSUInteger count = 0; count < 10; count++) {
        [text appendString:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n"];
    }
    textView.text = text;

    textView.translatesAutoresizingMaskIntoConstraints = NO;
    [constraints addObject:[textView.topAnchor constraintEqualToAnchor:label.bottomAnchor]];
    [constraints addObject:[textView.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor]];
    [constraints addObject:[textView.bottomAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.bottomAnchor]];
    [constraints addObject:[textView.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor]];
    [self.view addSubview:textView];
    self.textView = textView;

    [NSLayoutConstraint activateConstraints:constraints];

    [self _main_updateLabelText];
}

// MARK: - KBGKeyboardSafeAreaViewDelegate

- (void)keyboardSafeAreaView:(KBGKeyboardSafeAreaView *)keyboardSafeAreaView didChangeInsets:(UIEdgeInsets)insets
{
    UIEdgeInsets contentInsets = self.textView.contentInset;
    contentInsets.bottom = insets.bottom;
    self.textView.contentInset = contentInsets;

    UIEdgeInsets scrollIndicatorInsets = self.textView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom = insets.bottom;
    self.textView.scrollIndicatorInsets = scrollIndicatorInsets;
}

// MARK: - KBGKeyboardGuideObserver

- (void)keyboardGuide:(KBGKeyboardGuide *)keyboardGuide didChangeDockedKeyboardState:(KBGKeyboardState *)dockedKeyboardState
{
    [self _main_updateLabelText];
}

- (void)_main_updateLabelText
{
    KBGKeyboardState * const dockedKeyboardState = KBGKeyboardGuide.sharedGuide.dockedKeyboardState;

    NSString *text;
    if (dockedKeyboardState) {
        const CGRect frame = [dockedKeyboardState frameInView:self.view];
        text = NSStringFromCGRect(frame);
    } else {
        text = @"Undocked";
    }
    self.label.text = text;
}

@end

#endif
