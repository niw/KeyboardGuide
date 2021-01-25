//
//  ObjcViewController.h
//  Example
//
//  Created by Yoshimasa Niwa on 2/19/20.
//  Copyright © 2020 Yoshimasa Niwa. All rights reserved.
//

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
