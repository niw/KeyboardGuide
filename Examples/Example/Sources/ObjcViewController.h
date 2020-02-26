//
//  ObjcViewController.h
//  Example
//
//  Created by Yoshimasa Niwa on 2/19/20.
//  Copyright © 2020 Yoshimasa Niwa. All rights reserved.
//

// NOTE: Using KeyboardGuide in Swift Package from Objective-C requires Xcode 11.4, that has Swift 5.2.
// KeyboardGuide is a Swift target in the Swift Package.
// Prior to Swift 5.2, Swift Package Manager doesn't support using Swift target from Objective-C
// because it doesn't emit a module map and a header file needed for Objective-C.
//
// To make conditional build, extra build settings configuration file sets `XCODE_VERSION_ACTUAL`
// macro value for Objective-C code and use `swift(>=)` in Swift code.
// This conditional build is temporary workaround and it will be removed once Xcode 11.4 is released.
#if defined(XCODE_VERSION_ACTUAL) && XCODE_VERSION_ACTUAL >= 1140

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class ObjcViewController;

@protocol ObjcViewControllerDelegate <NSObject>

@optional
- (void)objcViewControllerDidTapDone:(ObjcViewController *)objcViewController;

@end

@interface ObjcViewController : UIViewController

@property (nonatomic, weak, nullable) id<ObjcViewControllerDelegate> delegate;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

#endif
