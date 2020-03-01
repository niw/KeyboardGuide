//
//  UIViewExtension.swift
//  KeyboardGuide
//
//  Created by Yoshimasa Niwa on 2/29/20.
//  Copyright © 2020 Yoshimasa Niwa. All rights reserved.
//

import Foundation
import ObjectiveC
import UIKit

extension UIView {
    private static var keyboardSafeAreaAssociateKey: UInt8 = 0

    /**
     A keyboard safe area for this `UIView`.

     - See also:
       - `KeyboardSafeArea`
     */
    @objc(kbg_keyboardSafeArea)
    public var keyboardSafeArea: KeyboardSafeArea {
        if let keyboardSafeArea = objc_getAssociatedObject(self, &UIView.keyboardSafeAreaAssociateKey) as? KeyboardSafeArea {
            return keyboardSafeArea
        }

        let keyboardSafeArea = KeyboardSafeArea(view: self)
        objc_setAssociatedObject(self, &UIView.keyboardSafeAreaAssociateKey, keyboardSafeArea, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return keyboardSafeArea
    }
}
