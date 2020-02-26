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

    var keyboardSafeAreaView: KeyboardSafeAreaView?

    var keyboardSafeAreaLayoutGuideView: UIView?

    var keyboardFrameLabel: UILabel?
    var localOnlySwitch: UISwitch?
    var showKeyboardSafeAreaLayoutGuideSwitch: UISwitch?

    override func viewDidLoad() {
        super.viewDidLoad()

        KeyboardGuide.shared.addObserver(self)

        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = UIColor.white
        }

        var constraints = [NSLayoutConstraint]()

        let spacing = UIFont.systemFontSize * 0.8

        let keyboardSafeAreaView = KeyboardSafeAreaView()
        keyboardSafeAreaView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(keyboardSafeAreaView.topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(keyboardSafeAreaView.leftAnchor.constraint(equalTo: view.leftAnchor))
        constraints.append(keyboardSafeAreaView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        constraints.append(keyboardSafeAreaView.rightAnchor.constraint(equalTo: view.rightAnchor))
        view.addSubview(keyboardSafeAreaView)
        self.keyboardSafeAreaView = keyboardSafeAreaView

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(stackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: spacing))
        constraints.append(stackView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: keyboardSafeAreaView.layoutGuide.bottomAnchor, constant: -spacing))
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
            textView.backgroundColor = UIColor.secondarySystemBackground
        } else {
            textView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        }
        textView.layer.cornerRadius = spacing
        textView.textContainerInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        textView.scrollIndicatorInsets = UIEdgeInsets(top: spacing, left: 0.0, bottom: spacing, right: 0.0)
        stackView.addArrangedSubview(textView)

        let keyboardSafeAreaLayoutGuideView = UIView()
        keyboardSafeAreaLayoutGuideView.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        keyboardSafeAreaLayoutGuideView.layer.borderColor = UIColor.red.cgColor
        keyboardSafeAreaLayoutGuideView.layer.borderWidth = 2.0
        keyboardSafeAreaLayoutGuideView.isUserInteractionEnabled = false
        keyboardSafeAreaLayoutGuideView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(keyboardSafeAreaLayoutGuideView.topAnchor.constraint(equalTo: keyboardSafeAreaView.layoutGuide.topAnchor))
        constraints.append(keyboardSafeAreaLayoutGuideView.leftAnchor.constraint(equalTo: keyboardSafeAreaView.layoutGuide.leftAnchor))
        constraints.append(keyboardSafeAreaLayoutGuideView.bottomAnchor.constraint(equalTo: keyboardSafeAreaView.layoutGuide.bottomAnchor))
        constraints.append(keyboardSafeAreaLayoutGuideView.rightAnchor.constraint(equalTo: keyboardSafeAreaView.layoutGuide.rightAnchor))
        view.addSubview(keyboardSafeAreaLayoutGuideView)
        self.keyboardSafeAreaLayoutGuideView = keyboardSafeAreaLayoutGuideView

        NSLayoutConstraint.activate(constraints)

        updateKeyboardFrameLabel()
        updateKeyboardSafeAreaIsLocalOnly()
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
        guard let keyboardSafeAreaView = keyboardSafeAreaView,
            let localOnlySwitch = localOnlySwitch else {
            return
        }

        keyboardSafeAreaView.isLocalOnly = localOnlySwitch.isOn
    }

    private func updateKeyboardSafeAreaLayoutGuideView() {
        guard let showKeyboardSafeAreaLayoutGuideSwitch = showKeyboardSafeAreaLayoutGuideSwitch,
            let keyboardSafeAreaLayoutGuideView = keyboardSafeAreaLayoutGuideView else {
            return
        }

        keyboardSafeAreaLayoutGuideView.isHidden = !showKeyboardSafeAreaLayoutGuideSwitch.isOn
    }

    // MARK: - Actions

    @objc
    public func didTapDone(_ sender: AnyObject) {
        delegate?.swiftViewControllerDidTapDone(self)
    }

    @objc
    public func localOnlySwitchDidChange(_ sender: AnyObject) {
        updateKeyboardSafeAreaIsLocalOnly()
    }

    @objc
    public func showKeyboardSafeAreaSwitchDidChange(_ sender: AnyObject) {
        updateKeyboardSafeAreaLayoutGuideView()
    }
}

// MARK: - KeyboardGuideObserver

extension SwiftViewController: KeyboardGuideObserver {
    func keyboardGuide(_ keyboardGuide: KeyboardGuide, didChangeDockedKeyboardState dockedKeyboardState: KeyboardState?) {
        updateKeyboardFrameLabel()
    }
}
