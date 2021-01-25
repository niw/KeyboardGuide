//
//  ViewController.swift
//  ShareExtension
//
//  Created by Yoshimasa Niwa on 1/24/21.
//  Copyright © 2021 Yoshimasa Niwa. All rights reserved.
//

import KeyboardGuide
import UIKit

protocol ViewControllerDelegate: AnyObject {
    func viewControllerDidTapDone(_ viewController: ViewController)
}

class ViewController: UIViewController {
    weak var delegate: ViewControllerDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)

        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        initialize()
    }

    func initialize() {
        title = "Example"

        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone(_:)))
        navigationItem.rightBarButtonItems = [doneBarButtonItem]
    }

    // MARK: - UIViewController

    private var spacing: CGFloat {
        UIFont.systemFontSize * 0.8
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        var constraints = [NSLayoutConstraint]()

        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: UIFont.systemFontSize * 2.0)
        if #available(iOS 13.0, *) {
            textView.backgroundColor = .secondarySystemBackground
        } else {
            textView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        }
        textView.text = (0..<5).map { _ in
            """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
            Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
            Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
            Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
            """
        }.joined()
        textView.layer.cornerRadius = spacing
        textView.textContainerInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        textView.scrollIndicatorInsets = UIEdgeInsets(top: spacing, left: 0.0, bottom: 0.0, right: 0.0)
        textView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 13.0, *) {
            textView.automaticallyAdjustsScrollIndicatorInsets = false
        }
        textView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(textView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: spacing))
        constraints.append(textView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor))
        constraints.append(textView.bottomAnchor.constraint(greaterThanOrEqualTo: textView.topAnchor))
        let textViewBottomAnchorConstraint = textView.bottomAnchor.constraint(equalTo: view.keyboardSafeArea.layoutGuide.bottomAnchor, constant: -spacing)
        textViewBottomAnchorConstraint.priority = .defaultLow
        constraints.append(textViewBottomAnchorConstraint)
        constraints.append(textView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor))
        view.addSubview(textView)

        let keyboardSafeAreaLayoutGuideView = UIView()
        keyboardSafeAreaLayoutGuideView.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        keyboardSafeAreaLayoutGuideView.layer.borderColor = UIColor.red.cgColor
        keyboardSafeAreaLayoutGuideView.layer.borderWidth = 2.0
        keyboardSafeAreaLayoutGuideView.isUserInteractionEnabled = false
        keyboardSafeAreaLayoutGuideView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(keyboardSafeAreaLayoutGuideView.topAnchor.constraint(equalTo: view.keyboardSafeArea.layoutGuide.topAnchor))
        constraints.append(keyboardSafeAreaLayoutGuideView.leftAnchor.constraint(equalTo: view.keyboardSafeArea.layoutGuide.leftAnchor))
        constraints.append(keyboardSafeAreaLayoutGuideView.bottomAnchor.constraint(equalTo: view.keyboardSafeArea.layoutGuide.bottomAnchor))
        constraints.append(keyboardSafeAreaLayoutGuideView.rightAnchor.constraint(equalTo: view.keyboardSafeArea.layoutGuide.rightAnchor))
        view.addSubview(keyboardSafeAreaLayoutGuideView)

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Actions

    @objc
    private func didTapDone(_ sender: AnyObject) {
        delegate?.viewControllerDidTapDone(self)
    }
}
