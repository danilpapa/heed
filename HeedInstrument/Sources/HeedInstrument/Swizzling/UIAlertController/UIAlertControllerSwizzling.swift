//
//  UIAlertControllerSwizzling.swift
//  HeedInstrument
//
//  Created by setuper on 25.03.2026.
//

import UIKit
import ObjectiveC.runtime

public final class UIAlertControllerSwizzling: IHeedSwizzling {

    public static func enable() {
        let cls: AnyClass = UIAlertController.self

        let originalAddAction = #selector(UIAlertController.addAction(_:))
        let swizzledAddAction = #selector(UIAlertController.hs_instrumented_addAction(_:))
        if let original = class_getInstanceMethod(cls, originalAddAction),
            let swizzled = class_getInstanceMethod(cls, swizzledAddAction) {
            method_exchangeImplementations(original, swizzled)
        }
    }
}
