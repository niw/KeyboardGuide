//
//  KeyboardGuide.swift
//  KeyboardGuide
//
//  Created by Yoshimasa Niwa on 2/18/20.
//  Copyright © 2020 Yoshimasa Niwa. All rights reserved.
//

import Foundation
import ObjectiveC
import UIKit

@objc(KBGKeyboardGuideObserver)
public protocol KeyboardGuideObserver {
    @objc
    func keyboardGuide(_ keyboardGuide: KeyboardGuide, didChangeDockedKeyboardState dockedKeyboardState: KeyboardState?)
}

@objc(KBGKeyboardGuide)
public final class KeyboardGuide: NSObject {
    private let isShared: Bool

    @objc(sharedGuide)
    public static let shared = KeyboardGuide(shared: true)

    public convenience override init() {
        self.init(shared: false)
    }

    private init(shared: Bool) {
        isShared = shared

        super.init()
    }

    private var applicationHost: ApplicationHost?

    private var isApplicationExtension: Bool {
        applicationHost?.isApplicationExtension ?? false
    }

    @objc
    public var isActive: Bool {
        applicationHost != nil
    }

    @objc
    public func activate() {
        activate(applicationHost: UIApplication.shared)
    }

    @objc(activateWithExtensionViewController:)
    public func activate(with extensionViewController: UIViewController) {
        activate(applicationHost: extensionViewController)
    }

