//
//  KeyboardSafeAreaView.swift
//  KeyboardGuide
//
//  Created by Yoshimasa Niwa on 2/18/20.
//  Copyright © 2020 Yoshimasa Niwa. All rights reserved.
//

import Foundation
import UIKit

@objc(KBGKeyboardSafeAreaViewDelegate)
public protocol KeyboardSafeAreaViewDelegate {
    /**
     Callback delegate when `KeyboardSafeAreaView` did lay out and change `insets` for `layoutGuide`.

     Use this callback for manual lay outing.
     You _MUST NOT_ change `KeyboardSafeAreaView`'s `frame` or anythings that can re-lay out it.

     - See also:
       - `KeyboardSafeAreaView`
     */
    @objc
    func keyboardSafeAreaView(_ keyboardSafeAreaView: KeyboardSafeAreaView, didChangeInsets insets: UIEdgeInsets)
}

/**
 A view that provides a layout guide that represents which part of that view is safe from, not covered by the current keyboard.
 */
@objc(KBGKeyboardSafeAreaView)
public final class KeyboardSafeAreaView: UIView {
    /**
     A callback delegate for the keyboard safe area layout changes.
     */
    @objc
    public weak var delegate: KeyboardSafeAreaViewDelegate?

    /**
     A layout guide where is safe from, not covered by the current keyboard.
     */
    @objc
    public private(set) var layoutGuide: UILayoutGuide!

    /**
     Insets from `bounds` to  `layoutGuide` where is safe from, not covered by the current keyboard.
     */
    @objc
    public var insets: UIEdgeInsets {
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

    var layoutGuideBottomAnchorEqualToBottomAnchorConstraint: NSLayoutConstraint!

    var layoutGuideBottomAnchorLessThanOrEqualToBottomAnchorConstraint: NSLayoutConstraint!
    var layoutGuideBottomAnchorEqualToKeyboardSafeAreaBottomAnchorConstraint: NSLayoutConstraint?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        initialize()
    }

    private func initialize() {
        var constraints = [NSLayoutConstraint]()

        let layoutGuide = UILayoutGuide()
        constraints.append(layoutGuide.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(layoutGuide.leftAnchor.constraint(equalTo: leftAnchor))
        layoutGuideBottomAnchorEqualToBottomAnchorConstraint = layoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor)
        layoutGuideBottomAnchorLessThanOrEqualToBottomAnchorConstraint = layoutGuide.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        constraints.append(layoutGuide.rightAnchor.constraint(equalTo: rightAnchor))
        addLayoutGuide(layoutGuide)
        self.layoutGuide = layoutGuide

        // This hidden view is added to have `layoutSubview` callback by the layout constraints to
        // the window keyboard safe area.
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(view.topAnchor.constraint(equalTo: layoutGuide.topAnchor))
        constraints.append(view.leftAnchor.constraint(equalTo: layoutGuide.leftAnchor))
        constraints.append(view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor))
        constraints.append(view.rightAnchor.constraint(equalTo: layoutGuide.rightAnchor))
        self.addSubview(view)

        NSLayoutConstraint.activate(constraints)

        updateLayoutGuideConstraints()
    }

    private var keyboardSafeArea: KeyboardSafeArea? = nil {
        didSet {
            updateLayoutGuideConstraints()
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        // TODO: Detect lay outing loop, also actual `insets` change.
        delegate?.keyboardSafeAreaView(self, didChangeInsets: self.insets)
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()

        if let window = window {
            keyboardSafeArea = window.keyboardSafeArea
        }
    }

    public override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        if newWindow == nil {
            keyboardSafeArea = nil
        }
    }

    private func updateLayoutGuideConstraints() {
        // Order of `isActive` change is important here, or application may crash.

        layoutGuideBottomAnchorEqualToKeyboardSafeAreaBottomAnchorConstraint?.isActive = false
        layoutGuideBottomAnchorEqualToKeyboardSafeAreaBottomAnchorConstraint = nil

        if let keyboardSafeArea = keyboardSafeArea {
            layoutGuideBottomAnchorEqualToBottomAnchorConstraint.isActive = false
            layoutGuideBottomAnchorLessThanOrEqualToBottomAnchorConstraint.isActive = true

            let keyboardSafeAreaLayoutGuide = (isLocalOnly) ? keyboardSafeArea.localOnlyLayoutGuide : keyboardSafeArea.layoutGuide

            let keyboardSafeAreaBottomAnchorConstraint = layoutGuide.bottomAnchor.constraint(equalTo: keyboardSafeAreaLayoutGuide.bottomAnchor)
            keyboardSafeAreaBottomAnchorConstraint.priority = .defaultLow
            keyboardSafeAreaBottomAnchorConstraint.isActive = true
            layoutGuideBottomAnchorEqualToKeyboardSafeAreaBottomAnchorConstraint = keyboardSafeAreaBottomAnchorConstraint
        } else {
            layoutGuideBottomAnchorLessThanOrEqualToBottomAnchorConstraint.isActive = false
            layoutGuideBottomAnchorEqualToBottomAnchorConstraint.isActive = true
        }
    }
}
