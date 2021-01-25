//
//  ApplicationHost.swift
//  KeyboardGuide
//
//  Created by Yoshimasa Niwa on 1/24/21.
//  Copyright © 2021 Yoshimasa Niwa. All rights reserved.
//

import Foundation
import UIKit

protocol ApplicationHost {
    var isApplicationExtension: Bool { get }

    var keyWindow: UIWindow? { get }
}

extension UIApplication: ApplicationHost {
    var isApplicationExtension: Bool {
        false
    }
}

extension UIViewController: ApplicationHost {
    var isApplicationExtension: Bool {
        true
    }

    var keyWindow: UIWindow? {
        view.window
    }
}
