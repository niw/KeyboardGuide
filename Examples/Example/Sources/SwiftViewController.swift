//
//  SwiftViewController.swift
//  Example
//
//  Created by Yoshimasa Niwa on 2/19/20.
//  Copyright © 2020 Yoshimasa Niwa. All rights reserved.
//

import Foundation
import KeyboardGuide
import UIKit

protocol SwiftViewControllerDelegate: AnyObject {
    func swiftViewControllerDidTapDone(_ swiftViewController: SwiftViewController)
}

class SwiftViewController: UIViewController {
    weak var delegate: SwiftViewControllerDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)

        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        initialize()
    }

    private func initialize() {
        title = "Example"

        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone(_:)))
        navigationItem.rightBarButtonItems = [doneBarButtonItem]
    }

    // MARK: - UIViewController

    private var keyboardSafeAreaLayoutGuideView: UIView?
    private var keyboardFrameLabel: UILabel?
    private var localOnlySwitch: UISwitch?
    private var useContentInsetsSwitch: UISwitch?
    private var showKeyboardSafeAreaLayoutGuideSwitch: UISwitch?
    private var textView: UITextView?
    private var textViewBottomAnchorConstraint: NSLayoutConstraint?

    private var spacing: CGFloat {
        UIFont.systemFontSize * 0.8
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        KeyboardGuide.shared.addObserver(self)

        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = UIColor.white
        }

        var constraints = [NSLayoutConstraint]()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(stackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: spacing))
        constraints.append(stackView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor))
        constraints.append(stackView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor))
        view.addSubview(stackView)

        let keyboardFrameLabel = UILabel()
        stackView.addArrangedSubview(keyboardFrameLabel)
        self.keyboardFrameLabel = keyboardFrameLabel

        let localOnlySwitchStackView = UIStackView()
        localOnlySwitchStackView.axis = .horizontal
        localOnlySwitchStackView.spacing = spacing
        stackView.addArrangedSubview(localOnlySwitchStackView)

        let localOnlySwitchLabel = UILabel()
        localOnlySwitchLabel.text = "Ignore keyboard for the other app"
        localOnlySwitchLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        localOnlySwitchStackView.addArrangedSubview(localOnlySwitchLabel)

        let localOnlySwitch = UISwitch()
        localOnlySwitch.addTarget(self, action: #selector(localOnlySwitchDidChange(_:)), for: .valueChanged)
        localOnlySwitchStackView.addArrangedSubview(localOnlySwitch)
        self.localOnlySwitch = localOnlySwitch

        let useContentInsetsSwitchStackView = UIStackView()
        useContentInsetsSwitchStackView.axis = .horizontal
        useContentInsetsSwitchStackView.spacing = spacing
        stackView.addArrangedSubview(useContentInsetsSwitchStackView)

        let useContentInsetsSwitchLabel = UILabel()
        useContentInsetsSwitchLabel.text = "Use text view content insets"
        useContentInsetsSwitchLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        useContentInsetsSwitchStackView.addArrangedSubview(useContentInsetsSwitchLabel)

        let useContentInsetsSwitch = UISwitch()
        useContentInsetsSwitch.addTarget(self, action: #selector(useContentInsetsSwitchDidChange(_:)), for: .valueChanged)
        useContentInsetsSwitchStackView.addArrangedSubview(useContentInsetsSwitch)
        self.useContentInsetsSwitch = useContentInsetsSwitch

        let showKeyboardSafeAreaLayoutGuideSwitchStackView = UIStackView()
        showKeyboardSafeAreaLayoutGuideSwitchStackView.axis = .horizontal
        showKeyboardSafeAreaLayoutGuideSwitchStackView.spacing = spacing
        stackView.addArrangedSubview(showKeyboardSafeAreaLayoutGuideSwitchStackView)

        let showKeyboardSafeAreaLayoutGuideSwitchLabel = UILabel()
        showKeyboardSafeAreaLayoutGuideSwitchLabel.text = "Show keyboard safe area"
        showKeyboardSafeAreaLayoutGuideSwitchLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        showKeyboardSafeAreaLayoutGuideSwitchStackView.addArrangedSubview(showKeyboardSafeAreaLayoutGuideSwitchLabel)

        let showKeyboardSafeAreaLayoutGuideSwitch = UISwitch()
        showKeyboardSafeAreaLayoutGuideSwitch.addTarget(self, action: #selector(showKeyboardSafeAreaSwitchDidChange(_:)), for: .valueChanged)
        showKeyboardSafeAreaLayoutGuideSwitchStackView.addArrangedSubview(showKeyboardSafeAreaLayoutGuideSwitch)
        self.showKeyboardSafeAreaLayoutGuideSwitch = showKeyboardSafeAreaLayoutGuideSwitch

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
        constraints.append(textView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: spacing))
        constraints.append(textView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor))
        constraints.append(textView.bottomAnchor.constraint(greaterThanOrEqualTo: textView.topAnchor))
        constraints.append(textView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor))
        view.addSubview(textView)
        self.textView = textView

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
        self.keyboardSafeAreaLayoutGuideView = keyboardSafeAreaLayoutGuideView

        NSLayoutConstraint.activate(constraints)

        updateKeyboardFrameLabel()
        updateKeyboardSafeAreaIsLocalOnly()
        updateTextViewLayoutConstraints()
        updateKeyboardSafeAreaLayoutGuideView()
    }

    private func updateKeyboardFrameLabel() {
        let text: String
        if let dockedKeyboardState = KeyboardGuide.shared.dockedKeyboardState {
            let frame = dockedKeyboardState.frame(in: view)
            text = frame?.debugDescription ?? "Invalid"
        } else {
            text = "Undocked"
        }
        keyboardFrameLabel?.text = text
    }

    private func updateKeyboardSafeAreaIsLocalOnly() {
        guard let localOnlySwitch = localOnlySwitch else { return }

        view.keyboardSafeArea.isLocalOnly = localOnlySwitch.isOn
    }

    private func updateTextViewLayoutConstraints() {
        guard let useContentInsetsSwitch = useContentInsetsSwitch,
            let textView = textView else {
            return
        }

        if let textViewBottomAnchorConstraint = textViewBottomAnchorConstraint {
            textViewBottomAnchorConstraint.isActive = false
            self.textViewBottomAnchorConstraint = nil
        }

        let textViewBottomAnchorConstraint = useContentInsetsSwitch.isOn ?
                textView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -spacing) :
                textView.bottomAnchor.constraint(equalTo: view.keyboardSafeArea.layoutGuide.bottomAnchor, constant: -spacing)
        textViewBottomAnchorConstraint.priority = .defaultLow
        textViewBottomAnchorConstraint.isActive = true
        self.textViewBottomAnchorConstraint = textViewBottomAnchorConstraint

        updateTextViewContentsBottomInset()
    }

    private func updateKeyboardSafeAreaLayoutGuideView() {
        guard let showKeyboardSafeAreaLayoutGuideSwitch = showKeyboardSafeAreaLayoutGuideSwitch,
            let keyboardSafeAreaLayoutGuideView = keyboardSafeAreaLayoutGuideView else {
            return
        }

        keyboardSafeAreaLayoutGuideView.isHidden = !showKeyboardSafeAreaLayoutGuideSwitch.isOn
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateTextViewContentsBottomInset()
    }

    private func updateTextViewContentsBottomInset() {
        guard let useContentInsetsSwitch = useContentInsetsSwitch,
            let textView = textView else {
            return
        }

        let bottomInset = useContentInsetsSwitch.isOn ? view.keyboardSafeArea.insets.bottom : 0.0
        textView.contentInset.bottom = bottomInset
        textView.scrollIndicatorInsets.bottom = max(spacing, bottomInset)
    }

    // MARK: - Actions

    @objc
    private func didTapDone(_ sender: AnyObject) {
        delegate?.swiftViewControllerDidTapDone(self)
    }

    @objc
    private func localOnlySwitchDidChange(_ sender: AnyObject) {
        updateKeyboardSafeAreaIsLocalOnly()
    }

    @objc
    private func useContentInsetsSwitchDidChange(_ sender: AnyObject) {
        updateTextViewLayoutConstraints()
    }

    @objc
    private func showKeyboardSafeAreaSwitchDidChange(_ sender: AnyObject) {
        updateKeyboardSafeAreaLayoutGuideView()
    }
}

// MARK: - KeyboardGuideObserver

extension SwiftViewController: KeyboardGuideObserver {
    func keyboardGuide(_ keyboardGuide: KeyboardGuide, didChangeDockedKeyboardState dockedKeyboardState: KeyboardState?) {
        updateKeyboardFrameLabel()
    }
}
