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
    private var bottomAnchorToWindowBottomAnchorConstraint: NSLayoutConstraint?

    init() {
        super.init(frame: CGRect.zero)

        isHidden = true
        isUserInteractionEnabled = false

        var constraints = [NSLayoutConstraint]()

        let subview = UIView()
        subview.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(subview.leftAnchor.constraint(equalTo: leftAnchor))
        let bottomAnchorConstraint = subview.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomAnchorConstraint.priority = .defaultLow
#if DEBUG
        bottomAnchorConstraint.identifier = "RelativeLayoutInWindowView.subview.bottomAnchorConstraint"
#endif
        constraints.append(bottomAnchorConstraint)
        constraints.append(subview.rightAnchor.constraint(equalTo: rightAnchor))
        constraints.append(subview.heightAnchor.constraint(equalToConstant: 0.0))
        addSubview(subview)
        self.subview = subview

        NSLayoutConstraint.activate(constraints)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIView

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let window = window else { return }

        let bottomAnchorToWindowBottomAnchorConstraint = subview.bottomAnchor.constraint(equalTo: window.bottomAnchor)
#if DEBUG
        bottomAnchorToWindowBottomAnchorConstraint.identifier = "RelativeLayoutInWindowView.subview.bottomAnchorToWindowBottomAnchorConstraint"
#endif
        bottomAnchorToWindowBottomAnchorConstraint.isActive = true
        self.bottomAnchorToWindowBottomAnchorConstraint = bottomAnchorToWindowBottomAnchorConstraint
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        guard newWindow == nil else { return }

        if let bottomAnchorToWindowBottomAnchorConstraint = bottomAnchorToWindowBottomAnchorConstraint {
            bottomAnchorToWindowBottomAnchorConstraint.isActive = false
            self.bottomAnchorToWindowBottomAnchorConstraint = nil
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
