//
//  KeyboardSafeArea.swift
//  KeyboardGuide
//
//  Created by Yoshimasa Niwa on 2/18/20.
//  Copyright © 2020 Yoshimasa Niwa. All rights reserved.
//

import Foundation
import UIKit

/**
 An object represent where is safe from, not covered by the current keyboard in the given view.

 Recommend to use `KeyboardSafeAreaView`.

 This is very important that the safe area represented by this object is **NOT** updated by changing the relative position
 between given view and the screen where the keyboard is presented.
 You _SHOULD NOT_ directly instantiate this class or it's your responsibility to understand this behavior
 also call `update` method upon the change.

 - See also:
   - `KeyboardSafeAreaView`
   - `UIWindow.keyboardSafeArea`
 */
@objc(KBGKeyboardSafeArea)
public final class KeyboardSafeArea: NSObject {
    /**
     A view where this safe area is for.
     */
    @objc
    public weak var view: UIView?

    /**
     A layout guide in the `view` where is safe from, not covered by the current keyboard.
     - See also:
       - `view`
     */
    @objc
    public let layoutGuide: UILayoutGuide
    let layoutGuideBottomAnchorConstraint: NSLayoutConstraint

    /**
     Insets from the `view`'s bounds to the `layoutGuide`.
     - See also:
       - `view`
       - `layoutGuide`
     */
    @objc
    public private(set) var insets = UIEdgeInsets.zero

    /**
     A layout guide in the `view` where is safe from, not covered by the current keyboard for this application.
     - See also:
       - `view`
       - `KeyboardState.isLocal`
     */
    @objc
    public let localOnlyLayoutGuide: UILayoutGuide
    let localOnlyLayoutGuideBottomAnchorConstraint: NSLayoutConstraint

    /**
     Insets from the `view`'s bounds to the `localOnlyLayoutGuide`.
     - See also:
       - `view`
       - `layoutGuide`
     */
    @objc
    public private(set) var localOnlyInsets = UIEdgeInsets.zero

    @objc
    public init(view: UIView) {
        var constraints = [NSLayoutConstraint]()

        self.view = view

        let layoutGuide = UILayoutGuide()
        constraints.append(layoutGuide.topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(layoutGuide.leftAnchor.constraint(equalTo: view.leftAnchor))
        let layoutGuideBottomAnchorConstraint = layoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        constraints.append(layoutGuideBottomAnchorConstraint)
        self.layoutGuideBottomAnchorConstraint = layoutGuideBottomAnchorConstraint
        constraints.append(layoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor))
        view.addLayoutGuide(layoutGuide)
        self.layoutGuide = layoutGuide

        let localOnlyLayoutGuide = UILayoutGuide()
        constraints.append(localOnlyLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(localOnlyLayoutGuide.leftAnchor.constraint(equalTo: view.leftAnchor))
        let localOnlyLayoutGuideBottomAnchorConstraint = localOnlyLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        constraints.append(localOnlyLayoutGuideBottomAnchorConstraint)
        self.localOnlyLayoutGuideBottomAnchorConstraint = localOnlyLayoutGuideBottomAnchorConstraint
        constraints.append(localOnlyLayoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor))
        view.addLayoutGuide(localOnlyLayoutGuide)
        self.localOnlyLayoutGuide = localOnlyLayoutGuide

        NSLayoutConstraint.activate(constraints)

        super.init()

        KeyboardGuide.shared.addObserver(self)
    }

    /**
     Call this method when the relative position between `view` and the screen where the keyboard is presented is changed.
     */
    @objc
    func update() {
        guard let view = view else { return }

        if let dockedKeyboardState = KeyboardGuide.shared.dockedKeyboardState,
            let keyboardFrameInView = dockedKeyboardState.frame(in: view) {
            let length = max(0.0, view.bounds.maxY - max(view.bounds.minY, keyboardFrameInView.minY))
            layoutGuideBottomAnchorConstraint.constant = -length
            insets.bottom = length
            localOnlyLayoutGuideBottomAnchorConstraint.constant = (dockedKeyboardState.isLocal) ? -length : 0.0
            localOnlyInsets.bottom = length
        } else {
            layoutGuideBottomAnchorConstraint.constant = 0.0
            insets.bottom = 0.0
            localOnlyLayoutGuideBottomAnchorConstraint.constant = 0.0
            localOnlyInsets.bottom = 0.0
        }

        view.layoutIfNeeded()
    }
}

// MARK: - KeyboardGuideObserver

extension KeyboardSafeArea: KeyboardGuideObserver {
    public func keyboardGuide(_ keyboardGuide: KeyboardGuide, didChangeDockedKeyboardState dockedKeyboardState: KeyboardState?) {
        update()
    }
}
