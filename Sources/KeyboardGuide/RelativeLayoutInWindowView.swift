//
//  RelativeLayoutInWindowView.swift
//  KeyboardGuide
//
//  Created by Yoshimasa Niwa on 3/1/20.
//  Copyright © 2020 Yoshimasa Niwa. All rights reserved.
//

import Foundation
import UIKit

protocol RelativeLayoutInWindowViewDelegate: AnyObject {
    func relativeLayoutInWindowView(_ layoutInWindowView: RelativeLayoutInWindowView, didLayoutInWindow window: UIWindow)
}

final class RelativeLayoutInWindowView: UIView {
    weak var delegate: RelativeLayoutInWindowViewDelegate?

    private var subview: UIView!
    private var constraint: NSLayoutConstraint?

    init() {
        super.init(frame: CGRect.zero)

        isHidden = true
        isUserInteractionEnabled = false

        let subview = UIView()
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        self.subview = subview
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIView

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let window = window else { return }

        let constraint = subview.bottomAnchor.constraint(lessThanOrEqualTo: window.bottomAnchor)
        constraint.isActive = true
        self.constraint = constraint
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        guard newWindow == nil else { return }

        if let constraint = constraint {
            constraint.isActive = false
            self.constraint = nil
        }
    }

    private var isLayOutingSubview: Bool = false

    override func layoutSubviews() {
        guard !isLayOutingSubview else { return }
        isLayOutingSubview = true
        defer {
            isLayOutingSubview = false
        }

        super.layoutSubviews()

        guard let window = window else { return }

        delegate?.relativeLayoutInWindowView(self, didLayoutInWindow: window)
    }
}
