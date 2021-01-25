//
//  ViewController.swift
//  Example
//
//  Created by Yoshimasa Niwa on 2/18/20.
//  Copyright © 2020 Yoshimasa Niwa. All rights reserved.
//

import Combine
import KeyboardGuide
import SwiftUI
import UIKit

class ViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)

        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        initialize()
    }

    @available(iOS 13.0, *)
    private class VisibilityWrapper {
        var cancellableSet = Set<AnyCancellable>()
    }

    private var _visibilityWrapper: Any?

    @available(iOS 13.0, *)
    private var visibilityWrapper: VisibilityWrapper {
        if let wrapper = _visibilityWrapper as? VisibilityWrapper {
            return wrapper
        }
        let wrapper = VisibilityWrapper()
        _visibilityWrapper = wrapper
        return wrapper
    }

    private struct Section {
        var title: String
        var description: String?
        var items: [Item]
    }

    private struct Item {
        var title: String
        var description: String?
        var action: (ViewController) -> Void
    }

    private var sections = [Section]()

    private func initialize() {
        title = "KeyboardGuide"

        var exampleItems = [Item]()
        exampleItems.append(Item(title: "Swift example", description: "Basic example of generic UI implementation with text area.") { (viewController) in
            let swiftViewController = SwiftViewController()
            swiftViewController.delegate = viewController

            let navigationController = UINavigationController(rootViewController: swiftViewController)
            viewController.present(navigationController, animated: true, completion: nil)
        })
        if #available(iOS 13.0, *) {
            let viewModel = SwiftUIView.Model()

            viewModel.didTapDone.sink { [weak self] in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
            }.store(in: &visibilityWrapper.cancellableSet)

            exampleItems.append(Item(title: "SwiftUI example", description: "SwiftUI API usage") { (viewController) in
                let rootView = SwiftUIView(model: viewModel)
                let swiftUIViewController = UIHostingController(rootView: rootView)
                viewController.present(swiftUIViewController, animated: true, completion: nil)
            })
        }
        exampleItems.append(Item(title: "Objective-C example", description: "Objective-C API usage") { (viewController) in
            let objcViewController = ObjcViewController()
            objcViewController.delegate = viewController

            let navigationController = UINavigationController(rootViewController: objcViewController)
            viewController.present(navigationController, animated: true, completion: nil)
        })
        sections.append(Section(title: "Examples", description: "Try examples in various situations such as on iPad multi tasking.", items: exampleItems))

        if #available(iOS 13.0, *) {
            sections.append(Section(title: "Scene", description: "On iOS 13 and later, application may have multiple windows.", items: [
                Item(title: "Open new windows", description: "Request new scene session to open new window.") { (_) in
                    UIApplication.shared.requestSceneSessionActivation(nil, userActivity: nil, options: nil, errorHandler: nil)
                }
            ]))
        }
    }

    // MARK: - UIViewController

    private static let itemCellIdentifier = "itemCellIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()

        let tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
}

// MARK: - SwiftViewControllerDelegate

extension ViewController: SwiftViewControllerDelegate {
    func swiftViewControllerDidTapDone(_ swiftViewController: SwiftViewController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - ObjcViewControllerDelegate

extension ViewController: ObjcViewControllerDelegate {
    func objcViewControllerDidTapDone(_ objcViewController: ObjcViewController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].description
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewController.itemCellIdentifier) ??
            UITableViewCell(style: .subtitle, reuseIdentifier: ViewController.itemCellIdentifier)
        let item = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.description
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = sections[indexPath.section].items[indexPath.row]
        item.action(self)
    }
}
