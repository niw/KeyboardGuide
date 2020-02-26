//
//  UIWindowExtension.swift
//  KeyboardGuide
//
//  Created by Yoshimasa Niwa on 2/20/20.
//  Copyright © 2020 Yoshimasa Niwa. All rights reserved.
//

import Foundation
import ObjectiveC
import UIKit

extension UIWindow {
    private static var keyboardSafeAreaAssociateKey: UInt8 = 0

    /**
     A keyboard safe area for this `UIWindow`.
     Recommend to use `KeyboardSafeAreaView` instead.

     - See also:
       - `KeyboardSafeAreaView`
     */
    @objc(kbg_keyboardSafeArea)
    public var keyboardSafeArea: KeyboardSafeArea {
        if let keyboardSafeArea = objc_getAssociatedObject(self, &UIWindow.keyboardSafeAreaAssociateKey) as? KeyboardSafeArea {
            return keyboardSafeArea
        }

        let keyboardSafeArea = KeyboardSafeArea(view: self)
        objc_setAssociatedObject(self, &UIWindow.keyboardSafeAreaAssociateKey, keyboardSafeArea, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return keyboardSafeArea
    }
}
