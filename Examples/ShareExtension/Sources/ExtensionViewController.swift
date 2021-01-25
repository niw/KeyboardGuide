//
//  ExtensionViewController.swift
//  ShareExtension
//
//  Created by Yoshimasa Niwa on 1/24/21.
//  Copyright © 2021 Yoshimasa Niwa. All rights reserved.
//

import KeyboardGuide
import UIKit

// This `@objc` with explicit class name is required.
// The class name must be same as `NSExtensionPrincipalClass` in `Info.plist`.
@objc(ExtensionViewController)
final class ExtensionViewController: UIViewController {
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
        KeyboardGuide.shared.activate(with: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let viewController = ViewController()
        viewController.delegate = self

        let navigationController = UINavigationController(rootViewController: viewController)

        self.addChild(navigationController)
        navigationController.view.frame = self.view.bounds
        view.addSubview(navigationController.view)
        navigationController.didMove(toParent: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: - ViewControllerDelegate

extension ExtensionViewController: ViewControllerDelegate {
    func viewControllerDidTapDone(_ viewController: ViewController) {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