    private func activate(applicationHost: ApplicationHost) {
        assert(Thread.isMainThread, "Must be called on main thread")

        guard self.applicationHost == nil else { return }
        self.applicationHost = applicationHost

        if isShared, isApplicationExtension {
            NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    // MARK: - Observer

    private let didChangeStateNotification = Notification.Name("KBGKeyboardGuideDidChangeStateNotification")

    @objc
    private final class ObserverNotificationProxy: NSObject {
        weak var observer: KeyboardGuideObserver?

        init(observer: KeyboardGuideObserver) {
            self.observer = observer
        }

        @objc
        func keyboardGuideDidChangeState(_ notification: Notification) {
            guard let keyboardGuide = notification.object as? KeyboardGuide else { return }
            observer?.keyboardGuide(keyboardGuide, didChangeDockedKeyboardState: keyboardGuide.dockedKeyboardState)
        }
    }

    private static var notificationProxyAssociationKey: UInt8 = 0

    @objc
    public func addObserver(_ observer: KeyboardGuideObserver) {
        let notificationProxy = ObserverNotificationProxy(observer: observer)
        NotificationCenter.default.addObserver(notificationProxy, selector: #selector(ObserverNotificationProxy.keyboardGuideDidChangeState(_:)), name: didChangeStateNotification, object: self)
        objc_setAssociatedObject(observer, &KeyboardGuide.notificationProxyAssociationKey, notificationProxy, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    @objc
    public func removeObserver(_ observer: KeyboardGuideObserver) {
        objc_setAssociatedObject(observer, &KeyboardGuide.notificationProxyAssociationKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    // MARK: - Properties

    @objc
    public var dockedKeyboardState: KeyboardState? {
        didSet {
            let notification = Notification(name: didChangeStateNotification, object: self, userInfo: nil)
            NotificationCenter.default.post(notification)
        }
    }

    // MARK: - Notifications

    /**
     UIKit behavior workaround

     When the application entered in background, iOS may send multiple state change events to the application,
     such as trait collection change events to capture screen image in both orientations for the application switcher.

     In some cases, the application may change its view structure and the text fields may resign first responder.
     However, since the application has entered in background, iOS will _NOT_ send any keyboard notifications to the application.

     Therefore, logically, there are no ways to know the current keyboard state after the application is entering background.
     To workaround this behavior, it retains the current first responder and restore it if `shouldRestoreFirstResponder` returns `true`
     (Default to `true` if it is `UITextInputTraits` such as `UITextView`.)

     - SeeAlso:
     `UIResponder.shouldRestoreFirstResponder`
    */
    private var lastFirstResponder: UIResponder?

    @objc
    public func applicationDidEnterBackground(_ notification: Notification) {
        guard isShared, !isApplicationExtension else { return }

        lastFirstResponder = UIResponder.currentFirstResponder
    }

    @objc
    public func applicationWillEnterForeground(_ notification: Notification) {
        guard isShared, !isApplicationExtension else { return }

        if let lastFirstResponder = lastFirstResponder,
            lastFirstResponder.shouldRestoreFirstResponder,
            lastFirstResponder.canBecomeFirstResponder {
            lastFirstResponder.becomeFirstResponder()
        }
        self.lastFirstResponder = nil
    }

    @objc
    public func keyboardWillShow(_ notification: Notification) {
        // _MAY BE_ called in `UIView` animation block.
        updateKeyboardState(with: notification)
    }

    @objc
    public func keyboardWillHide(_ notification: Notification) {
        // _MAY BE_ called in `UIView` animation block.
        dockedKeyboardState = nil
    }

    @objc
    public func keyboardWillChangeFrame(_ notification: Notification) {
        // _MAY BE_ called in `UIView` animation block.

        // Only update docked keyboard state when the keyboard is currently docked.
        guard dockedKeyboardState != nil else { return }

        updateKeyboardState(with: notification)
    }

    /**
     UIKit bug workaround

     - Confirmed on iOS 13 and iOS 14.
     - Only when it is application extension.
     - Only on iPadOS.

     When the keyboard notification sent to application extension on iPad, the keyboard frame in it is always wrong.
     The frame Y position is always shifted also its height is always shrunk.
     The amount of these sizes are the height of status bar, which is about 20.0 to 24.0 depends on the device.
     However, unfotunatelly, in the application extension process, there are no way to know `statusBarFrame`.

     To workaround, detect the negative height of the keyboard frame in `keyboardFrameBeginUserInfoKey` and use it
     as adjustment size.
     */
    private var keyboardFrameAdjustment: CGFloat? {
        guard #available(iOS 13.0, *), isApplicationExtension, UIDevice.current.userInterfaceIdiom == .pad else {
            return nil
        }
        if let actualKeyboardFrameAdjustment = actualKeyboardFrameAdjustment {
            return actualKeyboardFrameAdjustment
        }
        // The actual keyboard frame adjustment is about 20.0 to 24.0, depends on the device.
        // Use 24.0 for the best result until we can know actual keyboard frame adjustment.
        return 24.0
    }

    private var actualKeyboardFrameAdjustment: CGFloat?

    private func updateActualKeyboardFrameAdjustmentIfNeeded(with notification: Notification) {
        if #available(iOS 13.0, *),
           actualKeyboardFrameAdjustment == nil,
           isApplicationExtension, UIDevice.current.userInterfaceIdiom == .pad,
           let frame = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
           // This must be `frame.size.height` to know if it's negative value or not.
           // `frame.height` is absolute value and always positive.
           frame.size.height < 0.0 {
            actualKeyboardFrameAdjustment = frame.height
        }
    }

    private func updateKeyboardState(with notification: Notification) {
        // See `keyboardFrameAdjustment` for details.
        updateActualKeyboardFrameAdjustmentIfNeeded(with: notification)

        guard let isLocal = notification.userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? Bool,
            let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }

        // `UIResponder.keyboardWillChangeFrameNotification` _MAY BE_ posted with `CGRect.zero` frame.
        // Ignore it, which is useless.
        if frame == CGRect.zero {
            return
        }

        let keyboardScreen: UIScreen
        let coordinateSpace: UICoordinateSpace
        let keyboardFrame: CGRect
        if #available(iOS 13.0, *) {
            keyboardScreen = UIScreen.main
            coordinateSpace = keyboardScreen.coordinateSpace
            // See `keyboardFrameAdjustment` for details.
            if let keyboardFrameAdjustment = keyboardFrameAdjustment {
                keyboardFrame = CGRect(x: frame.minX, y: frame.minY - keyboardFrameAdjustment, width: frame.width, height: frame.height + keyboardFrameAdjustment)
            } else {
                keyboardFrame = frame
            }
        } else if let keyWindow = applicationHost?.keyWindow {
            keyboardScreen = keyWindow.screen
            coordinateSpace = keyWindow
            // Prior to iOS 13.0, keyboard frame in keyboard notifications is positioned wrongly and its X origin is always `0.0`.
            // Assign real X origin instead.
            let realKeyboardOriginX = coordinateSpace.convert(CGPoint.zero, from: keyboardScreen.coordinateSpace).x
            keyboardFrame = CGRect(x: realKeyboardOriginX, y: frame.origin.y, width: frame.size.width, height: frame.size.height)
        } else {
            return
        }

        // While the main screen bound is being changed, notifications _MAY BE_ posted with wrong frame.
        // Ignore it, because it will be eventual consistent with the following notifications.
        if keyboardScreen.bounds.width != keyboardFrame.width {
            return
        }

        dockedKeyboardState = KeyboardState(isLocal: isLocal, frame: keyboardFrame, coordinateSpace: coordinateSpace)
    }
}
