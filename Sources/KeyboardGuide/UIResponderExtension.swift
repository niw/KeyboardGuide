//
//  UIResponderExtension.swift
//  KeyboardGuide
//
//  Created by Yoshimasa Niwa on 2/18/20.
//  Copyright © 2020 Yoshimasa Niwa. All rights reserved.
//

import Foundation
import ObjectiveC
import UIKit

extension UIResponder {
    private static var shouldRestoreFirstResponderAssociateKey: UInt8 = 0

    /**
     Set `true` or `false` to explicitly restore first responder when the application will enter foreground.
     Default to `true` for any `UITextInputTraits`, `false` for the others.

     - See also:
       - `KeyboardGuide.lastFirstResponder` (Private)
     */
    @objc(kbg_shouldRestoreFirstResponder)
    public var shouldRestoreFirstResponder: Bool {
        set {
            objc_setAssociatedObject(self, &UIResponder.shouldRestoreFirstResponderAssociateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let shouldRestoreFirstResponder = objc_getAssociatedObject(self, &UIResponder.shouldRestoreFirstResponderAssociateKey) as? Bool {
                return shouldRestoreFirstResponder
            }

            return self is UITextInputTraits
        }
    }

    private static weak var repliedFirstResponder: UIResponder?

    @objc(_kbg_replyFristResponder)
    func replyFirstResponder() {
        UIResponder.repliedFirstResponder = self
    }

    private static var isReplyingFirstResponder = false

    static var currentFirstResponder: UIResponder? {
        assert(Thread.isMainThread, "Must be called on main thread")

        guard !isReplyingFirstResponder else { return nil }
        isReplyingFirstResponder = true
        defer {
            isReplyingFirstResponder = false
        }

        repliedFirstResponder = nil
        UIApplication.shared.sendAction(#selector(replyFirstResponder), to: nil, from: self, for: nil)
        let currentFirstResponder = repliedFirstResponder

        return currentFirstResponder
    }
}
