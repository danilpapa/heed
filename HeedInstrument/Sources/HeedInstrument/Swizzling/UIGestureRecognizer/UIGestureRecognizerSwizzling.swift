//
//  UIGestureRecognizerSwizzling.swift
//  HeedInstrument
//
//  Created by setuper on 23.03.2026.
//

import UIKit
import ObjectiveC.runtime

public final class UIGestureRecognizerSwizzling: IHeedSwizzling {

    public static func enable() {
        let cls: AnyClass = UIGestureRecognizer.self

        let originalAddTarget = #selector(UIGestureRecognizer.addTarget(_:action:))
        let swizzledAddTarget = #selector(UIGestureRecognizer.hs_instrumented_addTarget(_:action:))
        if let original = class_getInstanceMethod(cls, originalAddTarget),
           let swizzled = class_getInstanceMethod(cls, swizzledAddTarget) {
            method_exchangeImplementations(original, swizzled)
        }

        let originalInit = NSSelectorFromString("initWithTarget:action:")
        let swizzledInit = NSSelectorFromString("hs_instrumented_initWithTarget:action:")
        if let original = class_getInstanceMethod(cls, originalInit),
           let swizzled = class_getInstanceMethod(cls, swizzledInit) {
            method_exchangeImplementations(original, swizzled)
        }
    }
}
