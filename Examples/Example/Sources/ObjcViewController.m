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

@interface ObjcViewController () <KBGKeyboardGuideObserver>

@property (nonatomic, nullable) KBGKeyboardSafeAreaView *keyboardSafeAreaView;
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

    keyboardSafeAreaView.translatesAutoresizingMaskIntoConstraints = NO;
    [constraints addObject:[keyboardSafeAreaView.topAnchor constraintEqualToAnchor:self.view.topAnchor]];
    [constraints addObject:[keyboardSafeAreaView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor]];
    [constraints addObject:[keyboardSafeAreaView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]];
    [constraints addObject:[keyboardSafeAreaView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor]];
    [self.view addSubview:keyboardSafeAreaView];
    self.keyboardSafeAreaView = keyboardSafeAreaView;

    UITextView * const textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:UIFont.systemFontSize * 2.0];
    textView.layer.borderColor = UIColor.redColor.CGColor;
    textView.layer.borderWidth = 1.0;

    textView.translatesAutoresizingMaskIntoConstraints = NO;
    [constraints addObject:[textView.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor]];
    [constraints addObject:[textView.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor]];
    [constraints addObject:[textView.bottomAnchor constraintEqualToAnchor:keyboardSafeAreaView.layoutGuide.bottomAnchor]];
    [constraints addObject:[textView.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor]];
    [self.view addSubview:textView];
    self.textView = textView;

    [NSLayoutConstraint activateConstraints:constraints];
}

// MARK: - KBGKeyboardGuideObserver

- (void)keyboardGuide:(KBGKeyboardGuide *)keyboardGuide didChangeDockedKeyboardState:(KBGKeyboardState *)dockedKeyboardState
{
    NSString *text;
    if (dockedKeyboardState) {
        const CGRect frame = [dockedKeyboardState frameInView:self.view];
        text = NSStringFromCGRect(frame);
    } else {
        text = @"Undocked";
    }
    self.textView.text = text;
}

@end

#endif
