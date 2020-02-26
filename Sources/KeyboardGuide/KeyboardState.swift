//
//  KeyboardState.swift
//  KeyboardGuide
//
//  Created by Yoshimasa Niwa on 2/19/20.
//  Copyright © 2020 Yoshimasa Niwa. All rights reserved.
//

import Foundation
import UIKit

@objc(KBGKeyboardState)
public final class KeyboardState: NSObject {
    /**
     This property is whether the current keyboard is displayed for this application or not.
     This is useful on iPad devices.

     In general, recommend to ignore any non `isLocal` keyboard states, but it depends on the application.
     */
    @objc
    let isLocal: Bool

    private let frame: CGRect
    private let coordinateSpace: UICoordinateSpace

    init(isLocal: Bool, frame: CGRect, coordinateSpace: UICoordinateSpace) {
        self.isLocal = isLocal

        self.frame = frame
        self.coordinateSpace = coordinateSpace

        super.init()
    }

    /**
     Return the current keyboard frame in given `view`'s `bounds` coordinate.
     Use `frame(in:)` for Swift which returns `CGRect?` instead of using `CGRect.null`.

     - Parameters:
        - view: The current keyboard frame is converted in this `view`'s `bounds` coordinate.

     - Returns: A  keyboard frame in `view`'s `bounds` coordinate.
       If `view` is not in the same screen where the keyboard is displayed or not attached to the view hierarchy,
       the value _MAY BE_ `CGRectNull`.

     - See also:
        - `frame(in:)`
     */
    @objc
    public func frameInView(_ view: UIView) -> CGRect {
        view.convert(frame, from: coordinateSpace)
    }

    /**
     Return the current keyboard frame in given `view`'s `bounds` coordinate.

     - Parameters:
        - view: The current keyboard frame is converted in this `view`'s `bounds` coordinate.

     - Returns: A  keyboard frame in `view`'s `bounds` coordinate.
       If `view` is not in the same screen where the keyboard is displayed or not attached to the view hierarchy,
       the value _MAY BE_ `nil`.
     */
    public func frame(in view: UIView) -> CGRect? {
        let nullableFrameInView = frameInView(view)
        if nullableFrameInView.isNull {
            return nil
        } else {
            return nullableFrameInView
        }
    }
}
