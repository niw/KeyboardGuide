//
//  AppDelegate.swift
//  Example
//
//  Created by Yoshimasa Niwa on 2/18/20.
//  Copyright © 2020 Yoshimasa Niwa. All rights reserved.
//

import KeyboardGuide
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Activate KeyboardGuide at the beginning of application life cycle.
        KeyboardGuide.shared.activate()

        if #unavailable(iOS 13.0) {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = UINavigationController(rootViewController: ViewController())
            window.makeKeyAndVisible()
            self.window = window
        }
        return true
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
