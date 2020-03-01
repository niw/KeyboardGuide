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
 */
@objc(KBGKeyboardSafeArea)
public final class KeyboardSafeArea: NSObject {
    /**
     A view where this safe area is for.
     */
    @objc
    public weak var view: UIView?

    /**
     A layout guide for the `view` where is safe from, not covered by the current keyboard.

     - See also:
       - `view`
     */
    @objc
    public let layoutGuide: UILayoutGuide

    /**
     Insets from the `view`'s `bounds` to the `layoutGuide` edges.

     - See also:
       - `view`
       - `layoutGuide`
     */
    @objc
    public var insets: UIEdgeInsets {
        guard let view = layoutGuide.owningView else { return UIEdgeInsets.zero }

        let bounds = view.bounds
        let layoutFrame = layoutGuide.layoutFrame

        return UIEdgeInsets(
            top: layoutFrame.minY - bounds.minY,
            left: layoutFrame.minX - bounds.minX,
            bottom: bounds.maxY - layoutFrame.maxY,
            right: bounds.maxX - layoutFrame.maxX
        )
    }

    /**
     Set `true` to ignore any keyboard states that are not for this application.
     */
    @objc
    public var isLocalOnly: Bool = false {
        didSet {
            updateLayoutGuideConstraints()
        }
    }

    private let relativeLayoutInWindowView: RelativeLayoutInWindowView
    private let bottomAnchorConstraint: NSLayoutConstraint
    private var bottomAnchorToWindowConstraint: NSLayoutConstraint?

    init(view: UIView) {
        self.view = view

        var constraints = [NSLayoutConstraint]()

        relativeLayoutInWindowView = RelativeLayoutInWindowView()
        relativeLayoutInWindowView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(relativeLayoutInWindowView.leftAnchor.constraint(equalTo: view.leftAnchor))
        constraints.append(relativeLayoutInWindowView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        constraints.append(relativeLayoutInWindowView.rightAnchor.constraint(equalTo: view.rightAnchor))
        constraints.append(relativeLayoutInWindowView.heightAnchor.constraint(equalToConstant: 0.0))
        view.insertSubview(relativeLayoutInWindowView, at: 0)

        layoutGuide = UILayoutGuide()
#if DEBUG
        layoutGuide.identifier = "KeyboardSafeArea.layoutGuide"
#endif
        constraints.append(layoutGuide.topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(layoutGuide.leftAnchor.constraint(equalTo: view.leftAnchor))
        bottomAnchorConstraint = layoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor)
#if DEBUG
        bottomAnchorConstraint.identifier = "KeyboardSafeArea.layoutGuide.bottomAnchorConstraint"
#endif
        constraints.append(bottomAnchorConstraint)
        constraints.append(layoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor))
        view.addLayoutGuide(layoutGuide)

        NSLayoutConstraint.activate(constraints)

        super.init()

        relativeLayoutInWindowView.delegate = self
        KeyboardGuide.shared.addObserver(self)

        updateLayoutGuideConstraints(prefersLayout: false)
    }

    private func updateLayoutGuideConstraints(prefersLayout: Bool = true) {
        guard let view = view else { return }

        if let dockedKeyboardState = KeyboardGuide.shared.dockedKeyboardState,
            !(isLocalOnly && !dockedKeyboardState.isLocal),
            let keyboardFrameInView = dockedKeyboardState.frame(in: view) {
            let length = max(0.0, view.bounds.maxY - max(view.bounds.minY, keyboardFrameInView.minY))
            bottomAnchorConstraint.constant = -length
        } else {
            bottomAnchorConstraint.constant = 0.0
        }

        if prefersLayout {
            view.layoutIfNeeded()
        }
    }
}

// MARK: - RelativeLayoutInWindowViewDelegate

extension KeyboardSafeArea: RelativeLayoutInWindowViewDelegate {
    func relativeLayoutInWindowView(_ keyboardSafeAreaView: RelativeLayoutInWindowView, didLayoutInWindow window: UIWindow) {
        updateLayoutGuideConstraints()
    }
}

// MARK: - KeyboardGuideObserver

extension KeyboardSafeArea: KeyboardGuideObserver {
    public func keyboardGuide(_ keyboardGuide: KeyboardGuide, didChangeDockedKeyboardState dockedKeyboardState: KeyboardState?) {
        updateLayoutGuideConstraints()
    }
}
